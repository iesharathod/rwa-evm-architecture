
# Architecture Document  
## Compliance-First RWA Tokenization Protocol (EVM)  

### 1. Executive Positioning  
This document proposes a compliance-first, production-oriented architecture for tokenizing Real-World Assets (RWAs) on an EVM-compatible blockchain.  
This is not a DeFi protocol. It is a regulated asset infrastructure layer.  
Therefore, the design deliberately rejects permissionless assumptions and instead prioritizes:  
- Deterministic compliance enforcement  
- Institutional custody compatibility  
- Explicit administrative controls  
- Upgrade safety under regulatory evolution  
- Gas-efficient lifecycle operations  
- Auditability over composability  

The core architectural principle is simple:  
**Compliance must be enforced at the token layer, not assumed at the application layer.**  
Any architecture that relies on “the backend will prevent it” is fundamentally invalid for RWAs.  

### 2. Problem Framing: Why RWA Is Structurally Different  
Traditional ERC-20 tokens assume:  
- Free transferability  
- Anonymous participation  
- No jurisdictional constraints  
- No forced administrative actions  

RWA systems assume the opposite:  
- Transfers must be permissioned.  
- Investors must be KYC’d.  
- Jurisdiction restrictions may override user intent.  
- Regulators may require forced transfers or freezes.  
- Issuers require mint control.  
- Corporate actions must reflect off-chain economic events.  

This creates an architectural tension:  
We must preserve blockchain settlement guarantees while introducing controlled permissioning.  
The architecture resolves this tension by separating:  
- Economic ownership (token balance)  
- Regulatory eligibility (compliance state)  
- Administrative governance (controlled override mechanisms)  
Each is modularized.  

### 3. Design Principles (Non-Negotiable)  
The system adheres to the following non-negotiable principles:  

#### 3.1 Compliance Is On-Chain and Deterministic  
Every token transfer is validated on-chain.  
There is no backend-only enforcement.  
There is no reliance on UI restrictions.  
- If a wallet is not allowlisted, it cannot receive tokens.  
- If a wallet is frozen, it cannot transfer.  
This is enforced cryptographically.  

#### 3.2 Modular Contracts Over Monolithic Logic  
RWA platforms evolve with regulation.  
Embedding compliance logic inside the token contract permanently couples regulatory logic to asset logic.  
Instead:  
- Token contract handles balances and supply.  
- Compliance module handles eligibility.  
- Issuance module handles primary distribution.  
- Corporate actions module handles lifecycle events.  
Modules can be upgraded independently.  

#### 3.3 Administrative Powers Must Exist — But Be Constrained  
RWA systems require:  
- Pause mechanisms  
- Forced transfers  
- Freezing  
- Upgradeability  
The architecture does not pretend decentralization eliminates these needs.  
Instead, it constrains them via:  
- Multisig governance  
- Role separation  
- Timelocked upgrades  
- Transparent event logging  

#### 3.4 No PII On-Chain  
Regulated systems cannot leak investor identity.  
On-chain state stores only:  
- Wallet addresses  
- Jurisdiction codes  
- Investor-type flags  
- Compliance booleans  
All KYC data remains encrypted off-chain.  

#### 3.5 Gas Efficiency Is a First-Class Constraint  
Corporate actions must scale to thousands of holders.  
The system avoids:  
- Iterative loops over holders  
- Per-transfer heavy storage writes  
- Continuous dividend accounting  
Snapshot + pull-claim model is used deliberately.  

### 4. Logical System Architecture  
The platform consists of five trust domains:  
- Blockchain Domain (smart contracts)  
- Custody Domain (MPC / multisig)  
- Backend Domain (orchestration + reconciliation)  
- Compliance Domain (KYC provider)  
- User Domain (issuer + investor wallets)  

Each domain has clearly defined authority boundaries.  
The backend is never a source of truth for transfer eligibility.  
The blockchain is.  

### 5. Smart Contract Architecture  
The smart contract layer is composed of:  
- AssetFactory  
- AssetToken  
- ComplianceModule  
- IssuanceModule  
- CorporateActionsModule  
- Governance/AccessControl  

Each contract has a single responsibility.  

#### 5.1 AssetFactory  
**Purpose:** Deploy isolated AssetToken instances per issuer asset.  
**Rationale:**  
- Multi-tenant separation  
- Avoid shared storage risks  
- Per-asset cap configuration  
It does not manage balances.  
It does not enforce compliance.  
It only instantiates assets.  

