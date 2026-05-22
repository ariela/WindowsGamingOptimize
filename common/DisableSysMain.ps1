#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    SysMain サービスのスタートアップを無効に設定する（Desktop・UMPC 共通）。
.EXAMPLE
    Disable-SysMain
.EXAMPLE
    Disable-SysMain -WhatIf
#>
function Disable-SysMain {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        $SysMainKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\SysMain'

        Backup-RegistryKey -Path $SysMainKey

        if ($PSCmdlet.ShouldProcess($SysMainKey, 'SysMain スタートアップを無効に設定')) {
            try {
                Set-ItemProperty -Path $SysMainKey -Name 'Start' -Value 4 -Type DWord -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message 'SysMain Start = 4 (無効)'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "SysMain 設定失敗: $($Err.Exception.Message)"
                throw
            }
        }
    }
}
