$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location -LiteralPath $root

foreach ($name in @('java', 'python', 'node', 'npm')) {
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)) { throw "Falta $name en PATH." }
}
$javaVersion = (& java -version 2>&1 | Out-String)
if ($javaVersion -notmatch 'version "11') { throw "Se requiere Java 11. Versión detectada: $javaVersion" }
$pythonVersion = (& python --version 2>&1 | Out-String).Trim()
if ($pythonVersion -notmatch '^Python 3\.10\.') { throw "Se requiere Python 3.10. Versión detectada: $pythonVersion" }

$vendor = Join-Path $root 'tools/vendor'
$pythonTarget = Join-Path $vendor 'python'
$agentTarget = Join-Path $vendor 'android-agent'
$framework = Join-Path $vendor 'apktool-framework'
New-Item -ItemType Directory -Path $pythonTarget, $agentTarget, $framework -Force | Out-Null

$apktool = Join-Path $vendor 'apktool_3.0.3.jar'
if (-not (Test-Path $apktool)) {
    $url = 'https://github.com/iBotPeaches/Apktool/releases/download/v3.0.3/apktool_3.0.3.jar'
    Invoke-WebRequest -Uri $url -OutFile $apktool
}
$apktoolHash = (Get-FileHash $apktool -Algorithm SHA256).Hash.ToLowerInvariant()
if ($apktoolHash -ne 'dbf930b076c6b9be08d57c449cacefc3bdd6b71ebd59b3066fc0e1f5b14f9423') {
    throw "SHA-256 de apktool 3.0.3 no válido: $apktoolHash"
}
Write-Host 'Apktool 3.0.3 verificado.' -ForegroundColor Green

$gadget = Join-Path $vendor 'frida-gadget-17.24.3-android-arm64.so'
if (-not (Test-Path $gadget)) {
    $xz = Join-Path $vendor 'frida-gadget-17.24.3-android-arm64.so.xz'
    $url = 'https://github.com/frida/frida/releases/download/17.24.3/frida-gadget-17.24.3-android-arm64.so.xz'
    Invoke-WebRequest -Uri $url -OutFile $xz
    $decompress = 'import lzma,sys; open(sys.argv[2],"wb").write(lzma.decompress(open(sys.argv[1],"rb").read()))'
    python -c $decompress $xz $gadget
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $gadget)) { throw 'No se pudo descomprimir Frida Gadget.' }
    Remove-Item $xz -Force
}
if ((Get-Item $gadget).Length -lt 1000000) { throw 'Frida Gadget parece incompleto.' }
Write-Host 'Frida Gadget 17.24.3 arm64 preparado.' -ForegroundColor Green

$cli = Join-Path $agentTarget 'node_modules/frida-compile/dist/cli.js'
if (-not (Test-Path $cli)) {
    npm install --prefix $agentTarget --save-exact frida-compile@19.1.0
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo instalar frida-compile 19.1.0.' }
}
if (-not (Test-Path $cli)) { throw 'No aparece el CLI de frida-compile tras npm install.' }
Write-Host 'frida-compile 19.1.0 instalado.' -ForegroundColor Green

$cricodecsMarker = Join-Path $pythonTarget 'cricodecs'
if (-not (Test-Path $cricodecsMarker)) {
    python -m pip install --upgrade --target $pythonTarget 'cricodecs==1.2.0'
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo instalar cricodecs 1.2.0.' }
}
$check = 'import sys; sys.path.insert(0,sys.argv[1]); import cricodecs; from cricodecs import cpk,utf; print("CriCodecs listo")'
python -c $check $pythonTarget
if ($LASTEXITCODE -ne 0) { throw 'CriCodecs no expone las interfaces CPK/UTF requeridas.' }
Write-Host ''
Write-Host 'Dependencias auxiliares preparadas en tools/vendor.' -ForegroundColor Green
Write-Host 'Ahora instala Android SDK platform 33/build-tools 36.0.0 y prepara los datos fuente completos de data/ antes de ejecutar build_spanish_test_apk.ps1.'
