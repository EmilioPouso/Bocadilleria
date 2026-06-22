[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Stop"

$API_KEY = "AIzaSyA5xEEmDM8vmyZ81YyhcyXGfaw5LDqDZe8"
$DB = "https://bocadilleria-a5c81-default-rtdb.europe-west1.firebasedatabase.app"

$email = "seed-bot-v2-" + (Get-Random -Maximum 99999) + "@bocadilleria.local"
$password = "TempSeed-" + (Get-Random -Maximum 99999) + "!Aa1"
Write-Host "Creando usuario temporal admin: $email"

# 1) Sign up
$signupBody = @{ email = $email; password = $password; returnSecureToken = $true } | ConvertTo-Json
$signup = Invoke-RestMethod -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$API_KEY" -Method POST -Body $signupBody -ContentType "application/json" -TimeoutSec 20
$idToken = $signup.idToken
$uid = $signup.localId
Write-Host "  uid=$uid"

# 2) Write role=admin to /users/{uid}
$userBody = @{ email = $email; role = "admin"; createdAt = [int64](([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()) } | ConvertTo-Json
Invoke-RestMethod -Uri "$DB/users/$uid.json?auth=$idToken" -Method PUT -Body $userBody -ContentType "application/json" -TimeoutSec 20 | Out-Null
Write-Host "Usuario admin creado."

# 3) Leer JSON desde archivo (ya esta en UTF-8 con escapes \uXXXX)
$jsonPath = Join-Path $PSScriptRoot "seed_products.json"
$bytes = [System.IO.File]::ReadAllBytes($jsonPath)
Write-Host "JSON file: $jsonPath ($($bytes.Length) bytes)"

# 4) PUT a /products.json - sustituye todo
Write-Host "Subiendo 10 bocadillos a /products ..."
$r = Invoke-RestMethod -Uri "$DB/products.json?auth=$idToken" -Method PUT -Body $bytes -ContentType "application/json" -TimeoutSec 25
Write-Host "Productos escritos OK."

# 5) Eliminar usuarios huerfanos (favoritos del admin temp)
try { Invoke-RestMethod -Uri "$DB/favorites/$uid.json?auth=$idToken" -Method DELETE -TimeoutSec 10 | Out-Null } catch {}

Write-Host "Listo. Refresca la app para ver los 10 bocadillos."
