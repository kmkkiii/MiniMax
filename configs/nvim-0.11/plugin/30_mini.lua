-- ┌────────────────────┐
-- │ MINI configuration │
-- └────────────────────┘
--
-- このファイルには設定のMINI部分の設定が含まれています。
-- 'mini.nvim' プラグイン（'init.lua' でインストール）の設定のみが含まれています。
--
-- 'mini.nvim' はモジュールのライブラリです。各モジュールは `require('mini.xxx').setup()`
-- という規約を通じて独立して有効化されます。これはすべての意図された副作用を作成します:
-- マッピング、自動コマンド、ハイライトグループなど。また、後でモジュールの機能にアクセス
-- するために使用できるグローバルな `MiniXxx` テーブルを作成します。
--
-- すべてのモジュールの `setup()` 関数は、その動作を調整するためのオプションの `config`
-- テーブルを受け入れます。このテーブルの構造は `:h MiniXxx.config` を参照してください。
--
-- より一般的な原則については `:h mini.nvim-general-principles` を参照してください。
--
-- ここでは各モジュールの `setup()` に、モジュールが何のためのものか、その使用例
-- ('plugin/20_keymaps.lua' のLeaderマッピングを使用)、および詳細情報の方向性について
-- 簡単な説明があります。
-- モジュールの詳細については、そのヘルプページを参照してください（'mini.xxx' の場合は `:h mini.xxx`）。

-- 最初の画面描画までの時間を最小限にするため、モジュールは2つのステップで有効化されます:
-- - ステップ1は `now()` で最初の描画に必要なすべてを有効化します。
--   Neovimが `nvim -- path/to/file` として起動された場合にのみ必要な場合があります。
-- - それ以外はすべて `later()` で最初の描画まで遅延されます。
local now, later = MiniDeps.now, MiniDeps.later
local now_if_args = _G.Config.now_if_args

-- ステップ1 =================================================================
-- 'miniwinter' カラースキームを有効化。これは 'mini.nvim' に付属し、'mini.hues' を使用します。
--
-- 参照:
-- - `:h mini.nvim-color-schemes` - 他のカラースキームのリスト
-- - `:h MiniHues-examples` - 'mini.hues' でハイライトを定義する方法
-- - 'plugin/40_plugins.lua' の名誉ある言及 - 他の優れたカラースキーム
now(function() vim.cmd('colorscheme miniwinter') end)

-- これらの他の 'mini.hues' ベースのカラースキームを試すことができます（`gcc` でコメント解除）:
-- now(function() vim.cmd('colorscheme minispring') end)
-- now(function() vim.cmd('colorscheme minisummer') end)
-- now(function() vim.cmd('colorscheme miniautumn') end)
-- now(function() vim.cmd('colorscheme randomhue') end)

