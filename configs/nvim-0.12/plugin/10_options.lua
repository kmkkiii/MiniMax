-- ┌──────────────────────────┐
-- │ Built-in Neovim behavior │
-- └──────────────────────────┘
--
-- このファイルはNeovimの組み込み動作を定義します。目標はMINIで最も良く動作するように
-- 全体的なユーザビリティを向上させることです。
--
-- ここで `vim.o.xxx = value` はオプション `xxx` のデフォルト値を `value` に設定します。
-- `:h 'xxx'` を参照してください (`xxx` を実際のオプション名に置き換えてください)。
--
-- オプションの値はバッファまたはウィンドウごとにカスタマイズできます。
-- 一般的な例については 'after/ftplugin/' を参照してください。
--
-- 注意:
-- - 一部のオプション（`:h 'exrc'` など）はこのファイルが読み込まれる前に設定する必要があります。
--   'init.lua' ファイルの末尾で直接設定してください。

-- stylua: ignore start
-- 次の部分 (`-- stylua: ignore end` まで) は読みやすさのために手動で整列されています。
-- これを保持するか、`-- stylua` 行を削除して自動フォーマットすることを検討してください。

-- 一般設定 ===================================================================
vim.g.mapleader = ' ' -- `<Space>` を <Leader> キーとして使用

vim.o.mouse       = 'a'            -- マウスを有効化
vim.o.mousescroll = 'ver:25,hor:6' -- マウススクロールをカスタマイズ
vim.o.switchbuf   = 'usetab'       -- 切り替え時に既に開いているバッファを使用
vim.o.undofile    = true           -- 永続的なundoを有効化

vim.o.shada = "'100,<50,s10,:1000,/100,@100,h" -- ShaDaファイルを制限 (起動時用)

-- すべてのファイルタイププラグインとシンタックスを有効化 (未有効の場合、より良い起動のため)
vim.cmd('filetype plugin indent on')
if vim.fn.exists('syntax_on') ~= 1 then vim.cmd('syntax enable') end

-- UI =========================================================================
vim.o.breakindent    = true       -- 折り返し行を行頭に合わせてインデント
vim.o.breakindentopt = 'list:-1'  -- リストにパディングを追加（'wrap' 設定時）
vim.o.colorcolumn    = '+1'       -- 最大幅の右側にカラムを描画
vim.o.cursorline     = true       -- 現在行のハイライトを有効化
vim.o.linebreak      = true       -- 'breakat' で行を折り返す（'wrap' 設定時）
vim.o.list           = true       -- 便利なテキストインジケーターを表示
vim.o.number         = true       -- 行番号を表示
vim.o.pumborder      = 'single'   -- ポップアップメニューにボーダーを使用
vim.o.pumheight      = 10         -- ポップアップメニューを小さくする
vim.o.pummaxwidth    = 100        -- ポップアップメニューを広くしすぎない
vim.o.ruler          = false      -- カーソル座標を表示しない
vim.o.shortmess      = 'CFOSWaco' -- 一部の組み込み補完メッセージを無効化
vim.o.showmode       = false      -- コマンドラインにモードを表示しない
vim.o.signcolumn     = 'yes'      -- signcolumnを常に表示（ちらつき軽減）
vim.o.splitbelow     = true       -- 水平分割は下に配置
vim.o.splitkeep      = 'screen'   -- ウィンドウ分割時のスクロールを軽減
vim.o.splitright     = true       -- 垂直分割は右に配置
vim.o.winborder      = 'single'   -- フローティングウィンドウにボーダーを使用
vim.o.wrap           = false      -- 行を視覚的に折り返さない（\w で切り替え）

vim.o.cursorlineopt  = 'screenline,number' -- スクリーン行ごとにカーソル行を表示

-- 特殊なUIシンボル。'mini.basics' で後から追加設定されます。
vim.o.fillchars = 'eob: ,fold:╌'
vim.o.listchars = 'extends:…,nbsp:␣,precedes:…,tab:> '

