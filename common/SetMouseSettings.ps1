#Requires -Version 5.1

<#
.SYNOPSIS
    マウスのポインター精度を無効化する（Desktop・UMPC 共通）。
.EXAMPLE
    Set-MouseSetting
.EXAMPLE
    Set-MouseSetting -WhatIf
#>
function Set-MouseSetting {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        $MouseKey = 'HKCU:\Control Panel\Mouse'

        Backup-RegistryKey -Path $MouseKey

        $Props = [ordered]@{
            'MouseSpeed'      = '0'
            'MouseThreshold1' = '0'
            'MouseThreshold2' = '0'
        }

        foreach ($Name in $Props.Keys) {
            if ($PSCmdlet.ShouldProcess($MouseKey, "$Name → $($Props[$Name])")) {
                try {
                    Set-ItemProperty -Path $MouseKey -Name $Name -Value $Props[$Name] -Type String -ErrorAction Stop
                    Write-ScriptLog -Level INFO -Message "$Name = $($Props[$Name])"
                }
                catch {
                    $Err = $_
                    Write-ScriptLog -Level ERROR -Message "$Name 設定失敗: $($Err.Message)"
                    throw
                }
            }
        }
    }
}
