#Requires -Version 5.1

<#
.SYNOPSIS
    ナレーターのキーボードショートカットと PrintScreen キーのスニッピング起動を無効化する（Desktop・UMPC 共通）。
.EXAMPLE
    Set-AccessibilitySetting
.EXAMPLE
    Set-AccessibilitySetting -WhatIf
#>
function Set-AccessibilitySetting {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        $NarratorKey = 'HKCU:\Software\Microsoft\Narrator\NoRoam'
        $KeyboardKey = 'HKCU:\Control Panel\Keyboard'

        Backup-RegistryKey -Path $NarratorKey
        Backup-RegistryKey -Path $KeyboardKey

        if ($PSCmdlet.ShouldProcess($NarratorKey, 'ナレーター: キーボードショートカット → OFF')) {
            try {
                if (-not (Test-Path -Path $NarratorKey)) {
                    $null = New-Item -Path $NarratorKey -Force -ErrorAction Stop
                }
                Set-ItemProperty -Path $NarratorKey -Name 'WinEnterLaunchEnabled' -Value 0 -Type DWord -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message 'WinEnterLaunchEnabled = 0'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "WinEnterLaunchEnabled 設定失敗: $($Err.Message)"
                throw
            }
        }

        if ($PSCmdlet.ShouldProcess($KeyboardKey, 'PrintScreen キーによる画面キャプチャ起動 → OFF')) {
            try {
                Set-ItemProperty -Path $KeyboardKey -Name 'PrintScreenKeyForSnippingEnabled' -Value 0 -Type DWord -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message 'PrintScreenKeyForSnippingEnabled = 0'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "PrintScreenKeyForSnippingEnabled 設定失敗: $($Err.Message)"
                throw
            }
        }
    }
}
