// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Client account types for Solidity
 */
library ClientTypes {
    struct Client {
        bool verified;
        string verificationFormCID;
        bool blacklisted;
        address ethAddress;
        string name;
    }

    struct ClientAllocation {
        uint256 allocation; // Current subsidy token allocation left
        uint256 allocationLimit; // Subsidy token allocation
        uint256 dailyAllocation; // daily subsidy allocation for Clients
    }

    struct AllocationRequest {
        uint256 allocationLimit; // Subsidy token allocation
        uint256 dailyAllocation; // daily allocation in subsidy tokens
        uint256 oneTimeAllocation; // one time allocation in subsidy tokens
    }
}
