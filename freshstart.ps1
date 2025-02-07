# 1. Criar utilizador admin chamado xpto (se não existir)
$userName = "xpto"
$userExists = Get-LocalUser -Name $userName -ErrorAction SilentlyContinue

if (-not $userExists) {
    Write-Output "Criando utilizador $userName..."
    New-LocalUser -Name $userName -Password (ConvertTo-SecureString "SenhaSegura123!" -AsPlainText -Force) -FullName "Utilizador XPTO" -Description "Utilizador Administrador" -ErrorAction SilentlyContinue | Out-Null
    Add-LocalGroupMember -Group "Administradores" -Member $userName -ErrorAction SilentlyContinue | Out-Null
    Write-Output "Utilizador $userName criado e adicionado ao grupo de Administradores."
} else {
    Write-Output "Utilizador $userName já existe. Passando à frente..."
}

# 2. Instalar/atualizar programas usando Chocolatey
$chocoProgramsFile = "C:\caminho\para\lista_programas.txt"  # Substitua pelo caminho do ficheiro com a lista de programas
$chocoPrograms = Get-Content -Path $chocoProgramsFile -ErrorAction Stop

# Verifica se o Chocolatey está instalado
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Output "Instalando Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue | Out-Null
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) | Out-Null
}

$updatedPrograms = @()
$failedPrograms = @()

foreach ($program in $chocoPrograms) {
    Write-Output "Processando $program..."
    try {
        # Verifica se o programa já está instalado
        $installed = choco list --local-only $program --exact --limit-output --no-progress -r
        if ($installed) {
            Write-Output "$program já está instalado. Atualizando..."
            choco upgrade $program -y --no-progress --limit-output | Out-Null
        } else {
            Write-Output "$program não está instalado. Instalando..."
            choco install $program -y --no-progress --limit-output | Out-Null
        }
        $updatedPrograms += $program
    } catch {
        Write-Output "Falha ao processar $program."
        $failedPrograms += $program
    }
}

# 3. Mostrar programas atualizados e falhados
Write-Output "Programas atualizados: $($updatedPrograms -join ', ')"
Write-Output "Programas que falharam: $($failedPrograms -join ', ')"

# 4. Configurar pasta do Git e fazer push de um repositório
$repoPath = "C:\caminho\para\repositorio"  # Substitua pelo caminho do repositório
$remoteRepo = "https://github.com/seu_usuario/seu_repositorio.git"  # Substitua pelo URL do repositório remoto

if (-not (Test-Path $repoPath)) {
    Write-Output "Clonando repositório..."
    git clone $remoteRepo $repoPath 2>&1 | Out-Null
} else {
    Write-Output "Repositório já existe. Atualizando..."
    Set-Location $repoPath
    git pull 2>&1 | Out-Null
}

# Configurações do Git (substitua pelos seus dados)
git config --global user.name "Seu Nome" 2>&1 | Out-Null
git config --global user.email "seu_email@example.com" 2>&1 | Out-Null

# Adiciona, faz commit e push das alterações
Set-Location $repoPath
git add . 2>&1 | Out-Null
git commit -m "Atualização automática via script PowerShell" 2>&1 | Out-Null
git push origin main 2>&1 | Out-Null

Write-Output "Repositório configurado e push realizado com sucesso."

# Aguarda input do utilizador antes de terminar
Write-Output "Pressione Enter para sair..."
$null = Read-Host