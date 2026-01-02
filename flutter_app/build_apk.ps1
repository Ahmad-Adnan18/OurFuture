# Flutter APK Build Script - Force JDK 17

Write-Host "=== Flutter APK Builder (JDK 17 Forced) ===" -ForegroundColor Cyan

# Set environment
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot\"
$env:PATH = "$env:JAVA_HOME\bin;" + $env:PATH

# Verify
Write-Host "Java Version Check:" -ForegroundColor Yellow
java -version
Write-Host ""

# Kill all Java processes to clear Gradle daemon
Write-Host "Killing all Java/Gradle processes..." -ForegroundColor Yellow
Stop-Process -Name "java" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Build
Write-Host "Building APK with JDK 17..." -ForegroundColor Yellow
Write-Host "(gradle.properties sudah di-set untuk pakai JDK 17)" -ForegroundColor Gray
Write-Host ""

flutter build apk --release --verbose | Select-String -Pattern "jlink|BUILD|FAILURE|Using Java" -Context 0,2

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=== SUCCESS ===" -ForegroundColor Green
    Write-Host "APK: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Green
} else {
    Write-Host "`n=== FAILED ===" -ForegroundColor Red
    Write-Host "Cek error di atas untuk detail" -ForegroundColor Yellow
}
