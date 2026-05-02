# Configurações
$ARQUIVO_ZIP = "Pmw games unlock.zip"
$URL_FIX = "https://raw.githubusercontent.com/KRAYz-Oficial/KRAYz-Oficial/67065f398be63e1fe2c29ef2838f3030490eb3b6/Remover-bugs.ps1"

Write-Host "`n [INFO] Buscando diretorio da Steam..." -ForegroundColor Cyan

# 1. Detectar Caminho da Steam via Registro
$regPath = "HKCU:\Software\Valve\Steam"
if (-not (Test-Path $regPath)) {
    Write-Host " [ERRO] Steam nao encontrada no Registro." -ForegroundColor Red
    pause ; exit
}

$steamExe = (Get-ItemProperty -Path $regPath).SteamExe
$steamDir = Split-Path -Parent $steamExe
$configDir = Join-Path $steamDir "config"

# 2. Verificação de Arquivo
if (-not (Test-Path $ARQUIVO_ZIP)) {
    Write-Host " [AVISO] O arquivo $ARQUIVO_ZIP nao foi encontrado na pasta atual." -ForegroundColor Yellow
    pause ; exit
}

Write-Host " [OK] Steam localizada em: $steamDir" -ForegroundColor Green
Write-Host " [+] Iniciando instalacao..." -ForegroundColor Green

# 3. Fechar Steam
Write-Host " [-] Encerrando processos da Steam..." -ForegroundColor Gray
Stop-Process -Name "steam" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# 4. Extração Ultra Rápida (Usando Tar nativo)
$tempPath = Join-Path $env:TEMP "pmw_temp"
if (Test-Path $tempPath) { Remove-Item $tempPath -Recurse -Force }
New-Item -ItemType Directory -Path $tempPath | Out-Null

Write-Host " [+] Extraindo arquivos..." -ForegroundColor Gray
tar -xf $ARQUIVO_ZIP -C $tempPath

# 5. Cópia dos Arquivos
Write-Host " [+] Aplicando modificacoes..." -ForegroundColor Gray
if (Test-Path "$tempPath\Config") {
    Copy-Item -Path "$tempPath\Config\*" -Destination $configDir -Recurse -Force
}
Copy-Item -Path "$tempPath\Hid.dll" -Destination $steamDir -Force

# 6. Limpeza e Reinicialização
Remove-Item $tempPath -Recurse -Force
Write-Host " [+] Reiniciando Steam..." -ForegroundColor Gray
Start-Process $steamExe

# 7. Correção Online
Write-Host " [+] Executando script de correcao online..." -ForegroundColor Gray
Invoke-RestMethod -Uri $URL_FIX | Invoke-Expression

Write-Host "`n========================================================" -ForegroundColor Green
Write-Host "          INSTALACAO FINALIZADA COM SUCESSO!" -ForegroundColor Green
Write-Host "========================================================`n" -ForegroundColor Green
Start-Sleep -Seconds 3