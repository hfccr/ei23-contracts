// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import {SubsidyDaoTypes} from "./types/SubsidyDaoTypes.sol";
import {ClientRegistry} from "./ClientRegistry.sol";
import {StorageProviderRegistry} from "./StorageProviderRegistry.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract SubsidyDao is AccessControl {
    ClientRegistry clientRegistry;
    StorageProviderRegistry storageProviderRegistry;
    // store a queue of client whitelists
    uint256 public clientWhitelistRequestCount;
    mapping(uint256 => SubsidyDaoTypes.ClientWhitelistRequest) clientWhitelistRequestMap;

    uint256 public clientAllocationRequestCount;
    mapping(uint256 => SubsidyDaoTypes.ClientAllocationRequest) clientAllocationRequestMap;

    uint256 public storageProviderWhitelistRequestCount;
    mapping(uint256 => SubsidyDaoTypes.StorageProviderWhitelistRequest) storageProviderWhitelistRequestMap;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setClientRegistry(address _clientRegistryAddress) public onlyRole(DEFAULT_ADMIN_ROLE) {
        clientRegistry = ClientRegistry(_clientRegistryAddress);
    }

    function setStorageProviderRegistry(
        address _storageProviderRegistryAddress
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        storageProviderRegistry = StorageProviderRegistry(_storageProviderRegistryAddress);
    }

    function createClientWhitelistRequest(uint64 _clientId, address ethAddress) public {
        // Client must be registered before whitelist
        // require(clientRegistry.isClientIdRegistered(_clientId), "Client not registered");
        SubsidyDaoTypes.ClientWhitelistRequest storage request = clientWhitelistRequestMap[
            clientWhitelistRequestCount
        ];
        request.clientId = _clientId;
        request.approved = false;
        request.ethAddress = ethAddress;
        clientWhitelistRequestCount++;
    }

    function approveClientWhitelistRequest(uint256 _requestIndex) public {
        // Client must not be already whitelisted
        require(
            clientRegistry.isWhitelisted(clientWhitelistRequestMap[_requestIndex].clientId) ==
                false,
            "Client already whitelisted"
        );
        require(
            clientWhitelistRequestMap[_requestIndex].approved == false,
            "Request already approved"
        );
        // Call client registry with request params
        clientRegistry.whitelist(clientWhitelistRequestMap[_requestIndex].clientId);
        clientWhitelistRequestMap[_requestIndex].approved = true;
    }

    function createStorageProviderWhitelistRequest(uint64 _storageProviderId) public {
        // storage provider must be registered before whitelisting
        // require(
        //     storageProviderRegistry.isStorageProviderRegistered(_storageProviderId),
        //     "Storage provider not registered"
        // );
        SubsidyDaoTypes.StorageProviderWhitelistRequest
            storage request = storageProviderWhitelistRequestMap[
                storageProviderWhitelistRequestCount
            ];
        request.storageProviderId = _storageProviderId;
        request.approved = false;
        request.ethAddress = storageProviderRegistry.getEthAddress(_storageProviderId);
        storageProviderWhitelistRequestCount++;
    }

    function approveStorageProviderWhitelistRequest(uint256 _requestIndex) public {
        // storage provider must not be already whitelisted
        require(
            storageProviderRegistry.isWhitelisted(
                storageProviderWhitelistRequestMap[_requestIndex].storageProviderId
            ) == false,
            "Storage provider already whitelisted"
        );
        require(
            storageProviderWhitelistRequestMap[_requestIndex].approved == false,
            "Request already approved"
        );
        // Call client registry with request params
        storageProviderRegistry.whitelist(
            storageProviderWhitelistRequestMap[_requestIndex].storageProviderId
        );
        storageProviderWhitelistRequestMap[_requestIndex].approved = true;
    }

    function createClientAllocationRequest(uint64 _clientId, uint256 _allocation) public {
        // Client must be whitelisted
        require(clientRegistry.isWhitelisted(_clientId), "Client not whitelisted");
        SubsidyDaoTypes.ClientAllocationRequest storage request = clientAllocationRequestMap[
            clientAllocationRequestCount
        ];
        request.clientId = _clientId;
        request.allocation = _allocation;
        request.approved = false;
        request.ethAddress = clientRegistry.getEthAddress(_clientId);
        clientAllocationRequestCount++;
    }

    function createClientAllocationRequestByAddress(
        address _clientAddress,
        uint256 _allocation
    ) public {
        // Client must be whitelisted
        require(clientRegistry.isAddressWhitelisted(_clientAddress), "Client not whitelisted");
        SubsidyDaoTypes.ClientAllocationRequest storage request = clientAllocationRequestMap[
            clientAllocationRequestCount
        ];
        request.clientId = clientRegistry.getClientId(_clientAddress);
        request.allocation = _allocation;
        request.approved = false;
        request.ethAddress = _clientAddress;
        clientAllocationRequestCount++;
    }

    function approveClientAllocationRequest(uint256 _requestIndex) public {
        // Client must be whitelisted
        require(
            clientRegistry.isWhitelisted(clientAllocationRequestMap[_requestIndex].clientId),
            "Client not whitelisted"
        );
        require(
            clientAllocationRequestMap[_requestIndex].approved == false,
            "Request already approved"
        );
        // Call client registry with request params
        clientRegistry.allocateSubsidyToClient(
            clientAllocationRequestMap[_requestIndex].clientId,
            clientAllocationRequestMap[_requestIndex].allocation
        );
        clientAllocationRequestMap[_requestIndex].approved = true;
    }

    function getClientWhitelistRequests()
        public
        view
        returns (SubsidyDaoTypes.ClientWhitelistRequest[] memory)
    {
        SubsidyDaoTypes.ClientWhitelistRequest[]
            memory requests = new SubsidyDaoTypes.ClientWhitelistRequest[](
                clientWhitelistRequestCount
            );
        for (uint256 i = 0; i < clientWhitelistRequestCount; i++) {
            requests[i] = clientWhitelistRequestMap[i];
        }
        return requests;
    }

    function doesClientHaveAllocationRequest(address ethAddress) public view returns (bool) {
        for (uint256 i = 0; i < clientAllocationRequestCount; i++) {
            if (clientAllocationRequestMap[i].clientId == clientRegistry.getClientId(ethAddress)) {
                return true;
            }
        }
        return false;
    }

    function getClientAllocationRequestForClient(
        uint64 _clientId
    ) public view returns (SubsidyDaoTypes.ClientAllocationRequest memory) {
        for (uint256 i = 0; i < clientAllocationRequestCount; i++) {
            if (clientAllocationRequestMap[i].clientId == _clientId) {
                return clientAllocationRequestMap[i];
            }
        }
        revert("No allocation request found for client");
    }

    function getClientAllocationRequests()
        public
        view
        returns (SubsidyDaoTypes.ClientAllocationRequest[] memory)
    {
        SubsidyDaoTypes.ClientAllocationRequest[]
            memory requests = new SubsidyDaoTypes.ClientAllocationRequest[](
                clientAllocationRequestCount
            );
        for (uint256 i = 0; i < clientAllocationRequestCount; i++) {
            requests[i] = clientAllocationRequestMap[i];
        }
        return requests;
    }

    function getStorageProviderWhitelistRequests()
        public
        view
        returns (SubsidyDaoTypes.StorageProviderWhitelistRequest[] memory)
    {
        SubsidyDaoTypes.StorageProviderWhitelistRequest[]
            memory requests = new SubsidyDaoTypes.StorageProviderWhitelistRequest[](
                storageProviderWhitelistRequestCount
            );
        for (uint256 i = 0; i < storageProviderWhitelistRequestCount; i++) {
            requests[i] = storageProviderWhitelistRequestMap[i];
        }
        return requests;
    }
}
