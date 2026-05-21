# CLAUDE.md

## Purpose

Windows gaming PC 向けの設定・最適化スクリプト群。以下の2種類の実機に対して適用できるスクリプトを配置する。

- **Desktop Gaming PC**: 据え置き型ゲーミングPC（高性能 GPU・CPU を想定）
- **Gaming UMPC**: ゲーミング UMPC（APU 搭載の携帯型、Lenovo Legion Go / ASUS ROG Ally 等を想定）

スクリプトは PowerShell を主体とし、必要に応じて Windows Registry ファイル（.reg）や Windows batch ファイルも使用する。

## Target Environment

- OS: Windows 10 / Windows 11
- Shell: PowerShell 5.x
- 管理者権限での実行を前提とする

## Development Environment

ツールバージョン管理に [mise](https://mise.jdx.dev/) を使用する。`.mise.toml` でバージョンを固定している。

- **pwsh**: 7.4.15（LTS）— 静的解析・スクリプト検証用

### セットアップ

```sh
# ツールインストール（初回 or バージョン変更後）
mise install

# PSScriptAnalyzer インストール（初回のみ）
mise run install-analyzer
```

## Static Analysis

コードを修正したら `mise run lint` で静的解析を実施する。

```sh
mise run lint
```

- `PSUseBOMForUnicodeEncodedFile` ルールは除外済み（macOS/Linux での開発を考慮）
- `Error` 重大度の指摘があると exit 1 で終了する
- `Warning` / `Information` は一覧表示のみ（exit 0）

## Repository Conventions

### ディレクトリ構成（想定）

```
/
├── common/          # Desktop・UMPC 両方に適用するスクリプト
├── desktop/         # Desktop Gaming PC 専用スクリプト
├── umpc/            # Gaming UMPC 専用スクリプト
└── lib/             # 共通関数・ユーティリティ
```

### スクリプト記述ルール

- 各スクリプトの先頭に `#Requires -RunAsAdministrator` を明記する（管理者権限が必要な場合）
- 冪等性（何度実行しても同じ結果になること）を保証する
- 適用前に現在の設定値をバックアップ・ログ出力する
- Desktop 専用／UMPC 専用の差異はスクリプト分割で表現し、条件分岐で吸収しない
- レジストリ変更は `.reg` ファイルとして独立させるか、PowerShell の `Set-ItemProperty` で行う

### 命名規則

- スクリプトファイル: `PascalCase.ps1`（例: `DisableGameBar.ps1`、`SetPowerPlan.ps1`）
- 共通関数: `lib/` 配下に `PascalCase.ps1` で配置し、呼び出し元でドットソース読み込み（`. .\lib\Logging.ps1`）