// SPDX-License-Identifier: MIT LICENSE

pragma solidity 0.8.15;

import "./N2DRewards.sol";
import "@klaytn/contracts/KIP/token/KIP17/extensions/KIP17Enumerable.sol";
import "@klaytn/contracts/KIP/token/KIP17/IKIP17Receiver.sol";
import "@klaytn/contracts/KIP/token/KIP17/IKIP17.sol";
import "@klaytn/contracts/utils/Strings.sol";
import "witnet-solidity-bridge/contracts/requests/WitnetRequest.sol";
import "witnet-solidity-bridge/contracts/UsingWitnet.sol";

contract test is Ownable, IKIP17Receiver, UsingWitnet {
    uint256 public totalStaked;
    KIP17Enumerable public NFTContract;
    uint256 public requestId;
    // string[] arr;
    // Metadata[] arr2;

    // struct to store a stake's token, owner, and earning values
    struct Stake {
        uint24 tokenId;
        uint48 timestamp;
        address owner;
    }

    struct Metadata {
        uint256 mood;
        uint256 pose;
    }

    event NFTStaked(address owner, uint256 tokenId, uint256 value);
    event NFTUnstaked(address owner, uint256 tokenId, uint256 value);
    event Claimed(address owner, uint256 amount);

    // reference to the Block NFT contract
    KIP17Enumerable nft;
    N2DRewards token;

    // maps tokenId to stake
    mapping(uint256 => Stake) public vault;

    // maps tokenId to metadata
    mapping(uint256 => Metadata) public metadata;
    uint256[] metadata_result;

    constructor(
        WitnetRequestBoard _wrb,
        KIP17Enumerable _nft,
        N2DRewards _token
    ) UsingWitnet(_wrb) {
        nft = _nft;
        token = _token;
        NFTContract = _nft;
    }

    function _queryFactory(uint256 tokenId) private returns (WitnetRequest) {
        bytes memory d = bytes(Strings.toString(tokenId));
        bytes memory c = bytes(abi.encodePacked(uint8(0x28) + uint8(d.length)));
        bytes memory b;
        if (d.length > 1) {
            b = bytes(abi.encodePacked(uint8(0x7e) + uint8(d.length), hex"01"));
        } else {
            b = hex"7f";
        }
        bytes memory a = bytes(
            abi.encodePacked(uint8(0x95) + uint8(d.length) + uint8(b.length))
        );

        return
            new WitnetRequest(
                bytes(
                    abi.encodePacked(
                        hex"0a",
                        a,
                        hex"0112",
                        b,
                        hex"080112",
                        c,
                        hex"68747470733a2f2f736576656e2d646174612e62792d73796c2e636f6d2f6a736f6e2f",
                        d,
                        hex"2e6a736f6e1a508418778218616a617474726962757465738211828218676a74726169745f74797065831875a26a534537454e204d6f6f64f56e5369676e617475726520706f7365f5f482181a818218676576616c75651a090a050808120180100222090a05080812018010021080e497d012180a208094ebdc0328333080e8eda1ba01"
                    )
                )
            );
    }

    function st2num(string memory numString) public pure returns (uint256) {
        uint256 val = 0;
        bytes memory stringBytes = bytes(numString);
        for (uint256 i = 0; i < stringBytes.length; i++) {
            uint256 exp = stringBytes.length - i;
            bytes1 ival = stringBytes[i];
            uint8 uval = uint8(ival);
            uint256 jval = uval - uint256(0x30);

            val += (uint256(jval) * (10**(exp - 1)));
        }
        return val;
    }

    function extractPoseMood(string[] memory strings)
        internal
        returns (Metadata memory poseMood)
    {
        bytes memory s_mood = bytes(strings[0]);
        bytes memory s_pose = bytes(strings[1]);
        bytes memory result_m = new bytes(1);
        bytes memory result_p = new bytes(1);

        result_m[0] = s_mood[11];
        result_p[0] = s_pose[15];

        poseMood.mood = st2num(string(result_m));
        poseMood.pose = st2num(string(result_p));
        return poseMood;
    }


    function getPoseMood(uint256 tokenId)
        external
        payable
        returns (Metadata memory)
    {
        Metadata memory seven = metadata[tokenId];

        if (seven.mood == 0 && seven.pose == 0) {
            // WitnetRequest request = _queryFactory(tokenId);
            WitnetRequest request = new WitnetRequest('0a9701127f0801122968747470733a2f2f736576656e2d646174612e62792d73796c2e636f6d2f6a736f6e2f312e6a736f6e1a508418778218616a617474726962757465738211828218676a74726169745f74797065831875a26a534537454e204d6f6f64f56e5369676e617475726520706f7365f5f482181a818218676576616c75651a090a050808120180100222090a0508081201801002180220002833308094ebdc03');
            
            (uint256 id, ) = _witnetPostRequest(request);
            requestId = id;
            completeUpdate();
            
            
            // Witnet.Result memory result = _witnetReadResult(requestId);

            // if (witnet.isOk(result)) {
            //     string[] memory arr = witnet.asStringArray(result);
            //     Metadata memory arr2 = extractPoseMood(arr);
            //     return arr2;
            // }
        }
        return metadata[tokenId];
    }

    function completeUpdate() public witnetRequestSolved(requestId) returns (Metadata memory) {
        Witnet.Result memory result = _witnetReadResult(requestId);

        if (witnet.isOk(result)) {
            string[] memory arr = witnet.asStringArray(result);
            Metadata memory arr2 = extractPoseMood(arr);
            return arr2;
        } else {
            // You can decide here what to do if the query failed
        }
    }

    function stake(uint256[] calldata tokenIds) external {
        uint256 tokenId;
        totalStaked += tokenIds.length;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            require(
                nft.ownerOf(tokenId) == msg.sender,
                "Se7en: This is not your token."
            );
            require(vault[tokenId].tokenId == 0, "Se7en: Token already staked");

            nft.transferFrom(msg.sender, address(this), tokenId);
            emit NFTStaked(msg.sender, tokenId, block.timestamp);

            vault[tokenId] = Stake({
                owner: msg.sender,
                tokenId: uint24(tokenId),
                timestamp: uint48(block.timestamp)
            });
        }
    }

    function _unstakeMany(address account, uint256[] calldata tokenIds)
        internal
    {
        uint256 tokenId;
        totalStaked -= tokenIds.length;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            Stake memory staked = vault[tokenId];
            require(staked.owner == msg.sender, "not an owner");

            delete vault[tokenId];
            emit NFTUnstaked(account, tokenId, block.timestamp);
            nft.transferFrom(address(this), account, tokenId);
        }
    }

    function claim(uint256[] calldata tokenIds) external {
        _claim(msg.sender, tokenIds, false);
    }

    function claimForAddress(address account, uint256[] calldata tokenIds)
        external
    {
        _claim(account, tokenIds, false);
    }

    function unstake(uint256[] calldata tokenIds) external {
        _claim(msg.sender, tokenIds, true);
    }

    // @Net2Dev - Follow me on Youtube , Tiktok, Instagram
    // TOKEN REWARDS CALCULATION
    // MAKE SURE YOU CHANGE THE VALUE ON BOTH CLAIM AND EARNINGINFO FUNCTIONS.
    // Find the following line and update accordingly based on how much you want
    // to reward users with ERC-20 reward tokens.
    // I hope you get the idea based on the example.
    // rewardmath = 100 ether .... (This gives 1 token per day per NFT staked to the staker)
    // rewardmath = 200 ether .... (This gives 2 tokens per day per NFT staked to the staker)
    // rewardmath = 500 ether .... (This gives 5 tokens per day per NFT staked to the staker)
    // rewardmath = 1000 ether .... (This gives 10 tokens per day per NFT staked to the staker)

    function _claim(
        address account,
        uint256[] calldata tokenIds,
        bool _unstake
    ) internal {
        uint256 tokenId;
        uint256 earned = 0;
        uint256 rewardmath = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            Stake memory staked = vault[tokenId];
            require(staked.owner == account, "not an owner");
            uint256 stakedAt = staked.timestamp;
            rewardmath = (100 ether * (block.timestamp - stakedAt)) / 86400;
            earned = rewardmath / 100;
            vault[tokenId] = Stake({
                owner: account,
                tokenId: uint24(tokenId),
                timestamp: uint48(block.timestamp)
            });
        }
        if (earned > 0) {
            token.mint(account, earned);
        }
        if (_unstake) {
            _unstakeMany(account, tokenIds);
        }
        emit Claimed(account, earned);
    }

    function earningInfo(address account, uint256[] calldata tokenIds)
        external
        view
        returns (uint256[1] memory info)
    {
        uint256 tokenId;
        uint256 earned = 0;
        uint256 rewardmath = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            Stake memory staked = vault[tokenId];
            require(staked.owner == account, "not an owner");
            uint256 stakedAt = staked.timestamp;
            rewardmath = (100 ether * (block.timestamp - stakedAt)) / 86400;
            earned = rewardmath / 100;
        }
        if (earned > 0) {
            return [earned];
        }
    }

    // should never be used inside of transaction because of gas fee
    function balanceOf(address account) public view returns (uint256) {
        uint256 balance = 0;
        uint256 supply = nft.totalSupply();
        for (uint256 i = 1; i <= supply; i++) {
            if (vault[i].owner == account) {
                balance += 1;
            }
        }
        return balance;
    }

    // should never be used inside of transaction because of gas fee
    function tokensOfOwner(address account)
        public
        view
        returns (uint256[] memory ownerTokens)
    {
        uint256 supply = nft.totalSupply();
        uint256[] memory tmp = new uint256[](supply);

        uint256 index = 0;
        for (uint256 tokenId = 1; tokenId <= supply; tokenId++) {
            if (vault[tokenId].owner == account) {
                tmp[index] = vault[tokenId].tokenId;
                index += 1;
            }
        }

        uint256[] memory tokens = new uint256[](index);
        for (uint256 i = 0; i < index; i++) {
            tokens[i] = tmp[i];
        }

        return tokens;
    }

    function onKIP17Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        require(from == address(0x0), "Cannot send nfts to Vault directly");
        return IKIP17Receiver.onKIP17Received.selector;
    }
}
