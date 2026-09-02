{
  description = "workbench-demos — Ruby GTK4 ports of the Workbench Library demos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        ruby = pkgs.ruby_3_4;

        # Libraries the demos reach through GObject Introspection at runtime.
        # Their typelibs have to be on GI_TYPELIB_PATH even when no gem wraps
        # them, because several demos require the namespace directly.
        giLibs = with pkgs; [
          glib
          gobject-introspection
          cairo
          pango
          gdk-pixbuf
          graphene
          at-spi2-core
          gtk4
          libadwaita
          gtksourceview5
          libshumate
          libspelling
          libsoup_3
          webkitgtk_6_0
          gst_all_1.gstreamer
          gst_all_1.gst-plugins-base
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          # ruby-gnome gems resolve Requires.private in .pc files, so pull in
          # the GTK stack's own build environments rather than enumerating
          # every transitive dev library.
          inputsFrom = with pkgs; [ gtk4 glib cairo pango gdk-pixbuf at-spi2-core libadwaita gtksourceview5 ];

          nativeBuildInputs = [ pkgs.pkg-config ];

          buildInputs = with pkgs; [
            ruby
            libyaml
            openssl
            sqlite
            at-spi2-core # provides atk.pc for the atk gem
            expat # fontconfig's Requires.private, needed by the cairo gem
            libxdmcp # libxcb's Requires.private
            libselinux # libmount's Requires.private chain (gio2)
            libsepol
            libdatrie # libthai's Requires.private (pango)
            libdeflate # libtiff's Requires.private (gdk-pixbuf, gtk4)
            lerc # more libtiff Requires.private
            xz
            zstd
            libwebp
            libunwind # gstreamer's Requires.private
            orc # gstreamer's Requires.private
            xvfb-run # run a demo headlessly
            adwaita-icon-theme
            gsettings-desktop-schemas
            gst_all_1.gst-plugins-good
          ] ++ giLibs;

          shellHook = ''
            export GEM_HOME="$HOME/.gem-workbench-demos-${ruby.version}"
            export GEM_PATH="$GEM_HOME/ruby/${ruby.version.libDir}:$GEM_HOME"
            export PATH="$GEM_HOME/bin:$GEM_HOME/ruby/${ruby.version.libDir}/bin:$PATH"
            export BUNDLE_GEMFILE="$PWD/Gemfile"
            export BUNDLE_PATH="$GEM_HOME"
            export BUNDLE_BIN="$GEM_HOME/bin"

            # Namespaces without a ruby-gnome gem are loaded straight from
            # their typelibs, so keep the whole set on the search path.
            export GI_TYPELIB_PATH="${pkgs.lib.makeSearchPath "lib/girepository-1.0" (map (drv: drv.out or drv) giLibs)}''${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}"

            export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk4}/share/gsettings-schemas/${pkgs.gtk4.name}:${pkgs.adwaita-icon-theme}/share:$XDG_DATA_DIRS"

            echo "workbench-demos (ruby) — ruby $(ruby -e 'print RUBY_VERSION')"
            echo "  bundle install              install the ruby-gnome gems"
            echo "  ruby 'src/Box/main.rb'      run a demo"
          '';
        };
      }
    );
}
