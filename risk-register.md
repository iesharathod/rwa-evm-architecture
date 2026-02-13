# Risk Register

## Technical Risks
1. **Compliance Bypass**  
    *Mitigation:* Mandatory transfer hook validation.

2. **Admin Key Compromise**  
    *Mitigation:* Multisig + timelock governance.

3. **Upgrade Storage Collision**  
    *Mitigation:* UUPS + storage gaps + OZ patterns.

4. **Reentrancy in Dividend Claims**  
    *Mitigation:* ReentrancyGuard + pull-based model.

5. **Stablecoin Depeg**  
    *Mitigation:* Risk disclosure + alternative payout option.

## Operational Risks
6. **Custody Compromise**  
    *Mitigation:* MPC custody provider.

7. **KYC Provider Failure**  
    *Mitigation:* Secondary KYC fallback.

8. **Oracle Manipulation**  
    *Mitigation:* Multi-source price aggregation.

## Governance Risks
9. **Malicious Upgrade**  
    *Mitigation:* Timelock delay + public event logs.

10. **Forced Transfer Abuse**  
     *Mitigation:* Restricted role + on-chain event logging.

## Market Risks
11. **Illiquidity**  
     *Mitigation:* Controlled issuance + market making.

12. **Regulatory Changes**  
     *Mitigation:* Upgradeable modular architecture.