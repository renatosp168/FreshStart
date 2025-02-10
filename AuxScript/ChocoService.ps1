function Read-Choco {
     if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        return $false
     }
     return $true
}

function Install-Choco {
    Write-Output "Instalando Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue | Out-Null
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) | Out-Null
}

function Install-ChocoPackage {
    param (
        [string]$package,
        [string]$username
    )

    try {
        # Verifica se o pacote já está instalado
        $installed = choco list --local-only $package --exact --limit-output --no-progress -r
        if ($installed) {
            Write-Output "$package já está instalado. Atualizando..."
        } else {
            Write-Output "$package não está instalado. Instalando..."
        }

        # Instala/atualiza o pacote no contexto do utilizador
        Write-Output "Instalando/atualizando $package para o utilizador $username..."

        # Executa o comando Chocolatey no contexto do utilizador especificado
        $process = Start-Process -FilePath "choco" -ArgumentList "install $package -y --no-progress --limit-output" -Credential (Get-Credential -UserName $username -Message "Insira a senha para o utilizador $username") -NoNewWindow -Wait -PassThru

        if ($process.ExitCode -eq 0) {
            Write-Output "$package instalado/atualizado com sucesso para $username."
            return $true
        } else {
            Write-Output "Falha ao instalar/atualizar $package para $username."
            return $false
        }

    } catch {
        Write-Output "Erro ao processar $package para $username."
        $failedPrograms += "$package ($username)"
    }














    Write-Output "Instalando/atualizando $package para o utilizador $username..."

    # Executa o comando Chocolatey no contexto do utilizador especificado
    $process = Start-Process -FilePath "choco" -ArgumentList "install $package -y --no-progress --limit-output" -Credential (Get-Credential -UserName $username -Message "Insira a senha para o utilizador $username") -NoNewWindow -Wait -PassThru

    if ($process.ExitCode -eq 0) {
        Write-Output "$package instalado/atualizado com sucesso para $username."
        return $true
    } else {
        Write-Output "Falha ao instalar/atualizar $package para $username."
        return $false
    }
}