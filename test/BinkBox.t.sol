// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Vm.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/BindBox.sol";
import "../src/VRFv2Consumer.sol";
import "lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract BindBoxTest is Test {
    address public BindBox;
    address jim;
    string constant public blockUrl = "https://ipfs.io/ipfs/QmXvVFaHw3SVp6s2PE19mU8nRf1M9maAPxuADAaETM2fEJ/box.json";
    string constant public baseUri = "https://ipfs.io/ipfs/QmXvVFaHw3SVp6s2PE19mU8nRf1M9maAPxuADAaETM2fEJ/ppu";

    function setUp() public {
        BindBox = 0xE581e635264134aaa890e163F69b78D7B468D2Ca;
    }


    // 測項 1: 解盲前的URL
    function test_BeforeReveal() public  {
        uint256 forkId = vm.createFork(
            "https://eth-sepolia.g.alchemy.com/v2/DbEb9i79GXBoPu12o66beAkCtixxnaOg",
            4539868);
            
        vm.selectFork(forkId);
        jim = makeAddr("jim");
        vm.startPrank(jim);

        address(BindBox).call(abi.encodeWithSignature("setReveal(bool)",false));
        ( ,bytes memory data) = address(BindBox)
            .call(abi.encodeWithSignature("mint()"));

        uint tokenId = abi.decode(data, (uint));

        ( ,bytes memory encodeUri) = address(BindBox)
            .call(abi.encodeWithSignature("tokenURI(uint256)",tokenId));

        string memory uri = abi.decode(encodeUri, (string));

        assertEq(block.number, 4539868);
        assertEq(uri, blockUrl);
        vm.stopPrank();
    }

    // 測項 2: 解盲後的URL
    function test_AfterReveal() public  {
        uint256 forkId = vm.createFork(
            "https://eth-sepolia.g.alchemy.com/v2/DbEb9i79GXBoPu12o66beAkCtixxnaOg",
            4539868);
            
        vm.selectFork(forkId);
        jim = makeAddr("jim");
        vm.startPrank(jim);

        ( ,bytes memory data) = address(BindBox)
            .call(abi.encodeWithSignature("mint()"));

        uint tokenId = abi.decode(data, (uint));

        ( ,bytes memory encodeUri) = address(BindBox)
            .call(abi.encodeWithSignature("tokenURI(uint256)",tokenId));

        string memory uri = abi.decode(encodeUri, (string));

        assertEq(block.number, 4539868);
        assertEq(uri, string(abi.encodePacked(baseUri, Strings.toString(tokenId),".json")));
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