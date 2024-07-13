--[[

=====================================================================
==================== WELCOME TO MY NEOVIM CONFIG ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||      XY6.NVIM      ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:!sudo rm -rf /     ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

--]]

require("basicConfig")
require("neovide")

-- zen-mode config
-- fix: neotree 退出或进入文件会导致退出zen-mode
-- 解决方法是在非手动退出时立刻自动重新进入zen-mode
-- F11 toggle zen-mode 时设置 is_zen_manual_exit = true
-- 之后会执行 on_open 或 on_close，on_open 则设置回false，on_close 则检测是否为true，否则立刻重新进入zen-mode
local is_zen_manual_exit = false

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
 print("Lazy installed, now restart nvim.")
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath) -- enable require('lazy')

-- See `:help lazy.nvim`
require('lazy').setup({
  {
    -- 'catppuccin/nvim', -- download url
    -- name = 'catppuccin', -- name in lazy
    "ellisonleao/gruvbox.nvim",
    name = 'gruvbox',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      -- Load the colorscheme here.
      vim.cmd.colorscheme 'gruvbox'
      -- You can configure highlights by doing something like:
      vim.cmd.hi 'Comment gui=none'
      vim.api.nvim_set_hl(0, 'GruvboxGreen', { fg = '#ffcc99' })
      vim.api.nvim_set_hl(0, 'GruvboxGreenBold', { fg = '#ffcc99', bold = true })
      -- vim.api.nvim_set_hl(0, 'GruvboxAqua', { fg = '#ffcc99' })
      vim.api.nvim_set_hl(0, 'SignColumn', { fg = '#ffcc99' })
      vim.api.nvim_set_hl(0, 'FoldColumn', { fg = '#ffcc99' })
    end,
  },
  {
    'numToStr/Comment.nvim',
    opts = {},
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    'NvChad/nvim-colorizer.lua',
    opts = {},
  },
  {
    "petertriho/nvim-scrollbar",
    opts = {},
  },
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    -- See `:help gitsigns` to understand what the configuration keys do
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },
    },
    config = function (_, opts)
      require('gitsigns').setup(opts)
      local function diffthis()
        require('gitsigns').diffthis('', { split = 'belowright' })
      end
      vim.keymap.set('n', 'dif', diffthis, { desc = 'git show diff' })
    end
  },
  {
    "hrsh7th/nvim-cmp",
    -- event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-buffer",
    },
    config = function()
      vim.o.completeopt = '' -- Do not show the native completion menu?
	    local cmp = require 'cmp'
	    cmp.setup {
        completion = { completeopt = 'menu,menuone,noinsert' }, -- TODO: 怎样只选择但不插入文本?
        -- mapping = cmp.mapping.preset.insert(),  -- looks like the preset is the same?
        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<CR>'] = cmp.mapping.confirm { select = true },
        },
        sources = {
          {name = 'nvim_lsp'},
          {name = 'path'},
          {name = 'buffer'},
        }
      }
      -- Completion with command
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          {name = 'buffer'}
        }
      })
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          {name = 'path'},
          {name = 'cmdline'},
        }
      })
    end
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    -- Optional dependency
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      require('nvim-autopairs').setup {}
      -- If you want to automatically add `(` after selecting a function or method
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      local cmp = require 'cmp'
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done()) -- yes, it works
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true }, -- mason  NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim', -- Config with mason
      'WhoIsSethDaniel/mason-tool-installer.nvim', -- Auto install and update with mason
      { 'j-hui/fidget.nvim', opts = {} }, -- Shows a small floating window for LSP status
      { 'folke/neodev.nvim', opts = {} }, -- Used for lua config files (with support such as 'vim')
    },

    config = function()

      --    This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
     vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('xy6-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map('<C-k>', vim.lsp.buf.hover, 'Hover Documentation')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup('xy6-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('xy6-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'xy6-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following autocommand is used to enable inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      --  LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable the following language servers
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        clangd = {},
        pyright = {},
        -- gopls = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`tsserver`) will work just fine
        tsserver = {},
        html = {},
        cssls = {},
        emmet_ls = {},
        tailwindcss = {},
        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }
      local ensure_installed_list = vim.tbl_keys(servers or {})
      require('mason-tool-installer').setup { ensure_installed = ensure_installed_list }
      require('mason-lspconfig').setup {
        -- handler: handler functions table
        handlers = {
          -- default handler function for lsp servers not specified in a particular key
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            -- server.root_dir = function() -- (可传入参数 fname)
            --   -- root_dir 设置为当前工作目录
            --   print("Working directory:", vim.loop.cwd())
            --   return vim.loop.cwd()
            -- end
            require("lspconfig")[server_name].setup(server)
          end
        }
      }
      -- require('lspconfig').clangd.setup {}
    end,
  },
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()
      -- Document existing key chains
      require('which-key').register {
        -- ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
        ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
        ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
        ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
        ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
        ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
        ['<leader>e'] = { name = 'Neotree', _ = 'which_key_ignore' },
      } -- Must have register, at least 'register {}'
    end
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    keys = {
      { '<leader>e', ':Neotree toggle reveal_force_cwd float<CR>', { desc = 'Toggle Neotree' } },
    },
    opts = {
      popup_border_style = 'rounded',
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,  -- default is true
        },
        window = {
          mappings = {
            ["R"] = "refresh",  -- 刷新文件树
            ["h"] = "navigate_up",  -- 设置 'h' 键为返回上级目录
            ["l"] = function(state)  -- 使用 'l' 键进入文件夹/打开文件,并切换到该目录
              local node = state.tree:get_node()
              if node.type == "directory" then
                require('neo-tree.sources.filesystem').navigate(state, node:get_id())
              elseif node.type == "file" then
                vim.cmd('edit ' .. node.path)
                local parent_dir = vim.fn.fnamemodify(node.path, ':h')
                require('neo-tree.sources.filesystem').navigate(state, parent_dir)
              end
            end,
            ["?"] = function(state)
              local node = state.tree:get_node()
              print(node.path)
            end,
          },
        },
      },
    },
  },
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function ()
      -- You can add other plugins of mini.nvim here ->
      -- Statusline
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '第%l行 第%v列'
      end
    end
  },
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      -- { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    opts = {
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    config = function(_, opts)
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

      -- Prefer git instead of curl in order to improve connectivity in some environments
      require('nvim-treesitter.install').prefer_git = true
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)

      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },
  {
    'akinsho/bufferline.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function ()
      vim.o.termguicolors = true
      require('bufferline').setup{}
      vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>', { desc = "Next Buffer" })
      vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', { desc = "Prev Buffer" })
      vim.keymap.set('n', ']b', ':BufferLineCycleNext<CR>', { desc = "Next Buffer" })
      vim.keymap.set('n', '[b', ':BufferLineCyclePrev<CR>', { desc = "Prev Buffer" })
    end,
  },
  {
    'akinsho/toggleterm.nvim',
    config = function ()
      require('toggleterm').setup()
      vim.keymap.set('n', '<C-t>', ':ToggleTerm direction=float<CR>', { desc = "Toggle terminal" })
    end
  },
  { -- indent with '|'
    'lukas-reineke/indent-blankline.nvim',
    -- See `:help ibl`
    config = function ()
      require 'ibl'.setup()
      require 'ibl'.overwrite({
        exclude = {
          filetypes = {'dashboard'}
        }
      })
    end
  },
  {
    'HiPhish/rainbow-delimiters.nvim',
    config = function ()
      require('rainbow-delimiters.setup').setup {
        strategy = {
            -- ...
        },
        query = {
            -- ...
        },
        highlight = {
            -- ...
        },
      }
    end
  },
  { -- It works with: astro glimmer handlebars html javascript jsx markdown php rescript svelte tsx twig typescript vue xml
    'windwp/nvim-ts-autotag', -- < > < /> -- based on treesitter?
    opts = {
      opts = {
        enable_close = true, -- Auto close tags
        enable_rename = true, -- Auto rename pairs of tags
        enable_close_on_slash = true -- Auto close on trailing </
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
  {
    "OXY2DEV/markview.nvim",
    ft = { "markdown" },  -- should be 'markdown', not 'md'
    opts = {},
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons"
    },
  },
  {
    "folke/zen-mode.nvim",
    opts = {
      window = {
        width = .60  -- %60
      },
      on_open = function(win)
        -- 保持 bufferline 可见
        local view = require("zen-mode.view")
        local layout = view.layout(view.opts)
        vim.api.nvim_win_set_config(win, {
          width = layout.width,
          height = layout.height - 1,
        })
        vim.api.nvim_win_set_config(view.bg_win, {
          width = vim.o.columns,
          height = view.height() - 1,
          row = 1,
          col = layout.col,
          relative = "editor",
        })
        is_zen_manual_exit = false -- set to false when open
      end,
      on_close = function ()
        -- 检查是否是手动退出
        if not is_zen_manual_exit then
            -- 重新进入 Zen Mode
            vim.defer_fn(function()
                vim.cmd('ZenMode')
            end, 0)
        end
      end
    },
    config = function (_, opts)
      require('zen-mode').setup(opts)
      local function toggleZen()
        local current_buf = vim.api.nvim_get_current_buf()
        local buf_name = vim.api.nvim_buf_get_name(current_buf)
        -- 检查当前缓冲区名称是否包含 "neotree", 在聚焦Neotree时使用ZenMode可能导致窗口相关问题
        if buf_name:find("neo") and buf_name:find("tree") then
          print("不要在Neotree中使用ZenMode")
          return
        end
        is_zen_manual_exit = true  -- open (set to false on open) or manual close
        require('zen-mode').toggle()
      end
      vim.keymap.set('n', '<F11>', toggleZen)
      vim.keymap.set('i', '<F11>', toggleZen)
    end
  },
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    config = function()
      require('dashboard').setup {
        theme = 'hyper',
        config = {
          header = {
            "",
            "",
            "",
            " ⣇⣿⠘⣿⣿⣿⡿⡿⣟⣟⢟⢟⢝⠵⡝⣿⡿⢂⣼⣿⣷⣌⠩⡫⡻⣝⠹⢿⣿⣷ ",
            " ⡆⣿⣆⠱⣝⡵⣝⢅⠙⣿⢕⢕⢕⢕⢝⣥⢒⠅⣿⣿⣿⡿⣳⣌⠪⡪⣡⢑⢝⣇ ",
            " ⡆⣿⣿⣦⠹⣳⣳⣕⢅⠈⢗⢕⢕⢕⢕⢕⢈⢆⠟⠋⠉⠁⠉⠉⠁⠈⠼⢐⢕⢽ ",
            " ⡗⢰⣶⣶⣦⣝⢝⢕⢕⠅⡆⢕⢕⢕⢕⢕⣴⠏⣠⡶⠛⡉⡉⡛⢶⣦⡀⠐⣕⢕ ",
            " ⡝⡄⢻⢟⣿⣿⣷⣕⣕⣅⣿⣔⣕⣵⣵⣿⣿⢠⣿⢠⣮⡈⣌⠨⠅⠹⣷⡀⢱⢕ ",
            " ⡝⡵⠟⠈⢀⣀⣀⡀⠉⢿⣿⣿⣿⣿⣿⣿⣿⣼⣿⢈⡋⠴⢿⡟⣡⡇⣿⡇⡀⢕ ",
            " ⡝⠁⣠⣾⠟⡉⡉⡉⠻⣦⣻⣿⣿⣿⣿⣿⣿⣿⣿⣧⠸⣿⣦⣥⣿⡇⡿⣰⢗⢄ ",
            " ⠁⢰⣿⡏⣴⣌⠈⣌⠡⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣬⣉⣉⣁⣄⢖⢕⢕⢕ ",
            " ⡀⢻⣿⡇⢙⠁⠴⢿⡟⣡⡆⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣵⣵⣿ ",
            " ⡻⣄⣻⣿⣌⠘⢿⣷⣥⣿⠇⣿⣿⣿⣿⣿⣿⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿ ",
            " ⣷⢄⠻⣿⣟⠿⠦⠍⠉⣡⣾⣿⣿⣿⣿⣿⣿⢸⣿⣦⠙⣿⣿⣿⣿⣿⣿⣿⣿⠟ ",
            " ⡕⡑⣑⣈⣻⢗⢟⢞⢝⣻⣿⣿⣿⣿⣿⣿⣿⠸⣿⠿⠃⣿⣿⣿⣿⣿⣿⡿⠁⣠ ",
            " ⡝⡵⡈⢟⢕⢕⢕⢕⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣿⣿⣿⣿⣿⠿⠋⣀⣈⠙ ",
            " ⡝⡵⡕⡀⠑⠳⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⢉⡠⡲⡫⡪⡪⡣ ",
            '',
            '                      Welcome to XY6.nvim !                      ',
            '',
          }
        }
      }
    end,
  },
})

-- https://github.com/xyt-dev/nvim/
