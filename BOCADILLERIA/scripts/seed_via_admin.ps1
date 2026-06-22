[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Stop"

$API_KEY = "AIzaSyA5xEEmDM8vmyZ81YyhcyXGfaw5LDqDZe8"
$DB = "https://bocadilleria-a5c81-default-rtdb.europe-west1.firebasedatabase.app"

$email = "seed-bot-" + (Get-Random -Maximum 99999) + "@bocadilleria.local"
$password = "TempSeed-" + (Get-Random -Maximum 99999) + "!Aa1"
Write-Host "Creando usuario temporal: $email"

# 1) Sign up
$signupBody = @{ email = $email; password = $password; returnSecureToken = $true } | ConvertTo-Json
$signup = Invoke-RestMethod -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$API_KEY" -Method POST -Body $signupBody -ContentType "application/json" -TimeoutSec 20
$idToken = $signup.idToken
$uid = $signup.localId
Write-Host "  uid=$uid"

# 2) Write role=admin to /users/{uid} (typical rule: auth.uid == $uid allows this)
Write-Host "Escribiendo role=admin en /users/$uid ..."
$userBody = @{ email = $email; role = "admin"; createdAt = [int64](([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()) } | ConvertTo-Json
try {
  $r = Invoke-RestMethod -Uri "$DB/users/$uid.json?auth=$idToken" -Method PUT -Body $userBody -ContentType "application/json" -TimeoutSec 20
  Write-Host "  /users/$uid escrito OK"
} catch {
  Write-Host "  ERROR escribiendo /users/${uid}: $($_.Exception.Message)"
  if ($_.ErrorDetails) { Write-Host "  Detalles: $($_.ErrorDetails.Message)" }
  exit 1
}

# 3) Construir los 10 bocadillos
$products = [ordered]@{
  "boc-jamon-serrano" = @{
    name = "Bocadillo de Jamón Serrano"
    description = "Jamón serrano curado con tomate natural rallado y un toque de aceite de oliva virgen extra."
    price = 4.50
    imageUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Bocadillo_de_jam%C3%B3n_serrano_Mallorca.jpg/960px-Bocadillo_de_jam%C3%B3n_serrano_Mallorca.jpg"
    category = "bocadillos"
    ingredients = @("pan", "tomate", "jamón serrano", "aceite de oliva")
    ingredientExtraPrices = @{ "tomate" = 0.30; "jamón serrano" = 1.50; "aceite de oliva" = 0.20 }
    available = $true
    glutenFreeBread = $false
  }
  "boc-jamon-iberico" = @{
    name = "Bocadillo de Jamón Ibérico"
    description = "Jamón ibérico de bellota sobre pan con tomate y aceite de oliva virgen extra."
    price = 6.50
    imageUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Bocadillo_de_jam%C3%B3n_ib%C3%A9rico.jpg/960px-Bocadillo_de_jam%C3%B3n_ib%C3%A9rico.jpg"
    category = "bocadillos"
    ingredients = @("pan", "tomate", "jamón ibérico", "aceite de oliva")
    ingredientExtraPrices = @{ "tomate" = 0.30; "jamón ibérico" = 2.50; "aceite de oliva" = 0.20 }
    available = $true
    glutenFreeBread = $false
  }
  "boc-tortilla-espanola" = @{
    name = "Bocadillo de Tortilla Española"
    description = "Tortilla de patata casera, jugosa por dentro, en pan crujiente."
    price = 4.00
    imageUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/5/54/Bocadillo_de_tortilla_francesa%2C_pan_con_tomate_%28Espa%C3%B1a%29.jpg/960px-Bocadillo_de_tortilla_francesa%2C_pan_con_tomate_%28Espa%C3%B1a%29.jpg"
    category = "bocadillos"
    ingredients = @("pan", "tortilla de patata", "mahonesa")
    ingredientExtraPrices = @{ "tortilla de patata" = 1.20; "mahonesa" = 0.20 }
    available = $true
    glutenFreeBread = $false
  }
  "boc-calamares" = @{
    name = "Bocadillo de Calamares"
    description = "El clásico de Madrid: calamares rebozados crujientes con un toque de limón."
    price = 5.50
    imageUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Bocata_de_calamares.jpg/960px-Bocata_de_calamares.jpg"
    category = "bocadillos"
    ingredients = @("pan", "calamares", "limón", "mahonesa")
    ingredientExtraPrices = @{ "calamares" = 1.80; "limón" = 0.10; "mahonesa" = 0.20 }
    available = $true
    glutenFreeBread = $false
  }
  "boc-chorizo" = @{
    name = "Bocadillo de Chorizo"
    description = "Chorizo casero a la plancha con pan rústico recién hecho."
    price = 3.50
    imageUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Bocadillo_Chorizo_-_Madrid.JPG/960px-Bocadillo_Chorizo_-_Madrid.JPG"
    category = "bocadillos"
    ingredients = @("pan", "chorizo")
    ingredientExtraPrices = @{ "chorizo" = 0.80 }
    available = $true
    glutenFreeBread = $false
  }
  "boc-lomo-queso" = @{
    name = "Bocadillo de Lomo con Queso"
    description = "Lomo de cerdo adobado a la plancha con queso fundido y tomate."
    price = 5.00
    imageUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/3.-BOCADILLO-LOMO-Y-QUESO-min-scaled.jpg/960px-3.-BOCADILLO-LOMO-Y-QUESO-min-scaled.jpg"
    category = "bocadillos"
    ingredients = @("pan", "lomo", "queso", "tomate")
    ingredientExtraPrices = @{ "lomo" = 1.50; "queso" = 0.80; "tomate" = 0.30 }
    available = $true
    glutenFreeBread = $false
  }
  "boc-atun" = @{
    name = "Bocadillo de Atún"
    description = "Atún con mahonesa, tomate maduro y lechuga fresca."
    price = 3.80
    imageUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Bocadillo_at%C3%BAn.JPG/960px-Bocadillo_at%C3%BAn.JPG"
    category = "bocadillos"
    ingredients = @("pan", "atún", "mahonesa", "tomate", "lechuga")
    ingredientExtraPrices = @{ "atún" = 1.20; "mahonesa" = 0.20; "tomate" = 0.30; "lechuga" = 0.20 }
    available = $true
    glutenFreeBread = $false
  }
  "boc-mixto" = @{
    name = "Bocadillo Mixto"
    description = "El de toda la vida: jamón york y queso fundido en pan tierno."
    price = 3.50
    imageUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Bocadillo_Espa%C3%B1ol.jpg/960px-Bocadillo_Espa%C3%B1ol.jpg"
    category = "bocadillos"
    ingredients = @("pan", "jamón york", "queso")
    ingredientExtraPrices = @{ "jamón york" = 0.80; "queso" = 0.80 }
    available = $true
    glutenFreeBread = $false
  }
  "boc-ternasco" = @{
    name = "Bocadillo de Ternasco"
    description = "Ternasco asado con alioli suave y pimiento verde a la plancha."
    price = 6.00
    imageUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Bocadillo_de_ternasco%2C_alioli_y_pimiento_verde.jpeg/960px-Bocadillo_de_ternasco%2C_alioli_y_pimiento_verde.jpeg"
    category = "bocadillos"
    ingredients = @("pan", "ternasco", "alioli", "pimiento verde")
    ingredientExtraPrices = @{ "ternasco" = 2.00; "alioli" = 0.30; "pimiento verde" = 0.40 }
    available = $true
    glutenFreeBread = $false
  }
  "boc-esparragos" = @{
    name = "Bocadillo de Espárragos"
    description = "Espárragos verdes a la plancha con un toque de mahonesa casera."
    price = 4.20
    imageUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Bocadillo_de_esp%C3%A1rragos_silvestres_%28Espa%C3%B1a%29.jpg/960px-Bocadillo_de_esp%C3%A1rragos_silvestres_%28Espa%C3%B1a%29.jpg"
    category = "bocadillos"
    ingredients = @("pan", "espárragos", "mahonesa")
    ingredientExtraPrices = @{ "espárragos" = 1.00; "mahonesa" = 0.20 }
    available = $true
    glutenFreeBread = $false
  }
}

$json = $products | ConvertTo-Json -Depth 10
$utf8Json = [System.Text.Encoding]::UTF8.GetBytes($json)
Write-Host "Subiendo $(($products.Keys | Measure-Object).Count) bocadillos a /products ..."
try {
  $r = Invoke-RestMethod -Uri "$DB/products.json?auth=$idToken" -Method PUT -Body $utf8Json -ContentType "application/json; charset=utf-8" -TimeoutSec 25
  Write-Host "  Productos escritos OK."
} catch {
  Write-Host "  ERROR escribiendo productos: $($_.Exception.Message)"
  if ($_.ErrorDetails) { Write-Host "  Detalles: $($_.ErrorDetails.Message)" }
}

Write-Host "Listo. Refresca la app para ver los 10 bocadillos."
