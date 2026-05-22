#Requires -Version 5.1

<#
.SYNOPSIS
    レジストリバックアップユーティリティ。Backup-RegistryKey を提供する。
#>

function Backup-RegistryKey {
    <#
    .SYNOPSIS
        指定のレジストリキーを reg.exe でエクスポートし backup/ 配下に保存する。
    .EXAMPLE
        Backup-RegistryKey -Path 'HKCU:\Software\Microsoft\GameBar'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )
    process {
        if (-not $script:BackupRoot) {
            throw 'BackupRoot が未設定です。Initialize-Log を先に呼び出してください。'
        }

        # PowerShell ドライブ形式（HKCU:\）を reg.exe 形式（HKCU\）に変換
        $PrefixMap = [ordered]@{
            'HKCU:\' = 'HKCU\'
            'HKLM:\' = 'HKLM\'
            'HKCR:\' = 'HKCR\'
            'HKU:\'  = 'HKU\'
            'HKCC:\' = 'HKCC\'
        }
        $RegPath = $Path
        foreach ($Prefix in $PrefixMap.Keys) {
            if ($RegPath.StartsWith($Prefix)) {
                $RegPath = $PrefixMap[$Prefix] + $RegPath.Substring($Prefix.Length)
                break
            }
        }

        $SafeName    = $RegPath -replace '[\\/:*?"<>|]', '_'
        $Timestamp   = Get-Date -Format 'yyyyMMdd_HHmmss'
        $BackupFile  = Join-Path -Path $script:BackupRoot -ChildPath "${SafeName}_${Timestamp}.reg"

        if ($PSCmdlet.ShouldProcess($Path, 'レジストリキーをバックアップ')) {
            Write-ScriptLog -Level INFO -Message "レジストリバックアップ: $Path → $BackupFile"
            try {
                $null = & reg.exe export $RegPath $BackupFile /y 2>&1
                if ($LASTEXITCODE -ne 0) {
                    Write-ScriptLog -Level WARN -Message "reg.exe 終了コード $LASTEXITCODE（キーが存在しない場合は無視可）"
                }
            }
            catch {
                $Err = $_
                Write-ScriptLog -Level WARN -Message "バックアップをスキップ（続行）: $($Err.Exception.Message)"
            }
        }
    }
}
