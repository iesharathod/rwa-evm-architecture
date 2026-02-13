# Workflow & Implementation Architecture
## RWA Tokenization Platform (EVM)

### 1. System Implementation Overview
While core ownership, transfer restrictions, and corporate actions are enforced on-chain, a regulated RWA platform requires a structured off-chain orchestration layer to manage:
- KYC verification
- Subscription lifecycle
- Payment reconciliation
- Custody proof management
- Corporate action accounting
- Regulatory audit trails

The blockchain stores authoritative state for ownership and eligibility. The backend stores operational lifecycle data and compliance artifacts.

### 2. Technology Stack
#### 2.1 Blockchain Layer
- **Network:** EVM L2 (Arbitrum / Base)
- **Language:** Solidity (>=0.8.18)
- **Framework:** Foundry / Hardhat
- **OpenZeppelin modules:**
    - ERC20
    - ERC20Snapshot
    - AccessControl
    - UUPSUpgradeable
    - ReentrancyGuard

#### 2.2 Backend Layer
**Responsibilities**
- KYC orchestration
- Subscription lifecycle tracking
- Stablecoin reconciliation
- MPC transaction submission
- Event indexing
- Audit persistence

**Stack**
- **Runtime:** Node.js (TypeScript) or Python (FastAPI)
- **Web3:** ethers.js / viem
- **Queue:** Redis / RabbitMQ
- **Background workers:** BullMQ / Celery

#### 2.3 Database Layer
- **Primary database:** PostgreSQL
    - **Reasons:**
        - ACID compliance
        - Strong relational integrity
        - Transactional auditability
        - Foreign key enforcement
- **Event store:**
    - Append-only audit table (or Kafka stream)
- **Cache:**
    - Redis (ephemeral state, rate limiting)

### 3. External Integrations
#### 3.1 KYC Provider Integration
**Examples:**
- SumSub
- Onfido
- Persona

**Workflow**
1. Investor submits identity documents.
2. KYC provider verifies.
3. Backend receives webhook.
4. Backend updates compliance state.
5. Backend writes allowlist flag on-chain.

🔹 **Investor Persistence Model**
Stored after verification:

| Column            | Description                          |
|-------------------|--------------------------------------|
| id                | UUID                                 |
| wallet_address    | On-chain address                     |
| kyc_status        | VERIFIED / PENDING / REJECTED       |
| jurisdiction_code  | ISO country code                    |
| investor_type     | RETAIL / ACCREDITED / INSTITUTIONAL |
| kyc_hash          | Hash of KYC record                   |
| created_at        | Timestamp                            |
| updated_at        | Timestamp                            |

**Important:** No raw identity data stored on-chain. Only flags and codes.

#### 3.2 Custody Provider Integration
**Examples:**
- Fireblocks
- Anchorage
- Coinbase Custody

**Used for:**
- Mint approvals
- Governance upgrades
- Treasury transfers
- Dividend funding

**Custody Flow**
Backend → prepares transaction → sends to MPC → signed → broadcast.

🔹 **Custody Proof Persistence**
To ensure asset backing:

| Column                | Description               |
|-----------------------|---------------------------|
| id                    | UUID                      |
| asset_id              | FK                        |
| custodian_reference    | External proof ID        |
| proof_hash            | Hash of custody document  |
| verified_at           | Timestamp                 |
| expiry_at            | Optional                  |
| status                | VALID / EXPIRED           |

This ensures minting only occurs after proof verification.

#### 3.3 Stablecoin Settlement (USDC)
**Settlement via:**
- On-chain USDC transfer
- Escrow contract

**Backend listens to:**
- Transfer(address from, address to, uint256 amount)

# 4. Detailed Workflow

## 4.1 Issuer Onboarding
- Issuer submits asset documentation.
- Legal review completed.
- Backend registers issuer.
- AssetFactory deploys AssetToken.
- Issuer MPC assigned mint role.

### 🔹 Asset Registry Model
| Asset Table       | Description                          |
|-------------------|--------------------------------------|
| id                | UUID                                 |
| token_address     | ERC20 contract                       |
| issuer_id         | FK                                   |
| asset_type        | REAL_ESTATE / CREDIT / COMMODITY    |
| supply_cap        | Maximum mintable                     |
| metadata_uri      | IPFS / secure storage                |
| maturity_date     | Optional                             |
| status            | ACTIVE / PAUSED / REDEEMED          |

This table links on-chain token to real-world asset metadata.

## 4.2 Investor Onboarding
- Account creation.
- KYC session initiated.
- Webhook received.
- Investor record updated.
- ComplianceModule.setAllowlist(wallet, true).
- Database updated in Investor table.

