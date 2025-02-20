{inputs, ...}: let
  # utils = inputs.nixCats.utils; the options for this are defined at the end of the file, and will be how to include this template module in your system configuration.
in {
  imports = [
    inputs.nixCats.nixosModules.default
  ];
  config = {
    # this value, nixCats is the defaultPackageName you pass to mkNixosModules
    # it will be the namespace for your options.
    nixCats = {
      # these are some of the options. For the rest see :help nixCats.flake.outputs.utils.mkNixosModules you do not need to use every option here, anything you do not define will be pulled from the flake instead.
      enable = true;
      # this will add the overlays from ./overlays and also, add any plugins in inputs named "plugins-pluginName" to pkgs.neovimPlugins It will not apply to overall system, just nixCats.
      packageNames = ["myNixModuleNvim"];
      luaPath = "${./.}";
      # you could also import lua from the flake though, which we do for user config after this config for root packageDef is your settings and categories for this package. categoryDefinitions.replace will replace the whole categoryDefinitions with a new one
      categoryDefinitions.replace = {pkgs, ...}: { 
        lspsAndRuntimeDeps = {
          general = with pkgs; [
            universal-ctags
            curl
            lazygit
            ripgrep
            fd
            stdenv.cc.cc
            lua-language-server
            nil # I would go for nixd but lazy chooses this one idk
            stylua
            pyright
            black
            mypy
            ruff
            nixd
          ];
          neonixdev = {
            # also you can do this.
            inherit (pkgs) nix-doc nil lua-language-server nixd;
            # nix-doc tags will make your tags much better in nix but only if you have nil as well for some reason
          };
        };
      
        startupPlugins = with pkgs.vimPlugins; {
          general = [
            # LazyVim
            lazy-nvim
            LazyVim
            bufferline-nvim
            lazydev-nvim
            cmp-buffer
            cmp-nvim-lsp
            cmp-path
            cmp_luasnip
            conform-nvim
            dashboard-nvim
            dressing-nvim
            flash-nvim
            friendly-snippets
            gitsigns-nvim
            indent-blankline-nvim
            lualine-nvim
            neo-tree-nvim
            neoconf-nvim
            neodev-nvim
            noice-nvim
            nui-nvim
            nvim-cmp
            nvim-lint
            nvim-lspconfig
            nvim-notify
            nvim-spectre
            nvim-treesitter-context
            nvim-treesitter-textobjects
            nvim-ts-autotag
            nvim-ts-context-commentstring
            nvim-web-devicons
            persistence-nvim
            plenary-nvim
            telescope-fzf-native-nvim
            telescope-nvim
            todo-comments-nvim
            tokyonight-nvim
            trouble-nvim
            vim-illuminate
            vim-startuptime
            which-key-nvim
            snacks-nvim
            nvim-treesitter-textobjects
            nvim-treesitter.withAllGrammars
            # This is for if you only want some of the grammars
            # (nvim-treesitter.withPlugins (
            #   plugins: with plugins; [
            #     nix
            #     lua
            #   ]
            # ))

            # sometimes you have to fix some names
            { plugin = luasnip; name = "LuaSnip"; }
            { plugin = catppuccin-nvim; name = "catppuccin"; }
            { plugin = mini-ai; name = "mini.ai"; }
            { plugin = mini-icons; name = "mini.icons"; }
            { plugin = mini-bufremove; name = "mini.bufremove"; }
            { plugin = mini-comment; name = "mini.comment"; }
            { plugin = mini-indentscope; name = "mini.indentscope"; }
            { plugin = mini-pairs; name = "mini.pairs"; }
            { plugin = mini-surround; name = "mini.surround"; }
            # you could do this within the lazy spec instead if you wanted
            # and get the new names from `:NixCats pawsible` debug command
          ];
        };
      };

      # see :help nixCats.flake.outputs.packageDefinitions
      packageDefinitions = {
        replace = {
          # These are the names of your packages you can include as many as you wish.
          myNixModuleNvim = {...}: {
            # they contain a settings set defined above see :help nixCats.flake.outputs.settings
            settings = {
              wrapRc = true;
              # NOTE: IMPORTANT: you may not alias to nvim your alias may not conflict with your other packages.
              aliases = ["nv" "v"];
              # nvimSRC = inputs.neovim;
            };
            # and a set of categories that you want (and other information to pass to lua)
            categories = {
              general = true;
              test = false;
            };
            extra = {};
          };
        };
      };
    };
  };
}
