flowchart TB

    subgraph Frontend
        UI["Next.js Frontend"]
        Wallet["MetaMask / WalletConnect"]
    end

    subgraph Backend
        API["Node.js Backend"]
        DB[("PostgreSQL")]
        Cache["Redis"]
        Queue["BullMQ / RabbitMQ"]
        Indexer["Event Indexer"]
    end

    subgraph External
        KYC["KYC Provider (SumSub / Onfido)"]
        Custody["MPC Custody (Fireblocks / Anchorage)"]
        USDC["USDC (Arbitrum)"]
    end

    subgraph Blockchain
        Factory["AssetFactory"]
        Token["AssetToken (ERC20)"]
        Compliance["ComplianceModule"]
        Issuance["IssuanceModule"]
        Corporate["CorporateActionsModule"]
    end

    UI --> API
    Wallet --> UI

    API --> DB
    API --> Cache
    API --> Queue

    API --> KYC
    API --> Custody

    API --> Factory
    API --> Issuance
    API --> Compliance
    API --> Corporate

    USDC --> API

    Token --> Indexer
    Indexer --> DB
