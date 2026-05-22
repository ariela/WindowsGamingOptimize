#Requires -Version 5.1

<#
.SYNOPSIS
    スタートメニューの表示設定を構成する（Desktop・UMPC 共通）。
.EXAMPLE
    Set-StartMenuSetting
.EXAMPLE
    Set-StartMenuSetting -WhatIf
#>
function Set-StartMenuSetting {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        $AdvancedKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        $StartKey    = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Start'

        Backup-RegistryKey -Path $AdvancedKey
        Backup-RegistryKey -Path $StartKey

        $AdvancedProps = [ordered]@{
            'Start_Layout'             = @{ Value = 1; Desc = 'スタート レイアウト: さらにピン留めを表示' }
            'Start_TrackDocs'          = @{ Value = 0; Desc = '最近開いた項目をスタート等に表示 → OFF' }
            'Start_IrisRecommendations' = @{ Value = 0; Desc = 'おすすめコンテンツの表示 → OFF' }
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
                    Write-ScriptLog -Level ERROR -Message "$Name 設定失敗: $($Err.Exception.Message)"
                    throw
                }
            }
        }

        $StartProps = [ordered]@{
            'ShowRecentList'   = @{ Value = 1; Desc = '最近追加したアプリを表示 → ON' }
            'ShowFrequentList' = @{ Value = 1; Desc = 'よく使うアプリを表示 → ON' }
        }

        foreach ($Name in $StartProps.Keys) {
            $Prop = $StartProps[$Name]
            if ($PSCmdlet.ShouldProcess($StartKey, $Prop.Desc)) {
                try {
                    Set-ItemProperty -Path $StartKey -Name $Name -Value $Prop.Value -Type DWord -ErrorAction Stop
                    Write-ScriptLog -Level INFO -Message "$Name = $($Prop.Value)"
                }
                catch {
                    $Err = $_
                    Write-ScriptLog -Level ERROR -Message "$Name 設定失敗: $($Err.Exception.Message)"
                    throw
                }
            }
        }

        # スタート > フォルダー: 設定 のみ表示
        if ($PSCmdlet.ShouldProcess($StartKey, 'スタート フォルダー表示: 設定のみ ON')) {
            try {
                $VisiblePlaces = [byte[]](0x86, 0x08, 0x73, 0x52, 0xAA, 0x51, 0x43, 0x42, 0x9F, 0x7B, 0x27, 0x76, 0x58, 0x46, 0x59, 0xD4)
                Set-ItemProperty -Path $StartKey -Name 'VisiblePlaces' -Value $VisiblePlaces -Type Binary -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message 'VisiblePlaces を設定しました'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "VisiblePlaces 設定失敗: $($Err.Exception.Message)"
                throw
            }
        }
    }
}
