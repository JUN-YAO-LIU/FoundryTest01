// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Vm.sol";
import "forge-std/Test.sol";
import "../src/wETH.sol";

contract WrappedETHTest is Test {
    WrappedETH public token;
    address jim;
    address bob;


    // 初始化，每執行一次測試都會重新setUp一次。
    // 需要test開頭，他是用這樣來判斷要不要測試。
    function setUp() public {
       token = new WrappedETH();
       jim = makeAddr("jim");
       bob = makeAddr("bob");
       vm.deal(bob, 1 ether);
    }

    function test_wETHName() public {
        assertEq(token.name(), "Wrapped ETH");
    }

    // 測項 1: deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user
    function test_Deposite() public  {
        vm.startPrank(jim);
        vm.deal(jim, 1 ether);

        console.log(jim.balance);
        token.wrappedETH{value:50001}();
        console.log(jim.balance);
        console.log("Supply",token.totalSupply());

        vm.stopPrank();
        assertEq(token.balanceOf(jim), 50001);
    }

    // 測項 2: deposit 應該將 msg.value 的 ether 轉入合約
    function test_DepositeETH(uint256 amount) public  {
        vm.startPrank(jim);
        vm.deal(jim, amount);

        console.log("Jim Balance",jim.balance);
        console.log("ETH Balance",address(token).balance);
        token.wrappedETH{value:amount}();
        console.log("Jim Balance",jim.balance);
        console.log("ETH Balance",address(token).balance);

        vm.stopPrank();
        assertEq(address(token).balance, amount);
    }

    // 測項 3: deposit 應該要 emit Deposit event
    event  Deposit(address indexed dst, uint wad);
    function test_DepositEvent(uint256 amount) public {
        
        vm.startPrank(jim);
        vm.deal(jim, amount);

        vm.expectEmit(true, true, false, false);
        emit Deposit(jim, amount);

        token.wrappedETH{value:amount}();
        vm.stopPrank();
    }

    // 測項 4: withdraw 應該要 burn 掉與 input parameters 一樣的 erc20 token
    function test_UnwrappedETH() public {
        vm.startPrank(jim);
        vm.deal(jim, 10);
        
        token.wrappedETH{value:10}();
        uint256 beforeWithdrawl = token.totalSupply();
        console.log("beforeWithdrawl",beforeWithdrawl);

        token.unwrappedETH(3);

        uint256 afterithdrawl = token.totalSupply();
        console.log("afterithdrawl",afterithdrawl);

        vm.stopPrank();

        assertEq(beforeWithdrawl - afterithdrawl, 3);
    }

    // 測項 5: withdraw 應該將 burn 掉的 erc20 換成 ether 轉給 user
    function test_UnwrappedETHAndTransferToUser() public {
        vm.startPrank(jim);
        vm.deal(jim, 10);
        
        console.log("Jim before",jim.balance);
        token.wrappedETH{value:10}();
        console.log("Jim after",jim.balance);
        
        token.unwrappedETH(3);

        console.log("Jim withdrawl",jim.balance);

        vm.stopPrank();

        assertEq(jim.balance, 3);
    }

     // 測項 6: withdraw 應該要 emit Withdraw event
    event  Withdrawal(address indexed src, uint wad);
    function test_WithdrawEvent(uint _amount) public {
        vm.startPrank(jim);
        vm.deal(jim, _amount);
        
        token.wrappedETH{value:_amount}();

        vm.expectEmit(true, true, false, false);
        emit Withdrawal(jim, _amount);

        token.unwrappedETH(_amount);

        vm.stopPrank();
    }

    // 測項 7: transfer 應該要將 erc20 token 轉給別人
    function test_TransferToOther(uint _amount) public {
        vm.startPrank(jim);
        vm.deal(jim, _amount);
        
        token.wrappedETH{value:_amount}();

        token.transfer(bob, _amount);

        vm.stopPrank();

        assertEq(token.balanceOf(bob), _amount);
        assertEq(token.balanceOf(jim), 0);
    }


    // 測項 8: approve 應該要給他人 allowance
    function test_Allowance(uint _amount) public {
        vm.startPrank(jim);
        vm.deal(jim, _amount);
        
        token.wrappedETH{value:_amount}();

        token.approve(bob, _amount);

        vm.stopPrank();

        assertEq(token.allowance(jim,bob), _amount);
    }


    // 測項 9: transferFrom 應該要可以使用他人的 allowance
    function test_TransferFrom() public {
        vm.startPrank(jim);
        vm.deal(jim, 10);
        
        console.log("Jim's ETH amount",jim.balance);
        token.wrappedETH{value:10}();
        console.log("Jim's wETH amount",token.balanceOf(jim));

        token.approve(bob, 1);
        console.log("allowance wETH amount",token.allowance(jim,bob));
        vm.stopPrank();

        console.log("Bob's wETH amount",token.balanceOf(bob));
        vm.prank(bob);
        token.transferFrom(jim,bob, 1);
        console.log("Bob's wETH amount",token.balanceOf(bob));

        assertEq(token.balanceOf(bob), 1);
    }


    // 測項 10: transferFrom 後應該要減除用完的 allowance
    function test_AfterTransferFrom() public {
        vm.startPrank(jim);
        vm.deal(jim, 10);
        
        console.log("Jim's ETH amount",jim.balance);
        token.wrappedETH{value:10}();
        console.log("Jim's wETH amount",token.balanceOf(jim));

        token.approve(bob, 3);
        console.log("allowance wETH amount",token.allowance(jim,bob));
        vm.stopPrank();

        console.log("Bob's wETH amount",token.balanceOf(bob));
        vm.prank(bob);
        token.transferFrom(jim,bob, 1);
        console.log("Bob's wETH amount",token.balanceOf(bob));
        uint256 afterTransfer = token.allowance(jim,bob);
        console.log("afterTransfer",afterTransfer);

        assertEq(afterTransfer, 2);
    }
}