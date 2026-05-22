#Requires -Version 5.1

<#
.SYNOPSIS
    透明効果とアニメーション効果を無効化する（Gaming UMPC 専用）。
.DESCRIPTION
    バッテリー消費と描画負荷を抑えるため、APU 搭載の Gaming UMPC 向けに視覚効果を無効化する。
    - 透明効果: HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\EnableTransparency = 0
    - アニメーション効果: UserPreferencesMask（バイナリマスク）および MinAnimate = 0
.EXAMPLE
    Disable-VisualEffect
.EXAMPLE
    Disable-VisualEffect -WhatIf
#>
function Disable-VisualEffect {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param()
    process {
        $ThemeKey         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
        $DesktopKey       = 'HKCU:\Control Panel\Desktop'
        $WindowMetricsKey = 'HKCU:\Control Panel\Desktop\WindowMetrics'

        Backup-RegistryKey -Path $ThemeKey
        Backup-RegistryKey -Path $DesktopKey
        Backup-RegistryKey -Path $WindowMetricsKey

        if ($PSCmdlet.ShouldProcess($ThemeKey, '透明効果 → OFF')) {
            try {
                Set-ItemProperty -Path $ThemeKey -Name 'EnableTransparency' -Value 0 -Type DWord -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message 'EnableTransparency = 0'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "EnableTransparency 設定失敗: $($Err.Exception.Message)"
                throw
            }
        }

        if ($PSCmdlet.ShouldProcess($DesktopKey, 'アニメーション効果 → OFF (UserPreferencesMask)')) {
            try {
                $Mask = [byte[]](0x90, 0x12, 0x07, 0x80, 0x10, 0x00, 0x00, 0x00)
                Set-ItemProperty -Path $DesktopKey -Name 'UserPreferencesMask' -Value $Mask -Type Binary -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message 'UserPreferencesMask を設定しました'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "UserPreferencesMask 設定失敗: $($Err.Exception.Message)"
                throw
            }
        }

        if ($PSCmdlet.ShouldProcess($WindowMetricsKey, 'ウィンドウの最小化・最大化アニメーション → OFF')) {
            try {
                Set-ItemProperty -Path $WindowMetricsKey -Name 'MinAnimate' -Value '0' -Type String -ErrorAction Stop
                Write-ScriptLog -Level INFO -Message 'MinAnimate = 0'
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level ERROR -Message "MinAnimate 設定失敗: $($Err.Exception.Message)"
                throw
            }
        }
    }
}
