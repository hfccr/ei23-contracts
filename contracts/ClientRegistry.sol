// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ClientTypes} from "./types/ClientTypes.sol";
import {MinerAPI, MinerTypes, CommonTypes} from "@zondax/filecoin-solidity/contracts/v0.8/MinerAPI.sol";

contract ClientRegistry {
    // apply
    // verified
    // blacklisted

    // Mapping of client miner ids to their Client info
    mapping(uint64 => ClientTypes.Client) public clients;

    // Mapping of client actor ids to their allocation
    mapping(uint64 => ClientTypes.ClientAllocation) public allocations;

    // mapping of client actor ids to their allocation requests
    mapping(uint64 => ClientTypes.AllocationRequest) public allocationRequests;

    // mapping of liquid staking pools to its addresses
    mapping(address => bool) public pools;

    // mapping of client ethereum address to client actor id
    mapping(address => uint64) public clientAddressToId;

    mapping(uint64 => bool) public whitelistedClients;

    uint64[] public clientsList;

    uint256 public whitelistedCount;

    uint256 allocationLimit = 10000;

    function register(uint64 _clientId, string memory name) public {
        ClientTypes.Client storage client = clients[_clientId];
        // client.verificationFormCID = _verificationFormCID;
        client.ethAddress = msg.sender;
        client.name = name;
        clientAddressToId[msg.sender] = _clientId;
        // TODO: accept deposit
        clientsList.push(_clientId);
        // TODO: add whitelist request to dao
    }

    function whitelist(uint64 _clientId) public {
        ClientTypes.Client storage client = clients[_clientId];
        client.verified = true;
        ClientTypes.ClientAllocation storage allocation = allocations[_clientId];
        allocation.allocationLimit = allocationLimit;
        allocation.allocation = 0;
        whitelistedCount++;
        whitelistedClients[_clientId] = true;
    }

    function allocateSubsidyToClient(uint64 _clientId, uint256 _newAllocation) public {
        ClientTypes.ClientAllocation storage allocation = allocations[_clientId];
        require(_newAllocation < allocation.allocationLimit, "allocation exceeds limit");
        allocation.allocation = _newAllocation;
        // TODO: Generate tokens and give to client
    }

    function blacklist(uint64 _clientId) public {
        ClientTypes.Client storage client = clients[_clientId];
        client.blacklisted = true;
        whitelistedCount--;
        whitelistedClients[_clientId] = false;
        // TODO: take back all tokens
        // TODO: put deposit in vault
        // TODO: client.verif
        // DO NOT ACCEPT SUBSIDY
    }

    function isClientIdRegistered(uint64 _clientId) public view returns (bool) {
        return clients[_clientId].ethAddress != address(0);
    }

    function isClientAddressRegistered(address _clientAddress) public view returns (bool) {
        return clientAddressToId[_clientAddress] != 0;
    }

    function isWhitelisted(uint64 _clientId) public view returns (bool) {
        return clients[_clientId].verified;
    }

    function isAddressWhitelisted(address _clientAddress) public view returns (bool) {
        return clients[clientAddressToId[_clientAddress]].verified;
    }

    function getEthAddress(uint64 _clientId) public view returns (address) {
        return clients[_clientId].ethAddress;
    }

    function getWhitelistedClients() public view returns (uint64[] memory) {
        uint64[] memory whitelisted = new uint64[](whitelistedCount);
        uint64 count = 0;
        for (uint64 i = 0; i < clientsList.length; i++) {
            if (whitelistedClients[clientsList[i]]) {
                whitelisted[count] = clientsList[i];
                count++;
            }
        }
        return whitelisted;
    }

    function getAllClients() public view returns (ClientTypes.Client[] memory) {
        ClientTypes.Client[] memory allClients = new ClientTypes.Client[](clientsList.length);
        for (uint64 i = 0; i < clientsList.length; i++) {
            allClients[i] = clients[clientsList[i]];
        }
        return allClients;
    }

    function getClientByAddress(
        address _clientAddress
    ) public view returns (ClientTypes.Client memory) {
        return clients[clientAddressToId[_clientAddress]];
    }
}
