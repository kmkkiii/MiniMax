-- 警告: NEOVIM 0.13 はまだ開発中であり安定版ではありません。
-- 最新の開発版を使い続けることに抵抗がないことを確認してください。
-- この設定は少なくともバージョン `v0.13.0-dev-29+g1bcf2d7f90` で検証されています。
-- 迷った場合は最新の開発版に更新してください。

-- ┌────────────────────┐
-- │ Welcome to MiniMax │
-- └────────────────────┘
--
-- これは主にMINIを使用するように設計された設定です。すぐに使える
-- 安定した、洗練された、機能豊富なNeovim体験を提供します。構成:
--
-- ├ init.lua          起動時に実行される初期ファイル（このファイル）
-- ├ plugin/           起動時に自動的に読み込まれるファイル群
-- ├── 10_options.lua  Neovimの組み込み動作設定
-- ├── 20_keymaps.lua  カスタムキーマッピング
-- ├── 30_mini.lua     MINI設定
-- ├── 40_plugins.lua  MINI以外のプラグイン
-- ├ snippets/         ユーザー定義スニペット（デモファイル有り）
-- ├ after/            プラグインによる動作を上書きするファイル群
-- ├── ftplugin/       ファイルタイプ固有の動作設定（デモファイル有り）
-- ├── lsp/            言語サーバー設定（デモファイル有り）
-- ├── snippets/       より高い優先度のスニペットファイル（デモファイル有り）
--
-- 設定ファイルは読まれることを想定しており、できればこの設定を実行している
-- Neovimインスタンス内で、ルートディレクトリで開いて読むことを推奨します。これにより
-- セットアップをより深く理解できます。このファイルから始めてください。どの順序でも
-- 可能ですが、上記の順序を推奨します。設定をナビゲートする方法:
-- - `<Space>` + `e` + (いずれか) `iokmp` - 'init.lua' または 'plugin/' ファイルを編集
-- - 設定ディレクトリ内で: `<Space>ff` (ピッカー) または `<Space>ed` (エクスプローラー)
-- - 既存のバッファ間の移動: `[b`、`]b`、または `<Space>fb`
--
-- 設定ファイルはカスタマイズされることも想定しています。最初はMINIベースの
-- 動作する設定のベースラインです。あなた好みに変更してください。いくつかのアプローチ:
-- - 一貫性を保ちながら既存ファイルを変更する
-- - 設定の一貫性を保ちながら新しいファイルを追加する
--   通常は 'plugin/' または 'after/' 内に追加
--
-- このようなドキュメントコメントは、設定全体に渡って見られます。
-- 一般的な規約:
--
-- - 使用されるキー表記については `:h key-notation` を参照
-- - `:h xxx` は "ヘルプタグ xxx のドキュメント" を意味します。テキストを直接入力して
--   Enterを押すか、`<Space>fh` でヘルプタグのファジーピッカーを開けます
-- - "`<Space>fh` を入力" は "<Space> を押し、続いて f、続いて h を押す" を意味します
--   特に断りがない限り、Normal mode であることを想定しています
-- - "'path/to/file' を参照" は、記述されたパスでファイルを開いて読むことを意味します
-- - `:SomeCommand ...` または `:lua ...` は、記述されたコマンドを実行することを意味します

-- ┌────────────────┐
-- │ Plugin manager │
-- └────────────────┘
--
-- この設定は `vim.pack` - 組み込みプラグインマネージャーを使用します。主なエントリ
-- ポイントは `vim.pack.add()` 関数で、「よりスマートな `:packadd`」として動作します:
-- ソースからインストールされていることを確認した後にプラグインをロードします。
-- インストールされたプラグインの状態は 'nvim-pack-lock.json' というロックファイルに記録されます。
-- 使用例:
-- - `vim.pack.add({ ... })` - 設定内で1つ以上のプラグインを追加
-- - `:lua vim.pack.update()` - すべてのプラグインを更新; `:write` を実行して確認
-- - `:lua vim.pack.del({ ... })` - 特定のプラグインを削除
--
-- 参照:
-- - `:h vim.pack-examples` - 使用方法
-- - `:h vim.pack-lockfile` - ロックファイル情報
-- - `:h vim.pack-events` - 利用可能なイベントとプラグインフック例
-- - `:h vim.pack.update()` - 確認ステップの詳細

-- スクリプト間でデータを渡せるように設定テーブルを定義
-- `_G.Config` と `Config` の両方として使用できるグローバル変数です
_G.Config = {}

-- 'mini.nvim' - MiniMaxのほとんどの機能を支えるオールインワンプラグイン。
-- 使用方法については 'plugin/30_mini.lua' を参照してください。
-- カスタムローディングヘルパーで使用するために 'mini.misc' を今すぐロードします。
vim.pack.add({ 'https://github.com/nvim-mini/mini.nvim' })

-- 設定をフェイルセーフなパーツに整理するために使用されるローディングヘルパー。使用例:
-- - `now` - 即座に実行。起動時に実行する必要があるものに使用。
--   カラースキーム、ステータスライン、タブライン、ダッシュボードなど。
-- - `later` - 少し後に実行。起動時に必要でないものに使用。
-- - `now_if_args` - Neovimが `nvim -- path/to/file` のように起動された場合のみ
--   起動時にセットアップが必要で、それ以外は遅延しても問題ない場合に使用。
-- - 上記で十分なパフォーマンスが得られない場合にのみ使用するのが望ましいもの。
--   設定に複雑さを加えることに抵抗がない場合のみ使用してください:
--   - `on_event` - 最初にマッチしたイベントで一度実行。例: 「最初のInsert mode
--     開始まで遅延」: `on_event('InsertEnter', function() ... end)`
--   - `on_filetype` - 最初にマッチしたファイルタイプで一度実行。例: 「最初の
--     Luaファイルまで遅延」: `on_filetype('lua', function() ... end)`
--
-- 参照:
-- - `:h MiniMisc.safely()`
-- - 'plugin/30_mini.lua' と 'plugin/40_plugins.lua'
local misc = require('mini.misc')
Config.now = function(f) misc.safely('now', f) end
Config.later = function(f) misc.safely('later', f) end
Config.now_if_args = vim.fn.argc(-1) > 0 and Config.now or Config.later
Config.on_event = function(ev, f) misc.safely('event:' .. ev, f) end
Config.on_filetype = function(ft, f) misc.safely('filetype:' .. ft, f) end

-- カスタム自動コマンドグループと、自動コマンドを作成するヘルパーを定義。
-- 自動コマンドは、イベント発生時にアクションを実行するNeovimの仕組みです
-- (バッファ作成、オプション設定など)。
--
-- 参照:
-- - `:h autocommand`
-- - `:h nvim_create_augroup()`
-- - `:h nvim_create_autocmd()`
local gr = vim.api.nvim_create_augroup('custom-config', {})
Config.new_autocmd = function(event, pattern, callback, desc)
  local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
  vim.api.nvim_create_autocmd(event, opts)
end

-- カスタム `vim.pack.add()` フックヘルパーを定義します。プラグインデータは
-- コールバックの引数として渡されます。`:h vim.pack-events` を参照してください。
-- 使用例: 'plugin/40_plugins.lua' を参照。
Config.on_packchanged = function(plugin_name, kinds, callback, desc)
  local f = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then return end
    if not ev.data.active then vim.cmd.packadd(plugin_name) end
    callback(ev.data)
  end
  Config.new_autocmd('PackChanged', '*', f, desc)
end
