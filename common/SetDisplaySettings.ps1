#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    GPU ハードウェアスケジューリングを有効化し、ウィンドウゲームの最適化を無効化する（Desktop・UMPC 共通）。
.EXAMPLE
    Set-DisplaySetting
.EXAMPLE
    Set-DisplaySetting -WhatIf
#>
function Set-DisplaySetting {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        $GraphicsDriversKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers'
        $DirectXUserKey     = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'

        Backup-RegistryKey -Path $GraphicsDriversKey
        Backup-RegistryKey -Path $DirectXUserKey

        if ($PSCmdlet.ShouldProcess($GraphicsDriversKey, 'ハードウェアアクセラレータによる GPU スケジューリング → ON')) {
            try {
                Set-ItemProperty -Path $GraphicsDriversKey -Name 'HwSchMode' -Value 2 -Type DWord -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message 'HwSchMode = 2 (GPU スケジューリング ON)'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "HwSchMode 設定失敗: $($Err.Exception.Message)"
                throw
            }
        }

        if ($PSCmdlet.ShouldProcess($DirectXUserKey, 'ウィンドウゲームの最適化 → OFF')) {
            try {
                if (-not (Test-Path -Path $DirectXUserKey)) {
                    $null = New-Item -Path $DirectXUserKey -Force -ErrorAction Stop
                }
                Set-ItemProperty -Path $DirectXUserKey -Name 'DirectXUserGlobalSettings' -Value 'SwapEffectUpgradeEnable=0;' -Type String -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message 'DirectXUserGlobalSettings = SwapEffectUpgradeEnable=0;'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "DirectXUserGlobalSettings 設定失敗: $($Err.Exception.Message)"
                throw
            }
        }
    }
}
