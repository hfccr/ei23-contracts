// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library SubsidyDaoTypes {
    struct ClientWhitelistRequest {
        uint64 clientId;
        bool approved;
        address ethAddress;
    }

    struct ClientBlacklistRequest {
        uint64 clientId;
        bool approved;
    }

    struct StorageProviderWhitelistRequest {
        uint64 storageProviderId;
        bool approved;
        address ethAddress;
    }

    struct StorageProviderBlacklistRequest {
        uint64 storageProviderId;
        bool approved;
    }

    struct ClientAllocationRequest {
        uint64 clientId;
        address ethAddress;
        uint256 allocation;
        bool approved;
    }
}
