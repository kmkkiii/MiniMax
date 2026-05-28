-- ┌─────────────────────────┐
-- │ Filetype config example │
-- └─────────────────────────┘
--
-- これは特定のファイルタイプにのみ適用される設定の例で、ファイルのベース名と同じです
-- （この例では 'markdown'; '*.md' ファイル用）。
--
-- ファイルが開かれたときに通常実行される任意のコードを含めることができます
-- （厳密には、'filetype' オプション値がターゲット値に変更されるたびに）。
-- 通常、バッファ/ウィンドウローカルのオプションと変数を定義する必要があります。
-- したがって、オプションを設定するために `vim.o` の代わりに、バッファローカルオプションには
-- `vim.bo` を、ウィンドウローカルオプションには `vim.cmd('setlocal ...')` を使用します
-- （現在より堅牢）。
--
-- これはバッファローカルの 'mini.nvim' 変数を設定するのにも良い場所です。
-- `:h mini.nvim-buffer-local-config` と `:h mini.nvim-disabling-recipes` を参照してください。

-- ウィンドウのスペルチェックと折り返しを有効化
vim.cmd('setlocal spell wrap')

-- tree-sitterで折り畳み
vim.cmd('setlocal foldmethod=expr foldexpr=v:lua.vim.treesitter.foldexpr()')

-- 'mini.basics' を優先して組み込みの `gO` マッピングを無効化
vim.keymap.del('n', 'gO', { buffer = 0 })

-- 'mini.surround' でmarkdown固有の囲み文字を設定
vim.b.minisurround_config = {
  custom_surroundings = {
    -- Markdownリンク。一般的な使用法:
    -- `saiwL` + [リンクを入力/ペースト] + <CR> - リンクを追加
    -- `sdL` - リンクを削除
    -- `srLL` + [リンクを入力/ペースト] + <CR> - リンクを置換
    L = {
      input = { '%[().-()%]%(.-%)' },
      output = function()
        local link = require('mini.surround').user_input('Link: ')
        return { left = '[', right = '](' .. link .. ')' }
      end,
    },
  },
}
