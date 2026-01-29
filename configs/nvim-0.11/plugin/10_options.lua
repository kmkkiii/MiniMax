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
vim.o.breakindentopt = 'list:-1'  -- リストにパディングを追加 ('wrap' が設定されている場合)
vim.o.colorcolumn    = '+1'       -- 最大幅の右側に列を描画
vim.o.cursorline     = true       -- 現在行のハイライトを有効化
vim.o.linebreak      = true       -- 'breakat' で行を折り返す ('wrap' が設定されている場合)
vim.o.list           = true       -- 有用なテキストインジケータを表示
vim.o.number         = true       -- 行番号を表示
vim.o.pumheight      = 10         -- ポップアップメニューを小さくする
vim.o.ruler          = false      -- カーソル座標を表示しない
vim.o.shortmess      = 'CFOSWaco' -- 一部の組み込み補完メッセージを無効化
vim.o.showmode       = false      -- コマンドラインにモードを表示しない
vim.o.signcolumn     = 'yes'      -- 常にサインカラムを表示 (チラつきを減らす)
vim.o.splitbelow     = true       -- 水平分割は下に配置
vim.o.splitkeep      = 'screen'   -- ウィンドウ分割時のスクロールを減らす
vim.o.splitright     = true       -- 垂直分割は右に配置
vim.o.winborder      = 'single'   -- フローティングウィンドウで境界線を使用
vim.o.wrap           = false      -- 行を視覚的に折り返さない (\w で切り替え)

vim.o.cursorlineopt  = 'screenline,number' -- スクリーン行ごとにカーソル行を表示

-- 特殊なUIシンボル。さらに詳細は後で 'mini.basics' 経由で設定されます。
vim.o.fillchars = 'eob: ,fold:╌'
vim.o.listchars = 'extends:…,nbsp:␣,precedes:…,tab:> '

-- フォールド (`:h fold-commands`, `:h zM`, `:h zR`, `:h zA`, `:h zj` を参照)
vim.o.foldlevel   = 10       -- デフォルトでは何も折り畳まない; 折り畳むには 0 または 1 に設定
vim.o.foldmethod  = 'indent' -- インデントレベルに基づいて折り畳む
vim.o.foldnestmax = 10       -- フォールドレベルの数を制限
vim.o.foldtext    = ''       -- フォールド下のテキストをそのハイライトで表示

-- 編集 =======================================================================
vim.o.autoindent    = true    -- 自動インデントを使用
vim.o.expandtab     = true    -- タブをスペースに変換
vim.o.formatoptions = 'rqnl1j'-- コメント編集を改善
vim.o.ignorecase    = true    -- 検索時に大文字小文字を無視
vim.o.incsearch     = true    -- 入力中に検索マッチを表示
vim.o.infercase     = true    -- 組み込み補完で大文字小文字を推測
vim.o.shiftwidth    = 2       -- インデントにこの数のスペースを使用
vim.o.smartcase     = true    -- 検索パターンに大文字が含まれる場合は大文字小文字を区別
vim.o.smartindent   = true    -- インデントをスマートにする
vim.o.spelloptions  = 'camel' -- camelCaseの単語部分を個別の単語として扱う
vim.o.tabstop       = 2       -- タブをこの数のスペースとして表示
vim.o.virtualedit   = 'block' -- blockwiseモードで行末を越えることを許可

vim.o.iskeyword = '@,48-57,_,192-255,-' -- ダッシュを `word` テキストオブジェクトの一部として扱う

-- 番号付きリストの開始パターン (`gw` で使用)。これは次のように読めます:
-- "リストアイテムの開始は: 少なくとも1つの特殊文字 (数字、-、+、*)
-- その後に句読点 (. または `)`) が続く可能性があり、その後少なくとも1つのスペースが続く"
vim.o.formatlistpat = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]]

-- 組み込み補完
vim.o.complete    = '.,w,b,kspell'                  -- より少ないソースを使用
vim.o.completeopt = 'menuone,noselect,fuzzy,nosort' -- カスタム動作を使用

-- 自動コマンド ===============================================================

-- コメントを自動折り返ししない、'o' を押した後にコメントリーダーを挿入しない。
-- ファイルタイププラグインからのこれらの変更を常に上書きするために `FileType` で実行。
local f = function() vim.cmd('setlocal formatoptions-=c formatoptions-=o') end
_G.Config.new_autocmd('FileType', nil, f, "Proper 'formatoptions'")

-- 'mini.basics' によって作成される他の自動コマンドがあります。'plugin/30_mini.lua' を参照してください。

-- 診断 =======================================================================

-- Neovimは診断メッセージを表示するための組み込みサポートを持っています。これは
-- 有用性を保ちながら、より控えめな表示を設定します。
-- `:h vim.diagnostic` と `:h vim.diagnostic.config()` を参照してください。
local diagnostic_opts = {
  -- 他のサインの上にサインを表示するが、警告とエラーのみ
  signs = { priority = 9999, severity = { min = 'WARN', max = 'ERROR' } },

  -- すべての診断を下線で表示 (メッセージを見るには `<Leader>ld` を入力)
  underline = { severity = { min = 'HINT', max = 'ERROR' } },

  -- 現在行のエラーについては即座に詳細を表示
  virtual_lines = false,
  virtual_text = {
    current_line = true,
    severity = { min = 'ERROR', max = 'ERROR' },
  },

  -- 入力中は診断を更新しない
  update_in_insert = false,
}

-- 起動時に `vim.diagnostic` を読み込まないために `later()` を使用
MiniDeps.later(function() vim.diagnostic.config(diagnostic_opts) end)
-- stylua: ignore end
