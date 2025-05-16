# simple-sqlfluff.nvim
A dead-simple batteries-included sqlfluff linter for Neovim.

# 📎 Requirements
- Tested on Neovim 0.11.0.
- [sqlfluff](https://docs.sqlfluff.com/en/stable/index.html) (Tested on v3.4.0)

# 💾 Installation
## Lazy
```lua
{
    "michhernand/simple-sqlfluff.nvim",
    keys = {
        { "<leader>Sf", "<cmd>SQLFluffFormat<CR>", desc = "Format w/ SQLFluff" }
    }
	opts = {}
}
```

## Packer
```lua
use {
    "michhernand/simple-sqlfluff.nvim",
    config = function()
        require("simple-sqlfluff").setup{}
    end,
    keys = function()
        vim.keymap.set("n", "<leader>Sf", "<cmd>SQLFluffFormat<CR>", { desc = "Format w/ SQLFluff" })
    end
}
```

# ⚙️ Configuration
For configuring sqlfluff, use one of [sqlfluff's configuration file formats](https://docs.sqlfluff.com/en/stable/configuration/setting_configuration.html#configuration-files).

# 🖥️ Usage

![Demo1](./repo/gifs/simple-sqlfluff-demo1.gif)

Simply open a `.sql` file and start editing!

Use your preferred method to review linting errors.

*[Trouble](https://github.com/folke/trouble.nvim) (shown in the GIF) provides an excellent interface for reviewing linting (and other) errors.*
