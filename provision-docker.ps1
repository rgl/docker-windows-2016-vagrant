# see https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-docker/configure-docker-daemon
# see https://github.com/docker/docker/releases/tag/v17.04.0-ce

# download install the docker binaries.
$archiveName = 'docker-17.04.0-ce.zip'
$archivePath = "$env:TEMP\$archiveName"
Invoke-WebRequest https://get.docker.com/builds/Windows/x86_64/$archiveName -UseBasicParsing -OutFile $archivePath
Expand-Archive $archivePath -DestinationPath $env:ProgramFiles
Remove-Item $archivePath

# add docker to the Machine PATH.
[Environment]::SetEnvironmentVariable(
    'PATH',
    "$([Environment]::GetEnvironmentVariable('PATH', 'Machine'));$env:ProgramFiles\docker",
    'Machine')
# add docker to the current process PATH.
$env:PATH += ";$env:ProgramFiles\docker"

# install the docker service and configure it to always restart on failure.
dockerd --register-service
sc.exe failure docker reset= 0 actions= restart/1000/restart/1000/restart/1000

# configure docker through a configuration file.
# see https://docs.docker.com/engine/reference/commandline/dockerd/#windows-configuration-file
$config = @{
    'debug' = $false
    'labels' = @('os=windows')
    'hosts' = @('tcp://0.0.0.0:2375', 'npipe:////./pipe/docker_engine')
}
mkdir -Force "$env:ProgramData\docker\config"
Set-Content -Encoding ascii "$env:ProgramData\docker\config\daemon.json" ($config | ConvertTo-Json)

# start docker.
Start-Service docker

function docker {
    docker.exe @Args
    if ($LASTEXITCODE) {
        throw "$(@('docker')+$Args | ConvertTo-Json -Compress) failed with exit code $LASTEXITCODE"
    }
}

Write-Host 'Pulling the microsoft/nanoserver container image...'
docker pull microsoft/nanoserver

Write-Host 'Running a script inside microsoft/nanoserver...'
docker run --rm microsoft/nanoserver PowerShell @'
Write-Output 'Operating System version:'
Get-ComputerInfo -Property WindowsProductName,WindowsInstallationType,OsVersion,BuildVersion,WindowsBuildLabEx | Format-List

Write-Output 'PowerShell version:'
$PSVersionTable.GetEnumerator() | Sort-Object Name | Format-Table -AutoSize

Write-Output 'Machine IP addresses:'
Get-NetAdapter | Get-NetIPConfiguration | ForEach-Object {$_.IPv4Address.IPAddress} | Sort-Object
'@

Write-Host 'Pulling and running microsoft/dotnet-samples:dotnetapp-nanoserver...'
docker run --rm microsoft/dotnet-samples:dotnetapp-nanoserver

Write-Host '# docker version'
docker version

Write-Host '# docker info'
docker info

Write-Host '# docker network ls'
docker network ls

Write-Host '# docker images'
docker images

Write-Host '# docker disk space statistics'
docker system df -v

choco install -y docker-compose
Write-Host '# docker-compose version'
docker-compose version
