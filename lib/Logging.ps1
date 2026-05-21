#Requires -Version 5.1

<#
.SYNOPSIS
    ログ出力ユーティリティ。Initialize-Log と Write-ScriptLog を提供する。
#>

function Initialize-Log {
    <#
    .SYNOPSIS
        ログファイルを初期化し、以降の Write-ScriptLog の出力先を設定する。
    .EXAMPLE
        Initialize-Log -RootDir $PSScriptRoot
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RootDir
    )
    process {
        $LogsDir = Join-Path -Path $RootDir -ChildPath 'logs'
        if (-not (Test-Path -Path $LogsDir)) {
            New-Item -Path $LogsDir -ItemType Directory -Force | Out-Null
        }

        $BackupDir = Join-Path -Path $RootDir -ChildPath 'backup'
        if (-not (Test-Path -Path $BackupDir)) {
            New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
        }

        $RunTimestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $script:LogFilePath = Join-Path -Path $LogsDir -ChildPath "optimize_${RunTimestamp}.log"
        $script:BackupRoot  = $BackupDir

        Write-ScriptLog -Level INFO -Message "ログファイル: $($script:LogFilePath)"
    }
}

function Write-ScriptLog {
    <#
    .SYNOPSIS
        タイムスタンプ付きメッセージをログファイルとコンソールに出力する。
    .EXAMPLE
        Write-ScriptLog -Level INFO -Message '処理を開始します'
    .EXAMPLE
        Write-ScriptLog -Level ERROR -Message 'エラーが発生しました'
    #>
    [CmdletBinding()]
    [OutputType([void])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'ログ表示にカラー出力が必要なため')]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('INFO', 'WARN', 'ERROR')]
        [string]$Level,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )
    process {
        $Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $Line = "[$Timestamp] [$Level] $Message"

        if ($script:LogFilePath) {
            Add-Content -Path $script:LogFilePath -Value $Line -Encoding UTF8
        }

        switch ($Level) {
            'INFO'  { Write-Host $Line }
            'WARN'  { Write-Host $Line -ForegroundColor Yellow }
            'ERROR' { Write-Host $Line -ForegroundColor Red }
        }
    }
}
