function Create-User {
    param (
        [string]$username,
        [string]$password,
        [string]$name,
        [string]$description,
        [string]$admin
    )
    
    $userExists = Get-LocalUser -Name $userName -ErrorAction SilentlyContinue

    if (-not $userExists) {
        Write-Output "Criando utilizador $userName..."
        New-LocalUser -Name $userName -Password (ConvertTo-SecureString $password -AsPlainText -Force) -FullName $name -Description $description -ErrorAction SilentlyContinue | Out-Null
        Write-Output "Utilizador $userName criado."
        
        if($admin -eq 'true'){
            Write-Admin -username $username
        }

    } else {
        Write-Output "Utilizador $userName já existe. Passando à frente..."
    }
}

function Write-Admin{
    param (
        [string] $username
    )

    Add-LocalGroupMember -Group "Administradores" -Member $userName -ErrorAction SilentlyContinue | Out-Null
}