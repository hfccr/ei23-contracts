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

    function register(uint64 _storageProviderId, string memory _verificationFormCID) public {
        StorageProviderTypes.StorageProvider storage storageProvider = storageProviders[
            _storageProviderId
        ];
        storageProvider.verificationFormCID = _verificationFormCID;
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

    function isWhitelisted(uint64 _storageProviderId) public view returns (bool) {
        return whitelistedStorageProviders[_storageProviderId];
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
}
