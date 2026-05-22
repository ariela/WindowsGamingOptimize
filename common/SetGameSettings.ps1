#Requires -Version 5.1

<#
.SYNOPSIS
    GameBar のコントローラーショートカットを無効化し、ゲームモードを有効化する（Desktop・UMPC 共通）。
.EXAMPLE
    Set-GameSetting
.EXAMPLE
    Set-GameSetting -WhatIf
#>
function Set-GameSetting {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        $GameBarKey = 'HKCU:\Software\Microsoft\GameBar'

        Backup-RegistryKey -Path $GameBarKey

        $Props = [ordered]@{
            'UseNexusForGameBarEnabled' = @{ Value = 0; Desc = 'GameBar: コントローラーショートカット → OFF' }
            'AutoGameModeEnabled'       = @{ Value = 1; Desc = 'ゲームモード → ON' }
        }

        foreach ($Name in $Props.Keys) {
            $Prop = $Props[$Name]
            if ($PSCmdlet.ShouldProcess($GameBarKey, $Prop.Desc)) {
                try {
                    if (-not (Test-Path -Path $GameBarKey)) {
                        $null = New-Item -Path $GameBarKey -Force -ErrorAction Stop
                    }
                    Set-ItemProperty -Path $GameBarKey -Name $Name -Value $Prop.Value -Type DWord -ErrorAction Stop
                    Write-ScriptLog -Level INFO -Message "$Name = $($Prop.Value)"
                }
                catch {
                    $Err = $_
                    Write-ScriptLog -Level ERROR -Message "$Name 設定失敗: $($Err.Exception.Message)"
                    throw
                }
            }
        }
    }
}
