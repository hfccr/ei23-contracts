// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/// @custom:security-contact hfccr@outlook.com
contract ClientSubsidyToken is ERC20, ERC20Burnable, AccessControl {
    // Should be an ERC20 token
    // Cannot be transferred
    // Can be redeemed against subsidy for storage deals by providers
    // Anyone can call redeem function
    // Redeem function will transfer money in the deal to a whitelisted provider
    // from the vault of the pool

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    constructor(address defaultAdmin, address minter) ERC20("Client Subsidy Token", "CST") {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn() public onlyRole(BURNER_ROLE) {
        _burn(msg.sender, balanceOf(msg.sender));
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        revert("Cannot transfer CST");
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        revert("Cannot transfer CST");
    }
}
