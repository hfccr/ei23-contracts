// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title retrieval royalty types
 */

library SubsidyTypes {
    struct Subsidy {
        uint64 dealId;
        uint256 amountPaid;
        uint256 retrievalRoyaltyId;
    }
}
