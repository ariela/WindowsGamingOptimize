---
paths:
  - "**/*.ps1"
---

# PowerShell コーディングガイドライン

## 適用範囲と優先順位

対象は `.ps1` ファイルと関数定義。`.reg` / `.bat` は対象外。
冪等性・バックアップ・ディレクトリ構成・ファイル命名は `CLAUDE.md` を参照（重複記載しない）。

出典と矛盾時の優先順位（1 > 2 > 3 > 4）:

1. PSScriptAnalyzer rules and recommendations
2. Strongly Encouraged Development Guidelines (PowerShell 7.6)
3. PowerShell-Docs Style Guide
4. PoshCode PowerShellPracticeAndStyle

## バージョン互換

Windows PowerShell 5.1 互換を必須とする。以下の PS7 専用構文は禁止:

- 三項演算子 `$a ? $b : $c`
- null 合体 `??` / null 代入 `??=`
- パイプラインチェーン `&&` / `||`
- `ForEach-Object -Parallel`
- `clean {}` ブロック
- null 条件アクセス `?.` / `?[]`

## 命名

- 関数名: `Verb-Noun` 形式、承認動詞（`Get-Verb` 参照）、PascalCase、名詞は単数。
- パラメータ名: PascalCase。標準名（`Path`・`LiteralPath`・`Name`・`Credential`）を優先。
- 変数名: PascalCase（スクリプト内部の局所変数は camelCase でもよい）。

## エイリアス・完全名

- エイリアス禁止（例: `ls` → `Get-ChildItem`、`%` → `ForEach-Object`、`?` → `Where-Object`）。
- パラメータ名は省略せず明示する。
- 位置指定パラメータを避ける（例: `Get-Item $p` 禁止 → `Get-Item -Path $p`）。

## フォーマット

- インデント: 4スペース（タブ禁止）。
- ブレーススタイル: OTBS（開き括弧は行末、閉じ括弧は独立行）。
- 言語キーワード・演算子は小文字（`if`、`foreach`、`-and`、`-or`）。
- 行末セミコロン禁止。
- 演算子の前後・カンマの後にスペース1つ。
- 行長 ~115 文字目安。

## 行連結とスプラッティング

バッククォート（`` ` ``）による行連結は禁止（末尾空白で無音に破綻するため）。
引数が多い/行が長い場合はスプラッティングを使用。パイプ後・括弧内での自然改行を活用する。

```powershell
$Params = @{
    Path        = $DestPath
    Recurse     = $true
    ErrorAction = 'Stop'
}
Copy-Item @Params
```

## 関数定義

- `[CmdletBinding()]` を必ず付与する。
- パラメータ検証は属性（`[ValidateSet()]`・`[ValidateRange()]`・`[ValidateNotNullOrEmpty()]`）で行い、手動チェックを置き換える。
- `[OutputType()]` で出力型を明示する。
- パイプライン入力は `process {}` ブロックで処理する。
- `return` キーワードを避け、出力オブジェクトは単独行に置く。

## 状態変更と安全性

システム・レジストリ・ファイルを変更する関数は `SupportsShouldProcess` を宣言し
`$PSCmdlet.ShouldProcess()` で変更を保護する（本プロジェクトはシステム変更が主目的のため必須）。

```powershell
function Set-PowerPlan {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$PlanName)
    process {
        if ($PSCmdlet.ShouldProcess($PlanName, '電源プランを変更')) {
            # 実際の変更処理
        }
    }
}
```

## エラーハンドリング

- `-ErrorAction Stop` で非終了エラーを終了エラーに昇格させる。
- 状態変更は `try`/`catch` で構造化する。`catch {}` を空にしない。
- `catch` 冒頭で `$_` を自前変数へ退避する（後続処理で上書きされるため）。
- `$?` / null チェックによるエラー判定を避ける。

```powershell
try {
    Set-ItemProperty @Params -ErrorAction Stop
}
catch {
    $Err = $_
    Write-Error "変更失敗: $($Err.Message)"
}
```

## 出力

- データ出力: `Write-Output`（または暗黙の出力）。
- 診断情報: `Write-Verbose` / `Write-Warning` / `Write-Debug`。
- ユーザ通知: `Write-Information`。長時間処理: `Write-Progress`。
- `Write-Host` は表示専用途のみ（キャプチャ/パイプ不可のため）。
- 文字列とオブジェクトを同一パイプラインに混在出力しない。

## セキュリティ

- `Invoke-Expression` 禁止（コードインジェクションリスク）。
- 資格情報は `[PSCredential]` 型で受け取る。平文パスワードのパラメータ禁止。
- 機密値は `SecureString` で扱い、`ConvertFrom-SecureString` / `Export-CliXml` で永続化。
- WMI コマンドレット（`Get-WmiObject` 等）は非推奨。`Get-CimInstance` 等の CIM コマンドレットを使用。

## コメントベースヘルプ

公開スクリプト・公開関数にはコメントベースヘルプを付す。
ヘルプキーワードは大文字（`.SYNOPSIS`・`.DESCRIPTION`・`.PARAMETER`・`.EXAMPLE`・`.OUTPUTS`）。
最低限 `.SYNOPSIS` と `.EXAMPLE` を含める。

## 静的解析

PSScriptAnalyzer をデフォルトルールで適用し、警告ゼロを目標とする。

```powershell
Invoke-ScriptAnalyzer -Path . -Recurse -Severity Warning, Error
```
