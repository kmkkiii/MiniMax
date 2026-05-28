-- ┌────────────────────┐
-- │ LSP config example │
-- └────────────────────┘
--
-- このファイルには 'lua_ls' 言語サーバーの設定が含まれています。
-- ソース: https://github.com/LuaLS/lua-language-server
--
-- これは `:h vim.lsp.enable()` と `:h vim.lsp.config()` で使用されます。
-- 利用可能なすべてのフィールドについては `:h vim.lsp.Config` と `:h vim.lsp.ClientConfig` を参照してください。
--
-- この設定はNeovim周辺のLuaアクティビティ向けに設計されています。基本的な設定のみを提供し、
-- さらに改善することができます。
return {
  on_attach = function(client, buf_id)
    -- より良い 'mini.completion' 体験のために非常に長いトリガーリストを削減
    client.server_capabilities.completionProvider.triggerCharacters =
      { '.', ':', '#', '(' }

    -- この関数を使用して、アタッチされたクライアントに依存するバッファローカルマッピングと
    -- 動作、または言語サーバーがアタッチされている場合にのみ意味があるものを定義します。
  end,
  -- LuaLS これらの設定の構造はNeovimではなくLuaLSから来ています
  settings = {
    Lua = {
      -- ランタイムプロパティを定義。Neovimに組み込まれているため 'LuaJIT' を使用。
      runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
      workspace = {
        -- サブモジュールからのコードを解析しない
        ignoreSubmodules = true,
        -- より簡単なコード記述のためにNeovimのメソッドを追加
        library = { vim.env.VIMRUNTIME },
      },
    },
  },
}
