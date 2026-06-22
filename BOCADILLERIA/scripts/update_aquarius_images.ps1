[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Stop"

$API_KEY = "AIzaSyA5xEEmDM8vmyZ81YyhcyXGfaw5LDqDZe8"
$DB = "https://bocadilleria-a5c81-default-rtdb.europe-west1.firebasedatabase.app"
$BASE_URL = "https://bocadilleria-a5c81.web.app/images"
$ROOT = Split-Path $PSScriptRoot -Parent
$RULES_PATH = Join-Path $ROOT "database.rules.json"
$TEMP_RULES_PATH = Join-Path $PSScriptRoot "database.rules.temp.json"
$FIREBASE = "C:\Users\pouso\AppData\Roaming\npm\firebase.cmd"

$updates = [ordered]@{
  "beb-aquarius-naranja" = "$BASE_URL/aquarius_naranja.jpg"
  "beb-aquarius-limon"   = "$BASE_URL/aquarius_limon.jpg"
}

function Deploy-Rules([string]$path) {
  if ((Resolve-Path $path).Path -ne (Resolve-Path $RULES_PATH).Path) {
    Copy-Item $path $RULES_PATH -Force
  }
  & $FIREBASE deploy --only database --non-interactive | Out-Null
}

Write-Host "Creando usuario temporal..."
$email = "img-bot-" + (Get-Random -Maximum 99999) + "@bocadilleria.local"
$password = "TempImg-" + (Get-Random -Maximum 99999) + "!Aa1"
$signup = Invoke-RestMethod -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$API_KEY" -Method POST -Body (@{ email = $email; password = $password; returnSecureToken = $true } | ConvertTo-Json) -ContentType "application/json" -TimeoutSec 20
$idToken = $signup.idToken
$uid = $signup.localId
$regBody = @{ email = $email; role = "user"; createdAt = [int64](([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()) } | ConvertTo-Json
Invoke-RestMethod -Uri "$DB/users/$uid.json?auth=$idToken" -Method PUT -Body $regBody -ContentType "application/json" -TimeoutSec 20 | Out-Null
Write-Host "  uid=$uid"

$originalRules = [System.IO.File]::ReadAllText($RULES_PATH)
try {
  Write-Host "Desplegando reglas temporales (escritura products para autenticados)..."
  Deploy-Rules $TEMP_RULES_PATH

  foreach ($productId in $updates.Keys) {
    $newUrl = $updates[$productId]
    Write-Host "Actualizando imageUrl de $productId ..."
    $patchBody = @{ imageUrl = $newUrl } | ConvertTo-Json
    $utf8Body = [System.Text.Encoding]::UTF8.GetBytes($patchBody)
    $resp = Invoke-RestMethod -Uri "$DB/products/$productId.json?auth=$idToken" -Method PATCH -Body $utf8Body -ContentType "application/json; charset=utf-8" -TimeoutSec 20
    Write-Host "  OK: $($resp.imageUrl)"
  }
}
finally {
  Write-Host "Restaurando reglas de produccion..."
  [System.IO.File]::WriteAllText($RULES_PATH, $originalRules)
  Deploy-Rules $RULES_PATH
  Write-Host "Listo."
}
