# escape=`
FROM microsoft/nanoserver AS builder
SHELL ["C:/Windows/System32/WindowsPowerShell/v1.0/PowerShell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN cd $env:TMP; `
    $url = 'https://get.enterprisedb.com/postgresql/postgresql-9.6.4-1-windows-x64-binaries.zip'; `
    $sha256 = '15a963bd02f54fca9049c9270455d1d74f22674e921a3805b211695fd1a18c3e'; `
    Write-Host ('Downloading PostgreSQL from {0}...' -f $url); `
    Invoke-WebRequest -Uri $url -OutFile postgresql.zip; `
    Write-Host ('Verifying sha256 ({0})...' -f $sha256); `
    if ((Get-FileHash postgresql.zip -Algorithm sha256).Hash -ne $sha256) { `
        Write-Host 'FAILED!'; `
        Exit 1; `
    }; `
    Write-Host 'Expanding...'; `
    Expand-Archive postgresql.zip .; `
    Write-Host 'Removing unneeded files...'; `
    Remove-Item postgresql.zip; `
    cd pgsql; `
    Get-ChildItem -Exclude bin,lib,share | ForEach-Object {cmd.exe /c rd /s /q $_};
RUN cd $env:TMP; `
    $url = 'https://github.com/rgl/local-service-account/releases/download/v0.0.2/local-service-account.zip'; `
    $sha256 = '9d7e580887a36373b51550660c903d2efe769fdf01eeb3c073af7d804d372567'; `
    Write-Host ('Downloading local-service-account from {0}...' -f $url); `
    Invoke-WebRequest -Uri $url -OutFile local-service-account.zip; `
    Write-Host ('Verifying sha256 ({0})...' -f $sha256); `
    if ((Get-FileHash local-service-account.zip -Algorithm sha256).Hash -ne $sha256) { `
        Write-Host 'FAILED!'; `
        Exit 1; `
    }; `
    Write-Host 'Expanding...'; `
    Expand-Archive local-service-account.zip .; `
    Remove-Item local-service-account.zip;

FROM microsoft/nanoserver
SHELL ["C:/Windows/System32/WindowsPowerShell/v1.0/PowerShell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
COPY --from=builder /Users/ContainerAdministrator/AppData/Local/Temp/pgsql /pgsql/
COPY --from=builder /Users/ContainerAdministrator/AppData/Local/Temp/local-service-account.exe /init/
COPY init /init/
EXPOSE 5432
ENV PGPASSWORD="postgres"
ENV PGDATA="C:/data/pgdata"
VOLUME ["C:/data"]
ENTRYPOINT /init/init.ps1
