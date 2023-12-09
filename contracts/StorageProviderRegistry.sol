// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {StorageProviderTypes} from "./types/StorageProviderTypes.sol";
import {MinerAPI, MinerTypes, CommonTypes} from "@zondax/filecoin-solidity/contracts/v0.8/MinerAPI.sol";

contract StorageProviderRegistry {
    mapping(uint64 => StorageProviderTypes.StorageProvider) public storageProviders;
    mapping(uint64 => StorageProviderTypes.StorageProviderSubsidy) public subsidies;

    mapping(address => uint64) public storageProviderAddressToId;
    mapping(uint64 => bool) public whitelistedStorageProviders;
    uint64[] public storageProvidersList;
    uint256 public whitelistedCount;

    function register(uint64 _storageProviderId) public {
        StorageProviderTypes.StorageProvider storage storageProvider = storageProviders[
            _storageProviderId
        ];
        storageProvider.ethAddress = msg.sender;
        storageProviderAddressToId[msg.sender] = _storageProviderId;
        // TODO: accept deposit
        storageProvidersList.push(_storageProviderId);
    }

    function whitelist(uint64 _storageProviderId) public {
        StorageProviderTypes.StorageProvider storage storageProvider = storageProviders[
            _storageProviderId
        ];
        storageProvider.verified = true;
        StorageProviderTypes.StorageProviderSubsidy storage subsidy = subsidies[_storageProviderId];
        subsidy.numberOfDealsRedeemed = 0;
        whitelistedStorageProviders[_storageProviderId] = true;
        whitelistedCount++;
    }

    function blacklist(uint64 _storageProviderId) public {
        StorageProviderTypes.StorageProvider storage storageProvider = storageProviders[
            _storageProviderId
        ];
        storageProvider.blacklisted = true;
        whitelistedStorageProviders[_storageProviderId] = false;
        whitelistedCount--;
    }

    function isStorageProviderRegistered(uint64 _storageProviderId) public view returns (bool) {
        return storageProviders[_storageProviderId].ethAddress != address(0);
    }

    function isStorageProviderAddressRegistered(
        address _storageProviderAddress
    ) public view returns (bool) {
        return storageProviderAddressToId[_storageProviderAddress] != 0;
    }

    function getEthAddress(uint64 _storageProviderId) public view returns (address) {
        return storageProviders[_storageProviderId].ethAddress;
    }

    function isWhitelisted(uint64 _storageProviderId) public view returns (bool) {
        return whitelistedStorageProviders[_storageProviderId];
    }

    function isAddressWhitelisted(address _storageProviderAddress) public view returns (bool) {
        uint64 storageProviderId = storageProviderAddressToId[_storageProviderAddress];
        return whitelistedStorageProviders[storageProviderId];
    }

    function getWhitelistedStorageProviders() public view returns (uint64[] memory) {
        uint64[] memory whitelisted = new uint64[](whitelistedCount);
        uint64 count = 0;
        for (uint64 i = 0; i < storageProvidersList.length; i++) {
            if (whitelistedStorageProviders[storageProvidersList[i]]) {
                whitelisted[count] = storageProvidersList[i];
                count++;
            }
        }
        return whitelisted;
    }

    function getAllStorageProviders()
        public
        view
        returns (StorageProviderTypes.StorageProvider[] memory)
    {
        StorageProviderTypes.StorageProvider[]
            memory allStorageProviders = new StorageProviderTypes.StorageProvider[](
                storageProvidersList.length
            );
        for (uint64 i = 0; i < storageProvidersList.length; i++) {
            allStorageProviders[i] = storageProviders[storageProvidersList[i]];
        }
        return allStorageProviders;
    }

    function getStorageProviderByAddress(
        address _storageProviderAddress
    ) public view returns (StorageProviderTypes.StorageProvider memory) {
        uint64 storageProviderId = storageProviderAddressToId[_storageProviderAddress];
        return storageProviders[storageProviderId];
    }
}
