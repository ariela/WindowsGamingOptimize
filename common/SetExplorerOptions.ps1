#Requires -Version 5.1

<#
.SYNOPSIS
    エクスプローラーのフォルダーオプションを最適化する（Desktop・UMPC 共通）。
.EXAMPLE
    Set-ExplorerOption
.EXAMPLE
    Set-ExplorerOption -WhatIf
#>
function Set-ExplorerOption {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        $AdvancedKey      = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        $ExplorerKey      = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
        $ContextMenuKey   = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
        $WindowMetricsKey = 'HKCU:\Control Panel\Desktop\WindowMetrics'

        Backup-RegistryKey -Path $AdvancedKey
        Backup-RegistryKey -Path $ExplorerKey
        Backup-RegistryKey -Path $ContextMenuKey
        Backup-RegistryKey -Path $WindowMetricsKey

        $AdvancedProps = [ordered]@{
            'LaunchTo'                      = @{ Value = 1; Desc = 'エクスプローラーで開く → PC' }
            'Hidden'                        = @{ Value = 1; Desc = '隠しファイル・フォルダー・ドライブを表示' }
            'HideFileExt'                   = @{ Value = 0; Desc = '登録済み拡張子を表示' }
            'UseCompactMode'                = @{ Value = 1; Desc = 'コンパクトビュー ON' }
            'ShowInfoTip'                   = @{ Value = 0; Desc = 'アイテム説明のポップアップ → OFF' }
            'FolderContentsInfoTip'         = @{ Value = 0; Desc = 'フォルダーのヒント → OFF' }
            'HideDrivesWithNoMedia'         = @{ Value = 1; Desc = 'メディアのないドライブを非表示' }
            'ShowSyncProviderNotifications' = @{ Value = 0; Desc = '同期プロバイダー通知 → OFF' }
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

        if ($PSCmdlet.ShouldProcess($ExplorerKey, 'Office.com ファイルのクイックアクセス → OFF')) {
            try {
                Set-ItemProperty -Path $ExplorerKey -Name 'ShowCloudFilesInQuickAccess' -Value 0 -Type DWord -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message 'ShowCloudFilesInQuickAccess = 0'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "ShowCloudFilesInQuickAccess 設定失敗: $($Err.Message)"
                throw
            }
        }

        if ($PSCmdlet.ShouldProcess($ContextMenuKey, '右クリックメニューを Win10 以前に戻す')) {
            try {
                if (-not (Test-Path -Path $ContextMenuKey)) {
                    $null = New-Item -Path $ContextMenuKey -Force -ErrorAction Stop
                }
                Set-ItemProperty -Path $ContextMenuKey -Name '(default)' -Value '' -Type String -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message '右クリックメニュー: Win10 スタイルに変更'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "右クリックメニュー設定失敗: $($Err.Message)"
                throw
            }
        }

        if ($PSCmdlet.ShouldProcess($WindowMetricsKey, 'スクロールバー幅を -330 に設定')) {
            try {
                Set-ItemProperty -Path $WindowMetricsKey -Name 'ScrollWidth' -Value '-330' -Type String -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message 'ScrollWidth = -330'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "ScrollWidth 設定失敗: $($Err.Message)"
                throw
            }
        }
    }
}
