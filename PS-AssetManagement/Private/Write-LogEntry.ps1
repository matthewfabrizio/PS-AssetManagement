function Write-LogEntry() {
    [CmdletBinding()]
    [OutputType([System.Void])]
    param(
        # Value of log entry to be added
        [parameter(HelpMessage = "Value of log entry to be added")]
        [ValidateNotNullOrEmpty()]
        [string] $Value,

        # Name of the log file
        [parameter(HelpMessage = "Name of the log file")]
        [ValidateNotNullOrEmpty()]
        [string] $FileName = "status",

        # Prevents logging to output stream
        [Parameter(HelpMessage = "Prevents logging to output stream")]
        [switch] $OutNull,

        # Allows for multiple output types
        [Parameter(HelpMessage = "Allows for output type options")]
        [ValidateSet("Error", "Warning", "Information", "Verbose", "Null")]
        [string] $LogLevel = "Null",

        # Allows to start/end transcript
        [Parameter(HelpMessage = "Allows to start/end transcript")]
        [ValidateSet("Start", "Stop", "None")]
        [string] $Transcript = 'None',

        # Foreground color
        [Parameter(HelpMessage = "Foreground color")]
        [System.ConsoleColor] $ForegroundColor = [System.ConsoleColor]::White,

        # Background color
        [Parameter(HelpMessage = "Background color")]
        [System.ConsoleColor] $BackgroundColor = [System.ConsoleColor]::DarkMagenta,

        # Parameter help description
        [Parameter()]
        [switch]
        $Reset
    )

    if ($PSBoundParameters.ContainsKey('Reset')) {
        Remove-Item "$ModuleRoot\.log\status.log"
        return
    }

    # If running NEW Windows Terminal, adjust BC/FC
    if ((Get-Host).UI.RawUI.BackgroundColor -eq 'Black' -or $PSVersionTable.PSEdition -eq "Core") {
        $BackgroundColor = [System.ConsoleColor]::Black
        $ForegroundColor = [System.ConsoleColor]::Gray
    }

    switch ($Transcript) {
        'None' { break }
        'Stop' { Stop-Transcript | Out-Null }
        'Start' { Start-Transcript -Path "$PSScriptRoot\Status\$($FileName)-transcript.log" | Out-Null }
    }

    <# Determine LogLevel #>
    try {
        Write-Verbose -Message "Loglevel: $LogLevel"
        switch ($LogLevel) {
            'Null' {
                if (!$OutNull) {
                    if ($ForegroundColor) { Write-Host $Value -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor }
                }
            }
            'Information' {
                if (!$OutNull) { Write-Host "[INFO] : $Value" -ForegroundColor Green }
            }
            'Warning' {
                $FileName = 'warnings'
                if (!$OutNull) { Write-Host "[WARNING] : $Value" -ForegroundColor Yellow }
            }
            'Error' {
                $FileName = 'errors'
                if (!$OutNull) { Write-Host "[ERROR] : $Value" -ForegroundColor Red }
            }
            'Verbose' {
                if (!$OutNull -and $VerbosePreference) { Write-Host "[VERBOSE] : $Value" -ForegroundColor Cyan }
            }
        }

        <# Set log file location #>
        $LogFileRootPath = Join-Path -Path $ModuleRoot -ChildPath ".log"
        $LogFilePath = Join-Path -Path $LogFileRootPath -ChildPath "$FileName.log"
        # $LogFilePath = "$LogFileRootPath\$($FileName).log"

        # Write-Verbose -Message "Log root path: $LogFileRootPath"
        # Write-Verbose -Message "Log file path: $LogFilePath"

        if (-not (Test-Path -Path $LogFileRootPath)) { New-Item -Path $LogFileRootPath -ItemType Directory | Out-Null }

        # Write to the log file if Transcript Start/Stop
        if ($Transcript -eq 'None') {
            Out-File -InputObject "[$([System.DateTime]::Now.ToString('yyyy-MM-dd'))] -> $Value" -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
        }
    } catch [System.Exception] { Write-Warning -Message "Unable to append log entry to $FileName file" }
}
