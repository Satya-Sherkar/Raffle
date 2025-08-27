// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {console2} from "forge-std/console2.sol";
import {CodeConstants} from "script/HelperConfig.s.sol";

contract RaffleTest is Test, CodeConstants {
    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint32 callbackGasLimit;
    uint256 subscriptionId;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        callbackGasLimit = config.callbackGasLimit;
        subscriptionId = config.subscriptionId;
        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    function testRaffleStateInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
        // Another way to do the same
        // assert(uint256(raffle.getRaffleState()) == 0);
    }

    function testEntranceFeeCheck() public {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
        raffle.enterRaffle();
    }

    function testPlayersArrayUpdation() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);
    }

    function testEnteringRaffleEmitsEvent() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    function testEntryBanWhileCalculating() public {
        // Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        // Act / Assert
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    function testCheckUpKeepReturnsFalseIfNoBalance() public {
        // Arrange
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        // Act
        (bool upkeepNeeded,) = raffle.checkUpKeep("");

        // Assert
        assert(!upkeepNeeded);
    }

    function testCheckUpKeepReturnsFalseIfRaffleIsNotOpen() public {
        // Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        // Act
        (bool upKeepNeeded,) = raffle.checkUpKeep("");

        // Assert
        assert(!upKeepNeeded);
    }

    function testPerformUpKeepOnlyRunsIfCheckUpKeepIsTrue() public {
        // Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        // Act/Assert
        raffle.performUpkeep(""); // If this fails, the test will fail, if passed test will pass
    }

    function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
        // Arrange
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        Raffle.RaffleState rState = raffle.getRaffleState();

        // Act / Assert
        vm.expectRevert(
            abi.encodeWithSelector(Raffle.Raffle__UpkeepNotNeeded.selector, currentBalance, numPlayers, rState)
        );
        raffle.performUpkeep("");
    }

    modifier raffleEntredAndTimePassed() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    modifier skipFork() {
        if (block.chainid != LOCAL_CHAIN_ID) {
            return;
        }
        _;
    }

    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId() public raffleEntredAndTimePassed {
        // Act
        vm.recordLogs();
        raffle.performUpkeep(""); // emits requestId
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[0].topics[0];

        // Assert
        Raffle.RaffleState raffleState = raffle.getRaffleState();
        assert(uint256(requestId) > 0);
        assert(uint256(raffleState) == 1); // 0 = open, 1 = calculating
    }

    function testFulfillrandomWordsCanOnlyBeCalledAfterPerformUpKeep(uint256 randomRequestId)
        public
        skipFork
        raffleEntredAndTimePassed
    {
        // Arrange/Act/Assert
        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(randomRequestId, address(raffle));
    }

    // function testFulfillRandomWordsPicksAWinnerResetsAndSendMoney() public skipFork raffleEntredAndTimePassed {
    //     // Arrange
    //     uint256 additionalEntrants = 3;
    //     uint256 startingIndex = 1;
    //     address expectedWinner = address(1);

    //     for (uint256 i = startingIndex; i < startingIndex + additionalEntrants; i++) {
    //         address newPlayer = address(uint160(i));
    //         hoax(newPlayer, 1 ether);
    //         raffle.enterRaffle{value: entranceFee}();
    //     }

    //     uint256 startingTimestamp = raffle.getLastTimeStamp();
    //     uint256 winnerStartingBalance = expectedWinner.balance;

    //     // Act
    //     vm.recordLogs();
    //     raffle.performUpkeep(""); // emits requestId
    //     Vm.Log[] memory entries = vm.getRecordedLogs();
    //     bytes32 requestId = entries[0].topics[0];
    //     VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(uint256(requestId), address(raffle));

    //     // Assert
    //     address recentWinner = raffle.getRecentWinner();
    //     Raffle.RaffleState raffleState = raffle.getRaffleState();
    //     uint256 winnerBalance = recentWinner.balance;
    //     uint256 endingTimestamp = raffle.getLastTimeStamp();
    //     uint256 prize = entranceFee * (additionalEntrants + 1);

    //     assert(recentWinner == expectedWinner);
    //     assert(uint256(raffleState) == 0);
    //     assert(winnerBalance == winnerStartingBalance + prize);
    //     assert(endingTimestamp > startingTimestamp);
    // }
}
