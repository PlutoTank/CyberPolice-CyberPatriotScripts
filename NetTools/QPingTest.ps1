[CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Alias ('HostName','cn','Host','Computer')]
        [String]$ComputerName='localhost',
        [int] $Timeout = 10000
        )

foreach($c in $ComputerName) {
   
    Try {
        if(Test-Connection -Cn $c -BufferSize 16 -Count 1 -ea 0 -quiet)
        {
            Write-Host “Epic Gamer Elite Hacking Squad connected successfully to $c” -ForegroundColor Green
        }
        else {
            Write-Host “Epic Gamer Elite Hacking Squad could not connect to $c” -ForegroundColor Red
        }
    }
    Catch {
        Write-Host "Epic Gamer Elite Hacking Squad had an EPIC error!" -ForegroundColor Red
    }

}