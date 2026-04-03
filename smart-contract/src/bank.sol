// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Owner} from "./owner.sol";

contract Bank is Owner {
    //  State Variables
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event Deposit(address indexed owner, uint256 amount);
    event Withdraw(address indexed owner, uint256 amount);

    // Custom Errors
    error InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error InvalidSender(address sender);
    error InvalidReceiver(address receiver);
    error InvalidApprover(address approver);
    error InvalidSpender(address spender);
    error InsufficientAllowance(
        address spender,
        uint256 allowance,
        uint256 needed
    );

    // Constructor
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) Owner(msg.sender) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_;

        _balances[msg.sender] = totalSupply_;
    }

    //View Functions
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner_) public view returns (uint256) {
        return _balances[owner_];
    }

    function allowance(
        address owner_,
        address spender_
    ) public view returns (uint256) {
        return _allowances[owner_][spender_];
    }

    // Core ERC20 Functions
    function transfer(address to_, uint256 value_) public returns (bool) {
        _transfer(msg.sender, to_, value_);
        return true;
    }

    function approve(address spender_, uint256 value_) public returns (bool) {
        _approve(msg.sender, spender_, value_);
        return true;
    }

    function transferFrom(
        address from_,
        address to_,
        uint256 value_
    ) public returns (bool) {
        _spendAllowance(from_, msg.sender, value_);
        _transfer(from_, to_, value_);
        return true;
    }

    // Bank Logic
    function deposit(
        address owner_,
        uint256 value_
    ) public onlyOwner returns (bool) {
        _update(address(0), owner_, value_);
        emit Deposit(owner_, value_);
        return true;
    }

    function withdraw(
        address owner_,
        uint256 value_
    ) public onlyOwner returns (bool) {
        _update(owner_, address(0), value_);
        emit Withdraw(owner_, value_);
        return true;
    }

    // Internal Logic
    function _transfer(address from_, address to_, uint256 value_) internal {
        if (from_ == address(0)) revert InvalidSender(from_);
        if (to_ == address(0)) revert InvalidReceiver(to_);

        _update(from_, to_, value_);
    }

    function _update(address from_, address to_, uint256 value_) internal {
        if (from_ == address(0)) {
            _totalSupply += value_; // Mint
        } else {
            uint256 fromBalance = _balances[from_];
            if (fromBalance < value_) {
                revert InsufficientBalance(from_, fromBalance, value_);
            }

            unchecked {
                _balances[from_] = fromBalance - value_;
            }
        }

        if (to_ == address(0)) {
            _totalSupply -= value_; // Burn
        } else {
            _balances[to_] += value_;
        }

        emit Transfer(from_, to_, value_);
    }

    function _approve(
        address owner_,
        address spender_,
        uint256 value_
    ) internal {
        if (owner_ == address(0)) revert InvalidApprover(owner_);
        if (spender_ == address(0)) revert InvalidSpender(spender_);

        _allowances[owner_][spender_] = value_;
        emit Approval(owner_, spender_, value_);
    }

    function _spendAllowance(
        address owner_,
        address spender_,
        uint256 value_
    ) internal {
        uint256 currentAllowance = _allowances[owner_][spender_];

        if (currentAllowance < value_) {
            revert InsufficientAllowance(spender_, currentAllowance, value_);
        }

        uint256 currentBalance = _balances[owner_];
        if (currentBalance < value_) {
            revert InsufficientBalance(owner_, currentBalance, value_);
        }

        unchecked {
            _allowances[owner_][spender_] = currentAllowance - value_;
        }
    }
}
