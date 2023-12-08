// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {MarketAPI} from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import {MarketTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";
import {CommonTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import {StorageProviderRegistry} from "./StorageProviderRegistry.sol";
import {ClientRegistry} from "./ClientRegistry.sol";
import {ClientSubsidyToken} from "./ClientSubsidyToken.sol";
import {RetrievalRoyalty} from "./RetrievalRoyalty.sol";
import {LiquidStaking} from "./LiquidStaking.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract Subsidy is AccessControl {
    // Allow providers to create claim subsidy
    // Calculate subsidy based on deal size
    // Check client balance
    // Burn client tokens
    // Issue subsidy tokens to provider
    // Roles
    // Burner role in ClientSubsidyToken.sol
    // Can remove from vault
    // Creator role in RetrievalRoyalty.sol
    // Track subsidy redemptions

    StorageProviderRegistry storageProviderRegistry;
    ClientRegistry clientRegistry;
    ClientSubsidyToken clientSubsidyToken;
    RetrievalRoyalty retrievalRoyalty;
    LiquidStaking liquidStaking;
    address VAULT_ADDRESS;

    mapping(uint64 => bool) public dealsSubsidized;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setStorageProviderRegistry(
        address _storageProviderRegistry
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        storageProviderRegistry = StorageProviderRegistry(_storageProviderRegistry);
    }

    function setClientRegistry(address _clientRegistry) public onlyRole(DEFAULT_ADMIN_ROLE) {
        clientRegistry = ClientRegistry(_clientRegistry);
    }

    function setSubsidyToken(address _clientSubsidyToken) public onlyRole(DEFAULT_ADMIN_ROLE) {
        clientSubsidyToken = ClientSubsidyToken(_clientSubsidyToken);
    }

    function setRetrievalRoyalty(address _retrievalRoyalty) public onlyRole(DEFAULT_ADMIN_ROLE) {
        retrievalRoyalty = RetrievalRoyalty(_retrievalRoyalty);
    }

    function setLiquidStaking(address payable _liquidStaking) public onlyRole(DEFAULT_ADMIN_ROLE) {
        liquidStaking = LiquidStaking(_liquidStaking);
        VAULT_ADDRESS = _liquidStaking;
    }

    function claimSubsidyOnDeal(uint64 _dealId) public {
        require(!dealsSubsidized[_dealId], "Deal already subsidized");
        uint64 client = MarketAPI.getDealClient(_dealId);
        uint64 provider = MarketAPI.getDealProvider(_dealId);
        require(storageProviderRegistry.isWhitelisted(provider), "Provider not whitelisted");
        require(clientRegistry.isWhitelisted(client), "Client not whitelisted");
        address clientEthAddress = clientRegistry.getEthAddress(client);
        require(
            clientSubsidyToken.balanceOf(clientEthAddress) > 1,
            "Client does not have enough subsidy tokens to cover this deal"
        );
        // TODO calculate subsidy
        // TODO require vault balance
        // TODO remove from vault and give to storage provider
        // Add royalty
        retrievalRoyalty.addRoyalty(_dealId, 10, VAULT_ADDRESS);
    }
}
