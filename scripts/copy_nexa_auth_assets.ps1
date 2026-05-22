# Copy nexatracker auth visuals into this project (run once from repo root).
$base = Split-Path -Parent $PSScriptRoot
$src = Join-Path (Split-Path -Parent $base) "nexatrackerprod"

$pairs = @(
  @("lib\assets\images\gradient.png", "lib\assets\images\gradient.png"),
  @("asset\images\nexalogosize1.png", "lib\assets\images\nexalogosize1.png"),
  @("lib\assets\icons\phone.png", "lib\assets\icons\phone.png"),
  @("lib\assets\icons\asterisk.png", "lib\assets\icons\asterisk.png")
)

foreach ($p in $pairs) {
  $from = Join-Path $src $p[0]
  $to = Join-Path $base $p[1]
  $dir = Split-Path $to -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  if (Test-Path $from) {
    Copy-Item -LiteralPath $from -Destination $to -Force
    Write-Host "Copied $($p[1])"
  } else {
    Write-Warning "Missing source: $from"
  }
}

Write-Host "Done. Run: flutter pub get"
