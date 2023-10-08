// SPDX-License-Identifier: private
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

import "../abstract/ParentableWithName.sol";

contract Asset is
    ERC1155URIStorage,
    Initializable,
    AccessControl,
    ERC2981,
    ParentableWithName
{
    mapping(address => bool) private createChildAllowance;

    constructor(string memory uri) ERC1155(uri) {}

    uint256 private id;

    function generateId() internal returns (uint256) {
        return ++id;
    }

    function initialize(
        string memory _uri,
        string memory _name,
        uint256 _totalSupply,
        address _creator,
        uint256 _royalties,
        string memory cid
    ) external initializer {
        uint256 rootID = 0;
        _mint(_creator, rootID, _totalSupply, "");
        totalSupply = _totalSupply;
        _setName(rootID, _name);
        // set parent id to itself, because it is root asset
        _setParent(rootID, rootID);
        _setBaseURI(_uri);
        _setURI(rootID, cid);
        _setDefaultRoyalty(_creator, uint96(_royalties));
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC1155, AccessControl, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    uint256 public totalSupply;

    event CreatorTransfer(address indexed from, address indexed to);

    address public creator;

    bool private creatorSet = false;

    function _setCreator(address _creator) internal {
        require(!creatorSet, "creator already was set");
        creator = _creator;
        creatorSet = true;
        emit CreatorTransfer(address(0), _creator);
    }

    modifier onlyCreator() {
        require(msg.sender == creator, "Creator: caller is not the creator");
        _;
    }

    function transferCreator(address newCreator) public onlyCreator {
        address oldCreator = creator;
        creator = newCreator;
        emit CreatorTransfer(oldCreator, newCreator);
    }

    function createChild(
        address from,
        uint256 amount,
        uint256 childAmount,
        uint256 pid,
        string memory name,
        address to,
        string memory cid
    ) external onlyCreator {
        uint256 childId = generateId();
        _burn(from, pid, amount);
        _mint(to, id, childAmount, "");
        _setName(id, name);
        _setParent(id, pid);
        _setURI(id, cid);
        emit NewParent(childId, pid, amount);
    }

    function burn(uint256 amount) external {
        _burn(_msgSender(), 0, amount);
    }
}
