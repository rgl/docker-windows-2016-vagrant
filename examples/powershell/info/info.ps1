$FormatEnumerationLimit = -1

Write-Output '# Operating System version'
Get-ComputerInfo `
    -Property `
        WindowsProductName,
        WindowsInstallationType,
        OsVersion,
        BuildVersion,
        WindowsBuildLabEx `
    | Format-List

Write-Output '# PowerShell version'
$PSVersionTable.GetEnumerator() `
    | Sort-Object Name `
    | Format-Table -AutoSize `
    | Out-String -Stream -Width ([int]::MaxValue) `
    | ForEach-Object {$_.Trim()}

Write-Output '# Network Interfaces'
Get-NetAdapter `
    | ForEach-Object {
        New-Object PSObject -Property @{
            Name = $_.Name
            Description = $_.InterfaceDescription
            MacAddress = $_.MacAddress
            IpAddress = ($_ | Get-NetIPConfiguration | ForEach-Object { $_.IPv4Address.IPAddress })
        }
    } `
    | Sort-Object -Property Name `
    | Format-Table Name,Description,MacAddress,IpAddress `
    | Out-String -Stream -Width ([int]::MaxValue) `
    | ForEach-Object {$_.Trim()}

Write-Output '# Environment Variables'
dir env: `
    | Sort-Object -Property Name `
    | Format-Table -AutoSize `
    | Out-String -Stream -Width ([int]::MaxValue) `
    | ForEach-Object {$_.Trim()}

Write-Output '# Who Am I'
.\whoami.ps1
