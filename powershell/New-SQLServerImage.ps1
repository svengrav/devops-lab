# Since there are no Docker images for SQL Server with Windows 2019 for some time, I use this small script to create an image based on Microsoft.

$Image = "mcr.microsoft.com/windows/servercore:ltsc2019"
$Tag = "my/sqlserver"

# Create Image
$SourceDir = (New-Item -Path (Join-Path $env:TEMP (New-Guid)) -ItemType Directory).FullName
$Archive = Join-Path $SourceDir "Source.zip"
$RepositoryUrl = "https://api.github.com/repos/microsoft/mssql-docker/zipball/master" 

Invoke-RestMethod -Uri $RepositoryUrl -OutFile $Archive
Expand-Archive -Path $Archive -DestinationPath $SourceDir -Force
Remove-Item $Archive

$DockerDir = Join-Path $SourceDir "microsoft-mssql-docker*\windows\mssql-server-windows"
if(Test-Path $DockerDir) {
    $DockerDir = Get-Item $DockerDir
    $DockerFile = Get-Content (Join-Path $DockerDir dockerfile) 

    $DockerFile -Replace "FROM microsoft/windowsservercore", "FROM $Image" | `
        Set-Content (Join-Path $DockerDir dockerfile) 

    docker build -t $Tag $DockerDir.FullName
}

Remove-Item $SourceDir -Recurse -Force

# Run
# docker run --name "sqlserver" -d -p 1433:1433 -e sa_password="" -e ACCEPT_EULA=Y my/sqlserver 
