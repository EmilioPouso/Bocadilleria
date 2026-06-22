[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Stop"

$API_KEY = "AIzaSyA5xEEmDM8vmyZ81YyhcyXGfaw5LDqDZe8"
$DB = "https://bocadilleria-a5c81-default-rtdb.europe-west1.firebasedatabase.app"
$PRODUCT_ID = "beb-agua-grande"
$ROOT = Split-Path $PSScriptRoot -Parent
$RULES_PATH = Join-Path $ROOT "database.rules.json"
$TEMP_RULES_PATH = Join-Path $PSScriptRoot "database.rules.temp.json"
$FIREBASE = "C:\Users\pouso\AppData\Roaming\npm\firebase.cmd"

function Deploy-Rules([string]$path) {
  if ((Resolve-Path $path).Path -ne (Resolve-Path $RULES_PATH).Path) {
    Copy-Item $path $RULES_PATH -Force
  }
  & $FIREBASE deploy --only database --non-interactive | Out-Null
}

$productBody = @{
  name = "Agua grande"
  description = "Agua mineral natural. Botella 1,5 L."
  price = 2.00
  imageUrl = "https://bocadilleria-a5c81.web.app/images/agua_grande_sin_fondo.png"
  category = "bebidas"
  ingredients = @()
  ingredientExtraPrices = @{}
  available = $true
  glutenFreeBread = $false
} | ConvertTo-Json -Depth 5

$email = "restore-bot-" + (Get-Random -Maximum 99999) + "@bocadilleria.local"
$password = "TempRestore-" + (Get-Random -Maximum 99999) + "!Aa1"
$signup = Invoke-RestMethod -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$API_KEY" -Method POST -Body (@{ email = $email; password = $password; returnSecureToken = $true } | ConvertTo-Json) -ContentType "application/json" -TimeoutSec 20
$idToken = $signup.idToken
$uid = $signup.localId
$regBody = @{ email = $email; role = "user"; createdAt = [int64](([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()) } | ConvertTo-Json
Invoke-RestMethod -Uri "$DB/users/$uid.json?auth=$idToken" -Method PUT -Body $regBody -ContentType "application/json" -TimeoutSec 20 | Out-Null

$originalRules = [System.IO.File]::ReadAllText($RULES_PATH)
try {
  Deploy-Rules $TEMP_RULES_PATH
  $utf8Body = [System.Text.Encoding]::UTF8.GetBytes($productBody)
  $resp = Invoke-RestMethod -Uri "$DB/products/$PRODUCT_ID.json?auth=$idToken" -Method PUT -Body $utf8Body -ContentType "application/json; charset=utf-8" -TimeoutSec 20
  Write-Host "OK: $($resp.name) restaurado en Firebase"
}
finally {
  [System.IO.File]::WriteAllText($RULES_PATH, $originalRules)
  Deploy-Rules $RULES_PATH
}
