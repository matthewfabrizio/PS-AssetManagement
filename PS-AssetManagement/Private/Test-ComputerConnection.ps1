function Test-ComputerConnection {
    <#
    .SYNOPSIS
    Tests a computer connection on one or multiple hosts.

    .DESCRIPTION
    Tests a computer connection on one or multiple hosts for ICMP and WSMan.

    .NOTES
    https://stackoverflow.com/questions/65998379/if-using-test-connection-on-multiple-computers-with-quiet-how-do-i-know-which-r
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string[]]
        $ComputerName
    )

    begin {
        $results = [System.Collections.Generic.List[psobject]]::new()

        Write-LogEntry -Value "Starting connection scans on devices [$ComputerName]" -LogLevel Information
    }

    process {
        $results = $ComputerName | ForEach-Object -Parallel {
            if ($PSItem -eq "localhost" -or $PSItem -eq "127.0.0.1" -or $PSItem -eq $env:COMPUTERNAME) { $Hostname = "localhost" }
            else { $Hostname = $PSItem }

            $status = Test-Connection -ComputerName $Hostname -Count 1 -Quiet -Delay 1 -ErrorAction Stop

            [pscustomobject]@{
                Computer = $PSItem
                Status   = if ($null -ne $status) { $status } else { "Offline" }
                WSMan    = [bool](Test-WSMan -ComputerName $Hostname -ErrorAction SilentlyContinue)
            }
        } -ThrottleLimit 52 -AsJob
    }

    end {
        $results | Receive-Job -Wait
        Get-Job | Remove-Job
    }
}
