-- Transparent GPG file editing
-- Opens .gpg / .pgp / .asc files decrypted, encrypts on save.
-- Uses gpg-agent + your YubiKey (no passphrase prompt if cached).
return {
  {
    "jamessan/vim-gnupg",
    -- Eager load: vim-gnupg installs BufReadCmd autocmds at startup. Lazy-loading
    -- on BufReadPre is too late — the buffer read has already started by then,
    -- so nvim shows raw ciphertext instead of decrypting.
    lazy = false,
    init = function()
      -- Use ASCII-armored output by default (text-friendly diffs, etc).
      vim.g.GPGPreferArmor = 1

      -- Use symmetric encryption when no recipients are set? No — prefer asymmetric.
      vim.g.GPGPreferSymmetric = 0

      -- Sign new files automatically.
      vim.g.GPGPreferSign = 0

      -- Default recipients (leave empty to be prompted; fill in your key id/email
      -- here if you want every new GPG file encrypted to you by default).
      -- vim.g.GPGDefaultRecipients = { "ai-cora@failmode.com" }

      -- Use gpg2 explicitly (Homebrew installs as `gpg`, but be safe).
      vim.g.GPGExecutable = "gpg --trust-model always"

      -- Don't shell out for `which` checks at startup.
      vim.g.GPGUseAgent = 1
    end,
  },
}
