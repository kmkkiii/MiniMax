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
local now_if_args = Config.now_if_args

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
-- 参照:
-- - `:h MiniStatusline-example-content` - デフォルトコンテンツの例。これを使用して
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
  -- より良いユーザー体験のためにLSPレスポンスの後処理をカスタマイズ。
  -- 'Text' 候補は表示せず（通常ノイズが多い）、スニペットは最後に表示。
  local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
  local process_items = function(items, base)
    return MiniCompletion.default_process_items(items, base, process_items_opts)
  end
  require('mini.completion').setup({
    lsp_completion = {
      -- この設定がない場合、自動補完は `:h 'completefunc'` を通じて設定されます。
      -- 必要ではありませんが、`:h 'omnifunc'` を通じて設定する方がクリーンです
      -- （必要な時だけ設定され、`<C-u>` を使用できます）。
      source_func = 'omnifunc',
      auto_setup = false,
      process_items = process_items,
    },
  })

  -- 必要な時だけLSP補完のために 'omnifunc' を設定。
  local on_attach = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
  end
  Config.new_autocmd('LspAttach', nil, on_attach, "Set 'omnifunc'")

  -- Neovimが 'mini.completion' を通じて特定の補完およびシグネチャ機能を
  -- サポートするようになったことをサーバーに通知。
  vim.lsp.config('*', { capabilities = MiniCompletion.get_lsp_capabilities() })
end)

-- カスタマイズ可能な遅延でカーソル下の単語を自動ハイライト。
-- 単語の境界は `:h 'iskeyword'` オプションに基づいて定義されます。
--
-- その効果は好みの問題であるため、デフォルトでは有効になっていません。
-- 有効にするには次の行のコメントを解除してください（`gcc` を使用）。
-- later(function() require('mini.cursorword').setup() end)

-- バッファテキストとソースによって設定された参照テキストとの差分を表すdiff hunkを操作します。
-- デフォルトソースはGitインデックスのテキストを使用します。
-- また、'mini.statusline' の開発者セクションで使用されるサマリー情報も提供します。
-- 使用例:
-- - `ghip` - 段落内（*i*nside *p*aragraph）でhunkを適用（`gh`）
-- - `gHG` - カーソルからバッファの最後（`G`）までhunkをリセット（`gH`）
-- - `ghgh` - カーソル位置のhunk（`gh`）を適用（`gh`）
-- - `gHgh` - カーソル位置のhunk（`gh`）をリセット（`gH`）
-- - `<Leader>go` - オーバーレイを切り替え
--
-- 参照:
-- - `:h MiniDiff-overview` - モジュールがどのように動作するかの概要
-- - `:h MiniDiff-diff-summary` - 利用可能なサマリー情報
-- - `:h MiniDiff.gen_source` - 利用可能な組み込みソース
later(function() require('mini.diff').setup() end)

-- ファイルシステムのナビゲートと操作
--
-- ネストされたディレクトリを表示するためにカラムビュー（Miller columns）を使用してナビゲート。
-- 左上隅のフローティングウィンドウに表示されます。
--
-- 通常のバッファとしてテキストを編集することでファイルとディレクトリを操作します。
--
-- 使用例:
-- - `<Leader>ed` - 現在の作業ディレクトリを開く
-- - `<Leader>ef` - 現在のファイルのディレクトリを開く（ディスク上に存在する必要があります）
--
-- 基本的なナビゲーション:
-- - `l` - カーソル位置のエントリに入る: ディレクトリに移動またはファイルを開く
-- - `h` - フォーカスされたディレクトリから出る
-- - 通常のバッファのようにウィンドウをナビゲート
-- - エクスプローラー内で `g?` を押すとその他のマッピングが表示されます
--
-- 基本的な操作:
-- - 以下のいずれかのアクション後、Normal modeで `=` を押して同期し、アクションについて
--   よく読み、`y` または `<CR>` を押して確認します
-- - 新しいエントリ: `o` を押して名前を入力; `/` で終わるとディレクトリを作成
-- - 名前変更: `C` を押して新しい名前を入力
-- - 削除: `dd` と入力
-- - 移動/コピー: `dd`/`yy` と入力し、対象ディレクトリに移動して `p` を押す
--
-- 参照:
-- - `:h MiniFiles-navigation` - ナビゲート方法の詳細
-- - `:h MiniFiles-manipulation` - 操作方法の詳細
-- - `:h MiniFiles-examples` - 一般的なセットアップの例
later(function()
  -- ディレクトリ/ファイルプレビューを有効化
  require('mini.files').setup({ windows = { preview = true } })

  -- すべてのエクスプローラーに共通のブックマークを追加。エクスプローラー内での使用例:
  -- - `'c` で設定ディレクトリに移動
  -- - `g?` で利用可能なブックマークを表示
  local add_marks = function()
    MiniFiles.set_bookmark('c', vim.fn.stdpath('config'), { desc = 'Config' })
    local minideps_plugins = vim.fn.stdpath('data') .. '/site/pack/deps/opt'
    MiniFiles.set_bookmark('p', minideps_plugins, { desc = 'Plugins' })
    MiniFiles.set_bookmark('w', vim.fn.getcwd, { desc = 'Working directory' })
  end
  Config.new_autocmd('User', 'MiniFilesExplorerOpen', add_marks, 'Add bookmarks')
end)

