// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * Carbon Credit Coin (CCC)
 * Supply Total: 500 milhões
 * Compatível:
 * - Ethereum
 * - Polygon
 * - BNB Smart Chain
 */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CarbonCreditCoin is ERC20, Ownable {

    uint256 public constant MAX_SUPPLY =
        500_000_000 * 10 ** 18;

    bool public paused;

    mapping(address => bool) public blacklist;

    event TokensBurned(
        address indexed from,
        uint256 amount
    );

    event WalletBlacklisted(
        address indexed wallet,
        bool status
    );

    event ContractPaused(bool status);

    constructor(address initialOwner)
        ERC20("Carbon Credit Coin", "CCC")
        Ownable(initialOwner)
    {
        _mint(initialOwner, MAX_SUPPLY);
    }

    modifier notBlacklisted(address account) {
        require(
            !blacklist[account],
            "Wallet blacklisted"
        );
        _;
    }

    modifier whenNotPaused() {
        require(
            !paused,
            "Contract paused"
        );
        _;
    }

    function pauseContract()
        external
        onlyOwner
    {
        paused = true;
        emit ContractPaused(true);
    }

    function unpauseContract()
        external
        onlyOwner
    {
        paused = false;
        emit ContractPaused(false);
    }

    function blacklistWallet(
        address wallet,
        bool status
    )
        external
        onlyOwner
    {
        blacklist[wallet] = status;

        emit WalletBlacklisted(
            wallet,
            status
        );
    }

    function burn(
        uint256 amount
    ) external {

        _burn(msg.sender, amount);

        emit TokensBurned(
            msg.sender,
            amount
        );
    }

    function mint(
        address to,
        uint256 amount
    )
        external
        onlyOwner
    {
        require(
            totalSupply() + amount
                <= MAX_SUPPLY,
            "Max supply exceeded"
        );

        _mint(to, amount);
    }

    function _update(
        address from,
        address to,
        uint256 amount
    )
        internal
        override
        whenNotPaused
        notBlacklisted(from)
        notBlacklisted(to)
    {
        super._update(
            from,
            to,
            amount
        );
    }
}