#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    TCP の RSS・自動チューニング・タスクオフロードを無効化する（Desktop・UMPC 共通）。
.EXAMPLE
    Set-NetworkSetting
.EXAMPLE
    Set-NetworkSetting -WhatIf
#>
function Set-NetworkSetting {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        $TcpipKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'

        Backup-RegistryKey -Path $TcpipKey

        if ($PSCmdlet.ShouldProcess('TCP グローバル設定', 'RSS を無効化')) {
            try {
                $null = & netsh int tcp set global rss=disabled 2>&1
                if ($LASTEXITCODE -ne 0) {
                    throw "netsh が終了コード $LASTEXITCODE で終了しました"
                }
                Write-ScriptLog -Level INFO -Message 'TCP RSS: disabled'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "RSS 無効化失敗: $($Err.Exception.Message)"
                throw
            }
        }

        if ($PSCmdlet.ShouldProcess('TCP グローバル設定', '受信ウィンドウ自動チューニングを無効化')) {
            try {
                $null = & netsh int tcp set global autotuninglevel=disabled 2>&1
                if ($LASTEXITCODE -ne 0) {
                    throw "netsh が終了コード $LASTEXITCODE で終了しました"
                }
                Write-ScriptLog -Level INFO -Message 'TCP AutoTuningLevel: disabled'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "自動チューニング無効化失敗: $($Err.Exception.Message)"
                throw
            }
        }

        if ($PSCmdlet.ShouldProcess($TcpipKey, 'タスクオフロードを無効化')) {
            try {
                Set-ItemProperty -Path $TcpipKey -Name 'DisableTaskOffload' -Value 1 -Type DWord -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message 'DisableTaskOffload = 1'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "DisableTaskOffload 設定失敗: $($Err.Exception.Message)"
                throw
            }
        }
    }
}
