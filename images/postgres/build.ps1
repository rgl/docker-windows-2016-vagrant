Write-Output 'building the postgres image...'
time {docker build -t postgres:9.6-nanoserver .}
docker image ls postgres:9.6-nanoserver
docker history postgres:9.6-nanoserver
Pop-Location

Write-Output 'running a smoke-test postgres container...'
try {docker rm --force postgres-smoke-test} catch {}
$dataPath = 'c:\postgres-smoke-test-data'
if ($false -and (Test-Path $dataPath)) {
    . .\Enable-ProcessPrivilege.ps1
    Enable-ProcessPrivilege SeTakeOwnershipPrivilege
    Get-ChildItem $dataPath | ForEach-Object {
        $acl = Get-Acl $_.FullName
        $acl.SetOwner([Security.Principal.NTAccount]'Administrators')
        $acl.SetAccessRuleProtection($false, $false)
        Set-Acl $_.FullName $acl
    }
    Enable-ProcessPrivilege SeTakeOwnershipPrivilege -Disable
    Remove-Item -Recurse -Force $dataPath
}
mkdir -Force $dataPath | Out-Null
time {
    docker run `
        -d `
        -p 5432:5432 `
        --name postgres-smoke-test `
        --volume "${dataPath}:C:\data" `
        postgres:9.6-nanoserver
}

$containerIp = docker inspect --format '{{.NetworkSettings.Networks.nat.IPAddress}}' postgres-smoke-test
Write-Output "PostgreSQL running at ${containerIp}:5432"

Start-Sleep -Seconds (5*60)

Write-Output 'getting the container logs...'
docker logs postgres-smoke-test

Write-Output 'stopping the container...'
docker stop postgres-smoke-test

Write-Output 'removing the container...'
docker rm postgres-smoke-test
