{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.wunkus.presets.programs.neovim.plugins;
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
          		lua = { "stylua" },
          		nix = { "nixfmt", "injected" },
          		python = { "ruff_format", "black", stop_after_first = true },
          		go = { "gofmt" },
          		just = { "just", "injected" },
          		markdown = { "injected", "trim_whitespace" },
          		["_"] = { "trim_whitespace" },
          	},
          	default_format_opts = {
          		lsp_format = "fallback",
          	},
          	format_on_save = { timeout_ms = 500 },
          })
          vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
          vim.keymap.set("", "<leader>f", function()
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
    mini-diff = {
      config = # lua
        ''
          require("mini.diff").setup({})
        '';
    };
    mini-git = {
      config = # lua
        ''
          require("mini.git").setup({})
        '';
    };
    mini-icons = {
      config = # lua
        ''
          require("mini.icons").setup({})
        '';
    };
    mini-notify = {
      config = # lua
        ''
          require("mini.notify").setup({})
        '';
    };
    mini-pairs = {
      config = # lua
        ''
          require("mini.pairs").setup({})
        '';
    };
    mini-pick = {
      config = # lua
        ''
          local pick = require("mini.pick")
          pick.setup({
          	mappings = {
          		move_down = "<C-j>",
          		move_up = "<C-k>",
          		toggle_preview = "<C-p>",
          	},
          })
          vim.keymap.set("n", "<leader>pf", pick.builtin.files, { desc = "Pick from files" })
          vim.keymap.set(
          	"n",
          	"<leader>pg",
          	pick.builtin.grep_live,
          	{ desc = "Pick from grep pattern in files" }
          )
          vim.keymap.set("n", "<leader>pw", function()
          	pick.builtin.grep({ pattern = vim.fn.expand("<cword>") })
          end, { desc = "Pick from grep cword in files" })
          vim.keymap.set("n", "<leader>pW", function()
          	pick.builtin.grep({ pattern = vim.fn.expand("<cWORD>") })
          end, { desc = "Pick from grep cWORD in files" })
          vim.keymap.set("n", "<leader>ph", pick.builtin.help, { desc = "Pick from help" })
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
    mini-statusline = {
      config = # lua
        ''
          require("mini.statusline").setup({})
        '';
    };
    mini-surround = {
      config = # lua
        ''
          require("mini.surround").setup({})
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
    nvim-autopairs = {
      config = # lua
        ''
          require("nvim-autopairs").setup({})
        '';
    };
    nvim-cmp = {
      dependencies = with pkgs.vimPlugins; [
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline
        (pkgs.callPackage (
          {
            fetchFromGitHub,
            vimPlugins,
            vimUtils,
          }:
          vimUtils.buildVimPlugin {
            pname = "cmp-mini-snippets";
            version = "main";
            src = fetchFromGitHub {
              owner = "abeldekat";
              repo = "cmp-mini-snippets";
              rev = "582aea215ce2e65b880e0d23585c20863fbb7604";
              hash = "sha256-gSvhxrjz6PZBgqbb4eBAwWEWSdefM4qL3nb75qGPaFA=";
            };
            nativeBuildInputs = [ vimPlugins.nvim-cmp ];
            meta.homepage = "https://github.com/abeldekat/cmp-mini-snippets";
          }
        ) { })
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
          		{ name = "mini_snippets" },
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
        }")).nixosConfigurations.completions.options'';
        homeManagerExpr = ''(builtins.getFlake ("${
          cfg.plugins.nvim-lspconfig.extraData.nixConfigDir or "github:jtompkin/dotfiles"
        }")).homeConfigurations."none@completion".options'';
      in
      {
        config = # lua
          ''
            local function config_and_enable(server, config)
            	vim.lsp.config(server, config)
            	vim.lsp.enable(server)
            end
            vim.lsp.config("*", {
            	capabilities = require("cmp_nvim_lsp").default_capabilities(),
            })
            vim.lsp.enable("just")
            config_and_enable("pyright", {
            	cmd = { [[${lib.getExe' pkgs.pyright "pyright-langserver"}, "--stdio"]] },
            })
            config_and_enable("gopls", {
            	cmd = { [[${lib.getExe pkgs.gopls}]] },
            })
            config_and_enable("nixd", {
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
            config_and_enable("lua_ls", {
            	cmd = { [[${lib.getExe pkgs.lua-language-server}]] },
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
            					-- Tell the language server which version of Lua you're using (most
            					-- likely LuaJIT in the case of Neovim)
            					version = "LuaJIT",
            					-- Tell the language server how to find Lua modules same way as Neovim
            					-- (see `:h lua-module-load`)
            					path = {
            						"lua/?.lua",
            						"lua/?/init.lua",
            					},
            				},
            				-- Make the server aware of Neovim runtime files
            				workspace = {
            					checkThirdParty = false,
            					library = {
            						vim.env.VIMRUNTIME,
            						-- Depending on the usage, you might want to add additional paths
            						-- here.
            						-- "''${3rd}/luv/library"
            						-- "''${3rd}/busted/library"
            					},
            					-- Or pull in all of 'runtimepath'.
            					-- NOTE: this is a lot slower and will cause issues when working on
            					-- your own configuration.
            					-- See https://github.com/neovim/nvim-lspconfig/issues/3189
            					-- library = {
            					--   vim.api.nvim_get_runtime_file("", true),
            					-- }
            				},
            			})
            	end,
            	settings = {
            		Lua = {},
            	},
            })
          '';
      };
    nvim-surround = {
      config = # lua
        ''
          require("nvim-surround").setup({})
        '';
    };
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
          	"<leader>rp",
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
    programs.neovim.plugins = lib.concatMap (
      module: lib.optionals module.enable ([ module.config ] ++ module.dependencies)
    ) (lib.attrValues cfg.plugins);
  };
}
