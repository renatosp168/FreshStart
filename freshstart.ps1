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

# Função para instalar ou atualizar um pacote no contexto de um utilizador específico
function Install-ChocoPackage {
    param (
        [string]$package,
        [string]$username
    )

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

# 1. Ler o ficheiro de configuração
$chocoProgramsFile = "C:\caminho\para\lista_programas.txt"  # Substitua pelo caminho do ficheiro
$chocoPrograms = Get-Content -Path $chocoProgramsFile -ErrorAction Stop

# 2. Verificar se o Chocolatey está instalado
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Output "Instalando Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue | Out-Null
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) | Out-Null
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

    try {
        # Verifica se o pacote já está instalado
        $installed = choco list --local-only $package --exact --limit-output --no-progress -r
        if ($installed) {
            Write-Output "$package já está instalado. Atualizando..."
        } else {
            Write-Output "$package não está instalado. Instalando..."
        }

        # Instala/atualiza o pacote no contexto do utilizador
        if (Install-ChocoPackage -package $package -username $username) {
            $updatedPrograms += "$package ($username)"
        } else {
            $failedPrograms += "$package ($username)"
        }
    } catch {
        Write-Output "Erro ao processar $package para $username."
        $failedPrograms += "$package ($username)"
    }
}

# 4. Mostrar programas atualizados e falhados
Write-Output "Programas atualizados: $($updatedPrograms -join ', ')"
Write-Output "Programas que falharam: $($failedPrograms -join ', ')"

# 5. Aguarda input do utilizador antes de terminar
Write-Output "Pressione Enter para sair..."
$null = Read-Host

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