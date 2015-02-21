{_DEFINE WIN95}
const
  MAX_DEVICE_NAME  = 128;


{$ifdef WIN95}
    // Windows 95 Registry bases
    // Win95 requires 2 seperate sections - ...\Class\.. from driver data
    // and ...\Vxd\ for driver start info
 DRIVER_REGISTRY_BASE   = 'SYSTEM\\CurrentControlSet\\Services\\Class\\WinRT';
 MACHINE_REGISTRY_BASE  = '\\Registry\\Machine\\System\\CurrentControlSet\\Services\\Class\\WinRT';

    // Individual device Vxd start-up section
 VXD_REGISTRY_BASE      = 'SYSTEM\\CurrentControlSet\\Services\\VxD';
 MACHINE_VXD_REGISTRY_BASE = '\\Registry\\Machine\\System\\CurrentControlSet\\Services\\VxD';

{$else}

       // NT Regsitry base
 DRIVER_REGISTRY_BASE = 'SYSTEM\\CurrentControlSet\\Services\\WinRT';
 MACHINE_REGISTRY_BASE = '\\Registry\\Machine\\System\\CurrentControlSet\\Services\\WinRT';

{$endif}      // WIN95

    SERVICE_BOOT_START    = 0;
    SERVICE_SYSTEM_START  = 1;
    SERVICE_AUTO_START    = 2;
    SERVICE_DISABLED      = 3;
    SERVICE_DEMAND_START  = 4;

type
    // contains a Devices parameter and an indication if it is valid
 TDEVICE_ITEM = record
    dwItemValue : DWORD;                // For item's value
    bItemEmpty  : BOOLEAN;                 // For item-has-value status
 end;

 PDevice_Item = ^TDevice_Item;

    // Device data - see manual appendix for definition
    // of registry entries
 TDEVICE = record
    szDeviceName : array[0..MAX_DEVICE_NAME] of char;  // Name of this device
    szVxdName    : array[0..MAX_DEVICE_NAME] of char; // Name of this Vxd
    dwDeviceNumber : dword;             // Number of this device
    PortAdrs,              // Section 0 Data
    PortCnt,
    MemAdrs,
    MemCnt,
    IntNum,
    IntLevel,
    IntShare,
    IntMode,
    BusNum,
    BusType,
    IoIncrem,
    AllowConflict,
    Disable,
    PortAdrs1,             // Section 1 Data
    PortCnt1,
    MemAdrs1,
    MemCnt1    : TDEVICE_ITEM;
 end;

 PDevice = ^TDevice;

    // Driver data - see manual appendix for definition
    // of registry entries
 TDRIVER = record
    dwWinRTStart : DWORD;
{$ifndef WIN95}
    dwWinRTType  : DWORD;
    dwWinRTError : DWORD;
{$endif}      // !WIN95
 end;

 PDriver = ^TDriver;
 PBoolean = ^boolean;
 LPBYTE = PBYTE;