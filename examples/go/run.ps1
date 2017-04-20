# install go.
choco install -y golang

# setup the current process environment.
$env:GOROOT = 'C:\tools\go'
$env:PATH += ";$env:GOROOT\bin"

# setup the Machine environment.
[Environment]::SetEnvironmentVariable('GOROOT', $env:GOROOT, 'Machine')
[Environment]::SetEnvironmentVariable(
    'PATH',
    "$([Environment]::GetEnvironmentVariable('PATH', 'Machine'));$env:GOROOT\bin",
    'Machine')

# wrap the go command in order to terminate this script when it fails.
function go {
    go.exe $Args
    if ($LASTEXITCODE) {
        throw "$(@('go')+$Args | ConvertTo-Json -Compress) failed with exit code $LASTEXITCODE"
    }
}

Write-Output 'Go env:'
go env

Write-Output 'building the binaries...'
cd hello-world
go build -v

Write-Output 'building the container...'
docker build -t go-hello-world .

Write-Output 'getting the container history...'
docker history go-hello-world

Write-Output 'running the container in background...'
docker run --rm -d -p 80:8888 --name go-hello-world go-hello-world

# NB on Windows we cannot access the published 80 port at the http://localhost:80
#    address, we have to directly access the container IP adress.
#    see https://blog.sixeyed.com/published-ports-on-windows-containers-dont-do-loopback/
$containerIp = docker inspect --format '{{.NetworkSettings.Networks.nat.IPAddress}}' go-hello-world
$url = "http://$($containerIp):8888"

Write-Output "using the container by doing an http request to $url..."
Write-Output (Invoke-RestMethod $url)

Write-Output 'getting the container logs...'
docker logs go-hello-world

Write-Output 'stopping the container...'
docker stop go-hello-world
