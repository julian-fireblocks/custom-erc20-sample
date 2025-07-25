// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/// @title Lock Contract
/// @notice This contract locks Ether until a specified unlock time.
contract Lock {
    /// @notice The timestamp when the lock can be withdrawn
    uint public unlockTime;
    /// @notice The owner of the lock
    address payable public owner;

    /// @notice Emitted when a withdrawal is made
    /// @param amount The amount withdrawn
    /// @param when The timestamp of withdrawal
    event Withdrawal(uint amount, uint when);

    /// @notice Creates a new Lock contract
    /// @param _unlockTime The timestamp when funds can be withdrawn
    constructor(uint _unlockTime) payable {
        require(
            block.timestamp < _unlockTime,
            "Unlock time should be in the future"
        );

        unlockTime = _unlockTime;
        owner = payable(msg.sender);
    }

    /// @notice Withdraws the locked funds after unlock time
    function withdraw() public {
        // Uncomment this line, and the import of "hardhat/console.sol", to print a log in your terminal
        // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);

        require(block.timestamp >= unlockTime, "You can't withdraw yet");
        require(msg.sender == owner, "You aren't the owner");

        emit Withdrawal(address(this).balance, block.timestamp);

        owner.transfer(address(this).balance);
    }
}
