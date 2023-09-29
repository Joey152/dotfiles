local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("n", "<leader>f", function() end, { desc = "File"})
vim.keymap.set("n", "<leader>fx", vim.cmd.Ex, { desc = "Back to explorer"})

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-d>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", "\"_dP")

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

require("lazy").setup({
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme kanagawa]])
        end,
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.3",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Open file" })
            vim.keymap.set("n", "<leader>fs", function()
                builtin.grep_string({ search = vim.fn.input("Grep > ") })
            end, { desc = "Open file by search term" })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            "javascript",
            "typescript",
            "json",
            "lua",
            "zig",
        },
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")
            lspconfig.zls.setup {
                cmd = { "zls" },
            }

            lspconfig.tsserver.setup {
                cmd = {
                    "npx",
                    "typescript-language-server",
                    "--stdio",
                },
                filetypes = {
                    "javascript",
                    "typescript",
                },
            }

            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = "Goto declaration" })
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Goto definition" })
        end,
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 200
        end,
        opts = {
        }
    }
}, {
    ui = {
        custom_keys = {
            -- { "<leader>m", "", desc = "hello" },
            -- { "<leader>mm", function() vim.cd.Ex end, desc = "Back to explorer" },
          -- open a terminal for the plugin dir
          ["<localleader>t"] = function(plugin)
            require("lazy.util").float_term(nil, {
              cwd = plugin.dir,
            })
          end,
        },
    },
})

