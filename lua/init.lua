local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
	vim.cmd [[packadd packer.nvim]]
end

vim.cmd([[
	augroup packer_user_config
		autocmd!
		autocmd BufWritePost init.lua source <afile> | PackerCompile
	augroup end
]])

require('packer').startup(function()
	use 'wbthomason/packer.nvim' -- Package manager
	use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
	use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
	use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
	use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
	use 'L3MON4D3/LuaSnip' -- Snippets plugin
	use 'ellisonleao/gruvbox.nvim' -- Colorscheme
	use {
		'lewis6991/gitsigns.nvim', -- Git decorations
		requires = {
			'nvim-lua/plenary.nvim'
		},
		-- tag = 'release' -- To use the latest release
	}

	if packer_bootstrap then require('packer').sync() end
end)

-- Options
vim.opt.cursorline = true
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
-- Options: tab character and indent. See :h 'ts'
vim.opt.expandtab = false
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 0
vim.opt.tabstop = 2
-- Options: scroll
vim.opt.scrolloff = 0
vim.opt.sidescroll = 8
vim.opt.sidescrolloff = 0
vim.opt.wrap = false
-- Keymaps
vim.api.nvim_set_keymap('n', '<Tab>', '<C-W>', { noremap = true })
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-N>', { noremap = true })

if packer_bootstrap then return end

-- Diagnostic keymaps
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- LSP settings
local on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>. Do NOT use when using nvim-cmp!
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'gopls' }
for _, lsp in ipairs(servers) do
	require('lspconfig')[lsp].setup{
		on_attach = on_attach,
		capabilities = capabilities,
	}
end

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
vim.opt.completeopt = "menu,menuone,noselect"
local cmp = require 'cmp'
cmp.setup {
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end,
	},
	mapping = {
		['<C-p>'] = cmp.mapping.select_prev_item(),
		['<C-n>'] = cmp.mapping.select_next_item(),
		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.close(),
		['<CR>'] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		},
		['<Tab>'] = function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end,
		['<S-Tab>'] = function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end,
	},
	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	},
}

vim.opt.background = "dark"
vim.cmd([[colorscheme gruvbox]])

require('gitsigns').setup {
	on_attach = function(bufnr)
		local function map(mode, lhs, rhs, opts)
			opts = vim.tbl_extend('force', {noremap = true, silent = true}, opts or {})
			vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
		end

		-- Navigation
		map('n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", {expr=true})
		map('n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", {expr=true})

		-- Actions
		map('n', '<leader>hs', ':Gitsigns stage_hunk<CR>')
		map('v', '<leader>hs', ':Gitsigns stage_hunk<CR>')
		map('n', '<leader>hr', ':Gitsigns reset_hunk<CR>')
		map('v', '<leader>hr', ':Gitsigns reset_hunk<CR>')
		map('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<CR>')
		map('n', '<leader>hu', '<cmd>Gitsigns undo_stage_hunk<CR>')
		map('n', '<leader>hR', '<cmd>Gitsigns reset_buffer<CR>')
		map('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<CR>')
		map('n', '<leader>hb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
		map('n', '<leader>tb', '<cmd>Gitsigns toggle_current_line_blame<CR>')
		map('n', '<leader>hd', '<cmd>Gitsigns diffthis<CR>')
		map('n', '<leader>hD', '<cmd>lua require"gitsigns".diffthis("~")<CR>')
		map('n', '<leader>td', '<cmd>Gitsigns toggle_deleted<CR>')

		-- Text object
		map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
		map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
	end
}
