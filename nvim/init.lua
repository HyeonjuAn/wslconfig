-- Basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.updatetime = 50
vim.opt.clipboard:append('unnamedplus')

vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 300
        })
    end
})

-- Key mappings (keeping the most useful ones)
vim.g.mapleader = ' '
local keymap = vim.keymap

-- Essential mappings from your config
keymap.set('n', '<leader>w', '<cmd>w<cr>')
keymap.set('n', '<leader>q', '<cmd>q<cr>')
keymap.set('n', 'H', '^')
keymap.set('n', 'L', '$')
keymap.set('n', '<C-d>', '<C-d>zz')
keymap.set('n', '<C-u>', '<C-u>zz')
keymap.set('n', '<c-e>', '<cmd>NvimTreeToggle<cr>')
keymap.set('n', '<c-a>', 'gg<S-v>G')
keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { silent = true })
keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { silent = true })
keymap.set('n', '<leader>s', ':vsplit<Return><C-w>w', { silent = true })
keymap.set('n', 'f', '<C-w>w')
keymap.set('n', 'Q', '<nop>')
keymap.set('n', 'n', 'nzzzv')
keymap.set('n', 'N', 'Nzzzv')
keymap.set('n', '<C-v>', '<C-v>', { noremap = true }) -- Force CTRL-v to do visual block

require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    use 'nvim-lua/plenary.nvim'

    use {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' }
    }

    use({
        'akinsho/toggleterm.nvim',
        tag = '*'
    })

    use {
        'nvim-tree/nvim-tree.lua',
    }


    -- lsp
    use { 'williamboman/mason.nvim' }
    use { 'williamboman/mason-lspconfig.nvim' }
    use({ 'neovim/nvim-lspconfig' })
    use({ 'hrsh7th/nvim-cmp' })
    use({ 'hrsh7th/cmp-nvim-lsp' })

    -- treesitter
    use 'nvim-treesitter/nvim-treesitter'


    if packer_bootstrap then
        require('packer').sync()
    end
end)

-- telescope
local builtin = require('telescope.builtin')
local actions = require('telescope.actions')
keymap.set('n', '<leader>f', builtin.find_files, {})
keymap.set('n', '<leader>g', builtin.live_grep, {})
require('telescope').setup {
    defaults = {
        path_display = { 'smart' },
        mappings = {
            i = {
                ["<esc>"] = actions.close
            }
        }
    },
    layout_config = {
        horizontal = {
            preview_cutoff = 100,
            preview_width = 0.6
        }
    }
}

-- toggleterm setup
require('toggleterm').setup({
    direction = 'float',
    shell = 'powershell.exe',
    open_mapping = [[<C-\>]]
})

-- nvimtree setup
require('nvim-tree').setup({
    renderer = {
        icons = {
            show = {
                file = false,
                folder = true,
                folder_arrow = false,
                git = false,
            },
        },
    },
    actions = {
        open_file = {
            quit_on_open = true
        }
    },
    view = {
        width = 30,
    },
    filters = {
        dotfiles = false
    },
})

-- lsp setup
-- Add cmp_nvim_lsp capabilities settings to lspconfig
-- This should be executed before you configure any language server
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
    'force',
    lspconfig_defaults.capabilities,
    require('cmp_nvim_lsp').default_capabilities()
)

-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
        vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
        vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
        vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
        vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
    end,
})

require 'lspconfig'.lua_ls.setup {}
require 'lspconfig'.ts_ls.setup {}
require 'lspconfig'.pyright.setup {}
-- require'lspconfig'.csharp_ls.setup{}

local cmp = require('cmp')

cmp.setup({
    sources = {
        { name = 'nvim_lsp' },
    },
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
})

require('mason').setup({})
require('mason-lspconfig').setup({
    -- Replace the language servers listed here
    -- with the ones you want to install
    ensure_installed = { 'lua_ls', 'rust_analyzer', 'ts_ls', 'pyright' },
    handlers = {
        function(server_name)
            require('lspconfig')[server_name].setup({})
        end,
    }
})

local buffer_autoformat = function(bufnr)
    local group = 'lsp_autoformat'
    vim.api.nvim_create_augroup(group, { clear = false })
    vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })

    vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = bufnr,
        group = group,
        desc = 'LSP format on save',
        callback = function()
            -- note: do not enable async formatting
            vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
        end,
    })
end

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local id = vim.tbl_get(event, 'data', 'client_id')
        local client = id and vim.lsp.get_client_by_id(id)
        if client == nil then
            return
        end

        -- make sure there is at least one client with formatting capabilities
        if client.supports_method('textDocument/formatting') then
            buffer_autoformat(event.buf)
        end
    end
})

-- treesitter
require 'nvim-treesitter.configs'.setup {
    ensure_installed = { "c", "lua", "typescript", "javascript", "markdown", "python", "rust" },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,

    ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
    -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

    highlight = {
        enable = true,
    }
}
