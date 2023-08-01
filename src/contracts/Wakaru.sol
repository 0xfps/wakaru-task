// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

import {IWakaru} from "../interfaces/IWakaru.sol";

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ETHUSDConverter} from "./utils/ETHUSDConverter.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
* @title Wakaru
* @author fps (@0xfps).
* @dev An on-chain NFT game.
*/

contract Wakaru is 
    IWakaru,
    ETHUSDConverter,
    ERC721("WakaruNFT", "wNFT"),
    Ownable2Step
{
    uint8 internal increments = 50;
    uint256 internal index;
    uint256 internal upperLevelPlayers;
    string level1URI = "https://ipfs.io/ipfs/QmYt5VHushhmXhoz5TfPjV6a86xu4okttByMPtgMtAWsU6/1.json";
    string level2URI = "https://ipfs.io/ipfs/QmYt5VHushhmXhoz5TfPjV6a86xu4okttByMPtgMtAWsU6/2.json";

    mapping(uint256 tokenId => Avatar avatar) internal avatars;
    mapping(uint256 tokenId => bool upperLevelPlayer) internal isUpperLevelPlayer;

    /**
    * @dev Mints an avatar NFT to the user.
    * @notice   $20 USD is charged for every mint, the balance, returned.
    *           Avatars start on default levels, level 1.
    *           If you're wondering why this function is not nonReentrant,
    *           it's because ether is charged per call. Re-enter at your own risk.
    * @return uint256 User's NFT index.
    */
    function mint() public payable returns (uint256) {
        uint256 twentyUSD = twentyUSDInETH();
        if (msg.value < twentyUSD) revert("Wakaru: MINT_PRICE_IS_$20");
        ++index;

        uint256 balance = msg.value - twentyUSD;

        Avatar memory avatar = Avatar(1, 10, 10, 10, 10, level1URI);

        avatars[index] = avatar;

        _mint(msg.sender, index);

        bool sent;
        if (balance > 0) (sent, ) = msg.sender.call{value: balance}("");
        if (!sent) revert("Wakaru: REFUND_FAILED");

        emit Minted(msg.sender, index);

        return index;
    }

    /**
    * @dev Levels up `tokenId` by a level.
    * @param tokenId TokenId to be leveled up.
    */
    function levelUp(uint256 tokenId) public {
        if (msg.sender != _ownerOf(tokenId)) revert("Wakaru: NOT_OWNED_AVATAR");
        Avatar memory avatar = avatars[tokenId];

        uint48 oldLevel = avatar.level;

        avatar.level += 1;
        avatar.agility += 50;
        avatar.stamina += 50;
        avatar.strength += 50;
        avatar.wisdom += 50;
        avatar.image = level2URI;

        avatars[tokenId] = avatar;

        /// @dev    Since avatars level up by 1, it's safe to work with the
        ///         increment of + 1;
        /// @notice If the tokenId's level gets >= 3, the token should
        ///         be added as an upperLevelPlayer.
        if (((oldLevel + 1) > 2) && (!isUpperLevelPlayer[tokenId])) {
            isUpperLevelPlayer[tokenId] = true;
            ++upperLevelPlayers;
        }

        emit LeveledUp(tokenId, oldLevel, (++oldLevel));
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;

        (bool sent, ) = owner().call{value: amount}("");
        if (!sent) revert("Wakaru: WITHDRAW_FAILED");

        emit Withdrawn(amount);
    }

    /**
    * @dev Returns avatar data.
    * @param tokenId Avatar token ID.
    * @return Avatar Avatar data.
    */
    function getAvatar(uint256 tokenId) public view returns (Avatar memory) {
        _requireMinted(tokenId);

        return avatars[tokenId];
    }

    /**
    * @dev Returns avatar token URI.
    * @param tokenId Avatar token ID.
    * @return string Avatar image URI.
    */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);

        return avatars[tokenId].image;
    }

    /**
    * @dev Returns true is avatar `tokenId` is an upper level player.
    * @param tokenId Avatar token ID.
    * @return bool Upper Level Player status.
    */
    function tokenIsUpperLevelPlayer(uint256 tokenId) public view returns (bool) {
        _requireMinted(tokenId);

        return isUpperLevelPlayer[tokenId];
    }
}