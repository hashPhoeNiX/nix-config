{inputs, ...}: let
  utils = inputs.nixCats.utils; # the options for this are defined at the end of the file, and will be how to include this template module in your system configuration.
in {
  imports = [
    inputs.nixCats.nixosModules.default
  ];
  config = {
    # this value, nixCats is the defaultPackageName you pass to mkNixosModules
    # it will be the namespace for your options.
    nixCats = {
      inherit utils;
      luaPath = "${./.}";
      forEachSystem = utils.eachSystem inputs.nixpkgs.lib.platforms.all;
      # the following extra_pkg_config contains any values
      # which you want to pass to the config set of nixpkgs
      # import nixpkgs { config = extra_pkg_config; inherit system; }
      # will not apply to module imports
      # as that will have your system values
      extra_pkg_config = {
        # allowUnfree = true;
      };
      # management of the system variable is one of the harder parts of using flakes.

      # so I have done it here in an interesting way to keep it out of the way.
      # It gets resolved within the builder itself, and then passed to your
      # categoryDefinitions and packageDefinitions.

      # this allows you to use ${pkgs.system} whenever you want in those sections
      # without fear.

      # sometimes our overlays require a ${system} to access the overlay.
      # Your dependencyOverlays can either be lists
      # in a set of ${system}, or simply a list.
      # the nixCats builder function will accept either.
      # see :help nixCats.flake.outputs.overlays
      dependencyOverlays = /* (import ./overlays inputs) ++ */ [
        # This overlay grabs all the inputs named in the format
        # `plugins-<pluginName>`
        # Once we add this overlay to our nixpkgs, we are able to
        # use `pkgs.neovimPlugins`, which is a set of our plugins.
        (utils.standardPluginOverlay inputs)
        # add any other flake overlays here.

        # when other people mess up their overlays by wrapping them with system,
        # you may instead call this function on their overlay.
        # it will check if it has the system in the set, and if so return the desired overlay
        # (utils.fixSystemizedOverlay inputs.codeium.overlays
        #   (system: inputs.codeium.overlays.${system}.default)
        # )
      ];

      # see :help nixCats.flake.outputs.categories
      # and
      # :help nixCats.flake.outputs.categoryDefinitions.scheme
      categoryDefinitions = { pkgs, ... }: {
        # to define and use a new category, simply add a new list to a set here, 
        # and later, you will include categoryname = true; in the set you
        # provide when you build the package using this builder function.
        # see :help nixCats.flake.outputs.packageDefinitions for info on that section.

        # lspsAndRuntimeDeps:
        # this section is for dependencies that should be available
        # at RUN TIME for plugins. Will be available to PATH within neovim terminal
        # this includes LSPs
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
          ];
        };

        # NOTE: lazy doesnt care if these are in startupPlugins or optionalPlugins
        # also you dont have to download everything via nix if you dont want.
        # but you have the option, and that is demonstrated here.
        startupPlugins = {
          general = with pkgs.vimPlugins; [
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

        # not loaded automatically at startup.
        # use with packadd and an autocommand in config to achieve lazy loading
        # NOTE: this template is using lazy.nvim so, which list you put them in is irrelevant.
        # startupPlugins or optionalPlugins, it doesnt matter, lazy.nvim does the loading.
        # I just put them all in startupPlugins. I could have put them all in here instead.
        optionalPlugins = {};

        # shared libraries to be added to LD_LIBRARY_PATH
        # variable available to nvim runtime
        sharedLibraries = {
          general = with pkgs; [
            # libgit2
          ];
        };

        # environmentVariables:
        # this section is for environmentVariables that should be available
        # at RUN TIME for plugins. Will be available to path within neovim terminal
        environmentVariables = {
          test = {
            CATTESTVAR = "It worked!";
          };
        };

        # If you know what these are, you can provide custom ones by category here.
        # If you dont, check this link out:
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
        extraWrapperArgs = {
          test = [
            '' --set CATTESTVAR2 "It worked again!"''
          ];
        };

        # lists of the functions you would have passed to
        # python.withPackages or lua.withPackages

        # get the path to this python environment
        # in your lua config via
        # vim.g.python3_host_prog
        # or run from nvim terminal via :!<packagename>-python3
        extraPython3Packages = {
          test = [ (_:[]) ];
        };
        # populates $LUA_PATH and $LUA_CPATH
        extraLuaPackages = {
          test = [ (_:[]) ];
        };
      };



      # And then build a package with specific categories from above here:
      # All categories you wish to include must be marked true,
      # but false may be omitted.
      # This entire set is also passed to nixCats for querying within the lua.

      # see :help nixCats.flake.outputs.packageDefinitions
      packageDefinitions = {
        # These are the names of your packages
        # you can include as many as you wish.
        nvim = { pkgs, ... }: {
          # they contain a settings set defined above
          # see :help nixCats.flake.outputs.settings
          settings = {
            wrapRc = true;
            # IMPORTANT:
            # your alias may not conflict with your other packages.
            # aliases = [ "vim" ];
            # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
          };
          # and a set of categories that you want
          # (and other information to pass to lua)
          categories = {
            general = true;
            test = false;
          };
          extra = {};
        };
        # an extra test package with normal lua reload for fast edits
        # nix doesnt provide the config in this package, allowing you free reign to edit it.
        # then you can swap back to the normal pure package when done.
        testnvim = { pkgs, ... }: {
          settings = {
            wrapRc = false;
            unwrappedCfgPath = "/absolute/path/to/config";
          };
          categories = {
            general = true;
            test = false;
          };
          extra = {};
        };
      };
      # In this section, the main thing you will need to do is change the default package name
      # to the name of the packageDefinitions entry you wish to use as the default.
      defaultPackageName = "nvim";
    };
  };
}
