// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/// @title Minimal ERC1967 Proxy
/// @notice A minimal implementation of the EIP-1967 proxy pattern
contract ERC1967Proxy {
    /// @notice Deploys the proxy and sets the implementation
    /// @param _logic The address of the logic contract
    /// @param _data Initialization data for the logic contract
    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        if(_data.length > 0) {
            (bool success,) = _logic.delegatecall(_data);
            require(success, "Initialization failed");
        }
    }

    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /// @notice Returns the current implementation address
    function _getImplementation() internal view returns (address impl) {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    /// @notice Sets the implementation address
    /// @param newImplementation The new implementation address
    function _setImplementation(address newImplementation) private {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImplementation)
        }
    }

    /// @notice Delegates calls to the implementation
    fallback() external payable {
        _delegate(_getImplementation());
    }

    /// @notice Delegates calls to the implementation (receive)
    receive() external payable {
        _delegate(_getImplementation());
    }

    /// @notice Internal delegate function
    /// @param implementation The address to delegate to
    function _delegate(address implementation) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
