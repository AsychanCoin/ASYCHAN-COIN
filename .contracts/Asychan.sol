// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

contract ASYCHAN is
    Initializable,
    ERC20Upgradeable,
    ERC20PermitUpgradeable,
    ERC20VotesUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable
{
    // =====================================================
    // ROLES
    // =====================================================

    bytes32 public constant PAUSER_ROLE =
        keccak256("PAUSER_ROLE");

    bytes32 public constant UPGRADER_ROLE =
        keccak256("UPGRADER_ROLE");

    // =====================================================
    // TOKENOMICS
    // =====================================================

    uint256 public constant CAP =
        1_000_000 ether;

    uint256 public constant ECOSYSTEM_ALLOCATION =
        300_000 ether;

    uint256 public constant COMMUNITY_ALLOCATION =
        250_000 ether;

    uint256 public constant LIQUIDITY_ALLOCATION =
        150_000 ether;

    uint256 public constant MARKETING_ALLOCATION =
        100_000 ether;

    uint256 public constant TEAM_ALLOCATION =
        100_000 ether;

    uint256 public constant TREASURY_ALLOCATION =
        100_000 ether;

    // =====================================================
    // EVENTS
    // =====================================================

    event InitialDistributionCompleted();

    error CapExceeded();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address admin,
        address ecosystemWallet,
        address communityWallet,
        address liquidityWallet,
        address marketingWallet,
        address teamVestingWallet,
        address treasuryWallet
    ) external initializer {

        require(admin != address(0), "admin");
        require(ecosystemWallet != address(0), "eco");
        require(communityWallet != address(0), "community");
        require(liquidityWallet != address(0), "liquidity");
        require(marketingWallet != address(0), "marketing");
        require(teamVestingWallet != address(0), "team");
        require(treasuryWallet != address(0), "treasury");

        __ERC20_init(
            "ASYCHAN",
            "ASN"
        );

        __ERC20Permit_init(
            "ASYCHAN"
        );

        __ERC20Votes_init();

        __AccessControl_init();

        __Pausable_init();

        _grantRole(
            DEFAULT_ADMIN_ROLE,
            msg.sender
        );

        _grantRole(
            UPGRADER_ROLE,
            msg.sender
        );

        _authorizeUpgrade(msg.sender);

        _grantRole(
            DEFAULT_ADMIN_ROLE,
            admin
        );

        _grantRole(
            PAUSER_ROLE,
            admin
        );

        _grantRole(
            UPGRADER_ROLE,
            admin
        );

        uint256 totalAllocation =
            ECOSYSTEM_ALLOCATION +
            COMMUNITY_ALLOCATION +
            LIQUIDITY_ALLOCATION +
            MARKETING_ALLOCATION +
            TEAM_ALLOCATION +
            TREASURY_ALLOCATION;

        require(
            totalAllocation == CAP,
            "distribution mismatch"
        );

        _mint(
            ecosystemWallet,
            ECOSYSTEM_ALLOCATION
        );

        _mint(
            communityWallet,
            COMMUNITY_ALLOCATION
        );

        _mint(
            liquidityWallet,
            LIQUIDITY_ALLOCATION
        );

        _mint(
            marketingWallet,
            MARKETING_ALLOCATION
        );

        _mint(
            teamVestingWallet,
            TEAM_ALLOCATION
        );

        _mint(
            treasuryWallet,
            TREASURY_ALLOCATION
        );

        emit InitialDistributionCompleted();
    }

    // =====================================================
    // ADMIN
    // =====================================================

    function pause()
        external
        onlyRole(PAUSER_ROLE)
    {
        _pause();
    }

    function unpause()
        external
        onlyRole(PAUSER_ROLE)
    {
        _unpause();
    }

    // =====================================================
    // USER
    // =====================================================

    function burn(
        uint256 amount
    ) external {
        _burn(
            msg.sender,
            amount
        );
    }

    // =====================================================
    // UUPS
    // =====================================================

    function _authorizeUpgrade(
        address newImplementation
    )
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}

    // =====================================================
    // ERC20 + VOTES
    // =====================================================

    function _update(
        address from,
        address to,
        uint256 value
    )
        internal
        override(
            ERC20Upgradeable,
            ERC20VotesUpgradeable
        )
        whenNotPaused
    {
        super._update(
            from,
            to,
            value
        );

        if (
            totalSupply() > CAP
        ) {
            revert CapExceeded();
        }
    }

    function nonces(
        address owner
    )
        public
        view
        override(ERC20PermitUpgradeable, NoncesUpgradeable)
        returns (uint256)
    {
        return super.nonces(owner);
    }

    // =====================================================
    // VIEW
    // =====================================================

    function cap()
        external
        pure
        returns (uint256)
    {
        return CAP;
    }

    // =====================================================
    // STORAGE GAP
    // =====================================================

    uint256[50] private __gap;
}
