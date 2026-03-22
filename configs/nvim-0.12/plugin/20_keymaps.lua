-- ┌─────────────────┐
-- │ Custom mappings │
-- └─────────────────┘
--
-- このファイルにはカスタムの一般マッピングとLeaderマッピングの定義が含まれています。

-- 一般マッピング =============================================================

-- このセクションを使用してカスタムの一般マッピングを追加します。`:h vim.keymap.set()` を参照してください。

-- Normal modeマッピングを作成するヘルパーの例
local nmap = function(lhs, rhs, desc)
  -- `:h vim.keymap.set()` を参照
  vim.keymap.set('n', lhs, rhs, { desc = desc })
end

-- 現在行の前/後に行単位でペースト
-- 使用例: `yiw` で単語をヤンクし、`]p` で次の行に配置します。
nmap('[p', '<Cmd>exe "iput! " . v:register<CR>', 'Paste Above')
nmap(']p', '<Cmd>exe "iput "  . v:register<CR>', 'Paste Below')

-- 多くの一般マッピングは 'mini.basics' によって作成されます。'plugin/30_mini.lua' を参照してください。

-- stylua: ignore start
-- 次の部分 (`-- stylua: ignore end` まで) は読みやすさのために手動で整列されています。
-- これを保持するか、`-- stylua` 行を削除して自動フォーマットすることを検討してください。

-- Leaderマッピング ==========================================================

-- Neovimには Leader キーという概念があります (`:h <Leader>` を参照)。これは設定可能な
-- キーで、主に「ワークフロー」マッピング（テキスト編集とは対照的）に使用されます。
-- 例: "ファイルエクスプローラーを開く"、"スクラッチバッファを作成"、"バッファから選択"
--
-- 'plugin/10_options.lua' で <Leader> は <Space> に設定されています。つまり <Leader> を
-- 押すよう提案がある場合は <Space> を押します。
--
-- この設定は「2キーLeaderマッピング」アプローチを使用します: 最初のキーは意味的な
-- グループを記述し、2番目のキーがアクションを実行します。通常、両方のキーはある種の
-- ニーモニックを作成するように選択されます。
-- 例: `<Leader>f` は "find" タイプのアクションをグループ化; `<Leader>ff` - ファイルを検索
-- このセクションを使用して構造的な方法でLeaderマッピングを追加します。
--
-- 通常、グローバルとローカルの種類のアクションがある場合、小文字の2番目のキーは
-- グローバルを示し、大文字はローカルを示します。
-- 例: `<Leader>fs` / `<Leader>fS` - ワークスペース/ドキュメント LSP シンボルを検索
--
-- 多くのマッピングは 'plugin/30_mini.lua' でセットアップされた 'mini.nvim' モジュールを使用します。

-- 特定のモードのLeaderグループに関する情報を持つグローバルテーブルを作成します。
-- これは 'mini.clue' に追加のヒントを提供するために使用されます。
-- 新しいグループを作成する場合はエントリを追加してください。
Config.leader_group_clues = {
  { mode = 'n', keys = '<Leader>b', desc = '+Buffer' },
  { mode = 'n', keys = '<Leader>e', desc = '+Explore/Edit' },
  { mode = 'n', keys = '<Leader>f', desc = '+Find' },
  { mode = 'n', keys = '<Leader>g', desc = '+Git' },
  { mode = 'n', keys = '<Leader>l', desc = '+Language' },
  { mode = 'n', keys = '<Leader>m', desc = '+Map' },
  { mode = 'n', keys = '<Leader>o', desc = '+Other' },
  { mode = 'n', keys = '<Leader>s', desc = '+Session' },
  { mode = 'n', keys = '<Leader>t', desc = '+Terminal' },
  { mode = 'n', keys = '<Leader>v', desc = '+Visits' },

  { mode = 'x', keys = '<Leader>g', desc = '+Git' },
  { mode = 'x', keys = '<Leader>l', desc = '+Language' },
}

-- より簡潔な `<Leader>` マッピングのためのヘルパー。
-- ほとんどのマッピングは、簡潔でありながら説明的であるために、右辺 (RHS) として
-- `<Cmd>...<CR>` 文字列を使用します。`:h <Cmd>` を参照してください。
-- このアプローチは、マッピング作成時に基礎となるコマンド/関数が存在する必要がありません:
-- 起動時間を改善するための「遅延ロード」アプローチです。
local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('n', '<Leader>' .. suffix, rhs, { desc = desc })
end
local xmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('x', '<Leader>' .. suffix, rhs, { desc = desc })
end

