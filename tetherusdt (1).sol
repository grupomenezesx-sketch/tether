// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Importando OpenZeppelin
import "@openzeppelin/contracts/token/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract USDT_Style is ERC20, Ownable {
    bool public paused;
    mapping(address => bool) public blacklisted;

    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10 ** 18; // 1 bilhão de tokens

    constructor() ERC20("Tether USD", "USDT") {
        Ownable(msg.sender);
        _mint(msg.sender, MAX_SUPPLY); // Supply total já distribuído no deploy
    }

    // Modificadores
    modifier notPaused() {
        require(!paused, "Contract is paused");
        _;
    }
    modifier notBlacklisted(address account) {
        require(!blacklisted[account], "Blacklisted");
        _;
    }

    // Funções de administração
    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }

    function blacklist(address account) external onlyOwner {
        blacklisted[account] = true;
    }

    function unblacklist(address account) external onlyOwner {
        blacklisted[account] = false;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "Max supply exceeded");
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    // Transferências
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override notPaused notBlacklisted(from) notBlacklisted(to) {
        super._beforeTokenTransfer(from, to, amount);
    }
}