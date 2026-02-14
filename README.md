# How to Review This Submission

Follow this sequence to evaluate the system architecture:

## 1️⃣ Architecture Design
**File:** `/docs/architecture.md`

Core design document covering:
- Executive positioning and design philosophy
- Trust model and authority boundaries
- Modular smart contract architecture
- Compliance enforcement (transfer hook model)
- Custody & governance separation
- Primary market flow defense
- Corporate action gas design
- Upgrade risk analysis
- ERC-20 vs ERC-1155 vs ERC-1400 tradeoffs
- EVM vs non-EVM justification
- Explicit threat model

*Demonstrates protocol-level reasoning and architectural defensibility.*

## 2️⃣ Operational Workflow
**File:** `/docs/workflow-and-implementation.md`

Implementation guide covering:
- Backend orchestration responsibilities
- KYC provider integration workflow
- Custody provider (MPC) transaction flow
- Stablecoin settlement reconciliation model
- Database schemas for each lifecycle stage
- Subscription lifecycle state machine
- Dividend distribution accounting model
- Redemption handling workflow
- Event indexing architecture
- Audit log design
- Monitoring & observability strategy
- Deployment and environment separation
- Incremental build roadmap
- API Documentation


## 3️⃣ System Diagrams
**File:** `/docs/diagrams.mmd`

Mermaid source diagrams:
- Logical system architecture
- Smart contract module interaction
- Issuer onboarding flow
- Investor onboarding flow
- Primary issuance lifecycle
- Secondary transfer enforcement
- Dividend distribution
- Redemption lifecycle

*Provides reproducible visual specifications.*



##4️⃣ Directory Overview

### `/contracts/` — Solidity Interfaces & Skeletons
- Interface-level Solidity files and minimal contract skeletons.
- Clarifies architectural decisions:
    - Asset token structure
    - Compliance module boundary
    - Issuance module interface
    - Corporate actions interface
- Minimal by design; illustrates intent.


### 5️⃣`/tests.md` — Verification Strategy
- Defines:
    - Unit testing scope
    - Property-based testing goals
    - Fuzz testing coverage
    - Formal invariants
    - Security validation objectives

### 6️⃣ `/risk-register.md` — Risk Analysis
- Details:
    - Technical, governance, operational, and market risks
    - Mitigation strategies and architectural reasoning

---

## Architectural Themes

- Compliance enforced at token transfer layer; cannot be bypassed.
- Backend orchestrates, does not override on-chain guarantees.
- Administrative powers constrained via role separation and timelock governance.
- Corporate actions are gas-aware and scalable.
- Off-chain persistence structured for auditability and regulatory traceability.
- No personally identifiable information stored on-chain.

---

## Core Assumptions

- EVM-compatible L2 deployment
- USDC as primary settlement asset
- Hybrid custody (self-custody + MPC)
- Off-chain KYC provider integration
- Multi-issuer support
- Assumptions defended in architecture documentation

---

## Scope Clarification

This repository does **not** include:
- Production frontend
- Deployed mainnet contract suite
- Formal third-party audit

**Objective:** Demonstrate secure system design, regulatory realism, and protocol-level architectural depth.


# 7️⃣ Web Application Technical Architecture (Optional Extension)

**Directory:** `/docs/webapp-architecture/`

## Overview

Concrete implementation view of the off-chain orchestration layer interacting with the compliance-first RWA protocol.

## Technology Stack

| Component | Technology |
|-----------|-----------|
| Frontend | Next.js |
| Backend Runtime | Node.js / TypeScript |
| Database | PostgreSQL |
| Cache Layer | Redis |
| Queue System | BullMQ / RabbitMQ |
| Web3 Interaction | ethers.js / viem |
| MPC Custody | Fireblocks / Anchorage |
| KYC Provider | SumSub / Onfido |
| Stablecoin Settlement | USDC on Arbitrum |

## Responsibilities

The web application layer:

- Orchestrates KYC, subscription, and reconciliation workflows
- Signs transactions via MPC custody
- Indexes on-chain events for reporting and audit
- **Does not enforce compliance logic** (remains on-chain)

## Design Principles

✅ Production-ready infrastructure  
✅ Full-stack awareness  
✅ Preserves protocol's deterministic compliance guarantees  
