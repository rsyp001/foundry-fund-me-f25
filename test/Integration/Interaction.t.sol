// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/Fundme.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithDrawFundMe} from "../../script/Interaction.s.sol";

// contract InteractionTest is Test {
//     FundMe fundMe;

//     address USER = makeAddr("user");
//     uint constant SEND_VALUE = 0.1 ether;
//     uint constant STARTING_BALANCE = 10 ether;
//     uint constant GAS_PRICE = 1;

//     function setUp() external {
//         DeployFundMe deploy = new DeployFundMe();
//         fundMe = deploy.run();
//         vm.deal(USER, STARTING_BALANCE);
//     }

//     function testUserCanFundInteractions() public {
//         FundFundMe fundFundMe = new FundFundMe();
//         // vm.prank(USER);
//         // vm.deal(USER, 1e18);
//         fundFundMe.fundFundMe(address(fundMe));

//         // address funder = fundMe.getFunder(0);
//         // assertEq(funder, USER);
//         WithDrawFundMe withdrawFundMe = new WithDrawFundMe();
//         withdrawFundMe.WithdrawFundMe(address(fundMe));
//         assert(address(fundMe).balance == 0);
//     }
// }

contract InteractionsTest is Test {
    FundMe public fundMe;
    DeployFundMe deployFundMe;
    address USER = makeAddr("user");
    uint constant SEND_VALUE = 0.1 ether;
    uint constant STARTING_BALANCE = 10 ether;
    uint constant GAS_PRICE = 1;

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteraction() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        WithDrawFundMe withdrawFundMe = new WithDrawFundMe();
        withdrawFundMe.WithdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
