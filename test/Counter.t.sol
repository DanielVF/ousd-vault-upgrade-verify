// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Counter.sol";
import "../src/IUSDT.sol";
import "../src/IVaultCore.sol";
import "../src/IVaultAdmin.sol";
import "../src/IOUSD.sol";
import "../src/IERC20.sol";
import "../src/IProxy.sol";

import "../src/MockOracle.sol";

import "forge-std/Test.sol";

contract CounterTest is Test {
    IERC20 public constant dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 public constant usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IUSDT public constant usdt = IUSDT(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address constant diaOracle = 0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9;
    address constant usdcOracle = 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6;
    address constant usdtOracle = 0x3E7d1eAB13ad0104d2750B8863b489D65364e32D;

    IOUSD public constant ousd = IOUSD(0x2A8e1E676Ec238d8A992307B495b45B3fEAa5e86);
    IVaultCore public constant vaultCore = IVaultCore(0xE75D77B1865Ae93c7eaa3040B038D7aA7BC02F70);
    IVaultAdmin public constant vaultAdmin = IVaultAdmin(0xE75D77B1865Ae93c7eaa3040B038D7aA7BC02F70);
    IProxy public constant vaultProxy = IProxy(0xE75D77B1865Ae93c7eaa3040B038D7aA7BC02F70);
    address timelock = 0x35918cDE7233F2dD33fA41ae3Cb6aE0e42E0e69F;

    address internal me = address(this);
    uint256 internal logCounter = 0;

    function testCurrent() public {
        _runWithOracleChanges();
    }

    function testNew() public {
        vm.startPrank(timelock);
        vaultProxy.upgradeTo(0x0adD23eCF2Ef9f4be557C52E75A5beDCdD070d34);
        vaultCore.setAdminImpl(0x8b39590a49569dD5489E4186b8DD43069d4Ef0cC);
        vaultAdmin.setPriceProvider(0xe7fD05515A51509Ca373a42E81ae63A40AA4384b);
        vaultAdmin.cacheDecimals(address(dai));
        vaultAdmin.cacheDecimals(address(usdc));
        vaultAdmin.cacheDecimals(address(usdt));
        vm.stopPrank();

        _runWithOracleChanges();
    }

    function _runWithOracleChanges() internal {
        logCounter = 1000;

        _runActionSet();

        _setPrice(diaOracle, 100400023);
        _runActionSet();
        _setPrice(usdcOracle, 99900045);
        _runActionSet();
        _setPrice(usdtOracle, 100056000);
        _runActionSet();
    }

    function _runActionSet() public {
        deal(address(dai), me, 100000 * 1e18);
        dai.approve(address(vaultCore), 100000 * 1e18);
        deal(address(usdt), me, 100000 * 1e6);
        usdt.approve(address(vaultCore), 0);
        usdt.approve(address(vaultCore), 100000 * 1e6);
        deal(address(usdc), me, 100000 * 1e6);
        usdc.approve(address(vaultCore), 100000 * 1e6);
        _logNumbers();

        // Mint
        vaultCore.mint(address(dai), 50000 * 1e18, 0);
        _logNumbers();
        vaultCore.mint(address(usdc), 50000 * 1e6, 0);
        _logNumbers();
        vaultCore.mint(address(usdt), 50000 * 1e6, 0);
        _logNumbers();

        // Rebase
        usdt.transfer(address(vaultCore), 10000 * 1e6);
        _logNumbers();
        vaultCore.rebase();
        _logNumbers();

        // Redeem
        vaultCore.mint(address(dai), 50000 * 1e18, 0);
        _logNumbers();
        usdc.transfer(address(vaultCore), 10000 * 1e6);
        _logNumbers();
        vaultCore.redeem(50000 * 1e18, 0);
        _logNumbers();
    }

    function _setPrice(address oracle, uint256 _price) internal {
        MockOracle oracleCode = new MockOracle();
        vm.etch(oracle, address(oracleCode).code);
        MockOracle(oracle).setAnswer(_price);
    }

    function _logNumbers() internal {
        console.log(logCounter, block.number, block.timestamp);
        console.log(logCounter, ousd.totalSupply(), vaultCore.totalValue());
        console.log(logCounter, dai.balanceOf(me), usdc.balanceOf(me), usdt.balanceOf(me));

        logCounter++;
    }
}
