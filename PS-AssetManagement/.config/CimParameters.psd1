@{
    Win32_OperatingSystemSplat  = @{
        ClassName           = "Win32_OperatingSystem"
        Property            = "CSName", "Caption", "Version", "InstallDate", "OSArchitecture", "LastBootUpTime"
        OperationTimeoutSec = 30
        Erroraction         = "Stop"
    }

    Win32_ComputerSystemSplat   = @{
        ClassName           = "Win32_ComputerSystem"
        Property            = "Manufacturer", "Model", "Domain", "SystemFamily", "PCSystemType", "Username", "Domain"
        OperationTimeoutSec = 30
        Erroraction         = "Stop"
    }

    Win32_ProcessorSplat        = @{
        ClassName           = "Win32_Processor"
        Property            = "Name", "Description"
        OperationTimeoutSec = 30
        Erroraction         = "Stop"
    }

    Win32_LogicalDiskSplat      = @{
        ClassName           = "Win32_LogicalDisk"
        Property            = "Size", "FreeSpace"
        Filter              = "DeviceID='C:'"
        OperationTimeoutSec = 30
        Erroraction         = "Stop"
    }

    Win32_BIOSSplat             = @{
        ClassName           = "Win32_BIOS"
        Property            = "SMBIOSBIOSVersion", "Version", "ReleaseDate", "SerialNumber"
        OperationTimeoutSec = 30
        Erroraction         = "Stop"
    }

    # This is added onto the object if certain properties exist, may need to redo a better way
    Win32_NetworkAdapterSplat   = @{
        ClassName           = "Win32_NetworkAdapter"
        OperationTimeoutSec = 30
        Erroraction         = "Stop"
    }

    Win32_AntiVirusProductSplat = @{
        Namespace           = "ROOT/SecurityCenter2:AntiVirusProduct"
        ClassName           = "AntiVirusProduct"
        OperationTimeoutSec = 30
        Erroraction         = "Stop"
    }

    Win32_PhysicalMemorySplat   = @{
        ClassName           = "Win32_PhysicalMemory"
        Property            = "Capacity"
        OperationTimeoutSec = 30
        Erroraction         = "Stop"
    }

    Win32_ProcessSplat          = @{
        ClassName           = "Win32_Process"
        Filter              = "Name = 'explorer.exe'"
        OperationTimeoutSec = 30
        Erroraction         = "Stop"
    }
}