-- b は 'Buffer' を表します。一般的な使用法:
-- - `<Leader>bs` - スクラッチ（一時）バッファを作成
-- - `<Leader>ba` - 代替バッファに移動
-- - `<Leader>bw` - 現在のバッファをワイプアウト（完全削除）
local new_scratch_buffer = function()
  vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
end

nmap_leader('ba', '<Cmd>b#<CR>',                                 'Alternate')
nmap_leader('bd', '<Cmd>lua MiniBufremove.delete()<CR>',         'Delete')
nmap_leader('bD', '<Cmd>lua MiniBufremove.delete(0, true)<CR>',  'Delete!')
nmap_leader('bs', new_scratch_buffer,                            'Scratch')
nmap_leader('bw', '<Cmd>lua MiniBufremove.wipeout()<CR>',        'Wipeout')
nmap_leader('bW', '<Cmd>lua MiniBufremove.wipeout(0, true)<CR>', 'Wipeout!')

-- e は 'Explore' と 'Edit' を表します。一般的な使用法:
-- - `<Leader>ed` - 現在の作業ディレクトリでエクスプローラーを開く
-- - `<Leader>ef` - 現在のファイルのディレクトリを開く（ディスク上に存在する必要がある）
-- - `<Leader>ei` - 'init.lua' を編集
-- - `edit_plugin_file` を使用するすべてのマッピング - 'plugin/' 設定ファイルを編集
local edit_plugin_file = function(filename)
  return string.format('<Cmd>edit %s/plugin/%s<CR>', vim.fn.stdpath('config'), filename)
end
local explore_at_file = '<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>'
local explore_quickfix = function()
  vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and 'cclose' or 'copen')
end
local explore_locations = function()
  vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and 'lclose' or 'lopen')
end

nmap_leader('ed', '<Cmd>lua MiniFiles.open()<CR>',          'Directory')
nmap_leader('ef', explore_at_file,                          'File directory')
nmap_leader('ei', '<Cmd>edit $MYVIMRC<CR>',                 'init.lua')
nmap_leader('ek', edit_plugin_file('20_keymaps.lua'),       'Keymaps config')
nmap_leader('em', edit_plugin_file('30_mini.lua'),          'MINI config')
nmap_leader('en', '<Cmd>lua MiniNotify.show_history()<CR>', 'Notifications')
nmap_leader('eo', edit_plugin_file('10_options.lua'),       'Options config')
nmap_leader('ep', edit_plugin_file('40_plugins.lua'),       'Plugins config')
nmap_leader('eq', explore_quickfix,                         'Quickfix list')
nmap_leader('eQ', explore_locations,                        'Location list')

-- f は 'Fuzzy Find' を表します。一般的な使用法:
-- - `<Leader>ff` - ファイルを検索; 最高のパフォーマンスには `ripgrep` が必要
-- - `<Leader>fg` - ファイル内を検索; `ripgrep` が必要
-- - `<Leader>fh` - ヘルプタグを検索
-- - `<Leader>fr` - 最新のピッカーを再開
-- - `<Leader>fv` - すべての訪問したパス; 'mini.visits' が必要
--
-- これらはすべて 'mini.pick' を使用します。概要については `:h MiniPick-overview` を参照してください。
local pick_added_hunks_buf = '<Cmd>Pick git_hunks path="%" scope="staged"<CR>'
local pick_workspace_symbols_live = '<Cmd>Pick lsp scope="workspace_symbol_live"<CR>'

