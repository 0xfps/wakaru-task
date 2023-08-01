// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

/**
* @title IWakaru
* @author fps (@0xfps).
* @dev An interface for an on-chain NFT game.
*/

interface IWakaru {
    event LeveledUp(uint256 indexed id, uint48 oldLevel, uint48 newLevel);
    event Minted(address indexed minter, uint256 id);
    event Withdrawn(uint256 indexed amount);

    struct Avatar {
        uint48 level;
        uint48 strength;
        uint48 agility;
        uint48 wisdom;
        uint48 stamina;
        /// Image on Pinata, IPFS.
        string image;
    }

    function mint() external payable returns (uint256);
    function levelUp(uint256 tokenId) external;
    function getAvatar(uint256 tokenId) external view returns (Avatar memory);
    function tokenIsUpperLevelPlayer(uint256 tokenId) external view returns (bool);
    function withdraw() external;
}