#### 5.2 AssetToken  
The AssetToken represents economic ownership.  
It is implemented as an ERC-20 token with:  
- Supply cap  
- Mint authority (Issuer role)  
- Transfer hook calling ComplianceModule  
- Snapshot support for corporate actions  
The token does not store allowlists.  
It does not know about jurisdictions.  
It delegates validation.  
This separation prevents compliance logic from polluting asset logic.  

#### 5.3 ComplianceModule  
The ComplianceModule is the regulatory gatekeeper.  
It maintains:  
- Allowlist mapping  
- Jurisdiction mapping  
- Investor-type classification  
- Freeze flags  
- Global pause flag  
All transfer validation routes through this module.  
Validation is synchronous and mandatory.  
If validation fails, the transfer reverts.  
This is not optional.  

#### 5.4 IssuanceModule  
Primary issuance is not a simple mint.  
It is a regulated subscription process.  
The module:  
- Records subscription intent  
- Verifies payment reconciliation  
- Enforces mint caps  
- Emits structured events  
Minting is impossible without Issuer role and subscription approval.  

#### 5.5 CorporateActionsModule  
Corporate actions are external economic events mirrored on-chain.  
**Supported actions:**  
- Dividend distribution (snapshot-based)  
- Redemption at maturity  
Dividends are implemented via:  
- Snapshot at distribution date  
- Funding a dividend pool  
- Claim-based withdrawal  
This avoids unbounded gas costs.  

# 6. Compliance Enforcement — Deep Dive

RWA compliance cannot be advisory. It must be enforceable.

The system adopts a transfer-hook enforcement model where every token transfer routes through a ComplianceModule before state mutation occurs.

## 6.1 Enforcement Location

Compliance is enforced inside the token contract via `_beforeTokenTransfer`.

This guarantees:
- No transfer can bypass validation.
- No UI restriction can be circumvented.
- No backend outage can cause non-compliant transfers.
- Direct contract interaction cannot avoid compliance.

If validation fails, the transaction reverts. There is no secondary validation layer. This is the authoritative gate.

## 6.2 Why Not Backend-Only Compliance?

Backend enforcement fails under:
- Direct contract interaction
- Contract calls from other smart contracts
- Scripted interactions
- Compromised frontend

For RWAs, that is unacceptable. Therefore, the blockchain must be the enforcement boundary.

## 6.3 Compliance State Model

The ComplianceModule maintains:
- `allowlisted[address]`
- `jurisdictionCode[address]`
- `investorType[address]`
- `frozen[address]`
- `globalPause`

Each transfer validates:
- Global pause not active.
- Sender not frozen.
- Recipient allowlisted.
- Jurisdiction compatibility satisfied.
- Investor-type constraints satisfied.

**Optional extension:** Ownership caps per investor type.

## 6.4 Forced Transfers

Forced transfers are included because regulators may require:
- Court-ordered reassignments
- Sanctions compliance
- Asset seizure

Forced transfer capability is gated behind:
- Multisig governance
- Explicit event emission
- Audit logging

The architecture does not assume immutability eliminates legal authority.

# 7. Custody & Governance Model

RWAs require institutional-grade key management.

## 7.1 Key Domains

There are three administrative domains:
- Issuer Domain
- Platform Governance Domain
- Compliance Domain

Each is isolated.

## 7.2 Issuer Domain

Controlled via MPC.

**Responsibilities:**
- Minting
- Snapshot triggering
- Corporate action initiation

**Issuer cannot:**
- Upgrade contracts
- Modify compliance logic
- Change governance roles

## 7.3 Platform Governance Domain

Controlled via multisig + timelock.

**Responsibilities:**
- Contract upgrades
- Emergency pause
- Governance parameter changes

**Upgrades are:**
- Timelocked (24–72 hours)
- Publicly observable
- Executed only via multisig

## 7.4 Compliance Domain

Controls:
- Allowlist
- Jurisdiction flags
- Freeze operations

Separated from mint authority. This prevents compliance operators from minting tokens.

## 7.5 Why Role Separation Matters

RWA systems often fail due to:
- Overloaded admin keys
- Centralized upgrade authority
- No governance delay

This design enforces separation to reduce blast radius.

# 8. Primary Market Flow — Defensive Design

Primary issuance is not a simple mint function. It is a controlled economic event.

## 8.1 Subscription Model (Chosen)

Investor → KYC → Payment → Approval → Mint

