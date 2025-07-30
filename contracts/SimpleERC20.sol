// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title Simple ERC20 Token (Upgradeable)
/// @notice A minimal ERC20 implementation for demonstration purposes, upgradeable version
contract SimpleERC20 is Initializable, ContextUpgradeable, IERC20 {
    // Custom errors for revert codes
    error ApproveFromZeroAddress();
    error ApproveToZeroAddress();
    error TransferFromZeroAddress();
    error TransferToZeroAddress();
    error TransferAmountExceedsBalance();
    error MintToZeroAddress();
    error TransferAmountExceedsAllowance();
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    /// @notice Initializer for upgradeable contract
    /// @param name_ The name of the token
    /// @param symbol_ The symbol of the token
    /// @param decimals_ The decimals of the token
    /// @param initialSupply The initial token supply
    function initialize(string memory name_, string memory symbol_, uint8 decimals_, uint256 initialSupply) public initializer {
        __Context_init();
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _mint(_msgSender(), initialSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        uint256 currentAllowance = _allowances[from][_msgSender()];
        if (currentAllowance < amount) revert TransferAmountExceedsAllowance();
        _transfer(from, to, amount);
        _approve(from, _msgSender(), currentAllowance - amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        if (from == address(0)) revert TransferFromZeroAddress();
        if (to == address(0)) revert TransferToZeroAddress();
        if (_balances[from] < amount) revert TransferAmountExceedsBalance();
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal {
        if (account == address(0)) revert MintToZeroAddress();
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        if (owner == address(0)) revert ApproveFromZeroAddress();
        if (spender == address(0)) revert ApproveToZeroAddress();
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
