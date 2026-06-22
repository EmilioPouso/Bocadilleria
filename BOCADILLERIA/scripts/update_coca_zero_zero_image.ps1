[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Stop"

$API_KEY = "AIzaSyA5xEEmDM8vmyZ81YyhcyXGfaw5LDqDZe8"
$DB = "https://bocadilleria-a5c81-default-rtdb.europe-west1.firebasedatabase.app"
$NEW_URL = "https://bocadilleria-a5c81.web.app/images/coca_cola_zero_zero_sin_fondo.png"
$PRODUCT_ID = "beb-coca-cola-zero-zero"
$firebaseCmd = "C:\Users\pouso\AppData\Roaming\npm\firebase.cmd"
$env:PATH = "C:\Users\pouso\AppData\Roaming\npm;" + $env:PATH

Write-Host "Creando usuario temporal para actualizar imagen..."
$email = "img-bot-" + (Get-Random -Maximum 99999) + "@bocadilleria.local"
$password = "TempImg-" + (Get-Random -Maximum 99999) + "!Aa1"
$signup = Invoke-RestMethod -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$API_KEY" -Method POST -Body (@{ email = $email; password = $password; returnSecureToken = $true } | ConvertTo-Json) -ContentType "application/json" -TimeoutSec 20
$idToken = $signup.idToken
$uid = $signup.localId
$regBody = @{ email = $email; role = "user"; createdAt = [int64](([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()) } | ConvertTo-Json
Invoke-RestMethod -Uri "$DB/users/$uid.json?auth=$idToken" -Method PUT -Body $regBody -ContentType "application/json" -TimeoutSec 20 | Out-Null

Write-Host "Actualizando imageUrl de $PRODUCT_ID ..."
$patchBody = @{ imageUrl = $NEW_URL } | ConvertTo-Json
$utf8Body = [System.Text.Encoding]::UTF8.GetBytes($patchBody)
$resp = Invoke-RestMethod -Uri "$DB/products/$PRODUCT_ID.json?auth=$idToken" -Method PATCH -Body $utf8Body -ContentType "application/json; charset=utf-8" -TimeoutSec 20
Write-Host "OK: $($resp.imageUrl)"
