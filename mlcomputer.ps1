Install-module -Name Posh-SSH

$user = whoami /upn

while (1) {
   
    $input = ""

    while (!$input) {
        Write-Host "

        current user: $user
        
            [1] Check if on.
            [2] Check nvidia-smi
            [3] Check nvidia-smi in docker
            [4] Check IP-address
            [5] Send command
            [6] Change user
        "
        $input = Read-Host -Prompt "choose? "
    }
    
    switch ($input) {
        
        1 { 1..8 | ForEach-Object { Write-Host "Checking mlcomputer00$_"; Test-Connection -Count 1 mlcomputer00$_ }  }

        2 { $password = Read-Host "Type password: " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            1..8 | ForEach-Object { 
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Checking mlcomputer00$_" -ForegroundColor DarkYellow; 
                (Invoke-SSHCommand -SSHSession $session -Command nvidia-smi).Output
            } 
          }

        3 { $password = Read-Host "Type password: " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            1..8 | ForEach-Object { 
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Checking mlcomputer00$_" -ForegroundColor DarkYellow;  
                (Invoke-SSHCommand -SSHSession $session -Command "docker run --rm --gpus all ubuntu nvidia-smi").Output
            } 
          }
         
        4 { $password = Read-Host "Type password: " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            1..8 | ForEach-Object { 
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Checking mlcomputer00$_" -ForegroundColor DarkYellow; 
                (Invoke-SSHCommand -SSHSession $session -Commanddocker IP a ).Output
            } 
          }

        5 { 
            $command = Read-Host -Prompt "Command to execute: "
            $password = Read-Host "Type password: " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            1..8 | ForEach-Object { 
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Checking mlcomputer00$_" -ForegroundColor DarkYellow; 
                (Invoke-SSHCommand -SSHSession $session -Commanddocker $command ).Output
            } 
          }

        6 { $user = Read-Host -Prompt "User to use: "
          }
    }
}
