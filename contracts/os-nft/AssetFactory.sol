// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

import "./Asset.sol";

contract AssetFactory {
    address public logicAddress;
    address[] public deployed;

    event AssetCreated(address indexed newAddress, address indexed creator);

    constructor(address _logicAddress) {
        logicAddress = _logicAddress;
    }

    function create(
        string memory uri,
        string memory name,
        uint256 totalSupply,
        uint256 royalties,
        string memory cid
    ) public {
        address clone = Clones.clone(logicAddress);
        address creator = msg.sender;

        Asset(clone).initialize(
            uri,
            name,
            totalSupply,
            creator,
            royalties,
            cid
        );

        deployed.push(clone);

        emit AssetCreated(clone, msg.sender);
    }
}
