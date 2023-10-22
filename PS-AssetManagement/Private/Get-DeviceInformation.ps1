function Get-DeviceInformation {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string[]]
        $ComputerName
    )

    begin {
        $DatabaseName = $DBConfig.Database

        $results = [System.Collections.Generic.List[psobject]]::new()

        Write-LogEntry -Value "Received the following computers : $ComputerName" -LogLevel Information

        New-SQLiteDatabase -Database (Join-Path -Path $ModuleRoot -ChildPath "db\$DatabaseName.db")

        Update-SQLiteDatabase -Database (Join-Path -Path $ModuleRoot -ChildPath "db\$DatabaseName.db")
    }

    process {
        $ComputerName | ForEach-Object {
            if ($PSItem -eq "localhost" -or $PSItem -eq "127.0.0.1" -or $PSItem -eq $env:COMPUTERNAME) { $Computer = "localhost" }
            else { $Computer = $PSItem }

            try {
                $ScriptBlock = {
                    [CmdletBinding()]
                    param (
                        [Parameter()]
                        [hashtable]
                        $Config
                    )

                    # https://stackoverflow.com/questions/46927822/splatting-a-function-with-an-objects-property
                    $W32_Op = $Config.Win32_OperatingSystemSplat
                    $W32_Co = $Config.Win32_ComputerSystemSplat
                    $W32_Pr = $Config.Win32_ProcessorSplat
                    $W32_Lo = $Config.Win32_LogicalDiskSplat
                    $W32_Bi = $Config.Win32_BIOSSplat
                    $W32_Ne = $Config.Win32_NetworkAdapterSplat
                    $W32_Av = $Config.Win32_AntiVirusProductSplat
                    $W32_Ph = $Config.Win32_PhysicalMemorySplat

                    [pscustomobject]@{
                        Win32_OperatingSystem  = (Get-CimInstance @W32_Op)
                        WindowsBuild           = (Get-ItemProperty "Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\").DisplayVersion
                        Win32_ComputerSystem   = (Get-CimInstance @W32_Co)
                        Win32_Processor        = (Get-CimInstance @W32_Pr)
                        Win32_LogicalDisk      = (Get-CimInstance @W32_Lo)
                        Win32_BIOS             = (Get-CimInstance @W32_Bi)
                        Win32_NetworkAdapter   = (Get-CimInstance @W32_Ne)
                        Win32_AntiVirusProduct = ((Get-CimInstance @W32_Av)).displayName
                        Win32_PhysicalMemory   = [string]((((Get-CimInstance @W32_Ph).Capacity | Measure-Object -Sum).Sum / 1GB)) + " GB"
                    }
                }

                if ($Computer = "localhost") {
                    $results = Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList ($Config)
                }
                else {
                    $results = Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlock -ArgumentList ($Config) -Authentication Kerberos -Credential (Get-Credential)
                }
            } catch [System.Exception] {
                Write-Warning -Message "Not able to connect to device."
            }
        }
    }

    end {
        $CurrentScanProperties = [PSCustomObject][Ordered]@{
            'Hostname'               = $results.Win32_OperatingSystem.CSName
            'Antivirus'              = $results.Win32_AntiVirusProduct
            'Manufacturer'           = $results.Win32_ComputerSystem.Manufacturer
            'Model'                  = $results.Win32_ComputerSystem.Model
            'Serial Number'          = $results.Win32_BIOS.SerialNumber
            'Type'                   = if ($results.Win32_ComputerSystem.PCSystemType -eq 2) { "Laptop" } else { "Desktop" }
            'Windows Edition'        = $results.Win32_OperatingSystem.Caption
            'Windows Build'          = $results.WindowsBuild
            'Memory'                 = $results.Win32_PhysicalMemory
            'CPU'                    = $results.Win32_Processor.Name
            'CPU Description'        = $results.Win32_Processor.Description
            'Disk Size'              = [string]([math]::Round($results.Win32_LogicalDisk.Size / 1GB, 0)) + " GB"
            'Disk Size Available'    = [string]([math]::Round($results.Win32_LogicalDisk.FreeSpace / 1GB, 0)) + " GB"
            'Feature Update'         = (Get-Date $results.Win32_OperatingSystem.InstallDate -Format d)
            'OS Architecture'        = $results.Win32_OperatingSystem.OSArchitecture
            'Last Boot Time'         = $results.Win32_OperatingSystem.LastBootUpTime
            'Date Scanned'           = (Get-Date -UFormat %D)
            'BIOS Information'       = [PSCustomObject]@{
                "SMBIOSVersion"     = $results.Win32_BIOS.SMBIOSBIOSVersion
                "BIOS Version"      = $results.Win32_BIOS.Version
                "BIOS Release Date" = (Get-Date $results.Win32_BIOS.ReleaseDate -Format d)
            }
            'Network Adapter'        = [PSCustomObject]@{
                "Ethernet"  = ($results.Win32_NetworkAdapter | Where-Object { $_.NetConnectionID -like '*Ethernet*' } | Select-Object NetConnectionID, Name, MACAddress)
                "WLAN"      = ($results.Win32_NetworkAdapter | Where-Object { $_.NetConnectionID -like '*Wi-Fi*' } | Select-Object NetConnectionID, Name, MACAddress)
                "Bluetooth" = ($results.Win32_NetworkAdapter | Where-Object { $_.NetConnectionID -like '*Bluetooth*' } | Select-Object NetConnectionID, Name, MACAddress)
            }
            'Domain'                 = $results.Win32_ComputerSystem.Domain
            'Current Logged on User' = if ($null -eq $results.Win32_ComputerSystem.Username) { "" } else { $results.Win32_ComputerSystem.Username }
        }

        Set-SQLiteDatabase -Database (Join-Path -Path $ModuleRoot -ChildPath "db\$DatabaseName.db") -Data $CurrentScanProperties
    }
}
