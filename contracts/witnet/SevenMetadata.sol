// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

// For the Witnet Request Board OVM-compatible (Optimism) "trustable" implementation (e.g. BOBA network),
// replace the next import line with:
// import "witnet-solidity-bridge/contracts/impls/trustable/WitnetRequestBoardTrustableBoba.sol";
import "witnet-solidity-bridge/contracts/impls/trustable/WitnetRequestBoardTrustableDefault.sol";
import "witnet-solidity-bridge/contracts/requests/WitnetRequestInitializableBase.sol";

// The bytecode of the SevenMetadata query that will be sent to Witnet
contract SevenMetadataRequest is WitnetRequestInitializableBase {
  function initialize() public {
    WitnetRequestInitializableBase.initialize(hex"0a9701127f0801122968747470733a2f2f736576656e2d646174612e62792d73796c2e636f6d2f6a736f6e2f312e6a736f6e1a508418778218616a617474726962757465738211828218676a74726169745f74797065831875a26a534537454e204d6f6f64f56e5369676e617475726520706f7365f5f482181a818218676576616c75651a090a050808120180100222090a0508081201801002180220002833308094ebdc03");
  }
}

