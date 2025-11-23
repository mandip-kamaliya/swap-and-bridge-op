// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, Vm} from "forge-std/Test.sol";
import {Deployers} from "@uniswap/v4-core/test/utils/Deployers.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {PoolManager} from "v4-core/PoolManager.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Currency, CurrencyLibrary} from "v4-core/types/Currency.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";
import {SwapAndBridgeOptimismRouter, IL1StandardBridge} from "../src/SwapAndBridgeOptimismRouter.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {SwapParams, ModifyLiquidityParams} from "v4-core/types/PoolOperation.sol";

interface IOUTbToken {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function faucet() external;
}
contract TestSwapAndBridgeOptimismRouter is Test, Deployers {
    using CurrencyLibrary for Currency;
    using PoolIdLibrary for PoolKey;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    These are events from L1StandardBridge and CrossDomainMessenger
    //////////////////////////////////////////////////////////////*/

    event ETHDepositInitiated(
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes extraData
    );

    event ERC20DepositInitiated(
        address indexed l1Token,
        address indexed l2Token,
        address indexed from,
        address to,
        uint256 amount,
        bytes extraData
    );

    event ETHBridgeInitiated(
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes extraData
    );

    event ERC20BridgeInitiated(
        address indexed localToken,
        address indexed remoteToken,
        address indexed from,
        address to,
        uint256 amount,
        bytes extraData
    );

    event SentMessage(
        address indexed target,
        address sender,
        bytes message,
        uint256 messageNonce,
        uint256 gasLimit
    );

    event SentMessageExtension1(address indexed sender, uint256 value);
     uint256 sepoliaForkId = vm.createFork("https://sepolia.drpc.org");

    SwapAndBridgeOptimismRouter poolSwapAndBridgeOptimism;

    // OUTb = Optimism Useless Token Bridged (ETH Sepolia and OP Sepolia addresses)
    IOUTbToken OUTbL1Token =
        IOUTbToken(0x12608ff9dac79d8443F17A4d39D93317BAD026Aa);
    IOUTbToken OUTbL2Token =
        IOUTbToken(0x7c6b91D9Be155A6Db01f749217d76fF02A7227F2);

    // L1 Standard Bridge on ETH Sepolia
    IL1StandardBridge public constant l1StandardBridge =
        IL1StandardBridge(0xFBb0621E0B23b5478B630BD55a5f21f67730B0F1);

    // Cross Domain Messenger L2 Contract Address
    address public constant l2CrossDomainMessenger =
        0x4200000000000000000000000000000000000010;
}