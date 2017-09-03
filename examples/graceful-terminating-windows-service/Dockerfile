# escape=`
FROM microsoft/nanoserver AS builder
SHELL ["C:/Windows/System32/WindowsPowerShell/v1.0/PowerShell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN cd $env:TMP; `
    $url = 'https://github.com/rgl/graceful-terminating-windows-service/releases/download/v0.1.0/graceful-terminating-windows-service.zip'; `
    $sha256 = 'b4839ded8e46c7d653bdcdf06f5c641e72ff1bac713578430afc2fb6ff6a141f'; `
    Write-Host ('Downloading graceful-terminating-windows-service from {0}...' -f $url); `
    Invoke-WebRequest -Uri $url -OutFile graceful-terminating-windows-service.zip; `
    Write-Host ('Verifying sha256 ({0})...' -f $sha256); `
    if ((Get-FileHash graceful-terminating-windows-service.zip -Algorithm sha256).Hash -ne $sha256) { `
        Write-Host 'FAILED!'; `
        Exit 1; `
    }; `
    Write-Host 'Expanding...'; `
    Expand-Archive graceful-terminating-windows-service.zip .; `
    Write-Host 'Removing unneeded files...'; `
    Remove-Item graceful-terminating-windows-service.zip;

# FROM microsoft/nanoserver
FROM microsoft/windowsservercore
SHELL ["C:/Windows/System32/WindowsPowerShell/v1.0/PowerShell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
COPY --from=builder /Users/ContainerAdministrator/AppData/Local/Temp/graceful-terminating-windows-service.exe /app/
WORKDIR /app
COPY install.ps1 ./
COPY entrypoint.ps1 ./
RUN ./install.ps1
RUN mkdir c:/host | Out-Null
VOLUME ["c:/host"]
ENTRYPOINT .\entrypoint.ps1
