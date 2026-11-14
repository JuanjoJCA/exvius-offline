param(
    [Parameter(Mandatory = $true)]
    [string]$OriginalApk,
    [string]$Version = '0.1.32-es-test',
    [string]$ClientVersion = '9.0.0-es-test.1',
    [int]$VersionCode = 9016,
    [string]$DataTag = 'v0.1.32-es-test',
    [int]$DataRevision = 12,
    [string]$KeyStore = 'tools/vendor/exvius-test.jks',
    [string]$KeyAlias = 'exvius-test'
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location -LiteralPath $root
$originalHash = '955deacfbe4b3d0cd04e2947eb005e310915ba98132d71216626bfb3554ad246'
$original = (Resolve-Path -LiteralPath $OriginalApk).Path
$actualHash = (Get-FileHash -LiteralPath $original -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualHash -ne $originalHash) { throw "El APK original no coincide. SHA-256 recibido: $actualHash" }
Write-Host 'APK original verificado.' -ForegroundColor Green

function Require-File([string]$Path, [string]$Purpose) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw ($Purpose + ': ' + $Path + ' no encontrado') }
}
function Require-Directory([string]$Path, [string]$Purpose) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { throw ($Purpose + ': ' + $Path + ' no encontrado') }
}
function Require-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) { throw "No se encuentra '$Name' en PATH." }
}

Require-Command java
Require-Command javac
Require-Command python
Require-Command node
Require-Command keytool
$javaVersion = (& java -version 2>&1 | Out-String)
if ($javaVersion -notmatch 'version "11') { throw "Se requiere Java 11. Versión detectada: $javaVersion" }
$pythonVersion = (& python --version 2>&1 | Out-String).Trim()
if ($pythonVersion -notmatch '^Python 3\.10\.') { throw "Se requiere Python 3.10. Versión detectada: $pythonVersion" }
if (-not $env:ANDROID_HOME) { throw 'Define ANDROID_HOME con la ruta del Android SDK.' }
$sdk = $env:ANDROID_HOME
Require-File (Join-Path $sdk 'platforms/android-33/android.jar') 'Android SDK Platform 33'
Require-File (Join-Path $sdk 'build-tools/36.0.0/d8.bat') 'Android Build Tools 36.0.0'
Require-File (Join-Path $sdk 'build-tools/36.0.0/zipalign.exe') 'zipalign'
Require-File (Join-Path $sdk 'build-tools/36.0.0/apksigner.bat') 'apksigner'
Require-File 'source/memorial/android/gradle/wrapper/gradle-wrapper.jar' 'Gradle Wrapper'
Require-File 'tools/vendor/apktool_3.0.3.jar' 'apktool 3.0.3'
Require-File 'tools/vendor/frida-gadget-17.24.3-android-arm64.so' 'Frida Gadget 17.24.3 arm64'
Require-File 'tools/vendor/android-agent/node_modules/frida-compile/dist/cli.js' 'frida-compile'
Require-Directory 'tools/vendor/python' 'dependencias Python del proyecto'
New-Item -ItemType Directory -Path 'tools/vendor/apktool-framework' -Force | Out-Null
Require-Directory 'data/memorial' 'datos originales Memorial'
Require-Directory 'data/client/files' 'caché Global original'
Require-Directory 'data/mst_decoded' 'tablas MST decodificadas'
Require-Directory 'data/overlay' 'carpeta de overlays'

$pythonCheck = @'
import sys
sys.path.insert(0, "tools/vendor/python")
import cricodecs
print("cricodecs disponible")
'@
python -c $pythonCheck
if ($LASTEXITCODE -ne 0) { throw 'No está disponible cricodecs en tools/vendor/python.' }

$vendor = (Resolve-Path 'tools/vendor').Path
if (-not $env:JAVA_HOME) { $env:JAVA_HOME = Split-Path (Split-Path (Get-Command java).Source -Parent) -Parent }
$env:PYTHONUTF8 = '1'
$env:PYTHONDONTWRITEBYTECODE = '1'
$env:PYTHONPATH = (Join-Path $vendor 'python') + ';' + (Join-Path $root 'source/exvius') + ';' + (Join-Path $root 'source/server')

