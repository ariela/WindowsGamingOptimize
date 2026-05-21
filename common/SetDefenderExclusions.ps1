#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Windows Defender のスキャン対象から MsMpEng.exe を除外する（Desktop・UMPC 共通）。
.EXAMPLE
    Set-DefenderExclusion
.EXAMPLE
    Set-DefenderExclusion -WhatIf
#>
function Set-DefenderExclusion {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        $ExclusionPath    = 'C:\Program Files\Windows Defender\MsMpEng.exe'
        $ExclusionProcess = 'MsMpEng.exe'

        if ($PSCmdlet.ShouldProcess($ExclusionPath, 'Defender 除外パスに追加')) {
            try {
                $CurrentPaths = @((Get-MpPreference -ErrorAction Stop).ExclusionPath)
                if ($ExclusionPath -notin $CurrentPaths) {
                    Add-MpPreference -ExclusionPath $ExclusionPath -ErrorAction Stop
                    Write-ScriptLog -Level INFO -Message "除外パス追加: $ExclusionPath"
                }
                else {
                    Write-ScriptLog -Level INFO -Message "除外パス設定済み: $ExclusionPath"
                }
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "除外パス設定失敗: $($Err.Message)"
                throw
            }
        }

        if ($PSCmdlet.ShouldProcess($ExclusionProcess, 'Defender 除外プロセスに追加')) {
            try {
                $CurrentProcesses = @((Get-MpPreference -ErrorAction Stop).ExclusionProcess)
                if ($ExclusionProcess -notin $CurrentProcesses) {
                    Add-MpPreference -ExclusionProcess $ExclusionProcess -ErrorAction Stop
                    Write-ScriptLog -Level INFO -Message "除外プロセス追加: $ExclusionProcess"
                }
                else {
                    Write-ScriptLog -Level INFO -Message "除外プロセス設定済み: $ExclusionProcess"
                }
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "除外プロセス設定失敗: $($Err.Message)"
                throw
            }
        }
    }
}
