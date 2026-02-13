# Test & Verification Plan for RWA EVM Architecture

## 1. Unit Testing

### AssetToken
- [ ] **Mint Cap Enforcement**: Cannot mint beyond cap
- [ ] **Role-Based Minting**: Only ISSUER_ROLE can mint
- [ ] **Snapshot Tracking**: Snapshot ID increments properly
- [ ] **Compliance Validation**: Transfer reverts if compliance fails

### ComplianceModule
- [ ] **Allowlist Enforcement**: Non-allowlisted address cannot receive tokens
- [ ] **Frozen Account Restrictions**: Frozen address cannot transfer
- [ ] **Global Pause**: Global pause blocks transfers

### IssuanceModule
- [ ] **Approval Requirement**: Cannot mint without approval
- [ ] **Double Approval Prevention**: Cannot approve twice
- [ ] **Subscription Lifecycle**: Subscription lifecycle transitions valid

### CorporateActions
- [ ] **Dividend Proportionality**: Dividend claim equals snapshot balance proportion
- [ ] **Claim Prevention**: Cannot double claim
- [ ] **Redemption Accuracy**: Redemption burns correct amount

## 2. Property-Based Testing
- [ ] **Supply Cap Invariant**: Total supply never exceeds cap
- [ ] **Transfer Validation**: No transfer succeeds if validateTransfer == false
- [ ] **Dividend Bounds**: Sum of claimed dividends ≤ funded amount

## 3. Fuzz Testing
- [ ] **Mixed State Transfers**: Random transfer attempts across mixed allowlist/frozen states
- [ ] **Random Subscriptions**: Random subscription amounts
- [ ] **Snapshot Distributions**: Random snapshot distributions

## 4. Formal Invariants
- [ ] **Allowlist Invariant**: If !allowlisted[to] → transfer must revert
- [ ] **Cap Invariant**: totalSupply <= cap
- [ ] **Frozen Account Invariant**: Frozen accounts cannot reduce their balance via transfer
- [ ] **Dividend Pool Invariant**: Dividends cannot exceed funded pool
- [ ] **Role-Based Mint Invariant**: Mint only callable by ISSUER_ROLE