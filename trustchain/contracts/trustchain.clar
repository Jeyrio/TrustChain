;; TrustChain: A decentralized credential verification system
;; This contract enables professionals to register credentials, get verified,
;; and have their achievements endorsed by peers in a trustless environment.

(define-constant contract-owner principal "SP2P0E6ZGXZXF1E8ACX16CFXQF7DHTZPS4Q8Q43W9") 

;; Error codes
(define-constant err-unauthorized u100)
(define-constant err-record-not-found u102)
(define-constant err-already-exists u101)
(define-constant err-unverified u104)
(define-constant err-not-credential-owner u105)

;; Data Structures
(define-map credentials
    principal
    (tuple (full-name (string-utf8 50)) (contact (string-utf8 50)) (is-verified bool) (registration-date uint) (trust-score uint) (is-suspended bool)))

(define-map credential-attributes
    (tuple (user principal) (attribute-name (string-utf8 50)))
    (attribute-value (string-utf8 100)))

(define-map achievement-records
    uint
    (tuple (achievement-name (string-ascii 50)) (description (string-utf8 1000)) (owner principal) (creation-date uint) (verification-state (string-ascii 20))))

(define-map verification-endorsements
    (tuple (endorser principal) (record-id uint))
    (tuple (endorsement-date uint) (trust-rating uint) (endorsement-notes (string-utf8 500)) (is-valid bool)))

(define-map professional-score
    principal
    uint)

(define-counter record-counter)

;; Helper function to check if the sender is the contract owner
(define-public (is-contract-owner)
    (if (is-eq tx-sender contract-owner)
        (ok true)
        (err err-unauthorized)))

;; Credential Management
(define-public (register-credential full-name contact)
    (begin
        (asserts! (is-eq (get credentials tx-sender) none) err-already-exists)
        (map-set credentials tx-sender (tuple (full-name full-name) (contact contact) (is-verified false) (registration-date (get-block-time)) (trust-score u0) (is-suspended false)))
        (ok "Credential Registered")))

(define-public (verify-credential principal)
    (begin
        (is-contract-owner)
        (let ((credential (get credentials principal)))
            (asserts! (is-eq credential none) err-record-not-found)
            (asserts! (not (get is-verified credential)) err-already-exists)
            (map-set credentials principal (tuple (full-name (get full-name credential)) (contact (get contact credential)) (is-verified true) (registration-date (get registration-date credential)) (trust-score u0) (is-suspended (get is-suspended credential))))
            (ok "Credential Verified"))))

(define-public (suspend-credential principal)
    (begin
        (is-contract-owner)
        (let ((credential (get credentials principal)))
            (asserts! (is-eq credential none) err-record-not-found)
            (map-set credentials principal (tuple (full-name (get full-name credential)) (contact (get contact credential)) (is-verified false) (registration-date (get registration-date credential)) (trust-score u0) (is-suspended true)))
            (ok "Credential Suspended"))))

(define-public (add-credential-attribute attribute-name attribute-value)
    (begin
        (let ((credential (get credentials tx-sender)))
            (asserts! (is-eq credential none) err-record-not-found)
            (map-set credential-attributes (tuple (user tx-sender) (attribute-name attribute-name)) (attribute-value attribute-value))
            (ok "Attribute Added"))))

(define-read-only (get-credential)
    (get credentials tx-sender))

(define-read-only (check-verification)
    (let ((credential (get credentials tx-sender)))
        (if (is-eq credential none)
            (err err-record-not-found)
            (ok (get is-verified credential)))))

;; Trust Score Management
(define-public (update-trust-score principal change-amount)
    (begin
        (let ((current-score (get professional-score principal)))
            (map-set professional-score principal (+ current-score change-amount))
            (ok "Trust Score Updated"))))

(define-read-only (get-trust-score)
    (get professional-score tx-sender))

;; Achievement Record Management
(define-public (create-achievement achievement-name description)
    (begin
        (asserts! (check-verification) err-unverified)
        (let ((record-id (counter-increment record-counter)))
            (map-set achievement-records record-id (tuple (achievement-name achievement-name) (description description) (owner tx-sender) (creation-date (get-block-time)) (verification-state "pending")))
            (ok record-id))))

;; Peer Endorsement
(define-public (endorse-achievement record-id trust-rating endorsement-notes)
    (begin
        (asserts! (check-verification) err-unverified)
        (let ((achievement (get achievement-records record-id)))
            (asserts! (is-eq achievement none) err-record-not-found)
            (map-set verification-endorsements (tuple (endorser tx-sender) (record-id record-id)) (tuple (endorsement-date (get-block-time)) (trust-rating trust-rating) (endorsement-notes endorsement-notes) (is-valid true)))
            (ok "Endorsement Submitted"))))

;; Record Retrieval
(define-read-only (get-achievement-details record-id)
    (get achievement-records record-id))

(define-read-only (get-endorsements-by-record record-id)
    (filter (lambda (x) (is-eq (get record-id x) record-id)) (map-values verification-endorsements)))

(define-read-only (get-endorsements-by-user principal)
    (filter (lambda (x) (is-eq (get endorser x) principal)) (map-values verification-endorsements)))

;; Contract Initialization
(define-public (initialize-contract)
    (begin
        (ok "TrustChain Contract Initialized")))
