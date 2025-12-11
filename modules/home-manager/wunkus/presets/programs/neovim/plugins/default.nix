{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.wunkus.presets.programs.neovim.plugins;
  appendNewline = s: s + "\n";
  pluginConfigs = {
    cellular-automaton-nvim = {
      config = # lua
        ''
          vim.keymap.set("n", "<leader>fml", function()
          	vim.cmd.CellularAutomaton("make_it_rain")
          end, { desc = "Make it rain!" })
          vim.keymap.set("n", "<leader>fmg", function()
          	vim.cmd.CellularAutomaton("game_of_life")
          end, { desc = "Game of life!" })
          vim.keymap.set("n", "<leader>fms", function()
          	vim.cmd.CellularAutomaton("scramble")
          end, { desc = "Scramble!" })
        '';
    };
    conform-nvim = {
      config = # lua
        ''
          require("conform").setup({
          	formatters = {
          		nixfmt = {
          			command = [[${lib.getExe' pkgs.nixfmt-rfc-style "nixfmt"}]],
          		},
          	},
          	formatters_by_ft = {
          		go = { "gofmt" },
          		just = { "just", "injected" },
          		lua = { "stylua" },
          		markdown = { "injected", "trim_whitespace" },
          		nix = { "nixfmt", "injected" },
          		python = { "ruff_format", "black", stop_after_first = true },
          		toml = { "tombi" },
          		["_"] = { "trim_whitespace" },
          	},
          	default_format_opts = {
          		lsp_format = "fallback",
          	},
          	format_on_save = { timeout_ms = 500 },
          })
          vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
          vim.keymap.set("n", "<leader>fe", function()
          	if vim.o.formatexpr == "" then
          		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
          	else
          		vim.o.formatexpr = ""
          	end
          end, { desc = "Toggle using conform to format" })
          vim.keymap.set("", "<leader>ff", function()
          	require("conform").format({ async = true }, function(err)
          		if not err then
          			local mode = vim.api.nvim_get_mode().mode
          			if vim.startswith(string.lower(mode), "v") then
          				vim.api.nvim_feedkeys(
          					vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
          					"n",
          					true
          				)
          			end
          		end
          	end)
          end, { desc = "Format code" })
        '';
    };
    fzf-lua = {
      dependencies = [ pkgs.vimPlugins.nvim-web-devicons ];
      config = # lua
        ''
          local fzf = require("fzf-lua")
          vim.keymap.set("n", "<leader>pf", fzf.files, { desc = "Show files using fzf." })
          vim.keymap.set("n", "<leader>ps", fzf.grep, { desc = "Grep in files using fzf." })
          vim.keymap.set(
          	"n",
          	"<leader>pp",
          	fzf.grep_project,
          	{ desc = "Grep project using fzf." }
          )
          vim.keymap.set(
          	"n",
          	"<leader>pw",
          	fzf.grep_cword,
          	{ desc = "Grep word under cursor using fzf." }
          )
          vim.keymap.set(
          	"n",
          	"<leader>pW",
          	fzf.grep_cWORD,
          	{ desc = "Grep WORD under cursor using fzf." }
          )
          vim.keymap.set(
          	"v",
          	"pv",
          	fzf.grep_visual,
          	{ desc = "Grep visual selection using fzf." }
          )
        '';
    };
    harpoon2 = {
      config = # lua
        ''
          local harpoon = require("harpoon")
          harpoon:setup()
          vim.keymap.set("n", "<leader>ha", function()
          	harpoon:list():add()
          end, { desc = "Add current file to harpoon" })
          vim.keymap.set("n", "<leader>hd", function()
          	harpoon:list():remove()
          end, { desc = "Remove file from harpoon." })
          vim.keymap.set("n", "<leader>hh", function()
          	harpoon.ui:toggle_quick_menu(harpoon:list())
          end, { desc = "Show harpoon." })
          vim.keymap.set("n", "<leader>a", function()
          	harpoon:list():select(1)
          end)
          vim.keymap.set("n", "<leader>s", function()
          	harpoon:list():select(2)
          end)
          vim.keymap.set("n", "<leader>q", function()
          	harpoon:list():select(3)
          end)
          vim.keymap.set("n", "<leader>w", function()
          	harpoon:list():select(4)
          end)
          vim.keymap.set("n", "<leader>5", function()
          	harpoon:list():select(5)
          end)
          vim.keymap.set("n", "<leader>6", function()
          	harpoon:list():select(6)
          end)
          vim.keymap.set("n", "<leader>7", function()
          	harpoon:list():select(7)
          end)
          vim.keymap.set("n", "<leader>8", function()
          	harpoon:list():select(8)
          end)
          vim.keymap.set("n", "<leader>9", function()
          	harpoon:list():select(9)
          end)
          vim.keymap.set("n", "<leader>0", function()
          	harpoon:list():select(10)
          end)
        '';
    };
    lualine-nvim = {
      config = # lua
        ''
          require("lualine").setup({
          	sections = {
          		lualine_a = { "mode" },
          		lualine_b = {
          			{
          				"branch",
          				icon = "󰚄",
          			},
          			"diff",
          			"diagnostics",
          		},
          		lualine_c = {
          			{
          				"filename",
          				path = 4,
          			},
          			"searchcount",
          		},
          		lualine_x = { "filetype", "fileformat" },
          		lualine_y = { "progress" },
          		lualine_z = { "location" },
          	},
          	extensions = { "fzf" },
          })
        '';
    };
    mini-clue = {
      config = # lua
        ''
          local miniclue = require("mini.clue")
          miniclue.setup({
          	triggers = {
          		-- Leader triggers
          		{ mode = "n", keys = "<Leader>" },
          		{ mode = "x", keys = "<Leader>" },
          		-- Built-in completion
          		{ mode = "i", keys = "<C-x>" },
          		-- `g` key
          		{ mode = "n", keys = "g" },
          		{ mode = "x", keys = "g" },
          		-- Marks
          		{ mode = "n", keys = "'" },
          		{ mode = "n", keys = "`" },
          		{ mode = "x", keys = "'" },
          		{ mode = "x", keys = "`" },
          		-- Registers
          		{ mode = "n", keys = '"' },
          		{ mode = "x", keys = '"' },
          		{ mode = "i", keys = "<C-r>" },
          		{ mode = "c", keys = "<C-r>" },
          		-- Window commands
          		{ mode = "n", keys = "<C-w>" },
          		-- `z` key
          		{ mode = "n", keys = "z" },
          		{ mode = "x", keys = "z" },
          	},
          	clues = {
          		-- Enhance this by adding descriptions for <Leader> mapping groups
          		miniclue.gen_clues.builtin_completion(),
          		miniclue.gen_clues.g(),
          		miniclue.gen_clues.marks(),
          		miniclue.gen_clues.registers(),
          		miniclue.gen_clues.windows(),
          		miniclue.gen_clues.z(),
          	},
          })
        '';
    };
    mini-diff.config = appendNewline ''require("mini.diff").setup({})'';
    mini-files = {
      config = # lua
        ''
          require("mini.files").setup({})
          vim.keymap.set("n", "<leader>pV", MiniFiles.open, { desc = "Open file explorer" })
          vim.keymap.set("n", "<leader>pv", function()
          	MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
          	MiniFiles.reveal_cwd()
          end, { desc = "Open file explorer to current file" })
          local set_mark = function(id, path, desc)
          	MiniFiles.set_bookmark(id, path, { desc = desc })
          end
          local minifiles_group = vim.api.nvim_create_augroup("minifiles", {})
          vim.api.nvim_create_autocmd("user", {
          	group = minifiles_group,
          	pattern = "MiniFilesBufferCreate",
          	callback = function(args)
          		local b = args.data.buf_id
          		vim.keymap.set("n", "gy", function()
          			local path = (MiniFiles.get_fs_entry() or {}).path
          			if path == nil then
          				return vim.notify("Cursor is not on valid entry")
          			end
          			vim.fn.setreg(vim.v.register, path)
          		end, { buffer = b, desc = "Yank path" })
          		vim.keymap.set("n", "gX", function()
          			vim.ui.open(MiniFiles.get_fs_entry().path)
          		end, { buffer = b, desc = "Open with default OS handler" })
          	end,
          })
        '';
    };
    mini-git.config = appendNewline ''require("mini.git").setup({})'';
    mini-icons.config = appendNewline ''require("mini.icons").setup({})'';
    mini-jump.config = appendNewline ''require("mini.jump").setup({})'';
    mini-notify.config = appendNewline ''require("mini.notify").setup({})'';
    mini-pairs.config = appendNewline ''require("mini.pairs").setup({})'';
    mini-pick = {
      config = # lua
        ''
          require("mini.pick").setup({
          	mappings = {
          		move_down = "<C-j>",
          		move_up = "<C-k>",
          		toggle_preview = "<C-p>",
          	},
          })
          vim.keymap.set("n", "<leader>pf", MiniPick.builtin.files, { desc = "Pick from files" })
          vim.keymap.set(
          	"n",
          	"<leader>pg",
          	MiniPick.builtin.grep_live,
          	{ desc = "Pick from grep pattern in files" }
          )
          vim.keymap.set("n", "<leader>pw", function()
          	MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") })
          end, { desc = "Pick from grep cword in files" })
          vim.keymap.set("n", "<leader>pW", function()
          	MiniPick.builtin.grep({ pattern = vim.fn.expand("<cWORD>") })
          end, { desc = "Pick from grep cWORD in files" })
          vim.keymap.set("n", "<leader>ph", MiniPick.builtin.help, { desc = "Pick from help" })
          vim.keymap.set(
          	"n",
          	"<leader>pr",
          	MiniPick.builtin.resume,
          	{ desc = "Resume last picker" }
          )
        '';
    };
    mini-sessions = {
      config = # lua
        ''
          require("mini.sessions").setup({})
          vim.keymap.set("n", "<leader>sw", function()
          	MiniSessions.write(MiniSessions.config.file)
          end, { desc = "Write local session" })
          vim.keymap.set("n", "<leader>sn", function()
          	local session = vim.fn.input("Session name: ")
          	if session ~= "" then
          		MiniSessions.write(session)
          	end
          end, { desc = "Write new session" })
          vim.keymap.set("n", "<leader>sr", MiniSessions.read, { desc = "Read default session" })
          vim.keymap.set("n", "<leader>ps", MiniSessions.select, { desc = "Pick sessions" })
        '';
    };
    mini-snippets = {
      dependencies = [ pkgs.vimPlugins.friendly-snippets ];
      config = # lua
        ''
          local mini_snippets = require("mini.snippets")
          mini_snippets.setup({
          	mappings = {
          		jump_prev = "<C-h>",
          		jump_next = "<C-l>",
          	},
          	snippets = {
          		mini_snippets.gen_loader.from_lang(),
          	},
          })
        '';
    };
    mini-starter = {
      config = # lua
        ''
          local starter = require("mini.starter")
          starter.setup({
          	evaluate_single = true,
          	items = {
          		starter.sections.sessions(),
          		starter.sections.builtin_actions(),
          		starter.sections.pick(),
          	},
          })
        '';
    };
    mini-statusline.config = appendNewline ''require("mini.statusline").setup({})'';
    mini-surround = {
      config = # lua
        ''
          require("mini.surround").setup({
          	mappings = {
          		add = "<leader>ra",
          		delete = "<leader>rd",
          		find = "<leader>rf",
          		find_left = "<leader>rF",
          		highlight = "<leader>rh",
          		replace = "<leader>rr",
          	},
          })
        '';
    };
    neogen = {
      config = # lua
        ''
          local neogen = require("neogen")
          neogen.setup({
          	snippet_engine = "luasnip",
          	languages = {
          		python = {
          			template = {
          				annotation_convention = "numpydoc",
          			},
          		},
          	},
          })
          vim.keymap.set("n", "<leader>nf", neogen.generate, { desc = "Generate docstring" })
        '';
    };
    neogit = {
      dependencies = [ pkgs.vimPlugins.diffview-nvim ];
      config = # lua
        ''
          local neogit = require("neogit")
          neogit.setup({
          	mappings = {
          		finder = {
          			["<c-j>"] = "Next",
          			["<c-k>"] = "Previous",
          		},
          	},
          })
          vim.keymap.set("n", "<leader>gs", neogit.open, { desc = "Open git integration." })
        '';
    };
    nightfox-nvim = {
      config = # lua
        ''
          require("nightfox").setup({
          	specs = {
          		all = {
          			syntax = {
          				func = "magenta",
          				keyword = "red",
          				conditional = "red",
          				builtin0 = "pink",
          			},
          		},
          	},
          	groups = {
          		all = {
          			["@variable.parameter"] = { link = "Variable" },
          			["@function.builtin"] = { link = "Function" },
          			Special = { link = "@keyword" },
          		},
          	},
          	modules = {
          		neogit = true,
          	},
          })
          vim.cmd.colorscheme("carbonfox")
          vim.cmd.highlight("Normal guibg=none")
        '';
    };
    nvim-autopairs.config = appendNewline ''require("nvim-autopairs").setup({})'';
    nvim-cmp = {
      dependencies = with pkgs.vimPlugins; [
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline
        config.mornix.programs.vimPlugins.cmp-mini-snippets.package
      ];
      config = # lua
        ''
          local cmp = require("cmp")
          local mini_snippets = require("mini.snippets")
          cmp.setup({
          	enabled = function()
          		local disabled = false
          		disabled = disabled
          			or (vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt")
          		disabled = disabled or (vim.fn.reg_recording() ~= "")
          		disabled = disabled or (vim.fn.reg_executing() ~= "")
          		disabled = disabled
          			or require("cmp.config.context").in_treesitter_capture("comment")
          		return not disabled
          	end,
          	snippet = {
          		expand = function(args)
          			local insert = mini_snippets.config.expand.insert
          				or mini_snippets.default_insert
          			insert({ body = args.body })
          			cmp.resubscribe({ "TextChangedI", "TextChangedP" })
          			require("cmp.config").set_onetime({ sources = {} })
          		end,
          	},
          	window = {
          		completion = cmp.config.window.bordered(),
          		documentation = cmp.config.window.bordered(),
          	},
          	mapping = cmp.mapping.preset.insert({
          		["<C-j>"] = cmp.mapping.select_next_item(),
          		["<C-k>"] = cmp.mapping.select_prev_item(),
          		["<C-b>"] = cmp.mapping.scroll_docs(-4),
          		["<C-f>"] = cmp.mapping.scroll_docs(4),
          		["<C-space>"] = cmp.mapping.complete(),
          		["<C-e>"] = cmp.mapping.abort(),
          		["<C-y>"] = cmp.mapping.confirm({ select = true }),
          	}),
          	sources = cmp.config.sources({
          		{ name = "nvim_lsp" },
          		{ name = "mini_snippets", option = { use_items_cache = false } },
          	}, {
          		{ name = "buffer" },
          	}),
          })

          local cmdline_mapping = cmp.mapping.preset.cmdline()
          cmdline_mapping["<C-j>"] = cmdline_mapping["<Tab>"]
          cmdline_mapping["<C-k>"] = cmdline_mapping["<S-Tab>"]
          cmp.setup.cmdline({ "/", "?" }, {
          	mapping = cmdline_mapping,
          	sources = {
          		{ name = "buffer" },
          	},
          })

          cmp.setup.cmdline(":", {
          	mapping = cmdline_mapping,
          	sources = cmp.config.sources({
          		{ name = "path" },
          	}, {
          		{ name = "cmdline" },
          	}),
          	matching = { disallow_symbol_nonprefix_matching = false },
          })
        '';
    };
    nvim-lspconfig =
      let
        # Put these complex expressions in variables so injected Lua formatting works
        nixosExpr = ''(builtins.getFlake ("${
          cfg.plugins.nvim-lspconfig.extraData.nixConfigDir or "github:jtompkin/dotfiles"
        }")).nixosConfigurations.completion.options'';
        homeManagerExpr = ''(builtins.getFlake ("${
          cfg.plugins.nvim-lspconfig.extraData.nixConfigDir or "github:jtompkin/dotfiles"
        }")).homeConfigurations."none@completion".options'';
      in
      {
        order = 1001;
        config = # lua
          ''
            local function config_and_enable(server, config)
            	vim.lsp.config(server, config)
            	vim.lsp.enable(server)
            end
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            config_and_enable("just", { capabilities = capabilities })
            config_and_enable("basedpyright", { capabilities = capabilities })
            config_and_enable("gopls", { capabilities = capabilities })
            config_and_enable("tombi", { capabilities = capabilities })
            config_and_enable("nixd", {
            	capabilities = capabilities,
            	cmd = { [[${lib.getExe pkgs.nixd}]] },
            	settings = {
            		nixd = {
            			options = {
            				nixos = {
            					expr = [[${nixosExpr}]],
            				},
            				home_manager = {
            					expr = [[${homeManagerExpr}]],
            				},
            			},
            		},
            	},
            })
            -- From: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls
            config_and_enable("lua_ls", {
            	capabilities = capabilities,
            	on_init = function(client)
            		if client.workspace_folders then
            			local path = client.workspace_folders[1].name
            			if
            				path ~= vim.fn.stdpath("config")
            				and (
            					vim.uv.fs_stat(path .. "/.luarc.json")
            					or vim.uv.fs_stat(path .. "/.luarc.jsonc")
            				)
            			then
            				return
            			end
            		end
            		client.config.settings.Lua =
            			vim.tbl_deep_extend("force", client.config.settings.Lua, {
            				runtime = {
            					version = "LuaJIT",
            					path = {
            						"lua/?.lua",
            						"lua/?/init.lua",
            					},
            				},
            				workspace = {
            					checkThirdParty = false,
            					ignoreDir = { ".direnv" },
            					library = {
            						vim.env.VIMRUNTIME,
            					},
            				},
            			})
            	end,
            	settings = {
            		Lua = {},
            	},
            })
          '';
      };
    nvim-surround.config = appendNewline ''require("nvim-surround").setup({})'';
    nvim-treesitter = {
      config = # lua
        ''
          require("nvim-treesitter.configs").setup({
          	highlight = { enable = true },
          	indent = { enable = true },
          })
        '';
    };
    render-markdown-nvim = {
      config = # lua
        ''
          local render_markdown = require("render-markdown")
          render_markdown.setup({})
          vim.keymap.set(
          	"n",
          	"<leader>mp",
          	render_markdown.preview,
          	{ desc = "Render markdown preview" }
          )
        '';
    };
    which-key-nvim = {
      config = # lua
        ''
          local which_key = require("which-key")
          vim.keymap.set("n", "<leader>?", function()
          	which_key.show({ global = false })
          end, { desc = "Buffer local keymaps (which-key)" })
        '';
    };
  };
  pluginConfigType = lib.types.submodule {
    options = {
      type = lib.mkOption {
        type = lib.types.enum [ "lua" ];
        description = "Language used in config";
        default = "lua";
      };
      plugin = lib.mkPackageOption pkgs.vimPlugins "plugin" {
        default = null;
      };
      config = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        description = "Script to configure this plugin";
        default = null;
      };
    };
  };
  pluginType = lib.types.submodule (
    { config, name, ... }:
    {
      options = {
        enable = lib.mkEnableOption "${name} Neovim plugin";
        config = lib.mkOption {
          type = pluginConfigType;
          default = {
            plugin = cfg.pluginMapping.${name} or pkgs.vimPlugins.${name};
            config =
              "-- START: ${name}\n"
              + pluginConfigs.${name}.config or ""
              + config.extraConfig
              + "-- END: ${name}\n";
          };
          description = "Configuration of plugin including plugin type, package, and config text";
        };
        order = lib.mkOption {
          type = lib.types.int;
          description = "Order to merge this plugin. default = 1000; mkBefore = 500; mkAfter = 1500";
          default = pluginConfigs.${name}.order or 1000;
        };
        dependencies = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          description = "List of plugin packages that will be installed along with the plugin";
          default = pluginConfigs.${name}.dependencies or [ ];
        };
        extraConfig = lib.mkOption {
          type = lib.types.lines;
          description = "Extra lua configuration to append to base configuration";
          default = "";
        };
        extraData = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          description = "Arbitrary data that will be available to the plugin configuration";
          default = { };
        };
      };
    }
  );
in
{
  options.wunkus.presets.programs.neovim.plugins = {
    enable = lib.mkEnableOption "managing Neovim plugins with the Wunkus module";
    pluginMapping = lib.mkOption {
      type = lib.types.attrsOf lib.types.package;
      description = "Mapping of plugin name to plugin package to use. Plugins will automatically use pkgs.vimPlugins.<name> if not present in this option";
      default = { };
    };
    plugins = lib.mkOption {
      type = lib.types.attrsOf pluginType;
      description = "Attribute set of plugin names to their configuration";
      default = { };
    };
  };
  config = lib.mkIf cfg.enable {
    programs.neovim.plugins = lib.pipe cfg.plugins [
      lib.attrValues
      (lib.filter (module: module.enable))
      (lib.map (module: lib.mkOrder module.order ([ module.config ] ++ module.dependencies)))
      lib.mkMerge
    ];
  };
}
