choco install -y pgadmin4

Import-Module C:\ProgramData\chocolatey\helpers\chocolateyInstaller.psm1
Install-ChocolateyShortcut `
    -ShortcutFilePath "$env:USERPROFILE\Desktop\pgAdmin 4.lnk" `
    -TargetPath 'C:\Program Files (x86)\pgAdmin 4\v1\runtime\pgAdmin4.exe'
