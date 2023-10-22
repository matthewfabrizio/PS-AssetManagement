function Initialize-SQLiteConnection {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'Open', Mandatory)]
        [Parameter(ParameterSetName = 'Close', Mandatory)]
        [string]
        $Database,

        [Parameter(ParameterSetName = 'Open')]
        [switch]
        $Open,

        [Parameter(ParameterSetName = 'Close')]
        [switch]
        $Close
    )

    begin {
        try {
            Add-Type -Path "$PSScriptRoot\..\lib\x64\System.Data.SQLite.dll"
        }
        catch { throw "Could not load SQLite dll." }
        

        $Script:conn = New-Object -TypeName System.Data.SQLite.SQLiteConnection
        $conn.ConnectionString = "Data Source=$Database"
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Open' { $conn.Open(); Write-LogEntry -Value "Opening database" -LogLevel Verbose }
            'Close' { $conn.Close(); Write-LogEntry -Value "Closing database" -LogLevel Verbose }
            Default {}
        }
    }

    end {}
}
