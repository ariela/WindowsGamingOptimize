#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    電源プランを「高パフォーマンス」に設定する（Desktop 専用）。
.DESCRIPTION
    powercfg で高パフォーマンス電源プランをアクティブにする。
    適用前に現在のアクティブプランを Write-ScriptLog で記録する。
.EXAMPLE
    Set-HighPerformancePowerPlan
.EXAMPLE
    Set-HighPerformancePowerPlan -WhatIf
#>
function Set-HighPerformancePowerPlan {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        $PlanGuid = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
        $PlanName = 'High Performance'

        $CurrentScheme = & powercfg /getactivescheme 2>&1
        Write-ScriptLog -Level INFO -Message "現在の電源プラン: $($CurrentScheme -join ' ')"

        if ($PSCmdlet.ShouldProcess($PlanName, '電源プランを適用')) {
            try {
                $null = & powercfg /setactive $PlanGuid 2>&1
                if ($LASTEXITCODE -ne 0) {
                    throw "powercfg が終了コード $LASTEXITCODE で終了しました"
                }
                Write-ScriptLog -Level INFO -Message "電源プランを '$PlanName' に設定しました"
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "電源プラン設定失敗: $($Err.Message)"
                throw
            }
        }
    }
}
