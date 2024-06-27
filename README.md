# 💤 LazyVim

This configuration is based on the starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

I was using LunarVim, but got tired of how brittle it was so I switched to LazyVim.
LazyVim is a plugin that brings a lot of useful defaults to make NeoVim an IDE quickly and easily.

My development centers around Rust, SvelteKit, and Typescript at the moment, so the configuration includes plugins for those languages.

This configuration is designed to work on Windows and Linux. I don't use Mac OS, so I don't know how well it works on that platform.

## Rust Development

There is a lot happening in the Rust ecosystem, so breaking changes occur from time-to-time.
LazyVim currently uses [rustaceanvim](https://github.com/mrcjkb/rustaceanvim) to manage NeoVim support for the Rust language.
It needs exclusive control over the `rust-analyzer` language server, and specifically favors the version from your tool-chain, not the one Mason installs.
This configuration excludes `rust_analyzer` from automatic installation by Mason, but you may have to manually uninstall it to eliminate a warning message from `rustaceanvim` if you already have it installed.
Just go into Mason with `<leader>cm` and select the line with `rust-analyzer` and press `X` to uninstall it.
Another error may occur if you don't have `rust-analyzer` installed with your tool-chain.
In that case, install it with `rustup component add rust-analyzer`.
That command does not have to be executed within any Rust project because it installs the language server globally.
