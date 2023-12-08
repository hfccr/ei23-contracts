// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title retrieval royalty types
 */

library RetrievalRoyaltyTypes {
    struct RetrievalRoyalty {
        uint256 endsOn;
        bytes cid;
        uint64 dealId;
        uint256 commissionPercentage;
        address beneficiary;
    }
}