-- Neovimの状態に基づいたより直接的なGitアクションのためのGit統合。
-- フル機能のGitクライアントではなく、Neovimとよりよく統合するヘルパーを提供することを
-- 目的としています。使用例:
-- - `<Leader>gs` - カーソル位置の情報を表示
-- - `<Leader>gd` - ステージされていない変更を別のタブページにパッチとして表示
-- - `<Leader>gL` - 現在のファイルのGitログを表示
-- - `:Git help git` - Neovim内で `git help git` の出力を表示
--
-- 参照:
-- - `:h MiniGit-examples` - 一般的なセットアップの例
-- - `:h :Git` - `:Git` ユーザーコマンドの詳細
-- - `:h MiniGit.show_at_cursor()` - カーソル位置に表示される情報
later(function() require('mini.git').setup() end)

-- テキスト内のパターンをハイライト。`TODO`/`NOTE` やカラー16進コードなど。
-- 使用例:
-- - `:Pick hipatterns` - すべてのハイライトされたパターンから選択
--
-- 参照:
-- - `:h MiniHipatterns-examples` - 一般的なセットアップの例
later(function()
  local hipatterns = require('mini.hipatterns')
  local hi_words = MiniExtra.gen_highlighter.words
  hipatterns.setup({
    highlighters = {
      -- 一般的な単語の固定セットをハイライト。「コメント内のみ」ではなく、
      -- あらゆる場所でハイライトされます。
      fixme = hi_words({ 'FIXME', 'Fixme', 'fixme' }, 'MiniHipatternsFixme'),
      hack = hi_words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack'),
      todo = hi_words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo'),
      note = hi_words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote'),

      -- 16進カラー文字列（#aabbcc）をその色を背景としてハイライト
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

-- インデントスコープを可視化して操作します。「カーソル位置の」インデントスコープを
-- アニメーション付きの垂直線で可視化します。関連するモーションとテキストオブジェクトを提供します。
-- 使用例:
-- - `cii` - インデントスコープ内（*i*nside *i*ndent scope）を変更（*c*hange）
-- - `Vaiai` - インデントスコープ周囲（*a*round *i*ndent scope）を行選択（*V*isually select）し、
--   さらに新しいインデントスコープ周囲（*a*round new *i*ndent scope）を再選択
-- - `[i` / `]i` - スコープの上/下に移動
--
-- 参照:
-- - `:h MiniIndentscope.gen_animation` - 利用可能なアニメーションルール
later(function() require('mini.indentscope').setup() end)

-- 次/前の単一文字にジャンプ。複数行にまたがって動作し、「ジャンプモード」を開始し、
-- すべてのターゲットマッチをハイライトする「よりスマートな `fFtT` キー」（`:h f` を参照）を実装します。
-- 使用例:
-- - `fxff` - 次の文字「x」に前方（*f*orward）移動し、さらに次、さらに次へ
-- - `dt)` - 次の閉じ括弧（`)`）まで（*t*ill）削除（*d*elete）
later(function() require('mini.jump').setup() end)

-- 反復的なラベルフィルタリングを介して、表示されている行内の事前定義されたスポットにジャンプします。
-- スポットは設定可能なスポッター関数によって計算されます。使用例:
-- - ジャンプしたい場所に目を向ける
-- - `<CR>` - ジャンプを開始; ターゲットスポット上に文字ラベルが表示されます
-- - 目的の場所の上に表示される文字を入力; ターゲットスポットの数が減少します
-- - ターゲットスポットが一意になるまでラベルを入力し続けてジャンプを実行
--
-- 参照:
-- - `:h MiniJump2d.gen_spotter` - 利用可能なスポッターのリスト
later(function() require('mini.jump2d').setup() end)

-- 特殊なキーマッピング。以下のマッピングを行うためのヘルパーを提供します:
-- - マルチステップアクション。条件が満たされた場合はアクション1を適用; そうでなければ
--   条件が満たされた場合はアクション2を適用; など。
-- - コンボ。各キーが即座に動作し、すべてが十分速く入力された場合に追加アクションを実行する
--   キーのシーケンス。アクションを実行する意図なくマッピングキーを入力する際に遅延が
--   発生しないようにするため、Insert modeマッピングに便利です。
--
-- 参照:
-- - `:h MiniKeymap-examples` - 一般的なセットアップの例
-- - `:h MiniKeymap.map_multistep()` - マルチステップアクションのマップ
-- - `:h MiniKeymap.map_combo()` - コンボのマップ
later(function()
  require('mini.keymap').setup()
  -- 'mini.completion' メニューを `<Tab>` / `<S-Tab>` でナビゲート
  MiniKeymap.map_multistep('i', '<Tab>', { 'pmenu_next' })
  MiniKeymap.map_multistep('i', '<S-Tab>', { 'pmenu_prev' })
  -- `<CR>` で現在の補完アイテムの受け入れを試み、失敗した場合は 'mini.pairs' の
  -- ペアを考慮にフォールバック
  MiniKeymap.map_multistep('i', '<CR>', { 'pmenu_accept', 'minipairs_cr' })
  -- `<BS>` では 'mini.pairs' のペアを考慮するのみ
  MiniKeymap.map_multistep('i', '<BS>', { 'minipairs_bs' })
end)

-- テキスト概要ウィンドウ。右側に表示されます。クイック概要とナビゲーションに使用できます。
-- デフォルトでは非表示です。使用例:
-- - `<Leader>mt` - マップウィンドウを切り替え
-- - `<Leader>mf` - 高速ナビゲーションのためにマップにフォーカス
-- - `<Leader>ms` - マップの側を変更（下にあるものを覆っている場合）
--
-- 参照:
-- - `:h MiniMap.gen_encode_symbols` - テキストエンコーディングに使用するシンボルのリスト
-- - `:h MiniMap.gen_integration` - マップに表示する統合のリスト
--
-- 注意: 非常に大きなバッファ（10000行以上）では遅延が発生する可能性があります
later(function()
  local map = require('mini.map')
  map.setup({
    -- 点字ドットを使用してテキストをエンコード
    symbols = { encode = map.gen_encode_symbols.dot('4x2') },
    -- 組み込み検索マッチ、'mini.diff' hunk、診断エントリを表示
    integrations = {
      map.gen_integration.builtin_search(),
      map.gen_integration.diff(),
      map.gen_integration.diagnostic(),
    },
  })

  -- マップのリフレッシュを強制するために組み込みナビゲーション文字をマップ
  for _, key in ipairs({ 'n', 'N', '*', '#' }) do
    local rhs = key
      -- 次のマッチにジャンプする際に十分な折り畳みも開く
      .. 'zv'
      .. '<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>'
    vim.keymap.set('n', key, rhs)
  end
end)

-- 任意の選択を任意の方向に移動。Normal modeでの使用例:
-- - `<M-j>`/`<M-k>` - 現在の行を下/上に移動
-- - `<M-h>`/`<M-l>` - 現在の行のインデントを減少/増加
--
-- Visual modeでの使用例:
-- - `<M-h>`/`<M-j>`/`<M-k>`/`<M-l>` - 選択を左/下/上/右に移動
later(function() require('mini.move').setup() end)

-- テキスト編集オペレーター。すべてのオペレーターには以下のマッピングがあります:
-- - 通常のオペレーター（使用するモーション/テキストオブジェクトを待つ）
-- - 現在行アクション（オペレーターの2番目の文字を繰り返して有効化）
-- - 視覚的選択に対して動作（Visual modeでオペレーターを入力）
--
-- 使用例:
-- - `griw` - 単語内（*i*inside *w*ord）を置換（`gr`、*r*eplace）
-- - `gmm` - 現在の行を複数化/複製（`gm`、*m*ultiple）（追加の `m`）
-- - `vipgs` - 段落内（*i*nside *p*aragraph）を視覚的に選択（*v*isually select）してソート（`gs`）
-- - `gxiww.` - 単語内（*i*nside *w*ord）を次の単語と交換（`gx`、e*x*change）
--   （`w` で移動し、`.` で交換オペレーターを繰り返す）
-- - `g==` - 現在の行をLuaコードとして実行し、その出力で置換。
--   例えば、`vim.lsp.get_clients()` の行で `g==` と入力すると
--   すべての利用可能なLSPクライアントに関する情報が表示されます。
--
-- 参照:
-- - `:h MiniOperators-mappings` - マッピングがどのように作成されるかの概要
-- - `:h MiniOperators-overview` - 現在のオペレーターの概要
later(function()
  require('mini.operators').setup()

  -- 隣接する引数を交換するマッピングを作成。注意:
  -- - 'mini.ai' の `a` 引数テキストオブジェクトに依存します。
  -- - 100%信頼できるわけではありませんが、ほとんどの場合機能します。
  -- - `:h (` と `:h )` をオーバーライドします。
  -- 説明: `gx`-`ia`-`gx`-`ila` <=> 現在と最後の引数を交換
  -- 使用法: `(aa, bb)` の `a` 上で `)` を押してから `(` を押します。
  vim.keymap.set('n', '(', 'gxiagxila', { remap = true, desc = 'Swap arg left' })
  vim.keymap.set('n', ')', 'gxiagxina', { remap = true, desc = 'Swap arg right' })
end)

-- オートペア機能。開き文字を入力するとペアを挿入し、カーソルの右に既に存在する場合は
-- 右の文字を飛び越えます。ペア内にいる時に追加アクションを実行する `<CR>` と `<BS>` の
-- マッピングも提供します。Insert modeでの使用例:
-- - `(` - "()" を挿入し、カーソルをその間に配置
-- - 右に ")" がある時に `)` - 新しいものを挿入せずに ")" を飛び越える
-- - `<C-v>(` - 常に単一の "(" を文字通り挿入。これは 'mini.pairs' が自動バランスなどの
--   特にスマートな動作を提供しないため便利です
later(function()
  -- Insert modeだけでなくCommand line modeでもペアを作成
  require('mini.pairs').setup({ modes = { command = true } })
end)

-- 単一ウィンドウレイアウトと高速マッチングで何でも選択。これは多くの「素早く見つける」
-- ワークフローを支えるため、主要なユーザビリティ改善の1つです。ピッカーの使い方:
-- - ピッカーを開始します。通常は `:Pick <picker-name>` コマンドを使用します。例: `:Pick files`。
--   左下隅に選択可能なアイテムで満たされた単一のウィンドウが表示されます。現在のアイテムは
--   特別な全行ハイライトがあります。上部にはアイテムのフィルタリング+ソートに使用される
--   現在のクエリがあります。
-- - 文字を入力（上部に表示）してアイテムを絞り込みます。ファジーマッチングがあります:
--   文字は1対1でマッチしなくてもよいですが、正しい順序である必要があります。
-- - `<C-n>`/`<C-p>` で下/上にナビゲート。
-- - `<Tab>` を押してアイテムのプレビューを表示。再度 `<Tab>` でアイテムに戻ります。
-- - `<S-Tab>` を押してピッカーの情報を表示。再度 `<S-Tab>` でアイテムに戻ります。
-- - `<CR>` を押してアイテムを選択。正確なアクションはピッカーに依存します: `files`
--   ピッカーは選択したファイルを開き、`help` ピッカーは選択したタグのヘルプページを開きます。
--   アイテムを選択せずにピッカーを閉じるには、`<Esc>` を押します。
--
-- 使用例:
-- - `<Leader>ff` - ファイルを検索（*f*ind *f*iles）; 最高のパフォーマンスには `ripgrep` が必要
-- - `<Leader>fg` - ファイル内を検索（*f*ind inside files、別名「*g*rep」）; `ripgrep` が必要
-- - `<Leader>fh` - ヘルプタグを検索（*f*ind *h*elp tag）
-- - `<Leader>fr` - 最新のピッカーを再開（*r*esume）
-- - `:h vim.ui.select()` - 'mini.pick' で実装
--
-- 参照:
-- - `:h MiniPick-overview` - ピッカー機能の概要
-- - `:h MiniPick-examples` - 一般的なセットアップの例
-- - `:h MiniPick.builtin` と `:h MiniExtra.pickers` - 利用可能なピッカー;
--   Lua関数、`:Pick <picker-name>` コマンド、または 'plugin/20_keymaps.lua' で定義された
--   `<Leader>f` マッピングのいずれかで実行します
later(function() require('mini.pick').setup() end)

-- スニペット（頻繁に使用されるテキストのテンプレート）の管理と展開。
-- 典型的なワークフローは、スニペットの（設定可能な）プレフィックスを入力し、
-- スニペットセッションに展開することです。
--
-- スニペットの管理方法:
-- - 'mini.snippets' 自体には事前設定されたスニペットは付属していません。代わりに、
--   展開前にスニペットがどのように準備されるかについての柔軟なシステムがあります。
--   ディスク上の事前定義されたパス、設定やプラグイン内の 'snippets/' ディレクトリから取得したり、
--   `setup()` 呼び出し内で直接定義することができます。
-- - ただし、この設定にはスニペット設定が含まれています:
--     - 'snippets/global.json' は、任意のバッファで利用可能なグローバルスニペットを含むファイルです
--     - 'after/snippets/lua.json' は、Lua言語用の個人的なスニペットを定義します
--     - 'plugin/40_plugins.lua' で設定されている 'friendly-snippets' プラグインは
--       言語スニペットのコレクションを提供します
--
-- Insert modeでスニペットを展開する方法:
-- - スニペットのプレフィックスを知っている場合は、単語として入力し、`<C-j>` を押します。
--   スニペットの本体がプレフィックスの代わりに挿入されるはずです。
-- - スニペットのプレフィックスを覚えていない場合は、その一部のみを入力（または何も入力しない）し、
--   `<C-j>` を押します。入力された文字に一致するプレフィックスを持つすべてのスニペット
--   （何も入力されていない場合はすべてのスニペット）を含むピッカーが表示されるはずです。
--   1つを選択すると、その本体が以前に入力されたテキストの代わりに挿入されるはずです。
--
-- スニペットセッション中のナビゲート方法:
-- - スニペットにはタブストップ（ユーザーがテキストを対話的に調整する場所）を含めることができます。
--   各タブストップは、セッションの進行状況に応じてハイライトされます - タブストップが現在の
--   ものか、訪問済みか未訪問かによって。タブストップにまだテキストがない場合は、
--   特別な「ゴースト」インラインテキストで視覚化されます: デフォルトでは • と ∎。
-- - 現在のタブストップで必要なテキストを入力し、`<C-l>` / `<C-h>` を押して
--   次/前のタブストップにナビゲートします。
-- - 特別な最終タブストップ（通常は ∎ 記号で示される）に到達するまで前のステップを繰り返します。
--   以前のタブストップでミスを見つけた場合は、そこにナビゲートして最終タブストップに戻ります。
-- - 最終タブストップにいる時にスニペットセッションを終了するには、入力を続けるか
--   Normal modeに移行します。スニペットセッションを強制終了するには、`<C-c>` を押します。
--
-- 参照:
-- - `:h MiniSnippets-overview` - モジュールがどのように動作するかの概要
-- - `:h MiniSnippets-examples` - 一般的なセットアップの例
-- - `:h MiniSnippets-session` - スニペットセッションの詳細
-- - `:h MiniSnippets.gen_loader` - 利用可能なローダーのリスト
later(function()
  -- 'friendly-snippets' でよりよく動作するように言語パターンを定義
  local latex_patterns = { 'latex/**/*.json', '**/latex.json' }
  local lang_patterns = {
    tex = latex_patterns,
    plaintex = latex_patterns,
    -- markdownのtree-sitterパーサーの特別なインジェクト言語を認識
    markdown_inline = { 'markdown.json' },
  }

  local snippets = require('mini.snippets')
  local config_path = vim.fn.stdpath('config')
  snippets.setup({
    snippets = {
      -- 設定ディレクトリから常に 'snippets/global.json' をロード
      snippets.gen_loader.from_file(config_path .. '/snippets/global.json'),
      -- 'friendly-snippets' などのプラグインの 'snippets/' ディレクトリからロード
      snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
    },
  })

  -- デフォルトでは、カーソル位置で利用可能なスニペットは 'mini.completion' メニューの
  -- 候補として表示されません。これには、それらを提供する専用のインプロセスLSPサーバーが
  -- 必要です。それを有効にするには、次の行のコメントを解除してください（`gcc` を使用）。
  -- MiniSnippets.start_lsp_server()
end)

-- 引数（許可された区切り文字間の括弧内の領域）を分割および結合します。
-- 引数を見つけるためにLuaパターンを使用します。これはコメントや文字列内でも機能しますが、
-- tree-sitterベースのソリューションほど正確ではない場合があります。
-- 各アクションはフック（末尾カンマの追加/削除など）で設定できます。
-- 使用例:
-- - `gS` - 結合（すべて1行）と分割（各引数を別の行にインデント付きで配置）を切り替え。
--   ドット繰り返し可能です（`:h .` を参照）。
--
-- 参照:
-- - `:h MiniSplitjoin.gen_hook` - 利用可能なフックのリスト
later(function() require('mini.splitjoin').setup() end)

-- 囲み（Surround）アクション: 追加/削除/置換/検索/ハイライト。囲みを扱う作業は
-- 意外と一般的です: 単語を引用符で囲む、`)` を `]` に置き換えるなど。
-- このモジュールには、それぞれ単一の文字で識別される多くの組み込み囲みが付属しています。
-- カーソルをカバーする囲みのみを検索し、前方または後方に検索する特別な「next」/「last」
-- バージョンのアクションが付属しています（'mini.ai' と同様）。すべてのテキスト編集アクションは
-- ドット繰り返し可能です（`:h .` を参照）。
--
-- 使用例（最初は威圧的に感じるかもしれませんが、練習後はテキスト編集中に第二の天性になります）:
-- - `saiw)` - 単語内（*i*nside *w*ord）に括弧（`)`）を囲み追加（*s*urround *a*dd）
-- - `sdf`   - 関数呼び出し（*f*unction call）の囲みを削除（*s*urround *d*elete）（`f(var)` -> `var` など）
-- - `srb[`  - ブラケット（*b*racket）（[]、()、{} のいずれか）をパディング付き `[` に囲み置換（*s*urround *r*eplace）
-- - `sf*`   - `*` ペアの右部分を囲み検索（*s*urround *f*ind）（markdownの太字など）
-- - `shf`   - 現在の関数呼び出し（*f*unction call）を囲みハイライト（*s*urround *h*ighlight）
-- - `srn{{` - 次（*n*ext）の波括弧 `{` をパディング付き `{` に囲み置換（*s*urround *r*eplace）
-- - `sdl'`  - 最後（*l*ast）の引用符ペア（`'`）を囲み削除（*s*urround *d*elete）
-- - `vaWsa<Space>` - WORD周囲（*a*round *W*ORD）を視覚的に選択（*v*isually select）し、
--                    スペース（`<Space>`）を囲み追加（*s*urround *a*dd）
--
-- 参照:
-- - `:h MiniSurround-builtin-surroundings` - サポートされているすべての囲みのリスト
-- - `:h MiniSurround-surrounding-specification` - カスタム囲みの例
-- - `:h MiniSurround-vim-surround-config` - アクションマッピングの代替セット
later(function() require('mini.surround').setup() end)

-- 末尾空白をハイライトおよび削除。Insert modeでは一時的にハイライトを停止して
-- 入力時のノイズを減らします。使用例:
-- - `<Leader>ot` - バッファ内のすべての末尾空白をトリミング
later(function() require('mini.trailspace').setup() end)

-- ファイルシステムの訪問を追跡して再利用します。すべてのファイル/ディレクトリの訪問は
-- ディスク上に永続的に追跡され、後で再利用されます: 特別なfrecency順で表示など。また、
-- 訪問したパスにラベルを追加して、それらの間を素早くナビゲートすることもサポートします。
-- 使用例:
-- - `<Leader>fv` - すべての訪問から検索
-- - `<Leader>vv` / `<Leader>vV` - 現在のファイルに特別な「core」ラベルを追加/削除
-- - `<Leader>vc` / `<Leader>vC` - 「core」ラベルを持つファイルを表示; すべてまたは
--   現在の作業ディレクトリ内で追加されたもの
--
-- 参照:
-- - `:h MiniVisits-overview` - モジュールがどのように動作するかの概要
-- - `:h MiniVisits-examples` - 一般的なセットアップの例
later(function() require('mini.visits').setup() end)

-- ここでは言及されていませんが、役立つ可能性があります:
-- - 'mini.doc' - プラグイン開発者のみに必要。
-- - 'mini.fuzzy' - 日常的には実際には必要ありません。
-- - 'mini.test' - プラグイン開発者のみに必要。
