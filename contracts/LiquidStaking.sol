// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IWFIL} from "./libraries/tokens/IWFIL.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeTransferLib} from "./libraries/SafeTransferLib.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract LiquidStaking is ERC4626, ReentrancyGuard, AccessControl {
    IWFIL public WFIL; // WFIL implementation

    error InvalidAccess();
    error ERC4626ZeroShares();
    error InactiveActor();
    error InsufficientFunds();
    error InvalidOwner();
    error ERC4626Overflow();
    error ERC4626Underflow();
    error AllowanceUnderflow();
    error InvalidParams();

    uint256 liquidityCap = 10000;
    address WFIL_ADDRESS = 0xaC26a4Ab9cF2A8c5DBaB6fb4351ec0F4b07356c4;

    constructor() ERC4626(IWFIL(WFIL_ADDRESS)) ERC20("pSubsidy", "PST") {
        WFIL = IWFIL(WFIL_ADDRESS);
    }

    receive() external payable virtual {}

    fallback() external payable virtual {}

    function stake() external payable nonReentrant returns (uint256 shares) {
        uint256 assets = msg.value;
        address receiver = msg.sender;

        if (assets > maxDeposit(receiver)) revert ERC4626Overflow();
        shares = previewDeposit(assets);

        if (shares == 0) revert ERC4626ZeroShares();

        WFIL.deposit{value: assets}();

        _mint(receiver, shares);
        emit Deposit(_msgSender(), receiver, assets, shares);
    }

    function unstake(uint256 shares, address owner) external nonReentrant returns (uint256 assets) {
        if (shares > maxRedeem(owner)) revert ERC4626Overflow();

        address receiver = msg.sender;
        // owner = owner.normalize();

        assets = previewRedeem(shares);

        if (receiver != owner) {
            _spendAllowance(owner, receiver, shares);
        }

        _burn(owner, shares);

        // emit Unstaked(msg.sender, owner, assets, shares);

        _unwrapWFIL(payable(receiver), assets);
    }

    // TODO: send money to clients
    function pledge(address clientAddress) public {}

    function totalAssets() public view virtual override returns (uint256) {
        // TODO: add the value of subsidy tokens issued to the clients
        return totalFilAvailable();
    }

    function totalFilAvailable() public view returns (uint256) {
        return WFIL.balanceOf(address(this));
    }

    function _unwrapWFIL(address payable _recipient, uint256 _amount) internal {
        uint256 balanceWETH9 = WFIL.balanceOf(address(this));
        if (balanceWETH9 < _amount) revert InsufficientFunds();

        if (balanceWETH9 > 0) {
            WFIL.withdraw(_amount);
            _recipient.transfer(_amount);
        }
    }

    function maxDeposit(address) public view virtual override returns (uint256) {
        return liquidityCap - totalFilAvailable();
    }

    function maxMint(address) public view virtual override returns (uint256) {
        return liquidityCap - totalFilAvailable();
    }

    function maxWithdraw(address owner) public view virtual override returns (uint256) {
        return _convertToAssets(balanceOf(owner), Math.Rounding.Floor);
    }

    function maxRedeem(address owner) public view virtual override returns (uint256) {
        return balanceOf(owner);
    }
}
