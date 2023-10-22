@{
    Database = "database5"
    UniqueIndex = "Hostname"
    TableName = "devices"
    DatabaseIndex = "device_hostname"
    Columns = @{
        SERIAL_NUMBER = @{
            DataType = "VARCHAR(50)"
            Null = "NOT NULL"
            Key = "PRIMARY KEY"
        }

        Hostname = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        ANTIVIRUS = @{
            DataType = "VARCHAR"
        }

        MANUFACTURER = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        MODEL = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        TYPE = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        WINDOWS_EDITION = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        WINDOWS_BUILD = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        MEMORY = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        CPU = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        CPU_DESCRIPTION = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        DISK_SIZE = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        DISK_SIZE_AVAILABLE = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        FEATURE_UPDATE = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        OS_ARCHITECTURE = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        LAST_BOOT_TIME = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        DATE_SCANNED = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        BIOS_INFORMATION = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        NETWORK_ADAPTER = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        DOMAIN = @{
            DataType = "VARCHAR"
            Null = "NOT NULL"
        }

        CURRENT_LOGGED_ON_USER = @{
            DataType = "VARCHAR"
        }

        ASSET = @{
            DataType = "VARCHAR"
        }
    }
}
