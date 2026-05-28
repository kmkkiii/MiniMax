-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- このファイルにはMINI以外のプラグインのインストールと設定が含まれています。
-- これらはMINIではまだ実現できない方法でユーザー体験を大幅に向上させます。
-- これらは主にプログラミング言語固有の動作を提供するプラグインです。
--
-- このファイルを使用して、そのような他のプラグインをインストールおよび設定します。

-- 2段階でプラグインをインストール/追加するための簡潔なヘルパーを作成
local add, later = MiniDeps.add, MiniDeps.later
local now_if_args = Config.now_if_args

-- Tree-sitter ================================================================

-- Tree-sitterは高速な増分パースのためのツールです。テキストを階層構造（ツリーと呼ばれる）に
-- 変換し、高度でより正確なアクションを実装するために使用できます: シンタックスハイライト、
-- テキストオブジェクト、インデントなど。
--
-- Tree-sitterサポートはNeovimに組み込まれています (`:h treesitter` を参照)。ただし、
-- Neovimに直接付属していない2つの追加部品が必要です:
-- - 言語パーサー: テキストをツリーに変換するプログラム。いくつかは組み込み（Luaなど）で、
--   'nvim-treesitter' は多くの他のものを提供します。
--   注意: パーサーをビルドおよびインストールするにはサードパーティソフトウェアが必要です。
--   詳細はMiniMax READMEの "Requirements" セクションのリンクを参照してください。
-- - クエリファイル: ツリーから有用な方法で情報を抽出する方法の定義 (`:h treesitter-query`
--   を参照)。'nvim-treesitter' もこれらを提供し、'nvim-treesitter-textobjects' は
--   Neovimのテキストオブジェクト用のものを提供します (`:h text-objects`、
--   `:h MiniAi.gen_spec.treesitter()` を参照)。
--
-- 起動後にファイル（'mini.starter' ではなく）が表示される場合は、これらのプラグインを今すぐ追加します。
--
-- トラブルシューティング:
-- - 潜在的な問題を確認するには `:checkhealth vim.treesitter nvim-treesitter` を実行してください。
-- - Neovimにバンドルされたパーサー (`lua`、`vimdoc`、`markdown` など) のクエリに関連する
--   エラーが発生した場合は、`:TSInstall <language>` で 'nvim-treesitter' 経由で手動で
--   インストールしてください。必要なシステム依存関係があることを確認してください
--   (MiniMax READMEのソフトウェア要件セクションを参照)。
now_if_args(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    -- プラグイン更新後にtree-sitterパーサーを更新
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
    -- プラグインが Neovim=0.10 サポートを落とす直前のコミットに固定
    checkout = '42fc28ba918343ebfd5565147a42a26580579482',
  })
  add({
    source = 'nvim-treesitter/nvim-treesitter-textobjects',
    -- 'nvim-treesitter' のコミットに対応するコミットに固定
    checkout = 'b0debd5c424969b4baeabdc8f54db3036c691732',
  })

  -- パーサーがインストールされ自動で有効化される言語を定義
  -- これを変更した後、必要なパーサーをインストールするためにNeovimを一度再起動してください。
  -- 追加された言語のファイルを開く前にインストールが完了するまで待ってください。
  local languages = {
    -- これらは既にNeovimにプリインストールされています。例として使用されています。
    'lua',
    'vimdoc',
    'markdown',
    -- tree-sitterで使用したいさらに多くの言語をここに追加してください
    -- 利用可能な言語を確認するには:
    -- - `:=require('nvim-treesitter.parsers').available_parsers()` を実行
  }
  require('nvim-treesitter.configs').setup({
    ensure_installed = languages,
    highlight = { enable = true },
    -- 'mini.ai' を優先するため、増分選択を無効化
    incremental_selection = { enable = false },
    -- 'mini.ai' を優先するため、カスタムテキストオブジェクトのマッピングを無効化
    textobjects = { enable = false },
    -- tree-sitterベースのインデントはやや不安定なため無効化
    indent = { enable = false },
  })
end)

-- 言語サーバー ===============================================================

