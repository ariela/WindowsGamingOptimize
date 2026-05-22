#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Desktop Gaming PC 向け最適化を一括適用するエントリーポイント。
.DESCRIPTION
    lib/ のユーティリティと common/ desktop/ の最適化スクリプトをドットソースで読み込み、
    $Steps に列挙した関数を順に実行する。-WhatIf を付けると全ステップがドライランになる。
.EXAMPLE
    .\desktop.ps1
.EXAMPLE
    .\desktop.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RootDir = $PSScriptRoot

# lib をドットソース（ユーティリティ関数を読み込む）
foreach ($LibFile in Get-ChildItem -Path (Join-Path -Path $RootDir -ChildPath 'lib') -Filter '*.ps1' -File) {
    . $LibFile.FullName
}

Initialize-Log -RootDir $RootDir
Write-ScriptLog -Level INFO -Message '=== Desktop 最適化 開始 ==='

# 最適化スクリプトをドットソース（関数定義の読み込み）
foreach ($Category in @('common', 'desktop')) {
    $CategoryDir = Join-Path -Path $RootDir -ChildPath $Category
    if (-not (Test-Path -Path $CategoryDir -PathType Container)) { continue }
    foreach ($ScriptFile in Get-ChildItem -Path $CategoryDir -Filter '*.ps1' -File) {
        . $ScriptFile.FullName
    }
}

# 実行する最適化を順序付きで明示
$Steps = @(
    'Disable-GameBar'
    'Set-BalancedPowerPlan'
    'Set-ExplorerOption'
    'Set-MouseSetting'
    'Set-StartMenuSetting'
    'Set-TaskbarSetting'
    'Set-NtpServer'
    'Set-GameSetting'
    'Set-DisplaySetting'
    'Set-AccessibilitySetting'
    'Set-PrivacySetting'
    'Set-AppXService'
    'Disable-SysMain'
    'Set-NetworkSetting'
    'Set-DefenderExclusion'
    'Disable-Hibernation'
)

$FailureCount = 0
foreach ($Step in $Steps) {
    try {
        Write-ScriptLog -Level INFO -Message "--- $Step 開始 ---"
        & $Step
        Write-ScriptLog -Level INFO -Message "--- $Step 完了 ---"
    }
    catch {
        $StepError = $_
        $FailureCount++
        Write-ScriptLog -Level ERROR -Message "--- $Step 失敗: $($StepError.Exception.Message) ---"
    }
}

$SuccessCount = $Steps.Count - $FailureCount
Write-ScriptLog -Level INFO -Message "=== Desktop 最適化 終了: $SuccessCount 成功 / $FailureCount 失敗 ==="