$snapshotDir = Join-Path $root 'repository snapshots'
New-Item -ItemType Directory -Path $snapshotDir -Force | Out-Null
$stagedOriginal = Join-Path $snapshotDir 'FFBE-Global-v9.0.0-original.apk'
if (Test-Path -LiteralPath $stagedOriginal) {
    $stagedHash = (Get-FileHash -LiteralPath $stagedOriginal -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($stagedHash -ne $originalHash) { throw 'Ya existe una copia distinta del APK original en repository snapshots.' }
} else { Copy-Item -LiteralPath $original -Destination $stagedOriginal }

$apktool = Join-Path $vendor 'apktool_3.0.3.jar'
$framework = Join-Path $vendor 'apktool-framework'
$client = Join-Path $root 'source/build/android/client'
$decoded = Join-Path $root 'source/build/android/decoded-code'
New-Item -ItemType Directory -Path (Split-Path $client -Parent) -Force | Out-Null
if (Test-Path $client) { Remove-Item -LiteralPath $client -Recurse -Force }
if (Test-Path $decoded) { Remove-Item -LiteralPath $decoded -Recurse -Force }

Write-Host 'Decodificando recursos y manifiesto del cliente...' -ForegroundColor Cyan
java -jar $apktool d --no-src -f $stagedOriginal -p $framework -o $client
if ($LASTEXITCODE -ne 0) { throw 'Falló la decodificación de recursos con apktool.' }
Write-Host 'Decodificando código smali original...' -ForegroundColor Cyan
java -jar $apktool d -f $stagedOriginal -p $framework -o $decoded
if ($LASTEXITCODE -ne 0) { throw 'Falló la decodificación smali con apktool.' }
Require-File (Join-Path $decoded 'smali/com/square_enix/android_googleplay/FFBEWW/GooglePlayLapis.smali') 'código smali del cliente original'

Write-Host 'Ejecutando pruebas de localización...' -ForegroundColor Cyan
python -m py_compile source/exvius/fill_content_from_memorial.py tools/test_spanish_localizer.py
if ($LASTEXITCODE -ne 0) { throw 'Falló la comprobación de sintaxis Python.' }
python tools/test_spanish_localizer.py
if ($LASTEXITCODE -ne 0) { throw 'Fallaron las pruebas del localizador español.' }

Write-Host 'Aplicando los diálogos españoles a los CPK que se empaquetarán...' -ForegroundColor Cyan
python source/exvius/fill_content_from_memorial.py --out data/overlay --repair-text
if ($LASTEXITCODE -ne 0) { throw 'Falló la preparación de los CPK localizados.' }

Write-Host 'Generando paquetes de datos con los CPK localizados...' -ForegroundColor Cyan
$assets = Join-Path $root 'source/build/distribution/assets'
New-Item -ItemType Directory -Path $assets -Force | Out-Null
python source/exvius/build_release_data.py --output $assets --tag $DataTag --revision $DataRevision
if ($LASTEXITCODE -ne 0) { throw 'Falló la generación de paquetes de datos.' }

foreach ($test in @('source/exvius/test_android_display.js', 'source/exvius/test_home_carousel.js', 'source/exvius/test_summon_art.js')) {
    node $test
    if ($LASTEXITCODE -ne 0) { throw ("Falló la prueba: " + $test) }
}
python source/exvius/test_release_data.py
if ($LASTEXITCODE -ne 0) { throw 'Falló la validación de los paquetes de datos.' }

if (-not (Test-Path -LiteralPath $KeyStore)) {
    Write-Host 'No existe el almacén de firma de prueba. Se creará uno local; guarda bien la contraseña.' -ForegroundColor Yellow
    $secure = Read-Host 'Contraseña nueva para el keystore (mínimo 6 caracteres)' -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try { $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
    if ($password.Length -lt 6) { throw 'La contraseña del keystore debe tener al menos 6 caracteres.' }
    $env:EXVIUS_KEYSTORE_PASSWORD = $password
    New-Item -ItemType Directory -Path (Split-Path $KeyStore -Parent) -Force | Out-Null
    keytool -genkeypair -v -keystore $KeyStore -alias $KeyAlias -keyalg RSA -keysize 3072 -validity 10000 -dname 'CN=Exvius Offline Spanish Test' -storepass $password -keypass $password
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo crear el keystore de prueba.' }
} else {
    $secure = Read-Host 'Contraseña del keystore de prueba' -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try { $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
    $env:EXVIUS_KEYSTORE_PASSWORD = $password
}

Write-Host 'Compilando, firmando y verificando la APK...' -ForegroundColor Cyan
& (Join-Path $root 'source/exvius/build_distribution.ps1') -Version $Version -ClientVersion $ClientVersion -VersionCode $VersionCode -KeyStore $KeyStore -KeyAlias $KeyAlias
if ($LASTEXITCODE -ne 0) { throw 'Falló el proceso de distribución Android.' }

$output = Join-Path $root 'source/build/distribution/assets' ("exvius-offline-v" + $Version + '.apk')
Require-File $output 'APK compilada'
$verify = & (Join-Path $sdk 'build-tools/36.0.0/apksigner.bat') verify --verbose $output 2>&1
if ($LASTEXITCODE -ne 0) { throw "La firma de la APK no es válida: $verify" }
$finalHash = (Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host ''
Write-Host 'APK COMPILADA Y FIRMA VERIFICADA' -ForegroundColor Green
Write-Host "Archivo: $output"
Write-Host "Tamaño: $((Get-Item $output).Length) bytes"
Write-Host "SHA-256: $finalHash"
Write-Host 'Los paquetes de datos localizados están en source/build/distribution/assets.'
Write-Host 'Publica los paquetes de datos del tag indicado antes de habilitar su descarga remota.'
