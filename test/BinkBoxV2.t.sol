// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Vm.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/BindBox.sol";
import "../src/VRFv2Consumer.sol";

contract BindBoxTestV2 is Test {
    VRFv2Consumer public oracle;
    BindBox public token_bindBox;
    address jim;
   // uint256 forkId;

    function setUp() public {
        oracle = new VRFv2Consumer(6129);
        token_bindBox = new BindBox(0x6B9594F5A270A424D69b032A72a8698529CaE95c);
    }


    // 測項 1: 解盲前的URL
    function test_BeforeReveal() public  {
        uint256 forkId = vm.createFork(
            "https://eth-sepolia.g.alchemy.com/v2/DbEb9i79GXBoPu12o66beAkCtixxnaOg",
            4539868);
            
        vm.selectFork(forkId);
        jim = makeAddr("jim");
        vm.startPrank(jim);

        (bool success, ) = address(0xE581e635264134aaa890e163F69b78D7B468D2Ca)
            .call(abi.encodeWithSignature("totalSupply()"));
        
        require(success,"error");

        // (bytes4 selector, uint productAmount, bytes3 color) = decode(data);
        console.log();

        assertEq(block.number, 4539868);
        vm.stopPrank();
    }

    // function decode(bytes memory data) private pure returns(bytes4 selector, uint productAmount, bytes3 color) {
    //     assembly {
    //     // load 32 bytes into `selector` from `data` skipping the first 32 bytes
    //     selector := mload(add(data, 32))
    //     productAmount := mload(add(data, 64))
    //     color := mload(add(data, 96))
    //     }
    // }
}