nmap_leader('f/', '<Cmd>Pick history scope="/"<CR>',            '"/" history')
nmap_leader('f:', '<Cmd>Pick history scope=":"<CR>',            '":" history')
nmap_leader('fa', '<Cmd>Pick git_hunks scope="staged"<CR>',     'Added hunks (all)')
nmap_leader('fA', pick_added_hunks_buf,                         'Added hunks (buf)')
nmap_leader('fb', '<Cmd>Pick buffers<CR>',                      'Buffers')
nmap_leader('fc', '<Cmd>Pick git_commits<CR>',                  'Commits (all)')
nmap_leader('fC', '<Cmd>Pick git_commits path="%"<CR>',         'Commits (buf)')
nmap_leader('fd', '<Cmd>Pick diagnostic scope="all"<CR>',       'Diagnostic workspace')
nmap_leader('fD', '<Cmd>Pick diagnostic scope="current"<CR>',   'Diagnostic buffer')
nmap_leader('ff', '<Cmd>Pick files<CR>',                        'Files')
nmap_leader('fg', '<Cmd>Pick grep_live<CR>',                    'Grep live')
nmap_leader('fG', '<Cmd>Pick grep pattern="<cword>"<CR>',       'Grep current word')
nmap_leader('fh', '<Cmd>Pick help<CR>',                         'Help tags')
nmap_leader('fH', '<Cmd>Pick hl_groups<CR>',                    'Highlight groups')
nmap_leader('fl', '<Cmd>Pick buf_lines scope="all"<CR>',        'Lines (all)')
nmap_leader('fL', '<Cmd>Pick buf_lines scope="current"<CR>',    'Lines (buf)')
nmap_leader('fm', '<Cmd>Pick git_hunks<CR>',                    'Modified hunks (all)')
nmap_leader('fM', '<Cmd>Pick git_hunks path="%"<CR>',           'Modified hunks (buf)')
nmap_leader('fr', '<Cmd>Pick resume<CR>',                       'Resume')
nmap_leader('fR', '<Cmd>Pick lsp scope="references"<CR>',       'References (LSP)')
nmap_leader('fs', pick_workspace_symbols_live,                  'Symbols workspace (live)')
nmap_leader('fS', '<Cmd>Pick lsp scope="document_symbol"<CR>',  'Symbols document')
nmap_leader('fv', '<Cmd>Pick visit_paths cwd=""<CR>',           'Visit paths (all)')
nmap_leader('fV', '<Cmd>Pick visit_paths<CR>',                  'Visit paths (cwd)')

-- g は 'Git' を表します。一般的な使用法:
-- - `<Leader>gs` - カーソル位置の情報を表示
-- - `<Leader>go` - バッファ内のステージされていない変更を表示するために 'mini.diff' オーバーレイを切り替え
-- - `<Leader>gd` - ステージされていない変更を別のタブページでパッチとして表示
-- - `<Leader>gL` - 現在のファイルのGitログを表示
local git_log_cmd = [[Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order]]
local git_log_buf_cmd = git_log_cmd .. ' --follow -- %'

nmap_leader('ga', '<Cmd>Git diff --cached<CR>',             'Added diff')
nmap_leader('gA', '<Cmd>Git diff --cached -- %<CR>',        'Added diff buffer')
nmap_leader('gc', '<Cmd>Git commit<CR>',                    'Commit')
nmap_leader('gC', '<Cmd>Git commit --amend<CR>',            'Commit amend')
nmap_leader('gd', '<Cmd>Git diff<CR>',                      'Diff')
nmap_leader('gD', '<Cmd>Git diff -- %<CR>',                 'Diff buffer')
nmap_leader('gl', '<Cmd>' .. git_log_cmd .. '<CR>',         'Log')
nmap_leader('gL', '<Cmd>' .. git_log_buf_cmd .. '<CR>',     'Log buffer')
nmap_leader('go', '<Cmd>lua MiniDiff.toggle_overlay()<CR>', 'Toggle overlay')
nmap_leader('gs', '<Cmd>lua MiniGit.show_at_cursor()<CR>',  'Show at cursor')

xmap_leader('gs', '<Cmd>lua MiniGit.show_at_cursor()<CR>', 'Show at selection')