**Why this model?**
- Issuer retains final approval authority.
- Prevents over-minting.
- Supports regulatory review.

## 8.2 Payment Handling

Preferred method: On-chain stablecoin (USDC).

**Advantages:**
- Verifiable settlement.
- Transparent reconciliation.
- Reduced accounting ambiguity.

**Alternative:** Fiat off-chain. If fiat is used:
- Mint requires explicit reconciliation approval.
- Backend is not allowed to mint automatically.

## 8.3 Reconciliation Risk Mitigation

To prevent mismatched settlement:
- Payment must be confirmed after N blocks.
- Subscription ID must match payment reference.
- Mint event must emit orderId.
- No mint without verifiable payment mapping.

# 9. Corporate Action Gas Defense

Corporate actions must scale.

**Naive implementation:** Loop through all holders. Transfer dividend to each. This fails beyond small holder sets.

## 9.1 Snapshot + Pull Claim Model

The system uses:
- Snapshot at distribution date.
- Dividend pool funding.
- Claim-based withdrawal.

**Advantages:**
- No O(N) loops.
- Gas cost distributed across claimants.
- Reentrancy minimized.

## 9.2 Why Not Continuous Accounting?

Continuous dividend accrual:
- Increases per-transfer storage writes.
- Adds complexity.
- Expands audit surface.

Snapshot-based distribution is deterministic and cheaper.

# 10. Upgrade Risk Analysis

Upgradeability is required due to:
- Regulatory evolution
- Bug remediation
- Feature extensions

However, upgradeability introduces governance risk.

## 10.1 Pattern: UUPS

Chosen because:
- Gas efficient
- Widely audited
- Storage-safe via OZ patterns

## 10.2 Risk Mitigations

- Timelocked upgrades
- Multisig execution
- Storage gap reservation
- Explicit versioning

## 10.3 What Is Not Upgradeable

To reduce attack surface:
- Token balances are immutable state.
- Historical snapshots cannot be altered.
- Event logs cannot be rewritten.

# 11. Explicit Token Standard Tradeoffs

## 11.1 ERC-20 (Chosen)

**Pros:**
- Fungible unit representation
- Mature tooling
- Widely integrated
- Simpler compliance enforcement

**Cons:**
- No native multi-class structure

## 11.2 ERC-1155

**Pros:**
- Supports tranches
- Multi-class support
- Shared contract deployment

**Cons:**
- Increased complexity
- Per-token compliance logic required
- Higher audit surface
- More edge cases

**Decision:** ERC-20 is selected for initial implementation due to simplicity and reduced attack surface.

## 11.3 Why Not ERC-1400?

ERC-1400 is a security-token-focused standard.

**Reasons not selected:**
- Heavy interface surface.
- Lower ecosystem adoption.
- Many features can be replicated modularly.
- Increased audit complexity.

The architecture achieves equivalent compliance guarantees without full ERC-1400 adoption.

# 12. EVM vs Non-EVM Defense

EVM chosen because:
- Mature security tooling.
- Institutional audit ecosystem.
- Compatibility with stablecoins and custody providers.
- Standardized upgrade patterns.

Non-EVM chains (e.g., Solana) offer:
- Higher throughput.
- Lower base fees.

However:
- Compliance enforcement patterns are less standardized.
- Tooling ecosystem for regulated RWAs is less mature.
- Upgrade patterns differ significantly.

For institutional-grade RWA infrastructure, ecosystem maturity outweighs throughput.

# 13. Explicit Threat Model

The system defends against:

## 13.1 Technical Threats
- Unauthorized minting
- Compliance bypass
- Reentrancy
- Storage collision
- Upgrade hijack

## 13.2 Operational Threats
- Custody compromise
- Stablecoin depeg
- Backend reconciliation failure
- Insider abuse

## 13.3 Governance Threats
- Malicious upgrade
- Admin key misuse
- Emergency pause abuse

**Mitigations:**
- Multisig governance
- Timelock delay
- Role separation
- Transparent event emission
- Off-chain audit logging

# Short Section: Why Not ERC-1155 (Yet)

The architecture deliberately avoids ERC-1155 in its initial implementation.

While tranche-based tokenization may be required in structured products, introducing multi-token accounting at inception increases complexity, audit surface, and compliance edge cases.

The system is modular and can support future ERC-1155 expansion. However, for a compliance-first baseline deployment, ERC-20 provides sufficient functionality with reduced risk. This is a conscious tradeoff in favor of clarity and security.