#Requires -Version 5.1

<#
.SYNOPSIS
    検索のプライバシー設定を構成する（Desktop・UMPC 共通）。
.EXAMPLE
    Set-PrivacySetting
.EXAMPLE
    Set-PrivacySetting -WhatIf
#>
function Set-PrivacySetting {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        $SearchSettingsKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings'

        Backup-RegistryKey -Path $SearchSettingsKey

        $Props = [ordered]@{
            'SafeSearchMode'           = @{ Value = 0; Desc = 'セーフサーチ → OFF' }
            'IsMSACloudSearchEnabled'  = @{ Value = 0; Desc = 'MSA クラウドコンテンツの検索 → OFF' }
            'IsAADCloudSearchEnabled'  = @{ Value = 0; Desc = 'AAD クラウドコンテンツの検索 → OFF' }
            'IsDynamicSearchBoxEnabled' = @{ Value = 0; Desc = '検索のハイライト → OFF' }
        }

        foreach ($Name in $Props.Keys) {
            $Prop = $Props[$Name]
            if ($PSCmdlet.ShouldProcess($SearchSettingsKey, $Prop.Desc)) {
                try {
                    Set-ItemProperty -Path $SearchSettingsKey -Name $Name -Value $Prop.Value -Type DWord -ErrorAction Stop
                    Write-ScriptLog -Level INFO -Message "$Name = $($Prop.Value)"
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
