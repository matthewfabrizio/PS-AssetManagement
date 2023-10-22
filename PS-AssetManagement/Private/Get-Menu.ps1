function Get-Menu {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $Title
    )

    begin {
        $TitleLength = $Title.Length
        $TitlePadding = $TitleLength * 2
        $("=" * $TitlePadding); "`t$Title"; $("=" * $TitlePadding)

        $MainMenu = [PSCustomObject]@{
            "Menu" = @{
                "List" = @(
                    "Active Directory Query Scan",
                    "Organizational Unit Query Scan",
                    "Single Device Scan",
                    "Multi Device Scan",
                    "Find Device"
                )
            }
        }

        $TotalItems = $MainMenu.Menu.List.Count
    }

    process {
        $MenuList = 1..$TotalItems | ForEach-Object {
            '[{0}] : {1}' -f $PSItem, $MainMenu.Menu.List[$PSItem - 1]
        }
        $MenuList += "[Q] : Quit"
        $MenuList

        $ChoiceValid = $false
        while (-not $ChoiceValid) {
            $Choice = Read-Host "`nMake a selection"
            Write-Verbose -Message "Selected option : $($MainMenu.Menu.List[$Choice - 1])"
            Write-LogEntry -Value "Selected option : $($MainMenu.Menu.List[$Choice - 1])" -LogLevel Information

            if ($Choice -notin 1..$TotalItems -and $Choice -ne 'q') { Write-Warning -Message "Please select an option" }
            else {
                $ChoiceValid = $true
                switch ($Choice) {
                    '1' { Get-ADQueryInformation }
                    '2' { "WIP" }
                    { @('3', '4') -contains $PSItem } {
                        $HostnameExists = $false

                        while (-not $HostnameExists) {
                            Write-Output -InputObject "`nType 'stop|Stop|Ctrl+c' to exit.`n"

                            # Get device from user; quit on stop
                            $Computers = Read-Host "What computer would you like to scan?"
                            if ($Computers -contains 'stop') { exit }

                            # Combine all computers together
                            $Computers = $Computers.Split(",").Trim(" ")
                            Get-DeviceInformation -ComputerName $Computers

                            # If user selected single scan, auto set to $true
                            if ($PSItem -eq '3') { $HostnameExists = $true }
                        }
                    }
                    '5' {
                        $SearchTerm = (Read-Host "What device would you like information on?").ToUpper()

                        if ($SearchTerm) {
                            Write-LogEntry -Value "Search Term is $SearchTerm" -LogLevel Verbose
                            "SELECT * FROM $($DBConfig.TableName) WHERE Hostname='$SearchTerm'" | Select-SQLiteDatabase -Database (Join-Path -Path $ModuleRoot -ChildPath "db\$DatabaseName.db")
                        }
                        else {
                            "Device hostname invalid."
                        }

                    }
                    'q' { Clear-Host; }
                    Default {}
                }
            }
        }
    }

    end { }
}