-- Language Server Protocol (LSP) は言語固有のツールの作成を支える規約のセットです。
-- 2つの部分が必要です:
-- - サーバー - 言語固有の計算を実行するプログラム
-- - クライアント - サーバーに計算を要求し結果を表示するプログラム
--
-- ここではNeovim自体がクライアントです (`:h vim.lsp` を参照)。言語サーバーは
-- OS、CLIツール、および設定に基づいて個別にインストールする必要があります。
-- ファイルの最後にある 'mason.nvim' に関する注意を参照してください。
--
-- Neovimチームは、ほとんどの言語サーバーの一般的に使用される設定を
-- 'neovim/nvim-lspconfig' プラグイン内に収集しています。注意: Neovim>=0.11 で
-- `vim.lsp.config` アプローチを使用するため大きく刷新されました。そのため、この
-- プラグインを使用するには少なくとも Neovim 0.11 に更新することを強く推奨します。
--
-- 起動後にファイル（'mini.starter' ではなく）が表示される場合は、今すぐ追加します。
--
-- トラブルシューティング:
-- - 潜在的な問題を確認するには `:checkhealth vim.lsp` を実行してください。
now_if_args(function()
  add({
    source = 'neovim/nvim-lspconfig',
    -- プラグインが Neovim=0.10 サポートを落とす直前のコミットに固定
    -- この時点では Neovim>=0.11 の `vim.lsp.config` アプローチへの移行中で、
    -- ヘルプはすでに先行しています。
    checkout = '5bfcc89fd155b4ffc02d18ab3b7d19c2d4e246a7',
  })

  -- サーバーごとの設定は、対象サーバーを明示的にセットアップして行います。
  -- 例: `require('lspconfig').<server-name>.setup({ ... })`。
  -- `...` の代わりにサーバーごとの設定を渡します。以下は `lua_ls` の設定例です。
  -- LuaファイルでLSPサーバー（インストール済みの場合）を有効化するにはコメント解除してください。

  -- require('lspconfig').lua_ls.setup({
  --   on_attach = function(client, bufnr)
  --     -- クライアントごとの設定や機能を調整します。たとえば、より良い
  --     -- 'mini.completion' 体験のために非常に長い補完トリガー一覧を絞ります
  --     client.server_capabilities.completionProvider.triggerCharacters = { '.', ':' }
  --   end,
  --   settings = {
  --     Lua = {
  --       runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
  --     },
  --   },
  -- })
end)

-- フォーマット ===============================================================

-- テキストフォーマット専用のプログラム（別名フォーマッター）は非常に便利です。
-- Neovimにはテキストフォーマット用の組み込みツールがあります (`:h gq` と `:h 'formatprg'`
-- を参照)。これらは外部プログラムを設定するために使用できますが、面倒になる可能性があります。
--
-- 'stevearc/conform.nvim' プラグインは、より簡単なフォーマットセットアップのための
-- 優れたメンテナンスされたソリューションです。
later(function()
  add('stevearc/conform.nvim')

  -- 参照:
  -- - `:h Conform`
  -- - `:h conform-options`
  -- - `:h conform-formatters`
  require('conform').setup({
    default_format_opts = {
      -- 専用のフォーマッターが利用できない場合はLSPサーバーからのフォーマットを許可
      lsp_format = 'fallback',
    },
    -- ファイルタイプからフォーマッターへのマップ
    -- 必要なCLIツールが利用可能であることを確認してください
    -- formatters_by_ft = { lua = { 'stylua' } },
  })
end)

-- スニペット =================================================================

-- 'mini.snippets' はスニペットファイルを管理する機能を提供しますが、
-- 意図的にそれらを含んでいません。
--
-- 'rafamadriz/friendly-snippets' は現在最大のスニペットファイルのコレクションです。
-- これらは（ほとんど）言語ごとに 'snippets/' ディレクトリに整理されています。
-- 'mini.snippets' はできるだけシームレスに動作するように設計されています。
-- `:h MiniSnippets.gen_loader.from_lang()` を参照してください。
later(function() add('rafamadriz/friendly-snippets') end)

-- 名誉ある言及 ===============================================================

-- 'mason-org/mason.nvim'（別名 "Mason"）は、外部の言語サーバー、フォーマッター、
-- リンターをインストールするための優れたツール（パッケージマネージャー）です。
-- そのようなプログラムをインストール、更新、削除するための統一されたインターフェースを提供します。
--
-- 注意点は、これらのプログラムは主にNeovim内で使用されるように設定されることです。
-- 他の場所で動作させる必要がある場合は、他のパッケージマネージャーの使用を検討してください。
--
-- 次のように使用できます:
-- now_if_args(function()
--   add('mason-org/mason.nvim')
--   require('mason').setup()
-- end)

-- 'mini.nvim' 外の美しく、使いやすく、よくメンテナンスされたカラースキームで、
-- そのハイライトグループを完全にサポートしています。'plugin/30_mini.lua' で有効化された
-- 'miniwinter' または他の提案された 'mini.hues' ベースのものが気に入らない場合に使用します。
-- MiniDeps.now(function()
--   -- 必要なもののみをインストール
--   add('sainnhe/everforest')
--   add('Shatur/neovim-ayu')
--   add('ellisonleao/gruvbox.nvim')
--
--   -- 1つだけ有効化
--   vim.cmd('color everforest')
-- end)
