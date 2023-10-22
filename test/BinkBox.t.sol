// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Vm.sol";
import "forge-std/Test.sol";
import "../src/BindBox.sol";
import "../src/VRFv2Consumer.sol";

contract BindBoxTest is Test {
    VRFv2Consumer public oracle;
    BindBox public token_bindBox;
    address jim;
   // uint256 forkId;

    function setUp() public {
        oracle = new VRFv2Consumer(6129);
        token_bindBox = new BindBox(address(oracle));
    }


    // 測項 1: 解盲前的URL
    function test_BeforeReveal() public  {
        token_bindBox.setReveal(false);
        assertEq(token_bindBox.tokenURI(0), "https://ipfs.io/ipfs/QmXvVFaHw3SVp6s2PE19mU8nRf1M9maAPxuADAaETM2fEJ/box.json");
    }

    // 測項 2: 解盲後的URL
    function test_AfterReveal() public  {
        token_bindBox.setReveal(true);
        assertEq(token_bindBox.tokenURI(1), "https://ipfs.io/ipfs/QmXvVFaHw3SVp6s2PE19mU8nRf1M9maAPxuADAaETM2fEJ/ppu1.json");
    }
}