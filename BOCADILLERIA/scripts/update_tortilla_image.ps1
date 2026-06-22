[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Stop"

$API_KEY = "AIzaSyA5xEEmDM8vmyZ81YyhcyXGfaw5LDqDZe8"
$DB = "https://bocadilleria-a5c81-default-rtdb.europe-west1.firebasedatabase.app"
$NEW_URL = "https://bocadilleria-a5c81.web.app/images/bocadillo_tortilla_sin_fondo.png"
$PRODUCT_ID = "boc-tortilla-espanola"

$email = "img-bot-" + (Get-Random -Maximum 99999) + "@bocadilleria.local"
$password = "TempImg-" + (Get-Random -Maximum 99999) + "!Aa1"
Write-Host "Creando usuario temporal: $email"

$signupBody = @{ email = $email; password = $password; returnSecureToken = $true } | ConvertTo-Json
$signup = Invoke-RestMethod -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$API_KEY" -Method POST -Body $signupBody -ContentType "application/json" -TimeoutSec 20
$idToken = $signup.idToken
$uid = $signup.localId
Write-Host "  uid=$uid"

Write-Host "Asignando role=admin temporal en /users/$uid ..."
$userBody = @{ email = $email; role = "admin"; createdAt = [int64](([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()) } | ConvertTo-Json
try {
  Invoke-RestMethod -Uri "$DB/users/$uid.json?auth=$idToken" -Method PUT -Body $userBody -ContentType "application/json" -TimeoutSec 20 | Out-Null
  Write-Host "  OK"
} catch {
  Write-Host "  ERROR /users/${uid}: $($_.Exception.Message)"
  if ($_.ErrorDetails) { Write-Host "  Detalles: $($_.ErrorDetails.Message)" }
  exit 1
}

Write-Host "Actualizando imageUrl de $PRODUCT_ID ..."
$patchBody = @{ imageUrl = $NEW_URL } | ConvertTo-Json
$utf8Body = [System.Text.Encoding]::UTF8.GetBytes($patchBody)
try {
  $resp = Invoke-RestMethod -Uri "$DB/products/$PRODUCT_ID.json?auth=$idToken" -Method PATCH -Body $utf8Body -ContentType "application/json; charset=utf-8" -TimeoutSec 20
  Write-Host "  OK"
  Write-Host "  Respuesta: $($resp | ConvertTo-Json -Compress)"
} catch {
  Write-Host "  ERROR PATCH: $($_.Exception.Message)"
  if ($_.ErrorDetails) { Write-Host "  Detalles: $($_.ErrorDetails.Message)" }
  exit 1
}

Write-Host "Verificando..."
try {
  $check = Invoke-RestMethod -Uri "$DB/products/$PRODUCT_ID/imageUrl.json?auth=$idToken" -Method GET -TimeoutSec 15
  Write-Host "  imageUrl actual: $check"
} catch {
  Write-Host "  No se pudo verificar: $($_.Exception.Message)"
}

Write-Host "Hecho."
