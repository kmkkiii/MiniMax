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

-- 'mini.deps' によって管理されるように 'mini.nvim' を手動でブートストラップ
local mini_path = vim.fn.stdpath('data') .. '/site/pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local origin = 'https://github.com/nvim-mini/mini.nvim'
  local clone_cmd = { 'git', 'clone', '--filter=blob:none', origin, mini_path }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- プラグインマネージャー。`now()`/`later()` ヘルパーのために即座にセットアップ。
-- 使用例:
-- - `MiniDeps.add('...')` - 設定内でプラグインを追加
-- - `:DepsUpdate` - すべてのプラグインを更新
-- - `:DepsSnapSave` - 現在アクティブなプラグインのスナップショットを保存
--
-- 参照:
-- - `:h MiniDeps-overview` - 使用方法
-- - `:h MiniDeps-commands` - 利用可能なすべてのコマンド
-- - 'plugin/30_mini.lua' - 'mini.nvim' 全般についての詳細
require('mini.deps').setup()

-- スクリプト間でデータを渡せるように設定テーブルを定義
-- `_G.Config` と `Config` の両方として使用できるグローバル変数です
_G.Config = {}

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

-- 一部のプラグインと 'mini.nvim' モジュールは、Neovimが `nvim -- path/to/file` の
-- ように起動された場合のみ起動時のセットアップが必要で、それ以外は遅延セットアップで問題ありません
Config.now_if_args = vim.fn.argc(-1) > 0 and MiniDeps.now or MiniDeps.later