-- 折り畳み (`:h fold-commands`、`:h zM`、`:h zR`、`:h zA`、`:h zj` を参照)
vim.o.foldlevel   = 10       -- デフォルトでは何も折り畳まない; 0または1に設定して折り畳み
vim.o.foldmethod  = 'indent' -- インデントレベルに基づいて折り畳み
vim.o.foldnestmax = 10       -- 折り畳みレベル数を制限
vim.o.foldtext    = ''       -- 折り畳み下のテキストをハイライト付きで表示

-- 編集 ======================================================================
vim.o.autoindent    = true    -- 自動インデントを使用
vim.o.expandtab     = true    -- タブをスペースに変換
vim.o.formatoptions = 'rqnl1j'-- コメント編集を改善
vim.o.ignorecase    = true    -- 検索時に大文字小文字を無視
vim.o.incsearch     = true    -- 入力中に検索マッチを表示
vim.o.infercase     = true    -- 組み込み補完で大文字小文字を推測
vim.o.shiftwidth    = 2       -- インデントにこのスペース数を使用
vim.o.smartcase     = true    -- 検索パターンに大文字がある場合は大文字小文字を区別
vim.o.smartindent   = true    -- スマートインデントを有効化
vim.o.spelloptions  = 'camel' -- camelCaseの単語部分を別の単語として扱う
vim.o.tabstop       = 2       -- タブをこのスペース数で表示
vim.o.virtualedit   = 'block' -- ブロック選択モードで行末を超えた移動を許可

vim.o.iskeyword = '@,48-57,_,192-255,-' -- ダッシュを `word` テキストオブジェクトの一部として扱う

-- 番号付きリストの開始パターン（`gw` で使用）。これは次のように読みます:
-- "リスト項目の開始: 少なくとも1つの特殊文字（数字、-、+、*）に
-- オプションで句読点（. または `)`）が続き、少なくとも1つのスペースが続く"
vim.o.formatlistpat = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]]

-- 組み込み補完
vim.o.complete        = '.,w,b,kspell'                  -- 使用するソースを減らす
vim.o.completeopt     = 'menuone,noselect,fuzzy,nosort' -- カスタム動作を使用
vim.o.completetimeout = 100                             -- ソースの遅延を制限

-- 自動コマンド ===============================================================

-- コメントを自動折り返しせず、'o' を押した後にコメントリーダーを挿入しない。
-- ファイルタイププラグインからの変更を常にオーバーライドするために `FileType` で実行。
local f = function() vim.cmd('setlocal formatoptions-=c formatoptions-=o') end
Config.new_autocmd('FileType', nil, f, "Proper 'formatoptions'")

-- 'mini.basics' によって作成される他の自動コマンドもあります。'plugin/30_mini.lua' を参照してください。

-- 診断 ======================================================================

-- Neovimには診断メッセージを表示するための組み込みサポートがあります。これは
-- 便利さを維持しながら、より控えめな表示に設定します。
-- `:h vim.diagnostic` と `:h vim.diagnostic.config()` を参照してください。
local diagnostic_opts = {
  -- 他のサインの上にサインを表示するが、警告とエラーのみ
  signs = { priority = 9999, severity = { min = 'WARN', max = 'ERROR' } },

  -- すべての診断を下線で表示（メッセージは `<Leader>ld` で表示）
  underline = { severity = { min = 'HINT', max = 'ERROR' } },

  -- 現在行のエラーについてより詳細をすぐに表示
  virtual_lines = false,
  virtual_text = {
    current_line = true,
    severity = { min = 'ERROR', max = 'ERROR' },
  },

  -- 入力中は診断を更新しない
  update_in_insert = false,
}

-- 起動時に `vim.diagnostic` をソースしないために `later()` を使用
Config.later(function() vim.diagnostic.config(diagnostic_opts) end)
-- stylua: ignore end
