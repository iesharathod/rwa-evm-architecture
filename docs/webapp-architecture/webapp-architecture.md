
# Web Application Technical Architecture

## RWA Compliance-First EVM Deployment

This document describes the off-chain application infrastructure that interacts with the on-chain RWA protocol.

> The web application is an orchestration layer. The blockchain remains the authoritative enforcement boundary.

## 1. Deployment Assumptions

| Component | Specification |
|-----------|---------------|
| **Blockchain Network** | e.g Arbitrum (EVM L2) |
| **Settlement Asset** | USDC (Circle contract on Arbitrum) |
| **Smart Contracts** | Solidity (≥0.8.18) using OpenZeppelin UUPS pattern |
| **Custody Model** | MPC-based institutional custody |

## 2. Frontend Architecture

### Framework
- Next.js (React 18)
- TypeScript
- TailwindCSS (optional)

### Wallet Integration
- MetaMask
- WalletConnect v2

### Responsibilities
- Investor onboarding interface
- Subscription submission
- Dividend claim UI
- Redemption request UI
- Portfolio dashboard
- Legal document viewer

### Frontend Does NOT
- Enforce compliance
- Decide mint eligibility
- Modify token balances
- Approve subscriptions

*Compliance and state mutation are strictly on-chain.*

## 3. Backend Architecture

**Runtime:** Node.js (TypeScript) with Express or Fastify  
**Alternative:** Python (FastAPI)

## 4. Infrastructure Stack

### Database: PostgreSQL
Stores:
- Investor records
- Subscription lifecycle
- Asset registry
- Custody references
- Dividend records
- Redemption queue
- Event log (append-only)

**Why PostgreSQL:** ACID guarantees, strong indexing, regulatory audit compatibility

### Cache Layer: Redis
- Session caching
- Rate limiting
- Temporary subscription state

### Message Queue: BullMQ or RabbitMQ
- Subscription processing
- Payment confirmation buffer
- Indexing retries
- Corporate action task execution

## 5. Blockchain Interaction Layer

**Web3 Client:** ethers.js (v6) or viem

Backend interacts with:
- AssetFactory
- AssetToken
- ComplianceModule
- IssuanceModule
- CorporateActionsModule

All role-restricted transactions are signed via custody. Backend never signs transactions with hot private keys.

## 6. Custody Integration

**Example Providers:** Fireblocks, Anchorage Digital, Coinbase Custody

**Flow:**
1. Backend constructs transaction payload
2. Transaction sent to custody provider API
3. MPC signs
4. Signed transaction broadcast to Arbitrum

**Authority Separation:**
- Issuer mint authority → custody-controlled wallet
- Governance authority → separate multisig
- Compliance authority → separate role

## 7. KYC Integration

**Example Providers:** SumSub, Onfido, Persona

**Flow:**
1. Investor initiates KYC session
2. Provider verifies identity
3. Backend receives signed webhook
4. Backend updates investor record
5. Backend calls `ComplianceModule.setAllowlist(address, true)`

*No PII is written on-chain. Only eligibility flags are stored.*

## 8. Stablecoin Settlement Model

### On-Chain USDC (Preferred)
- Investor transfers USDC to escrow address
- Backend monitors Transfer events
- Requires N confirmations (e.g., 12 blocks)
- Payment reference matched to subscription ID
- IssuanceModule approval triggered

### Fiat Settlement
- Backend requires manual reconciliation approval
- Mint is never automated without verification

## 9. Event Indexing Architecture

### Listener Design
- WebSocket subscription to Arbitrum RPC
- Fallback polling mechanism
- Idempotent event processing

### Events Consumed
- AssetCreated
- Minted
- Burned
- Transfer
- DividendFunded
- DividendClaimed
- RedemptionRequested
- SubscriptionApproved

All events stored in append-only `event_log` table for audit replay, regulatory reporting, and investor statements.

## 10. Security Controls

- No private keys stored in backend
- MPC for issuer operations
- Multisig for governance
- Role separation across domains
- Backend cannot bypass compliance
- All critical actions emit on-chain events

## 11. Deployment Model

### Infrastructure
- Docker containers
- NGINX reverse proxy
- TLS enforced
- Secret manager (AWS KMS or GCP Secret Manager)
- PostgreSQL primary + read replica

### Environments
- Dev
- Testnet
- Staging
- Production
