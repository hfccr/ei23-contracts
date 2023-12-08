// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Storage provider account types
 */
library StorageProviderTypes {
    struct StorageProvider {
        bool active;
        bool verified;
        string verificationFormCID;
        bool blacklisted;
        address ethAddress;
    }

    struct StorageProviderSubsidy {
        uint256 numberOfDealsRedeemed;
        mapping(uint64 => bool) dealsRedeemed;
    }

    struct StorageProviderRetrievalCommission {
        uint256 commissionPercentage;
        uint256 commissionBalance;
    }
}
