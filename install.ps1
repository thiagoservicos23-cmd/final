# =====================================================
# CONFIGURAÇÕES (Mude para sua URL do Vercel)
# =====================================================
$VERCEL_URL = "https://final-b2ky.vercel.app"
$URL_ZIP = "$VERCEL_URL/Pmw%20games%20unlock.zip"
$URL_FIX = "https://raw.githubusercontent.com/KRAYz-Oficial/KRAYz-Oficial/67065f398be63e1fe2c29ef2838f3030490eb3b6/Remover-bugs.ps1"

# Caminhos Temporários
$tempPath = Join-Path $env:TEMP "pmw_temp"
$zipLocal = Join-Path $env:TEMP "pmw_files.zip"

Clear-Host
Write-Host "`n [GAMES UNLOCK - MODO TURBO v2]" -ForegroundColor Cyan
Write-Host " ==============================`n" -ForegroundColor Cyan

# 1. Detectar Steam
$regPath = "HKCU:\Software\Valve\Steam"
if (-not (Test-Path $regPath)) {
    Write-Host " [ERRO] Steam nao encontrada no Registro!" -ForegroundColor Red
    pause ; exit
}
$steamExe = (Get-ItemProperty -Path $regPath).SteamExe
$steamDir = Split-Path -Parent $steamExe
$configDir = Join-Path $steamDir "config"

# 2. Download com Verificação
Write-Host " [+] Baixando arquivos..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $URL_ZIP -OutFile $zipLocal -ErrorAction Stop
    Write-Host " [OK] Download concluido ($((Get-Item $zipLocal).Length / 1KB) KB)" -ForegroundColor Green
} catch {
    Write-Host " [ERRO] Falha ao baixar o ZIP. Verifique se o arquivo esta no Vercel!" -ForegroundColor Red
    pause ; exit
}

# 3. Fechar Steam
Write-Host " [-] Encerrando processos da Steam..." -ForegroundColor Gray
taskkill /F /IM steam.exe /T 2>$null | Out-Null

# 4. Extração via .NET (Mais confiável que o Tar)
Write-Host " [+] Extraindo arquivos..." -ForegroundColor Yellow
if (Test-Path $tempPath) { Remove-Item $tempPath -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $tempPath -Force | Out-Null

try {
    # Adiciona a biblioteca de compressão e extrai
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipLocal, $tempPath)
    Write-Host " [OK] Extracao concluida com sucesso." -ForegroundColor Green
} catch {
    Write-Host " [ERRO] Falha na extracao: $($_.Exception.Message)" -ForegroundColor Red
    pause ; exit
}

# 5. Cópia dos Arquivos (Verificando se existem)
Write-Host " [+] Aplicando modificacoes..." -ForegroundColor Yellow
$arquivosExtraidos = Get-ChildItem -Path $tempPath -Recurse

# Tenta copiar a pasta Config
if (Test-Path "$tempPath\Config") {
    Copy-Item -Path "$tempPath\Config\*" -Destination $configDir -Recurse -Force
    Write-Host " [OK] Pasta Config aplicada." -ForegroundColor Gray
}

# Tenta copiar a DLL (procura em qualquer subpasta se necessário)
$dll = Get-ChildItem -Path $tempPath -Filter "Hid.dll" -Recurse | Select-Object -First 1
if ($dll) {
    Copy-Item -Path $dll.FullName -Destination $steamDir -Force
    Write-Host " [OK] DLL Hid.dll aplicada em $steamDir" -ForegroundColor Gray
} else {
    Write-Host " [AVISO] Hid.dll nao encontrada dentro do ZIP!" -ForegroundColor Yellow
}

# 6. Limpeza e Script Online
Write-Host " [+] Executando correcao final..." -ForegroundColor Gray
try {
    Invoke-RestMethod -Uri $URL_FIX | Invoke-Expression
} catch {
    Write-Host " [!] Pulando correcao online (URL offline)." -ForegroundColor Yellow
}

# Limpar vestígios
Remove-Item $tempPath -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $zipLocal -Force -ErrorAction SilentlyContinue

# 7. Finalização
Write-Host " [+] Reiniciando Steam..." -ForegroundColor Gray
Start-Process $steamExe

Write-Host "`n ========================================================" -ForegroundColor Green
Write-Host "           INSTALACAO CONCLUIDA COM SUCESSO!" -ForegroundColor Green
Write-Host " ========================================================`n" -ForegroundColor Green
Start-Sleep -Seconds 3
