[CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [String]$path='$env:USERPROFILE',
        [int] $name = 'text.txt'
        )
        Write-Host "Creating $name..." -ForegroundColor Gray
        if (!(Test-Path "$path/$name")) {
            New-Item $path/$name -ItemType file | Out-Null
            Write-Host "$name created in $path" -ForegroundColor Green
        } else {
             Write-Host "$name already exists in $path" -ForegroundColor Yellow
             Write-Host "Did not create $name" -ForegroundColor Red
        }