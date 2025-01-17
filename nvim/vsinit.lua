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
