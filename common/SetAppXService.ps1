#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    AppX Development Service のスタートアップを手動トリガーに設定する（Desktop・UMPC 共通）。
.EXAMPLE
    Set-AppXService
.EXAMPLE
    Set-AppXService -WhatIf
#>
function Set-AppXService {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        $AppXSvcKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\AppXSvc'

        Backup-RegistryKey -Path $AppXSvcKey

        if ($PSCmdlet.ShouldProcess($AppXSvcKey, 'AppXSvc スタートアップを手動トリガーに設定')) {
            try {
                Set-ItemProperty -Path $AppXSvcKey -Name 'Start' -Value 3 -Type DWord -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message 'AppXSvc Start = 3 (手動トリガー)'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "AppXSvc 設定失敗: $($Err.Message)"
                throw
            }
        }
    }
}
