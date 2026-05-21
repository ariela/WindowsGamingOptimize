#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    電源プランを「バランス」に設定する（UMPC 専用）。
.DESCRIPTION
    powercfg でバランス電源プランをアクティブにする。
    携帯型 UMPC のバッテリー持続時間とパフォーマンスのバランスを最適化する。
    適用前に現在のアクティブプランを Write-ScriptLog で記録する。
.EXAMPLE
    Set-BalancedPowerPlan
.EXAMPLE
    Set-BalancedPowerPlan -WhatIf
#>
function Set-BalancedPowerPlan {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        $PlanGuid = '381b4222-f694-41f0-9685-ff5bb260df2e'
        $PlanName = 'Balanced'

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
