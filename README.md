# TrustChain

A decentralized credential verification system built on Stacks blockchain.

## Overview

TrustChain enables professionals to register their credentials, get verified by trusted authorities, and have their achievements endorsed by peers in a trustless environment. The system creates a transparent and immutable record of professional achievements and endorsements.

## Features

- **Credential Registration**: Users can register their professional credentials
- **Verification System**: Trusted authorities can verify user credentials
- **Achievement Records**: Verified users can create achievement records
- **Peer Endorsements**: Community members can endorse and validate achievements
- **Trust Scoring**: Dynamic trust score calculation based on endorsements and activity

## Smart Contract Functions

### Credential Management
- `register-credential`: Register a new professional credential
- `verify-credential`: Verify a user's credential (admin only)
- `suspend-credential`: Suspend a user's credential (admin only)
- `add-credential-attribute`: Add additional attributes to a credential

### Achievement Management
- `create-achievement`: Create a new achievement record
- `endorse-achievement`: Endorse someone else's achievement
- `get-achievement-details`: View details of an achievement

### Trust Score
- `update-trust-score`: Update a user's trust score
- `get-trust-score`: Get a user's current trust score

## Development

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) for local development and testing
- [Stacks CLI](https://docs.stacks.co/references/stacks-cli) for deployment

### Testing
Run tests with Clarinet:
```bash
clarinet test