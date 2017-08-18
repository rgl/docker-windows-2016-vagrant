Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
trap {
    Write-Output "ERROR: $_"
    Write-Output (($_.ScriptStackTrace -split '\r?\n') -replace '^(.*)$','ERROR: $1')
    Write-Output (($_.Exception.ToString() -split '\r?\n') -replace '^(.*)$','ERROR EXCEPTION: $1')
    Exit 1
}

$serviceHome = 'c:/pgsql'
$serviceName = 'pgsql'
$serviceUsername = 'pgsql'
$servicePassword = 'HeyH0Password' # TODO generate a random password and store it?

# the default postgres superuser username and password.
# see https://www.postgresql.org/docs/9.6/static/libpq-envars.html
$env:PGUSER = 'postgres'

function psql {
    &"$serviceHome/bin/psql.exe" -v ON_ERROR_STOP=1 -w @Args
    if ($LASTEXITCODE) {
        throw "psql failed with exit code $LASTEXITCODE"
    }
}

function pg_ctl {
    &"$serviceHome/bin/pg_ctl.exe" @Args
    if ($LASTEXITCODE) {
        throw "pg_ctl failed with exit code $LASTEXITCODE"
    }
}

function initdb {
    &"$serviceHome/bin/initdb.exe" @Args
    if ($LASTEXITCODE) {
        throw "initdb failed with exit code $LASTEXITCODE"
    }
}

if (!(Get-Service -ErrorAction SilentlyContinue $serviceName)) {
    Write-Output "Installing the $serviceName service..."
    /init/local-service-account.exe create pgsql $servicePassword
    if ($LASTEXITCODE) {
        throw "local-service-account failed with exit code $LASTEXITCODE"
    }
    pg_ctl `
        register `
        -N $serviceName `
        -U $serviceUsername `
        -P $servicePassword `
        -D $env:PGDATA `
        -S demand `
        -w
}

if (!(Test-Path "$env:PGDATA\PG_VERSION")) {
    mkdir -Force $env:PGDATA | Out-Null
    $acl = New-Object System.Security.AccessControl.DirectorySecurity
    $acl.SetAccessRuleProtection($true, $false)
    @(
        $serviceUsername
        $env:USERNAME
        'Administrators'
    ) | ForEach-Object {
        $acl.AddAccessRule((
            New-Object `
                System.Security.AccessControl.FileSystemAccessRule(
                    $_,
                    'FullControl',
                    'ContainerInherit,ObjectInherit',
                    'None',
                    'Allow')))
    }
    Set-Acl $env:PGDATA $acl

    # see https://www.postgresql.org/docs/9.6/static/creating-cluster.html
    Write-Host "Creating the Database Cluster in $env:PGDATA..."
    initdb `
        --username=$env:PGUSER `
        --auth-host=trust `
        --auth-local=reject `
        --encoding=UTF8 `
        --locale=en `
        -D $env:PGDATA

    Write-Host 'Configuring the listen address...'
    Set-Content -Encoding ascii "$env:PGDATA\postgresql.conf" (
        (Get-Content "$env:PGDATA\postgresql.conf") `
            -replace '^#?(listen_addresses\s+.+?\s+).+','$1''0.0.0.0'''
    )

    Write-Host 'Allowing external connections made with the md5 authentication method...'
@'

# allow md5 authenticated connections from any other address.
#
# TYPE  DATABASE        USER            ADDRESS                 METHOD
host    all             all             0.0.0.0/0               md5
host    all             all             ::/0                    md5
'@ `
    | Out-File -Append -Encoding ascii "$env:PGDATA\pg_hba.conf"
}

Write-Host 'Starting...'
Start-Service $serviceName
Write-Host "Running $(psql -t -c 'select version()' postgres)..."

Write-Host "Setting the $env:PGUSER user password..."
psql -c "alter role $env:PGUSER login password '$env:PGPASSWORD'" postgres

while ($true) {
    Start-Sleep -Seconds 2
}