## 4.3 Subscription Flow (Primary Issuance)
- Investor submits subscription request.
- Backend creates subscription record.
- Investor transfers USDC to escrow.
- Backend confirms N block confirmations.
- Issuer MPC signs mint approval.
- IssuanceModule.mint(orderId).

### 🔹 Subscription Persistence
| Subscription Table | Description                          |
|---------------------|--------------------------------------|
| id                  | UUID                                 |
| investor_id         | FK                                   |
| asset_id            | FK                                   |
| amount_requested     | Token units                          |
| payment_tx_hash     | Stablecoin tx                        |
| status              | REQUESTED / PAID / APPROVED / MINTED|
| created_at          | Timestamp                            |

Lifecycle: REQUESTED → PAID → APPROVED → MINTED

Mint cannot occur without:
- Payment confirmation
- Compliance verification

## 4.4 Secondary Transfers
- No backend involvement required.
- Compliance enforced on-chain.
- Indexer listens to Transfer events and updates internal portfolio views.

## 4.5 Dividend Distribution
- Issuer calls snapshot().
- Issuer funds dividend pool.
- DividendFunded event emitted.
- Investors claim.

### 🔹 Dividend Tracking Model
| Dividend Distribution Table | Description                          |
|-----------------------------|--------------------------------------|
| id                          | UUID                                 |
| asset_id                    | FK                                   |
| snapshot_id                 | On-chain reference                   |
| total_funded                | Stablecoin funded                    |
| distribution_date           | Timestamp                            |
| status                      | ACTIVE / CLOSED                      |

## 4.6 Redemption Flow
- Investor requests redemption.
- RedemptionModule burns tokens.
- Backend records redemption.
- Treasury settles underlying asset.
- Settlement status updated.

### 🔹 Redemption Persistence
| Redemption Table | Description                          |
|-------------------|--------------------------------------|
| id                | UUID                                 |
| investor_id       | FK                                   |
| asset_id          | FK                                   |
| amount            | Token units                          |
| burn_tx_hash      | On-chain burn                        |
| settlement_status  | PENDING / SETTLED                   |
| created_at        | Timestamp                            |

# 5. Event Processing Architecture
- **Indexer:**
    - WebSocket subscription
    - Poll fallback
    - Idempotent handling

### 🔹 Event Log Table (Append-Only)
| Column             | Description                          |
|--------------------|--------------------------------------|
| id                 | UUID                                 |
| tx_hash            | Blockchain tx                        |
| block_number       | Block                                |
| event_name         | Event type                           |
| decoded_payload     | JSON                                 |
| processed_at       | Timestamp                            |

**Purpose:**
- Regulatory replay
- Audit reconstruction
- Mismatch detection

# 6. Observability & Monitoring
**Monitored Signals:**
- Mint spikes
- Failed compliance validations
- Governance changes
- Escrow imbalance

**Stack:**
- Prometheus
- Grafana
- ELK
- Sentry

# 7. Deployment Architecture
**Environments:**
- Dev
- Testnet
- Staging
- Mainnet

**CI/CD:**
- Versioned ABI storage
- Deployment scripts
- Upgrade scripts
- Automated migrations

# 8. Data Security Model
**Sensitive Data:**
- KYC documents
- Legal identity artifacts

**Controls:**
- AES-256 encryption at rest
- RBAC
- Audit logging
- Key rotation
- No PII on-chain

# 9. Incremental Build Plan
**Phase 1:**
- ERC20 + ComplianceModule
- Issuance flow
- PostgreSQL persistence

**Phase 2:**
- Snapshot dividends
- Event indexer
- Audit log

**Phase 3:**
- Redemption module
- Multi-issuer scaling
- Advanced monitoring

# API Documentation

## Asset Management

### Create Asset
- **POST** `/api/assets`
    - Creates new asset (admin only)
    - Triggers AssetFactory deployment

### Get Assets
- **GET** `/api/assets`
    - Returns active RWA tokens

## Investor Onboarding

### Initiate KYC
- **POST** `/api/kyc/session`
    - Initiates KYC process

### Update Allowlist
- **POST** `/api/compliance/allowlist`
    - Writes allowlist status on-chain

## Subscription Flow

### Create Subscription
- **POST** `/api/subscriptions`
    - Creates subscription request

### Approve Subscription
- **POST** `/api/subscriptions/{id}/approve`
    - Approves and triggers mint

## Corporate Actions

### Fund Dividends
- **POST** `/api/dividends`
    - Funds dividend pool

### Initiate Redemption
- **POST** `/api/redemptions`
    - Initiates redemption process

## Observability

### Get Events
- **GET** `/api/events`
    - Returns indexed blockchain events  