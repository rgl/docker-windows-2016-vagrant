# define the process privilege manipulation function.
Add-Type @'
using System;
using System.Runtime.InteropServices;
using System.ComponentModel;
public class ProcessPrivileges
{
    [DllImport("advapi32.dll", SetLastError = true)]
    static extern bool LookupPrivilegeValue(string host, string name, ref long luid);
    [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
    static extern bool AdjustTokenPrivileges(IntPtr token, bool disableAllPrivileges, ref TOKEN_PRIVILEGES newState, int bufferLength, IntPtr previousState, IntPtr returnLength);
    [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
    static extern bool OpenProcessToken(IntPtr processHandle, int desiredAccess, ref IntPtr processToken);
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern bool CloseHandle(IntPtr handle);
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    struct TOKEN_PRIVILEGES
    {
        public int PrivilegeCount;
        public long Luid;
        public int Attributes;
    }
    const int SE_PRIVILEGE_ENABLED     = 0x00000002;
    const int SE_PRIVILEGE_DISABLED    = 0x00000000;
    const int TOKEN_QUERY              = 0x00000008;
    const int TOKEN_ADJUST_PRIVILEGES  = 0x00000020;
    public static void EnablePrivilege(IntPtr processHandle, string privilegeName, bool enable)
    {
        var processToken = IntPtr.Zero;
        if (!OpenProcessToken(processHandle, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref processToken))
        {
            throw new Win32Exception();
        }
        try
        {
            var privileges = new TOKEN_PRIVILEGES
            {
                PrivilegeCount = 1,
                Luid = 0,
                Attributes = enable ? SE_PRIVILEGE_ENABLED : SE_PRIVILEGE_DISABLED,
            };
            
            if (!LookupPrivilegeValue(null, privilegeName, ref privileges.Luid))
            {
                throw new Win32Exception();
            }
            if (!AdjustTokenPrivileges(processToken, false, ref privileges, 0, IntPtr.Zero, IntPtr.Zero))
            {
                throw new Win32Exception();
            }
        }
        finally
        {
            CloseHandle(processToken);
        }
    }
}
'@
function Enable-ProcessPrivilege {
    param(
        # see https://msdn.microsoft.com/en-us/library/bb530716(VS.85).aspx
        [string]$privilegeName,
        [int]$processId = $PID,
        [Switch][bool]$disable
    )
    $process = Get-Process -Id $processId
    try {
        [ProcessPrivileges]::EnablePrivilege(
            $process.Handle,
            $privilegeName,
            !$disable)
    } finally {
        $process.Close()
    }
}
