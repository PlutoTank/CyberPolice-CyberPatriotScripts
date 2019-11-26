[CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Alias ('HostName','cn','Host','Computer')]
        [String]$ComputerName='localhost',
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
        [int]$Port,
        [int] $Timeout = 10000
    )
    foreach($Computer in $ComputerName) {
    Try {
          $tcp = New-Object System.Net.Sockets.TcpClient
          $connection = $tcp.BeginConnect($Computer, $Port, $null, $null)
          $connection.AsyncWaitHandle.WaitOne($timeout,$false)  | Out-Null 
          if($tcp.Connected -eq $true) {
          Write-Host  "Epic Gamer Elite Hacking Squad successfully connected to Host: `"$Computer`" on Port: `"$Port`"" -ForegroundColor Green
      }
      else {
        Write-Host "Epic Gamer Elite Hacking Squad could not connect to Host: `"$Computer`" on Port: `"$Port`"" -ForegroundColor Red
      }
    }
    
    Catch {
            Write-Host "Epic Gamer Elite Hacking Squad had an EPIC error!" -ForegroundColor Red
          }

}