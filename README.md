# WindowsGamingOptimize

Windows ゲーミング PC 向けの設定・最適化スクリプト集。PowerShell スクリプトで
レジストリや OS 設定を一括変更し、ゲームプレイに最適な環境を構成する。

以下の 2 機種をターゲットとして、カテゴリ別にスクリプトを整理している。

- **Desktop Gaming PC** — 据え置き型ゲーミング PC（高性能 GPU・CPU を想定）
- **Gaming UMPC** — 携帯型ゲーミング PC（Lenovo Legion Go / ASUS ROG Ally 等の APU 搭載機）

## 対象環境

- OS: Windows 10 / Windows 11
- Shell: PowerShell 5.x
- 管理者権限での実行が必要

## 使い方

管理者権限で PowerShell を起動し、機種に応じたエントリポイントスクリプトを実行する。

```powershell
# Desktop Gaming PC
.\desktop.ps1

# Gaming UMPC
.\umpc.ps1
```

`-WhatIf` を付けると、実際の変更を加えずに適用内容を確認できる（ドライラン）。

```powershell
.\desktop.ps1 -WhatIf
```

各スクリプトは冪等性を保証しており、複数回実行しても同じ結果が得られる。
また、適用前にレジストリのバックアップとログ出力を行う。

---

## Common

desktop・UMPC の両機種に適用される最適化スクリプト。

| スクリプト名 | 説明 |
|---|---|
| `DisableGameBar.ps1` | Xbox Game Bar をレジストリで無効化する |
| `SetBalancedPowerPlan.ps1` | 電源プランを「バランス」に設定する |
| `SetExplorerOptions.ps1` | エクスプローラーのフォルダーオプションを最適化する |
| `SetMouseSettings.ps1` | マウスのポインター精度を無効化する |
| `SetStartMenuSettings.ps1` | スタートメニューの表示設定を構成する |
| `SetTaskbarSettings.ps1` | タスクバーの表示設定と Copilot を無効化する |
| `SetNtpServer.ps1` | NTP サーバーを ntp.nict.jp に設定する |
| `SetGameSettings.ps1` | GameBar のコントローラーショートカットを無効化し、ゲームモードを有効化する |
| `SetDisplaySettings.ps1` | GPU ハードウェアスケジューリングを有効化し、ウィンドウゲームの最適化を無効化する |
| `SetAccessibilitySettings.ps1` | ナレーターのキーボードショートカットと PrintScreen キーのスニッピング起動を無効化する |
| `SetPrivacySettings.ps1` | 検索のプライバシー設定を構成する |
| `SetAppXService.ps1` | AppX Development Service のスタートアップを手動トリガーに設定する |
| `SetNetworkSettings.ps1` | TCP の RSS・自動チューニング・タスクオフロードを無効化する |
| `SetDefenderExclusions.ps1` | Windows Defender のスキャン対象から MsMpEng.exe を除外する |
| `DisableSysMain.ps1` | SysMain サービスのスタートアップを無効化する |

---

## desktop

現在 `desktop/` ディレクトリに Desktop 専用の最適化スクリプトはない。
`desktop.ps1` は Common の全 15 スクリプトを適用する。

---

## umpc

Gaming UMPC 専用の最適化スクリプト。`umpc.ps1` は Common 全 15 スクリプトに加え、以下を適用する。

| スクリプト名 | 説明 |
|---|---|
| `DisableVisualEffects.ps1` | 透明効果とアニメーション効果を無効化する |

---

## lib

最適化スクリプトが共通で使用する内部ユーティリティ。設定の一括適用とは別に、ロギング・バックアップ機能を提供する。

| スクリプト名 | 説明 |
|---|---|
| `Logging.ps1` | ログ出力ユーティリティ（`Initialize-Log` / `Write-ScriptLog`） |
| `Backup.ps1` | レジストリバックアップユーティリティ（`Backup-RegistryKey`） |
