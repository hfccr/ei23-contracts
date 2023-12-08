// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {WFIL} from "fevmate/contracts/token/WFIL.sol";

interface IWFIL is IERC20 {
    /**
     * @notice Deposit Fil into the contract, and mint WFIL 1:1.
     */
    function deposit() external payable;

    /**
     * @notice Burns _amount WFIL from caller's balance, and transfers them
     * the unwrapped Fil 1:1.
     *
     * Note: The fund transfer used here is address.call{value: _amount}(""),
     * which does NOT work with the FVM's builtin Multisig actor. This is
     * because, under the hood, address.call acts like a message to an actor's
     * InvokeEVM method. The Multisig actor does not implement this method.
     *
     * This is a known issue, but we've decided to keep the method as-is,
     * because it's likely that the Multisig actor is eventually upgraded to
     * support this method. Even though a Multisig actor cannot directly
     * withdraw, it is still possible for Multisigs to deposit, transfer,
     * etc WFIL. So, if your Multisig actor needs to withdraw, you can
     * transfer your WFIL to another contract, which can perform the
     * withdrawal for you.
     *
     * (Though Multisig actors are not supported, BLS/SECPK/EthAccounts
     * and EVM contracts can use this method normally)
     */
    function withdraw(uint256 amount) external;
}
