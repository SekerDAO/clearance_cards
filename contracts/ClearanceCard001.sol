// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";

contract ClearanceCard001 is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 public totalEditions = 1000;
    uint256 public price = 0.00 ether;

    string[11] public URIs = [
        "https://sekerfactory.mypinata.cloud/ipfs/QmUkuyxyLR9UskihBcKBpkxHV5PuzmuCNwp1jPty811PwQ",
        "https://sekerfactory.mypinata.cloud/ipfs/QmfQFT67reWzd9DKohtmC8EfdnrQFEm7N4cHSCYT9sHuZC",
        "https://sekerfactory.mypinata.cloud/ipfs/QmQFHWJHFjYMogti4XEq9BALbuosjkdXTK5jGykdCKoHUt",
        "https://sekerfactory.mypinata.cloud/ipfs/QmSTC2gTipuWTPBxDvERZyp1Axoi7vgWPnrCX5yrHxTmKp",
        "https://sekerfactory.mypinata.cloud/ipfs/QmU1XWHwSMx95dYTyYxx6JaU1i81TDzcWFGYFYNU2B1QVH",
        "https://sekerfactory.mypinata.cloud/ipfs/QmTPmEBNJTVfDkAK7eDEZceqXzQ37co3QM1EssZKa1xdiB",
        "https://sekerfactory.mypinata.cloud/ipfs/QmWii6TdmVJAic5b5qeUr2uXDbd5izdAD8EYk9382Ew7cB",
        "https://sekerfactory.mypinata.cloud/ipfs/QmNYKTGxeMWo64KT8yzXzZLhMS2FR5dGQtLxkkkTHAJagi",
        "https://sekerfactory.mypinata.cloud/ipfs/QmegFhaEwpioKbuGVo3cbQGvoc6FauMaKyczFEfXqtWAyj",
        "https://sekerfactory.mypinata.cloud/ipfs/QmXkaN7DuXSF2X2hGF7tSEyTnDyMoCiMmvqLpvjh1ZSGEV",
        "https://sekerfactory.mypinata.cloud/ipfs/QmR6wRWH9N3sNhuroBGFZMR37G4ME85q25tTYZfvaz3RxM"
    ];

    mapping(uint256 => uint256) public cardLevels;

    event CardLevelUp(uint256 indexed id, uint256 indexed newLevel);
    event CardLevelDown(uint256 indexed id, uint256 indexed newLevel);

    constructor() ERC721("Seker Factory Clearance Cards 001", "SF001") {
        //_transferOwnership(address(0x7735b940d673344845aC239CdDddE1D73b5d5627));
    }

    function mint(uint256 _amount) public payable {
        require(
            Counters.current(_tokenIds) <= totalEditions,
            "minting has reached its max"
        );
        require(_amount <= 5, "can only mint 5 at a time");
        require(msg.value == price * _amount, "Incorrect eth amount");
        for (uint256 i; i <= _amount - 1; i++) {
            uint256 newNFT = _tokenIds.current();
            _safeMint(msg.sender, newNFT);
            _tokenIds.increment();
            cardLevels[newNFT] = 0;
        }
    }

    function levelUpCard(uint256 _id, uint256 _levels) public onlyOwner {
        require(cardLevels[_id] + _levels <= 10, "max level is 10");
        require(_exists(_id), "nonexistent id");
        cardLevels[_id] += _levels;
        emit CardLevelUp(_id, _levels);
    }

    function levelUpCardBatch(uint256[] memory _ids, uint256[] memory _levels) public onlyOwner {
        require(_ids.length == _levels.length, "length missmatch");
        for(uint256 i=0; i<_ids.length; i++) {
            require(cardLevels[_ids[i]] + _levels[i] <= 10, "max level is 10");
            require(_exists(_ids[i]), "nonexistent id");
            cardLevels[_ids[i]] += _levels[i];
            emit CardLevelUp(_ids[i], _levels[i]);
        }
    }

    function levelDownCard(uint256 _id, uint256 _levels) public onlyOwner {
        require(cardLevels[_id] - _levels >= 0, "min level is 0");
        require(_exists(_id), "nonexistent id");
        cardLevels[_id] -= _levels;
        emit CardLevelDown(_id, _levels);
    }

    function levelDownCardBatch(uint256[] memory _ids, uint256[] memory _levels) public onlyOwner {
        require(_ids.length == _levels.length, "length missmatch");
        for(uint256 i=0; i<_ids.length; i++) {
            require(cardLevels[_ids[i]] - _levels[i] >= 0, "min level is 0");
            require(_exists(_ids[i]), "nonexistent id");
            cardLevels[_ids[i]] -= _levels[i];
            emit CardLevelDown(_ids[i], _levels[i]);
        }
    }

    function tokenURI(uint256 tokenId) public view override(ERC721URIStorage) returns (string memory) {
        require(_exists(tokenId), 'Clearance Cards: URI query for nonexistent token');
        return generateCardURI(tokenId);
    }

    function generateCardURI(uint256 _id)
        public
        view
        returns (string memory)
    {
        uint256 level = cardLevels[_id];
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"Seker Factory Clearance Card 001",',
                                '"description":"Membership to the Seker Factory 001 DAO.",', 
                                '"attributes": ',
                                '[{"trait_type":"Level","value":"',
                                Strings.toString(level),
                                '"}],',
                                '"image":"',
                                URIs[level], 
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            // we are minting
        }

        if (to == address(0)) {
            // we are burning
        }

        if (to != address(0) && from != address(0)) {
            // we are transfering
            // reset level
            cardLevels[tokenId] = 0;
        }
    }

    // Withdraw
    function withdraw(address payable withdrawAddress)
        external
        payable
        onlyOwner
    {
        require(
            withdrawAddress != address(0),
            "Withdraw address cannot be zero"
        );
        require(address(this).balance >= 0, "Not enough eth");
        (bool sent, bytes memory data) = withdrawAddress.call{value:address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}
