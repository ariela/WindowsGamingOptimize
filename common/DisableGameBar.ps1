#Requires -Version 5.1

<#
.SYNOPSIS
    Xbox Game Bar をレジストリで無効化する（Desktop・UMPC 共通）。
.DESCRIPTION
    HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR および
    HKCU:\System\GameConfigStore の設定値を変更して Game Bar を無効化する。
    変更前に対象レジストリキーをバックアップする。
.EXAMPLE
    Disable-GameBar
.EXAMPLE
    Disable-GameBar -WhatIf
#>
function Disable-GameBar {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        $GameDvrKey    = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR'
        $GameConfigKey = 'HKCU:\System\GameConfigStore'

        Backup-RegistryKey -Path $GameDvrKey
        Backup-RegistryKey -Path $GameConfigKey

        if ($PSCmdlet.ShouldProcess($GameDvrKey, 'AppCaptureEnabled を 0 に設定')) {
            try {
                if (-not (Test-Path -Path $GameDvrKey)) {
                    New-Item -Path $GameDvrKey -Force | Out-Null
                }
                Set-ItemProperty -Path $GameDvrKey -Name 'AppCaptureEnabled' -Value 0 -Type DWord -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message "GameDVR: AppCaptureEnabled = 0"
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "GameDVR 設定失敗: $($Err.Message)"
                throw
            }
        }

        if ($PSCmdlet.ShouldProcess($GameConfigKey, 'GameDVR_Enabled を 0 に設定')) {
            try {
                if (-not (Test-Path -Path $GameConfigKey)) {
                    New-Item -Path $GameConfigKey -Force | Out-Null
                }
                Set-ItemProperty -Path $GameConfigKey -Name 'GameDVR_Enabled' -Value 0 -Type DWord -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message "GameConfigStore: GameDVR_Enabled = 0"
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "GameConfigStore 設定失敗: $($Err.Message)"
                throw
            }
        }
    }
}
