#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    NTP サーバーを ntp.nict.jp に設定する（Desktop・UMPC 共通）。
.EXAMPLE
    Set-NtpServer
.EXAMPLE
    Set-NtpServer -WhatIf
#>
function Set-NtpServer {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        $W32TimeKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters'
        $NtpServer  = 'ntp.nict.jp,0x9'

        Backup-RegistryKey -Path $W32TimeKey

        if ($PSCmdlet.ShouldProcess($W32TimeKey, "NtpServer を '$NtpServer' に設定")) {
            try {
                Set-ItemProperty -Path $W32TimeKey -Name 'NtpServer' -Value $NtpServer -Type String -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message "NtpServer = $NtpServer"
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "NtpServer 設定失敗: $($Err.Exception.Message)"
                throw
            }
        }
    }
}
