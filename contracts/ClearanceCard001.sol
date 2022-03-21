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

    string public LEVEL_0_URI = "https://sekerfactory.mypinata.cloud/ipfs/QmYMHEPQGirxDemTqnPkYsJuXK8igm4zodTGDF8eJdkhBF";
    string public LEVEL_1_URI = "https://sekerfactory.mypinata.cloud/ipfs/QmYMHEPQGirxDemTqnPkYsJuXK8igm4zodTGDF8eJdkhBF";
    string public LEVEL_2_URI = "https://sekerfactory.mypinata.cloud/ipfs/QmYMHEPQGirxDemTqnPkYsJuXK8igm4zodTGDF8eJdkhBF";
    string public LEVEL_3_URI = "https://sekerfactory.mypinata.cloud/ipfs/QmYMHEPQGirxDemTqnPkYsJuXK8igm4zodTGDF8eJdkhBF";

    mapping(uint256 => uint256) public cardLevels;

    event CardLevelUp(uint256 indexed id, uint256 indexed newLevel);
    event CardLevelDown(uint256 indexed id, uint256 indexed newLevel);

    constructor() ERC721("Seker Factory Clearance Cards 001", "SF001") {
    }

    function mint(uint256 _amount) public payable {
        require(
            Counters.current(_tokenIds) <= totalEditions,
            "minting has reached its max"
        );
        require(_amount <= 5, "can only mint 5 at a time");
        require(msg.value >= price * _amount, "Not enough eth");
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
    }

    function cardLevel(uint256 _id) public view returns (uint256) {
        return cardLevels[_id];
    }

    // function build(uint256 tokenId) external override {
    //     require(msg.sender == ERC721.ownerOf(tokenId), 'Wands: only owner can build wand');
    //     uint16 halo = 1 + uint16(psuedoRandom() % 4);
    //     // Construct Wand
    //     Wand memory wand = Wand({
    //         built: true,
    //         halo: halo,
    //         evolution: 0,
    //         birth: block.timestamp
    //     });
    //     _wands[tokenId] = wand;
    //     emit WandBuilt(tokenId, halo, 0, block.timestamp);
    // }

    function tokenURI(uint256 tokenId) public view override(ERC721URIStorage) returns (string memory) {
        require(_exists(tokenId), 'Clearance Cards: URI query for nonexistent token');
        return generateCardURI(tokenId);
    }

    // function cards(uint256 tokenId)
    //     external
    //     view
    //     override
    //     returns (
    //         uint16 halo,
    //         uint256 evolution,
    //         uint256 birth
    //     )
    // {
    //     require(_exists(tokenId), 'Wand: tokenID does not exist');
    //     Wand memory wand = _wands[tokenId];
    //     return (
    //         wand.halo,
    //         wand.evolution,
    //         wand.birth
    //     );
    // }

    // function _baseURI() internal view virtual override returns (string memory) {
    //     return "https://sekerfactory.mypinata.cloud/ipfs/";
    // }

    function generateCardURI(uint256 _id)
        public
        view
        returns (string memory)
    {
        uint256 level = cardLevels[_id];
        string memory imgURI = "";

        if(level == 0) {
            imgURI = LEVEL_0_URI;
        } else if (level == 1) {
            imgURI = LEVEL_1_URI;
        } else if (level == 2) {
            imgURI = LEVEL_2_URI;
        } else if (level == 3) {
            imgURI = LEVEL_3_URI;
        }

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                "name",
                                '", "description":"Seker Factory Cards."', 
                                '"attributes": ',
                                '[{"trait_type":"Level","value":"',
                                //string(abi.encodePacked(level)),
                                Strings.toString(level),
                                '"}]',
                                '"image":"',
                                imgURI, 
                                '"}"'
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
            // reset evolutions and age?
            // _wands[tokenId].evolution = 0;
            // _wands[tokenId].birth = block.timestamp;
        }
    }
}
