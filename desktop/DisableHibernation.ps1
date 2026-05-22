#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    休止状態を無効化する（Desktop 専用）。
.DESCRIPTION
    powercfg /hibernate off を実行して休止状態を無効化し、hiberfil.sys を削除する。
    デスクトップ PC では休止状態が不要なため、ディスク容量の節約と不要な電源移行を排除する。
.EXAMPLE
    Disable-Hibernation
.EXAMPLE
    Disable-Hibernation -WhatIf
#>
function Disable-Hibernation {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        if ($PSCmdlet.ShouldProcess('hibernate', '休止状態を無効化 (powercfg /hibernate off)')) {
            try {
                & powercfg /hibernate off
                if ($LASTEXITCODE -ne 0) {
                    throw "powercfg /hibernate off が終了コード $LASTEXITCODE で失敗した"
                }
                Write-ScriptLog -Level INFO -Message '休止状態を無効化しました (powercfg /hibernate off)'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "休止状態の無効化失敗: $($Err.Exception.Message)"
                throw
            }
        }
    }
}