-- 一般的な設定プリセット。使用例:
-- - Insert modeで `<C-s>` - 保存してNormal modeに移行
-- - `go` / `gO` - Normal modeで前/後に空行を挿入
-- - `gy` / `gp` - システムクリップボードからコピー/ペースト
-- - `\` + キー - 一般的なオプションを切り替え。例: `\h` は検索のハイライトを切り替え
-- - `<C-hjkl>`（4つの組み合わせ）- ウィンドウ間を移動
-- - Insert/Command modeで `<M-hjkl>` - そのモードで移動
--
-- 参照:
-- - `:h MiniBasics.config.options` - 調整されたオプションのリスト
-- - `:h MiniBasics.config.mappings` - 作成されたマッピングのリスト
-- - `:h MiniBasics.config.autocommands` - 作成された自動コマンドのリスト
now(function()
  require('mini.basics').setup({
    -- 教育目的で 'plugin/10_options.lua' でオプションを管理
    options = { basic = false },
    mappings = {
      -- ウィンドウナビゲーション用の `<C-hjkl>` マッピングを作成
      windows = true,
      -- InsertとCommandモードでのナビゲーション用の `<M-hjkl>` マッピングを作成
      move_with_alt = true,
    },
  })
end)

-- アイコンプロバイダー。通常、手動で使用する必要はありません。'mini.pick'、'mini.files'、
-- 'mini.statusline' などのプラグインによって使用されます。
now(function()
  -- 一部の拡張子に対して拡張子ベースのアイコンを優先しないように設定
  local ext3_blocklist = { scm = true, txt = true, yml = true }
  local ext4_blocklist = { json = true, yaml = true }
  require('mini.icons').setup({
    use_file_extension = function(ext, _)
      return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
    end,
  })

  -- 'mini.icons' サポートのないプラグインのために 'nvim-tree/nvim-web-devicons' をモック。
  -- 'mini.nvim' または MiniMax には不要ですが、他のプラグインには有用かもしれません。
  later(MiniIcons.mock_nvim_web_devicons)

  -- LSP kindアイコンを追加。'mini.completion' に有用です。
  later(MiniIcons.tweak_lsp_kind)
end)

-- さまざまな小さいが便利な関数群。使用例:
-- - `<Leader>oz` - 現在のバッファの「ズーム」表示と通常表示を切り替え
-- - `<Leader>or` - ウィンドウを「編集可能な幅」にリサイズ
-- - `:lua put_text(vim.lsp.get_clients())` - 関数の出力を現在のバッファの
--   カーソル下に配置。詳細な探索に便利です。
-- - `:lua put(MiniMisc.stat_summary(MiniMisc.bench_time(f, 100)))` - 関数 `f` を
--   100回実行し、実行時間の統計サマリーをレポート
--
-- `nvim -- path/to/file` のように起動された場合に `setup_xxx()` が動作するように `now()` を使用
now_if_args(function()
  -- `:h MiniMisc.put()` と `:h MiniMisc.put_text()` を公開
  require('mini.misc').setup()

  -- 現在のファイルパスに基づいて現在の作業ディレクトリを変更。最初のルートマーカー
  -- （'.git' または 'Makefile'）までファイルツリーを上に検索し、その親ディレクトリを
  -- 現在のディレクトリとして設定します。
  -- これは複数のプロジェクトのファイルを同時に扱う際に役立ちます。
  MiniMisc.setup_auto_root()

  -- ファイルを開く際に最後のカーソル位置を復元
  MiniMisc.setup_restore_cursor()

  -- Neovimインスタンスの周りの異なる可能性のあるカラーパディングを削除するために
  -- ターミナルエミュレータの背景とNeovimの背景を同期
  MiniMisc.setup_termbg_sync()
end)

-- 通知プロバイダー。あらゆる種類の通知を右上隅（デフォルト）に表示します。使用例:
-- - `:h vim.notify()` - 通知を表示（自動的に非表示）
-- - `<Leader>en` - 通知履歴を表示
--
-- 参照:
-- - `:h MiniNotify.config` - 一般的な設定例
now(function() require('mini.notify').setup() end)

-- セッション管理。セッションファイルを一貫して管理する `:h mksession` の薄いラッパー。使用例:
-- - `<Leader>sn` - 新しいセッションを開始
-- - `<Leader>sr` - 以前に開始したセッションを読み込み
-- - `<Leader>sd` - 以前に開始したセッションを削除
now(function() require('mini.sessions').setup() end)

-- スタート画面。`nvim` のようにNeovimを開いたときに表示されるものです。使用例:
-- - プレフィックスキーを入力して利用可能な候補を制限
-- - `<C-n>` と `<C-p>` で下/上に移動
-- - `<CR>` を押してエントリを選択
--
-- 参照:
-- - `:h MiniStarter-example-config` - デフォルト以外の設定例
-- - `:h MiniStarter-lifecycle` - Starterバッファでの作業方法
now(function() require('mini.starter').setup() end)

-- ステータスライン。ウィンドウ下の行により多くの情報を表示するために `:h 'statusline'` を設定します。使用例:
-- - 最も左のセクションは現在のモードを示します（テキスト + ハイライト）
-- - 左から2番目のセクションは「開発者情報」を表示: Git、diff、診断、LSP
-- - 中央のセクションは表示されているバッファの名前を表示
-- - 右から2番目のセクションはより多くのバッファ情報を表示
-- - 最も右のセクションは現在のカーソル座標と検索結果を表示
--
-- See also:
-- - `:h MiniStatusline-example-content` - example of default content. Use it to
--   `config.content.active` 関数を設定してカスタムステータスラインを設定できます。
now(function() require('mini.statusline').setup() end)

-- タブライン。すべてのリストされたバッファを上部の行に表示するために `:h 'tabline'` を設定します。
-- バッファは作成された順序で並べられます。`[b` と `]b` でナビゲートします。
now(function() require('mini.tabline').setup() end)

-- ステップ2 =================================================================

-- 追加の 'mini.nvim' 機能。
--
-- 参照:
-- - `:h MiniExtra.pickers` - ピッカー。ほとんどは `<Leader>f` グループにマッピングされています。
--   `setup()` を呼び出すと 'mini.pick' が 'mini.extra' ピッカーを尊重します。
-- - `:h MiniExtra.gen_ai_spec` - 'mini.ai' テキストオブジェクト仕様
-- - `:h MiniExtra.gen_highlighter` - 'mini.hipatterns' ハイライター
later(function() require('mini.extra').setup() end)

-- `:h a(`、`:h a'` などの a/i テキストオブジェクトを拡張および作成します。
-- `a` と `i` タイプのテキストオブジェクトだけでなく、カーソルの後と前のテキストオブジェクトを
-- 明示的に検索する "next" と "last" バリアントも含まれます。使用例:
-- - `ci)` - 括弧（`)`）内を変更（*c*hange *i*nside）
-- - `di(` - パディングされた括弧（`(`）内を削除（*d*elete *i*nside）
-- - `yaq` - クォート（""、''、または `` のいずれか）周囲をヤンク（*y*ank *a*round *q*uote）
-- - `vif` - 関数呼び出し内を視覚的に選択（*v*isually select *i*nside *f*unction call）
-- - `cina` - 次の引数内を変更（*c*hange *i*nside *n*ext *a*rgument）
-- - `valaala` - 最後（つまり前）の引数周囲を視覚的に選択（*v*isually select *a*round *l*ast *a*rgument）
--   してから再び新しい最後の引数周囲を再選択（*a*round new *l*ast *a*rgument）
--
-- 参照:
-- - `:h text-objects` - テキストオブジェクトとは何かについての一般情報
-- - `:h MiniAi-builtin-textobjects` - サポートされているすべてのテキストオブジェクトのリスト
-- - `:h MiniAi-textobject-specification` - カスタムテキストオブジェクトの例
later(function()
  local ai = require('mini.ai')
  ai.setup({
    -- 'mini.ai' はカスタムテキストオブジェクトで拡張できます
    custom_textobjects = {
      -- `aB` / `iB` をバッファ全体の周囲/内側に作用させる
      B = MiniExtra.gen_ai_spec.buffer(),
      -- 構造認識が必要なより複雑なテキストオブジェクトの場合は、tree-sitterを使用します。
      -- この例では `aF`/`iF` を関数定義（呼び出しではない）の周囲/内側を意味するようにします。
      -- 詳細は `:h MiniAi.gen_spec.treesitter()` を参照してください。
      F = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
    },

    -- 'mini.ai' はデフォルトでほぼ組み込みの検索動作を模倣します: 最初にカーソルを
    -- カバーするテキストオブジェクトを見つけようとし、次に右側を見つけようとします。
    -- これはほとんどの場合機能しますが、混乱する場合もあります。常にカバーする
    -- テキストオブジェクトのみを検索し、次（`an`/`in`）または最後（`al`/`il`）を
    -- 明示的に検索するように要求する方がより堅牢です。
    -- これを試してください。気に入らない場合は次の行とこのコメントを削除してください。
    search_method = 'cover',
  })
end)

-- テキストを対話的に整列します。使用例:
-- - `gaip,` - `ga`（整列オペレーター）を段落内でカンマによって実行
-- - `gAip` - 段落で対話的な整列を開始。文字列部分を分割、配置、マージする方法を選択。
--   `<CR>` を押すと永続化し、`<Esc>` を押すと初期状態に戻ります。
--
-- 参照:
-- - `:h MiniAlign-example` - 整列を練習するための実践的な例のリスト
-- - `:h MiniAlign.gen_step` - サポートされるステップカスタマイズのリスト
-- - `:h MiniAlign-algorithm` - アルゴリズムレベルで整列がどのように行われるか
later(function() require('mini.align').setup() end)

-- 一般的なNeovimアクションをアニメーション化します。カーソル移動、スクロール、ウィンドウ
-- リサイズ、ウィンドウを開く、ウィンドウを閉じるなど。アニメーションはNeovimイベントに
-- 基づいて行われ、カスタムマッピングは必要ありません。
--
-- その効果は好みの問題であるため、デフォルトでは有効になっていません。
-- また、スクロールとリサイズにはいくつかの望ましくない副作用があります (`:h mini.animate` を参照)。
-- 有効にするには次の行のコメントを解除してください（`gcc` を使用）。
-- later(function() require('mini.animate').setup() end)

-- 角括弧で前/後に移動します。選択されたターゲット（バッファ、診断、quickfixリスト
-- エントリなど）に対して一貫したマッピングのセットを実装します。使用例:
-- - `]b` - 次のバッファに移動
-- - `[j` - 現在のバッファ内の前のジャンプに移動
-- - `[Q` - quickfixリストの最初のエントリに移動
-- - `]X` - バッファ内の最後のコンフリクトマーカーに移動
--
-- 参照:
-- - `:h MiniBracketed` - 全体的なマッピング設計とターゲットのリスト
later(function() require('mini.bracketed').setup() end)

-- バッファを削除します。開いたファイルはタブラインとバッファピッカーでスペースを占有します。
-- 不要になったら削除できます。使用例:
-- - `<Leader>bw` - 現在のバッファを完全にワイプアウト（`:h :bwipeout` を参照）
-- - `<Leader>bW` - 変更があっても現在のバッファを完全にワイプアウト
-- - `<Leader>bd` - 現在のバッファを削除（`:h :bdelete` を参照）
later(function() require('mini.bufremove').setup() end)

-- 次のキーヒントを右下のウィンドウに表示します。ヒントトリガーとして機能するキーには
-- 明示的なオプトインが必要です。使用例:
-- - `<Leader>` を押して1秒待ちます。次の利用可能なキーに関する情報を含むウィンドウが表示されます。
-- - リストされているキーの1つを押します。ウィンドウは即座に更新され、新しい次の利用可能な
--   キーに関する情報が表示されます。`<BS>` を押してキーシーケンスを戻ることができます。
-- - キーがマッピングに解決されるまでキーを押します。
--
-- 注意: これは通常のファイル用のバッファで動作するように設計されています。
-- ローカルマッピングと競合しないように、特別なバッファ（'mini.starter' や 'mini.files' など）では
-- 動作しません。
--
-- 参照:
-- - `:h MiniClue-examples` - 一般的なセットアップの例
-- - `:h MiniClue.ensure_buf_triggers()` - バッファでトリガーを有効にするために使用
-- - `:h MiniClue.set_mapping_desc()` - 設定からではなくマッピングの説明を変更
later(function()
  local miniclue = require('mini.clue')
  -- stylua: ignore
  miniclue.setup({
    -- 表示するヒントを定義。デフォルトではカスタムマッピングのヒントのみを表示
    -- （マッピングの `desc` フィールドを使用; カスタムヒントよりも優先されます）。
    clues = {
      -- これは 'plugin/20_keymaps.lua' でLeaderグループの説明とともに定義されています
      Config.leader_group_clues,
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.square_brackets(),
      -- これはウィンドウリサイズマッピングのサブモードを作成します。次を試してください:
      -- - `<C-w>s` を押してウィンドウを分割します。
      -- - `<C-w>+` を押して高さを増やします。ヒントウィンドウは `<C-w>` が再び
      --   押されたかのようにヒントを表示し続けます。`+` だけを押し続けて高さを増やします。
      --   `-` を押して高さを減らすことを試してください。
      -- - `<Esc>` またはサブモードにないキーでサブモードを停止します。
      miniclue.gen_clues.windows({ submode_resize = true }),
      miniclue.gen_clues.z(),
    },
    -- ヒントウィンドウをトリガーする一般的なキーのセットに明示的にオプトイン
    triggers = {
      { mode = { 'n', 'x' }, keys = '<Leader>' }, -- Leaderトリガー
      { mode =   'n',        keys = '\\' },       -- mini.basics
      { mode = { 'n', 'x' }, keys = '[' },        -- mini.bracketed
      { mode = { 'n', 'x' }, keys = ']' },
      { mode =   'i',        keys = '<C-x>' },    -- 組み込み補完
      { mode = { 'n', 'x' }, keys = 'g' },        -- `g` キー
      { mode = { 'n', 'x' }, keys = "'" },        -- マーク
      { mode = { 'n', 'x' }, keys = '`' },
      { mode = { 'n', 'x' }, keys = '"' },        -- レジスタ
      { mode = { 'i', 'c' }, keys = '<C-r>' },
      { mode =   'n',        keys = '<C-w>' },    -- ウィンドウコマンド
      { mode = { 'n', 'x' }, keys = 's' },        -- `s` キー (mini.surround など)
      { mode = { 'n', 'x' }, keys = 'z' },        -- `z` キー
    },
  })
end)

-- コマンドラインの調整。コマンドライン編集を次のように改善します:
-- - 自動補完。基本的には自動化された `:h cmdline-completion`
-- - 入力時の単語の自動修正。`:W`->`:w`、`:lau`->`:lua` など
-- - 入力時のコマンド範囲（開始時の行番号など）の自動プレビュー
later(function() require('mini.cmdline').setup() end)

-- 任意のカラースキームを調整して保存します。色空間とカラースキームを操作するための
-- ユーティリティ関数が含まれています。使用例:
-- - `:Colorscheme default` - アニメーション付きでデフォルトのカラースキームに切り替え
--
-- 参照:
-- - `:h MiniColors.interactive()` - カラースキームを対話的に調整
-- - `:h MiniColors-recipes` - 対話的な調整中に使用する一般的なレシピ
-- - `:h MiniColors.convert()` - 色空間間の変換
-- - `:h MiniColors-color-spaces` - サポートされている色空間のリスト
--
-- 日常的には本当に必要ではないため、デフォルトでは有効になっていません。
-- 有効にするには次の行のコメントを解除してください（`gcc` を使用）。
-- later(function() require('mini.colors').setup() end)

-- 行をコメントアウトします。コメント行を操作する機能を提供します。
-- コメント構造を推測するために `:h 'commentstring'` オプションを使用します。
-- 使用例:
-- - `gcip` - 段落内のコメントを切り替え（`gc`）
-- - `vapgc` - 段落周囲を視覚的に選択（*v*isually select *a*round *p*aragraph）して
--   コメントを切り替え（`gc`）
-- - `gcgc` - カーソル位置のコメントブロックのコメント解除（`gc`、オペレーター）
--   (`gc`、テキストオブジェクト）
--
-- 組み込みの `:h commenting` は 'mini.comment' に基づいています。それでもこのモジュールは
-- より多くのカスタマイズの機会を提供するため、まだ有効になっています。
later(function() require('mini.comment').setup() end)

-- 補完とシグネチャヘルプ。非同期の「2段階」自動補完を実装します:
-- - 補完をサポートするアタッチされたLSPサーバーに基づく
-- - LSP候補がない場合のフォールバック（組み込みキーワード補完に基づく）
--
-- アタッチされたLSPでのInsert modeでの使用例:
-- - LSPが認識すべきテキスト（変数名など）の入力を開始します。
-- - 100ms後に候補を含むポップアップメニューが表示されます。
-- - `<Tab>` / `<S-Tab>` を押してリストを下/上にナビゲートします。これらは 'mini.keymap'
--   で設定されています。`<C-n>` / `<C-p>` も使用できます。
-- - ナビゲーション中、右側に情報ウィンドウが表示され、LSPサーバーが候補について提供できる
--   追加情報が表示されます。候補が100ms選択された後に表示されます。`<C-f>` / `<C-b>` を
--   使用してスクロールできます。
-- - エントリにナビゲートするとバッファテキストも変更されます。それで満足な場合は、
--   その後入力を続けます。補完を完全に破棄するには、`<C-e>` を押します。
-- - 特別なトリガー（通常は `(`）を押すと、現在の関数/メソッドのシグネチャを表示する
--   ウィンドウが表示されます。入力すると更新され、現在アクティブなパラメーターが表示されます。
--
-- アタッチされたLSPなし、またはLSPがサポートしていない場所（コメントなど）での
-- Insert modeでの使用例:
-- - 現在のバッファまたは開いているバッファに存在する単語の入力を開始します。
-- - 100ms後に候補を含むポップアップメニューが表示されます。
-- - `<Tab>` / `<S-Tab>` または `<C-n>` / `<C-p>` でナビゲートします。これによりバッファ
--   テキストも更新されます。選択に満足したら、入力を続けます。`<C-e>` で停止します。
--
-- LSPサーバーが提供するスニペット候補でも機能します。'mini.snippets'（このファイルで
-- セットアップされています）と組み合わせると最高の体験が得られます。
later(function()
  -- Customize post-processing of LSP responses for a better user experience.
  -- Don't show 'Text' suggestions (usually noisy) and show snippets last.
  local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
  local process_items = function(items, base)
    return MiniCompletion.default_process_items(items, base, process_items_opts)
  end
  require('mini.completion').setup({
    lsp_completion = {
      -- Without this config autocompletion is set up through `:h 'completefunc'`.
      -- Although not needed, setting up through `:h 'omnifunc'` is cleaner
      -- (sets up only when needed) and makes it possible to use `<C-u>`.
      source_func = 'omnifunc',
      auto_setup = false,
      process_items = process_items,
    },
  })

  -- Set 'omnifunc' for LSP completion only when needed.
  local on_attach = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
  end
  _G.Config.new_autocmd('LspAttach', nil, on_attach, "Set 'omnifunc'")

  -- Advertise to servers that Neovim now supports certain set of completion and
  -- signature features through 'mini.completion'.
  vim.lsp.config('*', { capabilities = MiniCompletion.get_lsp_capabilities() })
end)

-- Autohighlight word under cursor with a customizable delay.
-- Word boundaries are defined based on `:h 'iskeyword'` option.
--
-- It is not enabled by default because its effects are a matter of taste.
-- Uncomment next line (use `gcc`) to enable.
-- later(function() require('mini.cursorword').setup() end)

-- Work with diff hunks that represent the difference between the buffer text and
-- some reference text set by a source. Default source uses text from Git index.
-- Also provides summary info used in developer section of 'mini.statusline'.
-- Example usage:
-- - `ghip` - apply hunks (`gh`) within *i*nside *p*aragraph
-- - `gHG` - reset hunks (`gH`) from cursor until end of buffer (`G`)
-- - `ghgh` - apply (`gh`) hunk at cursor (`gh`)
-- - `gHgh` - reset (`gH`) hunk at cursor (`gh`)
-- - `<Leader>go` - toggle overlay
--
-- See also:
-- - `:h MiniDiff-overview` - overview of how module works
-- - `:h MiniDiff-diff-summary` - available summary information
-- - `:h MiniDiff.gen_source` - available built-in sources
later(function() require('mini.diff').setup() end)

-- Navigate and manipulate file system
--
-- Navigation is done using column view (Miller columns) to display nested
-- directories, they are displayed in floating windows in top left corner.
--
-- Manipulate files and directories by editing text as regular buffers.
--
-- Example usage:
-- - `<Leader>ed` - open current working directory
-- - `<Leader>ef` - open directory of current file (needs to be present on disk)
--
-- Basic navigation:
-- - `l` - go in entry at cursor: navigate into directory or open file
-- - `h` - go out of focused directory
-- - Navigate window as any regular buffer
-- - Press `g?` inside explorer to see more mappings
--
-- Basic manipulation:
-- - After any following action, press `=` in Normal mode to synchronize, read
--   carefully about actions, press `y` or `<CR>` to confirm
-- - New entry: press `o` and type its name; end with `/` to create directory
-- - Rename: press `C` and type new name
-- - Delete: type `dd`
-- - Move/copy: type `dd`/`yy`, navigate to target directory, press `p`
--
-- See also:
-- - `:h MiniFiles-navigation` - more details about how to navigate
-- - `:h MiniFiles-manipulation` - more details about how to manipulate
-- - `:h MiniFiles-examples` - examples of common setups
later(function()
  -- Enable directory/file preview
  require('mini.files').setup({ windows = { preview = true } })

  -- Add common bookmarks for every explorer. Example usage inside explorer:
  -- - `'c` to navigate into your config directory
  -- - `g?` to see available bookmarks
  local add_marks = function()
    MiniFiles.set_bookmark('c', vim.fn.stdpath('config'), { desc = 'Config' })
    local minideps_plugins = vim.fn.stdpath('data') .. '/site/pack/deps/opt'
    MiniFiles.set_bookmark('p', minideps_plugins, { desc = 'Plugins' })
    MiniFiles.set_bookmark('w', vim.fn.getcwd, { desc = 'Working directory' })
  end
  _G.Config.new_autocmd('User', 'MiniFilesExplorerOpen', add_marks, 'Add bookmarks')
end)

-- Git integration for more straightforward Git actions based on Neovim's state.
-- It is not meant as a fully featured Git client, only to provide helpers that
-- integrate better with Neovim. Example usage:
-- - `<Leader>gs` - show information at cursor
-- - `<Leader>gd` - show unstaged changes as a patch in separate tabpage
-- - `<Leader>gL` - show Git log of current file
-- - `:Git help git` - show output of `git help git` inside Neovim
--
-- See also:
-- - `:h MiniGit-examples` - examples of common setups
-- - `:h :Git` - more details about `:Git` user command
-- - `:h MiniGit.show_at_cursor()` - what information at cursor is shown
later(function() require('mini.git').setup() end)

-- Highlight patterns in text. Like `TODO`/`NOTE` or color hex codes.
-- Example usage:
-- - `:Pick hipatterns` - pick among all highlighted patterns
--
-- See also:
-- - `:h MiniHipatterns-examples` - examples of common setups
later(function()
  local hipatterns = require('mini.hipatterns')
  local hi_words = MiniExtra.gen_highlighter.words
  hipatterns.setup({
    highlighters = {
      -- Highlight a fixed set of common words. Will be highlighted in any place,
      -- not like "only in comments".
      fixme = hi_words({ 'FIXME', 'Fixme', 'fixme' }, 'MiniHipatternsFixme'),
      hack = hi_words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack'),
      todo = hi_words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo'),
      note = hi_words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote'),

      -- Highlight hex color string (#aabbcc) with that color as a background
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

-- Visualize and work with indent scope. It visualizes indent scope "at cursor"
-- with animated vertical line. Provides relevant motions and textobjects.
-- Example usage:
-- - `cii` - *c*hange *i*nside *i*ndent scope
-- - `Vaiai` - *V*isually select *a*round *i*ndent scope and then again
--   reselect *a*round new *i*indent scope
-- - `[i` / `]i` - navigate to scope's top / bottom
--
-- See also:
-- - `:h MiniIndentscope.gen_animation` - available animation rules
later(function() require('mini.indentscope').setup() end)

-- Jump to next/previous single character. It implements "smarter `fFtT` keys"
-- (see `:h f`) that work across multiple lines, start "jumping mode", and
-- highlight all target matches. Example usage:
-- - `fxff` - move *f*orward onto next character "x", then next, and next again
-- - `dt)` - *d*elete *t*ill next closing parenthesis (`)`)
later(function() require('mini.jump').setup() end)

-- Jump within visible lines to pre-defined spots via iterative label filtering.
-- Spots are computed by a configurable spotter function. Example usage:
-- - Lock eyes on desired location to jump
-- - `<CR>` - start jumping; this shows character labels over target spots
-- - Type character that appears over desired location; number of target spots
--   should be reduced
-- - Keep typing labels until target spot is unique to perform the jump
--
-- See also:
-- - `:h MiniJump2d.gen_spotter` - list of available spotters
later(function() require('mini.jump2d').setup() end)

-- Special key mappings. Provides helpers to map:
-- - Multi-step actions. Apply action 1 if condition is met; else apply
--   action 2 if condition is met; etc.
-- - Combos. Sequence of keys where each acts immediately plus execute extra
--   action if all are typed fast enough. Useful for Insert mode mappings to not
--   introduce delay when typing mapping keys without intention to execute action.
--
-- See also:
-- - `:h MiniKeymap-examples` - examples of common setups
-- - `:h MiniKeymap.map_multistep()` - map multi-step action
-- - `:h MiniKeymap.map_combo()` - map combo
later(function()
  require('mini.keymap').setup()
  -- Navigate 'mini.completion' menu with `<Tab>` /  `<S-Tab>`
  MiniKeymap.map_multistep('i', '<Tab>', { 'pmenu_next' })
  MiniKeymap.map_multistep('i', '<S-Tab>', { 'pmenu_prev' })
  -- On `<CR>` try to accept current completion item, fall back to accounting
  -- for pairs from 'mini.pairs'
  MiniKeymap.map_multistep('i', '<CR>', { 'pmenu_accept', 'minipairs_cr' })
  -- On `<BS>` just try to account for pairs from 'mini.pairs'
  MiniKeymap.map_multistep('i', '<BS>', { 'minipairs_bs' })
end)

-- Window with text overview. It is displayed on the right hand side. Can be used
-- for quick overview and navigation. Hidden by default. Example usage:
-- - `<Leader>mt` - toggle map window
-- - `<Leader>mf` - focus on the map for fast navigation
-- - `<Leader>ms` - change map's side (if it covers something underneath)
--
-- See also:
-- - `:h MiniMap.gen_encode_symbols` - list of symbols to use for text encoding
-- - `:h MiniMap.gen_integration` - list of integrations to show in the map
--
-- NOTE: Might introduce lag on very big buffers (10000+ lines)
later(function()
  local map = require('mini.map')
  map.setup({
    -- Use Braille dots to encode text
    symbols = { encode = map.gen_encode_symbols.dot('4x2') },
    -- Show built-in search matches, 'mini.diff' hunks, and diagnostic entries
    integrations = {
      map.gen_integration.builtin_search(),
      map.gen_integration.diff(),
      map.gen_integration.diagnostic(),
    },
  })

  -- Map built-in navigation characters to force map refresh
  for _, key in ipairs({ 'n', 'N', '*', '#' }) do
    local rhs = key
      -- Also open enough folds when jumping to the next match
      .. 'zv'
      .. '<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>'
    vim.keymap.set('n', key, rhs)
  end
end)

-- Move any selection in any direction. Example usage in Normal mode:
-- - `<M-j>`/`<M-k>` - move current line down / up
-- - `<M-h>`/`<M-l>` - decrease / increase indent of current line
--
-- Example usage in Visual mode:
-- - `<M-h>`/`<M-j>`/`<M-k>`/`<M-l>` - move selection left/down/up/right
later(function() require('mini.move').setup() end)

-- Text edit operators. All operators have mappings for:
-- - Regular operator (waits for motion/textobject to use)
-- - Current line action (repeat second character of operator to activate)
-- - Act on visual selection (type operator in Visual mode)
--
-- Example usage:
-- - `griw` - replace (`gr`) *i*inside *w*ord
-- - `gmm` - multiple/duplicate (`gm`) current line (extra `m`)
-- - `vipgs` - *v*isually select *i*nside *p*aragraph and sort it (`gs`)
-- - `gxiww.` - exchange (`gx`) *i*nside *w*ord with next word (`w` to navigate
--   to it and `.` to repeat exchange operator)
-- - `g==` - execute current line as Lua code and replace with its output.
--   For example, typing `g==` over line `vim.lsp.get_clients()` shows
--   information about all available LSP clients.
--
-- See also:
-- - `:h MiniOperators-mappings` - overview of how mappings are created
-- - `:h MiniOperators-overview` - overview of present operators
later(function()
  require('mini.operators').setup()

  -- Create mappings for swapping adjacent arguments. Notes:
  -- - Relies on `a` argument textobject from 'mini.ai'.
  -- - It is not 100% reliable, but mostly works.
  -- - It overrides `:h (` and `:h )`.
  -- Explanation: `gx`-`ia`-`gx`-`ila` <=> exchange current and last argument
  -- Usage: when on `a` in `(aa, bb)` press `)` followed by `(`.
  vim.keymap.set('n', '(', 'gxiagxila', { remap = true, desc = 'Swap arg left' })
  vim.keymap.set('n', ')', 'gxiagxina', { remap = true, desc = 'Swap arg right' })
end)

-- Autopairs functionality. Insert pair when typing opening character and go over
-- right character if it is already to cursor's right. Also provides mappings for
-- `<CR>` and `<BS>` to perform extra actions when inside pair.
-- Example usage in Insert mode:
-- - `(` - insert "()" and put cursor between them
-- - `)` when there is ")" to the right - jump over ")" without inserting new one
-- - `<C-v>(` - always insert a single "(" literally. This is useful since
--   'mini.pairs' doesn't provide particularly smart behavior, like auto balancing
later(function()
  -- Create pairs not only in Insert, but also in Command line mode
  require('mini.pairs').setup({ modes = { command = true } })
end)

-- Pick anything with single window layout and fast matching. This is one of
-- the main usability improvements as it powers a lot of "find things quickly"
-- workflows. How to use a picker:
-- - Start picker, usually with `:Pick <picker-name>` command. Like `:Pick files`.
--   It shows a single window in the bottom left corner filled with possible items
--   to choose from. Current item has special full line highlighting.
--   At the top there is a current query used to filter+sort items.
-- - Type characters (appear at top) to narrow down items. There is fuzzy matching:
--   characters may not match one-by-one, but they should be in correct order.
-- - Navigate down/up with `<C-n>`/`<C-p>`.
-- - Press `<Tab>` to show item's preview. `<Tab>` again goes back to items.
-- - Press `<S-Tab>` to show picker's info. `<S-Tab>` again goes back to items.
-- - Press `<CR>` to choose an item. The exact action depends on the picker: `files`
--   picker opens a selected file, `help` picker opens help page on selected tag.
--   To close picker without choosing an item, press `<Esc>`.
--
-- Example usage:
-- - `<Leader>ff` - *f*ind *f*iles; for best performance requires `ripgrep`
-- - `<Leader>fg` - *f*ind inside files (a.k.a. "to *g*rep"); requires `ripgrep`
-- - `<Leader>fh` - *f*ind *h*elp tag
-- - `<Leader>fr` - *r*esume latest picker
-- - `:h vim.ui.select()` - implemented with 'mini.pick'
--
-- See also:
-- - `:h MiniPick-overview` - overview of picker functionality
-- - `:h MiniPick-examples` - examples of common setups
-- - `:h MiniPick.builtin` and `:h MiniExtra.pickers` - available pickers;
--   Execute one either with Lua function, `:Pick <picker-name>` command, or
--   one of `<Leader>f` mappings defined in 'plugin/20_keymaps.lua'
later(function() require('mini.pick').setup() end)

-- Manage and expand snippets (templates for a frequently used text).
-- Typical workflow is to type snippet's (configurable) prefix and expand it
-- into a snippet session.
--
-- How to manage snippets:
-- - 'mini.snippets' itself doesn't come with preconfigured snippets. Instead there
--   is a flexible system of how snippets are prepared before expanding.
--   They can come from pre-defined path on disk, 'snippets/' directories inside
--   config or plugins, defined inside `setup()` call directly.
-- - This config, however, does come with snippet configuration:
--     - 'snippets/global.json' is a file with global snippets that will be
--       available in any buffer
--     - 'after/snippets/lua.json' defines personal snippets for Lua language
--     - 'friendly-snippets' plugin configured in 'plugin/40_plugins.lua' provides
--       a collection of language snippets
--
-- How to expand a snippet in Insert mode:
-- - If you know snippet's prefix, type it as a word and press `<C-j>`. Snippet's
--   body should be inserted instead of the prefix.
-- - If you don't remember snippet's prefix, type only part of it (or none at all)
--   and press `<C-j>`. It should show picker with all snippets that have prefixes
--   matching typed characters (or all snippets if none was typed).
--   Choose one and its body should be inserted instead of previously typed text.
--
-- How to navigate during snippet session:
-- - Snippets can contain tabstops - places for user to interactively adjust text.
--   Each tabstop is highlighted depending on session progression - whether tabstop
--   is current, was or was not visited. If tabstop doesn't yet have text, it is
--   visualized with special "ghost" inline text: • and ∎ by default.
-- - Type necessary text at current tabstop and navigate to next/previous one
--   by pressing `<C-l>` / `<C-h>`.
-- - Repeat previous step until you reach special final tabstop, usually denoted
--   by ∎ symbol. If you spotted a mistake in an earlier tabstop, navigate to it
--   and return back to the final tabstop.
-- - To end a snippet session when at final tabstop, keep typing or go into
--   Normal mode. To force end snippet session, press `<C-c>`.
--
-- See also:
-- - `:h MiniSnippets-overview` - overview of how module works
-- - `:h MiniSnippets-examples` - examples of common setups
-- - `:h MiniSnippets-session` - details about snippet session
-- - `:h MiniSnippets.gen_loader` - list of available loaders
later(function()
  -- Define language patterns to work better with 'friendly-snippets'
  local latex_patterns = { 'latex/**/*.json', '**/latex.json' }
  local lang_patterns = {
    tex = latex_patterns,
    plaintex = latex_patterns,
    -- Recognize special injected language of markdown tree-sitter parser
    markdown_inline = { 'markdown.json' },
  }

  local snippets = require('mini.snippets')
  local config_path = vim.fn.stdpath('config')
  snippets.setup({
    snippets = {
      -- Always load 'snippets/global.json' from config directory
      snippets.gen_loader.from_file(config_path .. '/snippets/global.json'),
      -- Load from 'snippets/' directory of plugins, like 'friendly-snippets'
      snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
    },
  })

  -- By default snippets available at cursor are not shown as candidates in
  -- 'mini.completion' menu. This requires a dedicated in-process LSP server
  -- that will provide them. To have that, uncomment next line (use `gcc`).
  -- MiniSnippets.start_lsp_server()
end)

-- Split and join arguments (regions inside brackets between allowed separators).
-- It uses Lua patterns to find arguments, which means it works in comments and
-- strings but can be not as accurate as tree-sitter based solutions.
-- Each action can be configured with hooks (like add/remove trailing comma).
-- Example usage:
-- - `gS` - toggle between joined (all in one line) and split (each on a separate
--   line and indented) arguments. It is dot-repeatable (see `:h .`).
--
-- See also:
-- - `:h MiniSplitjoin.gen_hook` - list of available hooks
later(function() require('mini.splitjoin').setup() end)

-- Surround actions: add/delete/replace/find/highlight. Working with surroundings
-- is surprisingly common: surround word with quotes, replace `)` with `]`, etc.
-- This module comes with many built-in surroundings, each identified by a single
-- character. It searches only for surrounding that covers cursor and comes with
-- a special "next" / "last" versions of actions to search forward or backward
-- (just like 'mini.ai'). All text editing actions are dot-repeatable (see `:h .`).
--
-- Example usage (this may feel intimidating at first, but after practice it
-- becomes second nature during text editing):
-- - `saiw)` - *s*urround *a*dd for *i*nside *w*ord parenthesis (`)`)
-- - `sdf`   - *s*urround *d*elete *f*unction call (like `f(var)` -> `var`)
-- - `srb[`  - *s*urround *r*eplace *b*racket (any of [], (), {}) with padded `[`
-- - `sf*`   - *s*urround *f*ind right part of `*` pair (like bold in markdown)
-- - `shf`   - *s*urround *h*ighlight current *f*unction call
-- - `srn{{` - *s*urround *r*eplace *n*ext curly bracket `{` with padded `{`
-- - `sdl'`  - *s*urround *d*elete *l*ast quote pair (`'`)
-- - `vaWsa<Space>` - *v*isually select *a*round *W*ORD and *s*urround *a*dd
--                    spaces (`<Space>`)
--
-- See also:
-- - `:h MiniSurround-builtin-surroundings` - list of all supported surroundings
-- - `:h MiniSurround-surrounding-specification` - examples of custom surroundings
-- - `:h MiniSurround-vim-surround-config` - alternative set of action mappings
later(function() require('mini.surround').setup() end)

-- Highlight and remove trailspace. Temporarily stops highlighting in Insert mode
-- to reduce noise when typing. Example usage:
-- - `<Leader>ot` - trim all trailing whitespace in a buffer
later(function() require('mini.trailspace').setup() end)

-- Track and reuse file system visits. Every file/directory visit is persistently
-- tracked on disk to later reuse: show in special frecency order, etc. It also
-- supports adding labels to visited paths to quickly navigate between them.
-- Example usage:
-- - `<Leader>fv` - find across all visits
-- - `<Leader>vv` / `<Leader>vV` - add/remove special "core" label to current file
-- - `<Leader>vc` / `<Leader>vC` - show files with "core" label; all or added within
--   current working directory
--
-- See also:
-- - `:h MiniVisits-overview` - overview of how module works
-- - `:h MiniVisits-examples` - examples of common setups
later(function() require('mini.visits').setup() end)

-- Not mentioned here, but can be useful:
-- - 'mini.doc' - needed only for plugin developers.
-- - 'mini.fuzzy' - not really needed on a daily basis.
-- - 'mini.test' - needed only for plugin developers.
