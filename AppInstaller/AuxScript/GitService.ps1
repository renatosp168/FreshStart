function Config-git{
    param(
        [string] $localRepository,
        [string] $remoteRepository,
        [string] $username,
        [string] $mail
    )

    if (-not (Test-Path $remoteRepository)) {
        Write-Output "Clonando repositório..."
        git clone $remoteRepository $localRepository 2>&1 | Out-Null
    } else {
        Write-Output "Repositório já existe. Atualizando..."
        Set-Location $localRepository
        git pull 2>&1 | Out-Null
    }

    # Configurações do Git (substitua pelos seus dados)
    git config --global user.name $username 2>&1 | Out-Null
    git config --global user.email $mail 2>&1 | Out-Null

    # Adiciona, faz commit e push das alterações
    Set-Location $localRepository
    git add . 2>&1 | Out-Null
    git commit -m "Atualização automática via script PowerShell" 2>&1 | Out-Null
    git push origin main 2>&1 | Out-Null

    Write-Output "Repositório configurado e push realizado com sucesso."

}