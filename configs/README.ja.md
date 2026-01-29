## MiniMax 設定

利用可能:

- [`nvim-0.11`](nvim-0.11) - Neovim>=0.11用

計画中（'nvim-0.11'の公開テスト後）:

- `nvim-0.9` - Neovim>=0.9用
- `nvim-0.10` - Neovim>=0.10用
- `nvim-0.12` - Neovim>=0.12用

### 構造

#### `init.lua`

起動時に最初に実行される初期ファイル。

#### `plugin/`

起動時にアルファベット順に自動的に実行されるファイル群:

- `10_options.lua` - Neovimの組み込み動作。
- `20_keymaps.lua` - カスタムマッピング、主に[`:h <Leader>`](https://neovim.io/doc/user/helptag.html?tag=<Leader>)キー用。
- `30_mini.lua` - MINI設定。
- `40_plugins.lua` - MINI以外のプラグイン。

> [!NOTE]
> 多くの設定は、設定をモジュール化するために明示的な`require()`呼び出しで'lua/'ディレクトリを使用することを好みます。これは使用しても問題ありませんが、'lua'名前空間を占有するという欠点があります。すべてのプラグイン間で共有されるため、`require()`中に競合が発生する可能性があります。通常、'lua/username'のような専用の「ユーザー」ディレクトリ内に設定ファイルを配置することで解決されます。
>
> 'plugin/'アプローチにはこの問題がありません。また、ファイルが実行されるために'init.lua'内で明示的な`require()`呼び出しを必要としません。

> [!TIP]
> このアプローチの詳細については、[`:h load-plugins`](https://neovim.io/doc/user/helptag.html?tag=load-plugins)を参照してください。特に:
> - サブディレクトリが許可されています。それらのファイルもアルファベット順にソースされます。
> - 'plugin/'ファイルは、Neovimが`nvim -u path/to/file`で起動された場合でも実行されます。`--noplugin`も渡すか、[`:h $NVIM_APPNAME`](https://neovim.io/doc/user/helptag.html?tag=$NVIM_APPNAME)アプローチを使用してください。

#### `snippets/`

ユーザー定義スニペット。デモとして単一の'global.json'ファイルを含んでいます（'mini.snippets'セットアップで使用）。

#### `after/`

プラグインによって追加された動作を上書きするためのファイル。通常、'ftplugin/'のような特別なサブディレクトリ内に配置されます（[`:h 'runtimepath'`](https://neovim.io/doc/user/helptag.html?tag='runtimepath')を参照）。このディレクトリのファイルは、プラグインによって提供される同様のファイルの後に効果を発揮します。

デモンストレーション目的で、'after/'の一般的な使用方法の例が含まれています。

##### `after/ftplugin/`

ファイルタイププラグイン。[`:h 'filetype'`](https://neovim.io/doc/user/helptag.html?tag='filetype')オプションが設定されたときにソースされるファイルが含まれています。

たとえば、'\*.txt'ファイルには`text`ファイルタイプがあるため、'\*.txt'ファイルが開かれると'ftplugin/text.lua'がソースされます。これは`text`ファイルにのみ存在すべき動作を定義します。

##### `after/lsp/` (Neovim>=0.11用)

LSPサーバーを設定するファイル。これらはNeovimの組み込み[`:h vim.lsp.config()`](https://neovim.io/doc/user/helptag.html?tag=vim.lsp.config())と[`:h vim.lsp.enable()`](https://neovim.io/doc/user/helptag.html?tag=vim.lsp.enable())によって使用されます。詳細については[`:h lsp-quickstart`](https://neovim.io/doc/user/helptag.html?tag=lsp-quickstart)も参照してください。

たとえば、'lsp/lua_ls.lua'ファイルは`vim.lsp.enable({ 'lua_ls' })`中に使用される設定の一部を定義します（つまり、同じ名前で）。

##### `after/snippets/`

言語ごとのスニペット定義を含むファイル。['mini.snippets'](https://nvim-mini.org/mini.nvim/doc/mini-snippets.html)によって使用されます。'after/'に配置されているため、プラグイン（'rafamadriz/friendly-snippets'など）によって提供されるスニペットを上書きします。

たとえば、'snippets/lua.json'に基づいて、Luaファイル内のInsert modeで`l` + `<C-j>`と入力すると、常に`local $1 = $0`スニペットが挿入されます。他のスニペットプロバイダーがこれまたは競合するスニペットを含んでいても関係ありません。
