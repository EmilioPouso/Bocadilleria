[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Stop"

$API_KEY = "AIzaSyA5xEEmDM8vmyZ81YyhcyXGfaw5LDqDZe8"
$DB = "https://bocadilleria-a5c81-default-rtdb.europe-west1.firebasedatabase.app"

# 1) Crear usuario admin temporal
$email = "seed-drinks-" + (Get-Random -Maximum 99999) + "@bocadilleria.local"
$password = "TempSeed-" + (Get-Random -Maximum 99999) + "!Aa1"
Write-Host "Creando usuario temporal admin: $email"

$signupBody = @{ email = $email; password = $password; returnSecureToken = $true } | ConvertTo-Json
$signup = Invoke-RestMethod -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$API_KEY" -Method POST -Body $signupBody -ContentType "application/json" -TimeoutSec 20
$idToken = $signup.idToken
$uid = $signup.localId

# 2) Marcar como admin en /users
$userBody = @{ email = $email; role = "admin"; createdAt = [int64](([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()) } | ConvertTo-Json
Invoke-RestMethod -Uri "$DB/users/$uid.json?auth=$idToken" -Method PUT -Body $userBody -ContentType "application/json" -TimeoutSec 20 | Out-Null
Write-Host "Usuario admin creado: $uid"

# 3) Leer JSON de bebidas
$jsonPath = Join-Path $PSScriptRoot "seed_drinks.json"
$bytes = [System.IO.File]::ReadAllBytes($jsonPath)
Write-Host "JSON file: $jsonPath ($($bytes.Length) bytes)"

# 4) PATCH a /products.json - fusiona con lo existente, sin borrar bocadillos
Write-Host "Anyadiendo 11 bebidas a /products (PATCH, no sobreescribe los bocadillos)..."
$r = Invoke-RestMethod -Uri "$DB/products.json?auth=$idToken" -Method PATCH -Body $bytes -ContentType "application/json" -TimeoutSec 25
Write-Host "Bebidas anyadidas OK."

Write-Host "Listo. Refresca la app para ver las bebidas junto a los bocadillos."
