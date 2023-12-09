// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {RetrievalRoyaltyTypes} from "./types/RetrievalRoyaltyTypes.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract RetrievalRoyalty is AccessControl {
    mapping(uint64 => RetrievalRoyaltyTypes.RetrievalRoyalty) public retrievalRoyaltiesForDeal;
    uint256 public royaltyCount;
    bytes32 public constant SUBSIDY_PROVIDER = keccak256("SUBSIDY_PROVIDER");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // Create a royalty post subsidy
    function addRoyalty(
        uint64 _dealId,
        uint256 _commissionPercentage,
        address _beneficiary
    ) public {
        RetrievalRoyaltyTypes.RetrievalRoyalty storage royalty = retrievalRoyaltiesForDeal[_dealId];
        royalty.dealId = _dealId;
        royalty.commissionPercentage = _commissionPercentage;
        royalty.beneficiary = _beneficiary;
    }

    function getRoyalty(
        uint64 _dealId
    ) public view returns (RetrievalRoyaltyTypes.RetrievalRoyalty memory) {
        return retrievalRoyaltiesForDeal[_dealId];
    }
}
