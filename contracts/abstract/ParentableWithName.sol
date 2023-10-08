// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

abstract contract ParentableWithName {
    event NewParent(
        uint256 indexed id,
        uint256 indexed pid,
        uint256 indexed amount
    );

    mapping(uint256 => uint256) private _parents;
    mapping(uint256 => string) private _names;

    function _setParent(uint256 id, uint256 pid) internal virtual {
        _parents[id] = pid;
    }

    function getParent(uint256 id) public view returns (uint256) {
        return _parents[id];
    }

    function _setName(uint256 id, string memory name) internal virtual {
        _names[id] = name;
    }

    function getName(uint256 id) public view virtual returns (string memory) {
        return _names[id];
    }

    function getFullName(uint256 id) public view returns (string memory) {
        if (id != 0) {
            uint256 pid = _parents[id];
            string memory pname = getFullName(pid);
            return string(bytes.concat(bytes(pname), "/", bytes(_names[id])));
        } else {
            return _names[id];
        }
    }
}
