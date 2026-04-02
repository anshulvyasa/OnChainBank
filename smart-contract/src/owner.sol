// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Owner {
    // State Variable
    address private _owner;

    // Event
    event OwnerChanged(address indexed previousOwner, address indexed newOwner);

    // Custom Error
    error InvalidNewOwner(address newOwner);

    // Constructor
    constructor(address owner_) {
        _owner = owner_;
    }

    // Modifier
    modifier onlyOwner() {
        require(msg.sender == _owner, "Not authorized");
        _;
    }

    // View Function
    function getOwner() public view returns (address) {
        return _owner;
    }

    // Change Owner
    function changeOwner(address newOwner_) public onlyOwner {
        if (newOwner_ == address(0)) {
            revert InvalidNewOwner(newOwner_);
        }

        address previousOwner = _owner;
        _owner = newOwner_;

        emit OwnerChanged(previousOwner, newOwner_);
    }
}
