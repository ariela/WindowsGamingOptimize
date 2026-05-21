#Requires -Version 5.1

<#
.SYNOPSIS
    タスクバーの表示設定と Copilot を無効化する（Desktop・UMPC 共通）。
.EXAMPLE
    Set-TaskbarSetting
.EXAMPLE
    Set-TaskbarSetting -WhatIf
#>
function Set-TaskbarSetting {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        $SearchKey        = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
        $AdvancedKey      = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        $CopilotPolicyKey = 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot'
        $SearchPolicyKey  = 'HKCU:\Software\Policies\Microsoft\Windows\Explorer'

        Backup-RegistryKey -Path $SearchKey
        Backup-RegistryKey -Path $AdvancedKey
        Backup-RegistryKey -Path $CopilotPolicyKey
        Backup-RegistryKey -Path $SearchPolicyKey

        if ($PSCmdlet.ShouldProcess($SearchKey, '検索ボックスをテキスト検索ボックスで表示')) {
            try {
                Set-ItemProperty -Path $SearchKey -Name 'SearchboxTaskbarMode' -Value 2 -Type DWord -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message 'SearchboxTaskbarMode = 2'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "SearchboxTaskbarMode 設定失敗: $($Err.Message)"
                throw
            }
        }

        $AdvancedProps = [ordered]@{
            'ShowCopilotButton'  = @{ Value = 0; Desc = 'タスクバー: Copilot ボタン → OFF' }
            'ShowTaskViewButton' = @{ Value = 0; Desc = 'タスクバー: タスクビュー → OFF' }
            'TaskbarDa'          = @{ Value = 0; Desc = 'タスクバー: ウィジェット → OFF' }
        }

        foreach ($Name in $AdvancedProps.Keys) {
            $Prop = $AdvancedProps[$Name]
            if ($PSCmdlet.ShouldProcess($AdvancedKey, $Prop.Desc)) {
                try {
                    Set-ItemProperty -Path $AdvancedKey -Name $Name -Value $Prop.Value -Type DWord -ErrorAction Stop
                    Write-ScriptLog -Level INFO -Message "$Name = $($Prop.Value)"
                }
                catch {
                    $Err = $_
                    Write-ScriptLog -Level ERROR -Message "$Name 設定失敗: $($Err.Message)"
                    throw
                }
            }
        }

        if ($PSCmdlet.ShouldProcess($CopilotPolicyKey, 'Windows Copilot を無効化')) {
            try {
                if (-not (Test-Path -Path $CopilotPolicyKey)) {
                    $null = New-Item -Path $CopilotPolicyKey -Force -ErrorAction Stop
                }
                Set-ItemProperty -Path $CopilotPolicyKey -Name 'TurnOffWindowsCopilot' -Value 1 -Type DWord -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message 'TurnOffWindowsCopilot = 1'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "Copilot 無効化失敗: $($Err.Message)"
                throw
            }
        }

        if ($PSCmdlet.ShouldProcess($SearchPolicyKey, '検索ボックスのインターネット検索を無効化')) {
            try {
                if (-not (Test-Path -Path $SearchPolicyKey)) {
                    $null = New-Item -Path $SearchPolicyKey -Force -ErrorAction Stop
                }
                Set-ItemProperty -Path $SearchPolicyKey -Name 'DisableSearchBoxSuggestions' -Value 1 -Type DWord -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message 'DisableSearchBoxSuggestions = 1'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "検索サジェスト無効化失敗: $($Err.Message)"
                throw
            }
        }
    }
}
