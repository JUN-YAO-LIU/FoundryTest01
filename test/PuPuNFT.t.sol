// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Vm.sol";
import "forge-std/Test.sol";
import "../src/PuPuNFT.sol";

contract PuPuNFTTest is Test {
    NoUseFul public token_NoUse;
    PuPuERC721 public token_PuPu;
    ReturnPuPuERC721 public token_ReturnPuPu;
    address jim;
    address bob;


    // 初始化，每執行一次測試都會重新setUp一次。
    // 需要test開頭，他是用這樣來判斷要不要測試。
    function setUp() public {
        token_PuPu = new PuPuERC721();
        token_ReturnPuPu = new ReturnPuPuERC721(address(token_PuPu));
    }


    // 測項 1: 原始的 sender(Jim) 可以收到原本的 token + NONFT token
    function test_TransferNoUseNftAndGetPuPu() public  {
        jim = makeAddr("jim");
        vm.startPrank(jim);

        token_NoUse = new NoUseFul();
        token_NoUse.safeTransferFrom(jim,address(token_ReturnPuPu),1,"0x");

        assertEq(token_PuPu.ownerOf(0), jim);
        assertEq(token_NoUse.ownerOf(1), jim);
        vm.stopPrank();
    }
}