-- l は 'Language' を表します。一般的な使用法:
-- - `<Leader>ld` - フローティングウィンドウでより詳細な診断を表示
-- - `<Leader>lr` - LSP経由でリネームを実行
-- - `<Leader>ls` - カーソル下のシンボルのソース定義に移動
--
-- 注意: ほとんどのLSPマッピングは組み込みのLSPマッピング (`:h gra` など) を置き換える
-- より構造化された方法を表しています。これは `gr` が 'mini.operators' の "replace"
-- オペレーターにマッピングされているため必要です（こちらがより一般的に使用されます）。
nmap_leader('la', '<Cmd>lua vim.lsp.buf.code_action()<CR>',     'Actions')
nmap_leader('ld', '<Cmd>lua vim.diagnostic.open_float()<CR>',   'Diagnostic popup')
nmap_leader('lf', '<Cmd>lua require("conform").format()<CR>',   'Format')
nmap_leader('li', '<Cmd>lua vim.lsp.buf.implementation()<CR>',  'Implementation')
nmap_leader('lh', '<Cmd>lua vim.lsp.buf.hover()<CR>',           'Hover')
nmap_leader('lr', '<Cmd>lua vim.lsp.buf.rename()<CR>',          'Rename')
nmap_leader('lR', '<Cmd>lua vim.lsp.buf.references()<CR>',      'References')
nmap_leader('ls', '<Cmd>lua vim.lsp.buf.definition()<CR>',      'Source definition')
nmap_leader('lt', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', 'Type definition')

xmap_leader('lf', '<Cmd>lua require("conform").format()<CR>', 'Format selection')

-- m は 'Map' を表します。一般的な使用法:
-- - `<Leader>mt` - 'mini.map' のマップを切り替え（デフォルトでは閉じている）
-- - `<Leader>mf` - 高速ナビゲーションのためにマップにフォーカス
-- - `<Leader>ms` - マップの側を変更（下の何かをカバーしている場合）
nmap_leader('mf', '<Cmd>lua MiniMap.toggle_focus()<CR>', 'Focus (toggle)')
nmap_leader('mr', '<Cmd>lua MiniMap.refresh()<CR>',      'Refresh')
nmap_leader('ms', '<Cmd>lua MiniMap.toggle_side()<CR>',  'Side (toggle)')
nmap_leader('mt', '<Cmd>lua MiniMap.toggle()<CR>',       'Toggle')

-- o は 'Other' を表します。一般的な使用法:
-- - `<Leader>oz` - 現在のバッファの「ズーム」表示と通常表示を切り替え
nmap_leader('or', '<Cmd>lua MiniMisc.resize_window()<CR>', 'Resize to default width')
nmap_leader('ot', '<Cmd>lua MiniTrailspace.trim()<CR>',    'Trim trailspace')
nmap_leader('oz', '<Cmd>lua MiniMisc.zoom()<CR>',          'Zoom toggle')

-- s は 'Session' を表します。一般的な使用法:
-- - `<Leader>sn` - 新しいセッションを開始
-- - `<Leader>sr` - 以前に開始したセッションを読み込み
-- - `<Leader>sd` - 以前に開始したセッションを削除
local session_new = 'MiniSessions.write(vim.fn.input("Session name: "))'

nmap_leader('sd', '<Cmd>lua MiniSessions.select("delete")<CR>', 'Delete')
nmap_leader('sn', '<Cmd>lua ' .. session_new .. '<CR>',         'New')
nmap_leader('sr', '<Cmd>lua MiniSessions.select("read")<CR>',   'Read')
nmap_leader('sw', '<Cmd>lua MiniSessions.write()<CR>',          'Write current')

-- t は 'Terminal' を表します
nmap_leader('tT', '<Cmd>horizontal term<CR>', 'Terminal (horizontal)')
nmap_leader('tt', '<Cmd>vertical term<CR>',   'Terminal (vertical)')

-- v は 'Visits' を表します。一般的な使用法:
-- - `<Leader>vv` - 現在のファイルに "core" ラベルを追加
-- - `<Leader>vV` - 現在のファイルから "core" ラベルを削除
-- - `<Leader>vc` - "core" ラベルを持つすべてのファイルから選択
local make_pick_core = function(cwd, desc)
  return function()
    local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
    local local_opts = { cwd = cwd, filter = 'core', sort = sort_latest }
    MiniExtra.pickers.visit_paths(local_opts, { source = { name = desc } })
  end
end

nmap_leader('vc', make_pick_core('',  'Core visits (all)'),       'Core visits (all)')
nmap_leader('vC', make_pick_core(nil, 'Core visits (cwd)'),       'Core visits (cwd)')
nmap_leader('vv', '<Cmd>lua MiniVisits.add_label("core")<CR>',    'Add "core" label')
nmap_leader('vV', '<Cmd>lua MiniVisits.remove_label("core")<CR>', 'Remove "core" label')
nmap_leader('vl', '<Cmd>lua MiniVisits.add_label()<CR>',          'Add label')
nmap_leader('vL', '<Cmd>lua MiniVisits.remove_label()<CR>',       'Remove label')
-- stylua: ignore end
