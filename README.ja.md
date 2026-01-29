<p align="center"> <img src="logo.png" alt="mini.nvim" style="max-width:100%;border:solid 2px"/> </p>

## 最大限のMINIを持つNeovim

MiniMaxは、完全に機能する自己完結型のNeovim設定のコレクションです。すべての設定が以下の特徴を持っています:

- 主にMINIを使用してその機能を紹介します。
- すぐに使える安定した、洗練された、機能豊富なNeovim体験を提供します。
- 構築可能な最小限の構造を共有します。
- 読まれることを意図した広範にコメントされた設定ファイルを含んでいます。

[利用可能な設定](configs)から最適なものを使用する、自動[セットアップ](#セットアップ)が可能です。

変更履歴については[チェンジログ](CHANGELOG.md)を参照してください。

このプロジェクトが役に立つと思われた場合は、GitHubスターを残すことをご検討ください。

### 外観

<a href="https://github.com/nvim-mini/assets/blob/main/demo/demo-minimax_1.png?raw=true"> <img alt="セットアップ中" src="https://github.com/nvim-mini/assets/blob/main/demo/demo-minimax_1.png?raw=true" style="width: 45%"/> </a>
<a href="https://github.com/nvim-mini/assets/blob/main/demo/demo-minimax_2.png?raw=true"> <img alt="ピッカー" src="https://github.com/nvim-mini/assets/blob/main/demo/demo-minimax_2.png?raw=true" style="width: 45%"/> </a>

<a href="https://github.com/nvim-mini/assets/blob/main/demo/demo-minimax_3.png?raw=true"> <img alt="ヒント" src="https://github.com/nvim-mini/assets/blob/main/demo/demo-minimax_3.png?raw=true" style="width: 45%"/> </a>
<a href="https://github.com/nvim-mini/assets/blob/main/demo/demo-minimax_4.png?raw=true"> <img alt="ファイルエクスプローラー" src="https://github.com/nvim-mini/assets/blob/main/demo/demo-minimax_4.png?raw=true" style="width: 45%"/> </a>

### MiniMaxでないもの

これは「Neovimディストリビューション」ではありません。つまり、設定の自動更新はありません。設定がセットアップされた後は、それはあなたのものであり、改善と更新を行います（これによりこのアプローチはより安定します）。それでもMiniMax自体がどのように更新されるかを確認し（[更新](#更新)と[チェンジログ](CHANGELOG.md)を参照）、それに応じて設定を調整できます。

これはすべてのNeovim機能とプラグインの設定と使用方法に関する包括的なガイドではありません。設定のほとんどの部分は、安定性と機能のバランスを達成するために慎重に選択されています。

### 要件

#### ソフトウェア

- [Neovim](https://neovim.io/)実行ファイル。`nvim`という名前であると想定されています。
- [Git](https://git-scm.com/)実行ファイル。`git`という名前であると想定されています。
- オペレーティングシステム: Neovimがサポートする任意のOS。
- プラグインをダウンロードするためのインターネット接続。
- (オプションですが推奨) [`ripgrep`](https://github.com/BurntSushi/ripgrep#installation)。
- (オプションですが推奨) [True colors](https://github.com/termstandard/colors#truecolor-support-in-output-devices)と[Nerd Fontアイコン](https://www.nerdfonts.com/)をサポートするターミナルエミュレータ（またはGUI）。完全なNerdフォントは必要ありません。フォールバックとして[`NerdFontsSymbolsOnly`](https://github.com/ryanoasis/nerd-fonts/releases/latest)を使用するだけで通常は十分です。
- (オプションですが推奨) ['nvim-treesitter/nvim-treesitter'プラグインの`main`ブランチのシステム要件](https://github.com/nvim-treesitter/nvim-treesitter/tree/main?tab=readme-ov-file#requirements)。

#### 知識

以下の方法の基本的な理解レベル:

- CLIの使用（コマンドライン）: 開く、ファイルシステムをナビゲート、コマンドを実行、閉じる。

- Neovimの使用: 開く、モーダル編集、ヘルプを読む、閉じる。Neovim内で[`:h help.txt`](https://neovim.io/doc/user/helptag.html?tag=help.txt)（またはリンクの場合はクリック）と入力し、その後`<Enter>`を押すと、基本を理解するためのガイドが表示されます。

    いくつかの個人的な推奨事項（全文を読む必要はありません；その内容を認識してください）: [`:h notation`](https://neovim.io/doc/user/helptag.html?tag=notation), [`:h key-notation`](https://neovim.io/doc/user/helptag.html?tag=key-notation), [`:h vim-modes`](https://neovim.io/doc/user/helptag.html?tag=vim-modes), [`:h mode-switching`](https://neovim.io/doc/user/helptag.html?tag=mode-switching), [`:h windows-intro`](https://neovim.io/doc/user/helptag.html?tag=windows-intro),  [`:h vimtutor`](https://neovim.io/doc/user/helptag.html?tag=vimtutor)

- Neovim内からヘルプファイルを読む: ヘルプタグの概念、キー表記、ナビゲーション。

  > [!TIP]
  > 既にMiniMax設定内にいる場合は、`<Space>` + `f` + `h`を押してすべてのヘルプタグをファジー検索できます。

- [Lua言語](https://learnxinyminutes.com/lua/)を読む: 変数、テーブル、関数呼び出し、イテレーション。[`:h lua-concepts`](https://neovim.io/doc/user/helptag.html?tag=lua-concepts)と[`:h lua-guide`](https://neovim.io/doc/user/helptag.html?tag=lua-guide)も参照してください。

#### モチベーション

- ドキュメントを読んで練習する精神的な準備ができていると、本当に役立ちます。NeovimやMINIに初めて触れる場合、多く感じるかもしれません。学習と練習を重ねるにつれて、より簡単になります。これがないと、NeovimとMiniMaxを十分に楽しめない可能性があります。

### セットアップ

これは一時的な'nvim-minimax'設定をセットアップし、通常の設定には影響しません。完全な設定をセットアップするには、`NVIM_APPNAME=nvim-minimax`のすべてのインスタンスを削除してください。

```bash
# ダウンロード
git clone --filter=blob:none https://github.com/nvim-mini/MiniMax ./MiniMax

# 設定をセットアップ（設定ファイルをコピーし、場合によってはGitリポジトリを初期化します）
NVIM_APPNAME=nvim-minimax nvim -l ./MiniMax/setup.lua

# Neovimを起動
NVIM_APPNAME=nvim-minimax nvim

# プラグインがインストールされるまで待つ（新しい通知がなくなるまで）

# 新しい設定を楽しんでください!
# そのファイルを読むことから始めてください。`<Space>`+`e`+`i`と入力して'init.lua'を開きます。
```

注意:

- MiniMaxプロジェクトは手動でダウンロードできます（GitHub UIなど経由）。

- `NVIM_APPNAME=nvim-minimax`を使用すると、設定ディレクトリはUnixでは'\~/.config/nvim-minimax'、Windowsでは'\~/AppData/Local/nvim-minimax'になります。

    完全な設定ディレクトリは、Unixでは'\~/.config/nvim'、Windowsでは'\~/AppData/Local/nvim'です。

- セットアップ中にバックアップされたファイルに関するメッセージがある場合、ターゲット設定ディレクトリにMiniMaxから来ることを意図したファイルが既に含まれていたことを意味します。以前のファイルは`MiniMax-backup`ディレクトリに移動されました。それらを確認/復元し、バックアップディレクトリ全体を削除してください。

- [MiniMax](configs)を手動で探索して、どの設定例（の一部）が最適かを見つけることができます。関連する設定例（'init.lua'から始まる）を読み、既存の設定で興味深い部分を使用してください。

### 更新

MiniMaxは、既にセットアップされた設定の完全に自動的な更新を提供しません。推奨されるアプローチは、[configs](configs)と[チェンジログ](CHANGELOG.md)を手動で探索して変更を確認することです。

自動更新に最も近いアプローチは:

```bash
# MiniMax自体の更新をプル
git -C ./MiniMax pull

# セットアップスクリプトを再度実行。完全な設定の場合は `NVIM_APPNAME=nvim-minimax` を削除
NVIM_APPNAME=nvim-minimax nvim -l ./MiniMax/setup.lua

# おそらくバックアップされたファイルに関するメッセージがあります:
# 1. 競合するファイルを含む 'MiniMax-backup' ディレクトリを確認します。
# 2. 必要なものを復元します。
# 3. バックアップディレクトリを削除します。
```

### 類似プロジェクト

- [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)

- より自動化されたアプローチ（「Neovimディストリビューション」）:
    - [LazyVim/LazyVim](https://github.com/LazyVim/LazyVim)
    - [NvChad/NvChad](https://github.com/NvChad/NvChad)
    - [AstroNvim/AstroNvim](https://github.com/AstroNvim/AstroNvim)
