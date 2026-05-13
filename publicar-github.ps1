param(
  [string] $Mensagem = "atualiza site"
)

# Publica o site no GitHub (abra o PowerShell nesta pasta: Shift+clique direito > Abrir no Terminal).
# 1) Crie um repositorio VAZIO em https://github.com/new (sem README).
# 2) Edite a linha abaixo com a URL do seu repositorio e salve.
$repoUrl = "https://github.com/joaovictornery49-jpg/pedido-de-desculpas.git"

if ($repoUrl -match "SEU_USUARIO") {
  Write-Host "Edite publicar-github.ps1 e coloque a URL do seu repositorio em `$repoUrl." -ForegroundColor Yellow
  Start-Process "https://github.com/new"
  exit 1
}

git add .
git status
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
  git commit -m $Mensagem
}
if (-not (git remote get-url origin 2>$null)) {
  git remote add origin $repoUrl
}
git branch -M main 2>$null
git push -u origin main
Write-Host "No GitHub: Settings > Pages > Source: GitHub Actions. O link aparece em Settings > Pages apos o workflow rodar." -ForegroundColor Green
