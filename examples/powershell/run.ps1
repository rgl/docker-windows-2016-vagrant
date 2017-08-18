cd info

Write-Output 'building the container...'
time {docker build -t powershell-info .}

Write-Output 'running the container in foreground...'
time {docker run --rm powershell-info}
