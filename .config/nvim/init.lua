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

-- move visual lines up/down
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")

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
            vim.keymap.set("n", "<leader>ff", function()
                builtin.find_files({ no_ignore_parent = true })
            end, { desc = "Open file" })
            vim.keymap.set("n", "<leader>fa", function()
                builtin.find_files({ no_ignore_parent = true, hidden = true })
            end, { desc = "Open file (ignore .gitignore)" })
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
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",

            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/nvim-cmp",

            "L3MON4D3/LuaSnip",
            "rafamadriz/friendly-snippets",

            "lunarmodules/Penlight",
        },
        config = function()
            require("mason").setup()

            local tablex = require("pl.tablex")
            local mason_lspconfig = require("mason-lspconfig");
            local lsp = require("lspconfig")

            mason_lspconfig.setup {
                ensure_installed = {
                    "tsserver",
                    "quick_lint_js",
                }
            }

            local cmp = require("cmp")
            cmp.setup {
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<C-CR>'] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }, {
                    { name = "buffer" },
                })
            }


            local capabilities = require("cmp_nvim_lsp")
                .default_capabilities(vim.lsp.protocol.make_client_capabilities())

            local on_attach = function(client, bufnr)
                local opts_buffer = { noremap = true, silent = true, buffer = bufnr }
                vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts_buffer, { desc = "Goto type definition" })
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = "Goto declaration" })
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Goto definition" })
            end

            local default_mason_opts = {
                capabilities = capabilities,
                on_attach = on_attach,
                root_dir = lsp.util.root_pattern(".git")
            }

            mason_lspconfig.setup_handlers({
                function(server_name)
                    lsp[server_name].setup(default_mason_opts)
                end,
                ["tsserver"] = function()
                    lsp.tsserver.setup(tablex.merge(default_mason_opts, {
                        cmd = { "/home/joey/.local/share/nvim/mason/bin/typescript-language-server", "--stdio", "--log-level", "4" },
                        settings = {
                            implicitProjectConfiguration = {
                                checkJs = true,
                            },
                        },
                    }, true))
                end
            })

            lsp.zls.setup {
                cmd = { "zls" },
            }

        end,
    },
    {
        "mbbill/undotree",
        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Undo tree" })
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

