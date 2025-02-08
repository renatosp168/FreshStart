. ./GeneralServices.ps1
. ./UserService.ps1
. ./ChocoService.ps1
. ./GitService.ps1

# 1. load general configurations
$configurations = Read-Configurations -configFilePath "./default.conf"

# 2. load User configuration
try{
    $usersInfo = Read-Configurations -configFilePath $configurations['userConfigurationFile']
    Create-User -username $usersInfo['username'] -password $usersInfo['password'] -name $usersInfo['name'] -description $usersInfo['description']
    #need to check if user should be admin
    Make-Admin -username "xpto"
}catch {
    Write-Error "Erro: O ficheiro de configuração de utilizadores não foi encontrado"
}




# 1. Ler o ficheiro de configuração
$chocoProgramsFile = ".\lista_programas.txt"  # Substitua pelo caminho do ficheiro
$chocoPrograms = Get-Content -Path $chocoProgramsFile -ErrorAction Stop

# 2. Verificar se o Chocolatey está instalado
if(-not Check-Choco) {
    Install-Choco
}

# 3. Processar cada linha do ficheiro
$updatedPrograms = @()
$failedPrograms = @()

foreach ($line in $chocoPrograms) {
    $package, $username = $line -split '\|'  # Divide a linha no delimitador

    if (-not $package -or -not $username) {
        Write-Output "Formato inválido na linha: $line"
        continue
    }
    
    Write-Output "Processando $package para o utilizador $username..."

    $installed = Install-ChocoPackage -username $username -package $package
    if ($installed) {
        $updatedPrograms += "$package ($username)"
    } else {
        $failedPrograms += "$package ($username)"
    }
}

# 4. Mostrar programas atualizados e falhados
Write-Output "Programas atualizados: $($updatedPrograms -join ', ')"
Write-Output "Programas que falharam: $($failedPrograms -join ', ')"

# 4. Configurar pasta do Git e fazer push de um repositório
$repoPath = "C:\caminho\para\repositorio"  # Substitua pelo caminho do repositório
$remoteRepo = "https://github.com/seu_usuario/seu_repositorio.git"  # Substitua pelo URL do repositório remoto

Config-git(-localRepository $repoPath -remoteRepository $remoteRepo -username "" -mail "")

# Aguarda input do utilizador antes de terminar
Write-Output "Pressione Enter para sair..."
$null = Read-Host