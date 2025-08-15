// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/Fundme.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint constant SEND_VALUE = 0.1 ether;
    uint constant STARTING_BALANCE = 10 ether;
    uint constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);

        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function testMINIMUMUSDISFIVE() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testownerisMsgSenders() public view {
        console.log(msg.sender);
        console.log(fundMe.i_owner());
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testGetVersionIsAccurate() public {
        uint version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testPriceFeedVersionIsAccurate() public {
        if (block.chainid == 11155111) {
            uint version = fundMe.getVersion();
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            uint version = fundMe.getVersion();
            assertEq(version, 6);
        }
    }

    function testFundFailwithoutEnoughETH() public {
        vm.expectRevert(); //the next line should revert
        fundMe.fund();
    }

    function testFundUpdateFundedDataStructure() public {
        vm.prank(USER); //the next tx will be sent by USER
        fundMe.fund{value: SEND_VALUE}();

        uint AmountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(AmountFunded, SEND_VALUE);
    }

    function testAddsFundertoArrayOfFunders() public {
        vm.prank(USER); //the next tx will be sent by USER
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER); //the next tx will be sent by USER
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER); //the next tx will be sent by USER
        vm.expectRevert(); //the next line should revert
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        //1-arrange
        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;
        //2-act
        // vm.txGasPrice(GAS_PRICE);
        // uint gasStart = gasleft();

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        // uint gasEnd = gasleft();
        // uint gasUsed = (gasStart - gasEnd);

        //3-assert
        uint endingFundMeBalance = address(fundMe).balance;
        uint endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
    }

    function testWithDrawFromMultipleAccounts() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}(); //hoax is a helper function that creates a transaction from a specific address with a specific value
        }

        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // uint endingFundMeBalance = address(fundMe).balance;
        // uint endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(address(fundMe).balance, 0);
        assertEq(
            fundMe.getOwner().balance,
            startingOwnerBalance + startingFundMeBalance
        );
        // assert(
        //     (numberOfFunders + 1) * SEND_VALUE ==
        //         fundMe.getOwner().balance - startingOwnerBalance
        // );
    }

    function testWithDrawFromMultipleAccountCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = 1; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}(); //hoax is a helper function that creates a transaction from a specific address with a specific value
        }

        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // uint endingFundMeBalance = address(fundMe).balance;
        // uint endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(address(fundMe).balance, 0);
        assertEq(
            fundMe.getOwner().balance,
            startingOwnerBalance + startingFundMeBalance
        );
    }
}
