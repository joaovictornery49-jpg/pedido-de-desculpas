# Gera um link HTTPS público (trycloudflare.com) para abrir o site no celular HOJE,
# sem depender do GitHub Pages. Mantenha esta janela aberta enquanto quiser o link ativo.
$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

$node = $null
try {
  $c = Get-Command node -ErrorAction Stop
  $node = $c.Source
} catch {
  $fallback = "$env:LOCALAPPDATA\Programs\cursor\resources\app\resources\helpers\node.exe"
  if (Test-Path $fallback) { $node = $fallback }
}

if (-not $node -or -not (Test-Path $node)) {
  Write-Host "Não achei o Node.js. Instale em https://nodejs.org e rode de novo." -ForegroundColor Red
  exit 1
}

$cf = Join-Path $env:TEMP "cloudflared-windows-amd64.exe"
if (-not (Test-Path $cf)) {
  Write-Host "Baixando Cloudflare Tunnel (primeira vez só)..." -ForegroundColor Cyan
  Invoke-WebRequest `
    -Uri "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe" `
    -OutFile $cf -UseBasicParsing
}

$script = Join-Path $root "servir-celular.js"
Write-Host "Subindo o site a partir de: $root" -ForegroundColor Green

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $node
$psi.Arguments = "`"$script`""
$psi.WorkingDirectory = $root
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true
$serv = [System.Diagnostics.Process]::Start($psi)
Start-Sleep -Seconds 2

if ($serv.HasExited) {
  Write-Host "O servidor local não iniciou (porta 3333 em uso?)." -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host ">>> No CELULAR, use o link https://....trycloudflare.com que aparecer abaixo <<<" -ForegroundColor Yellow
Write-Host "    (Funciona de qualquer lugar. Feche esta janela ou Ctrl+C para encerrar o link.)" -ForegroundColor Gray
Write-Host ""

try {
  & $cf tunnel --url "http://127.0.0.1:3333"
} finally {
  if (-not $serv.HasExited) { $serv.Kill() }
}
