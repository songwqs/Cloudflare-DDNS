@echo off
setlocal enabledelayedexpansion

:: 配置 Cloudflare API 信息
set ZONE_NAME=主域名
set DOMAIN=子域名（需要先去添加谁便填写一个ip如8.8.8.8 开启仅 DNS）
set TOKEN=API 令牌 （不是Global API Key！！！ 就是编辑区域 DNS的 API 令牌）

:: 获取 Zone ID
for /f "delims=" %%i in ('powershell -Command "Invoke-RestMethod -Uri 'https://api.cloudflare.com/client/v4/zones?name=%ZONE_NAME%' -Headers @{Authorization='Bearer %TOKEN%'} | Select-Object -ExpandProperty result | Select-Object -First 1 | Select-Object -ExpandProperty id"') do (
    set ZONE_ID=%%i
)

:: 获取记录 ID
for /f "delims=" %%i in ('powershell -Command "Invoke-RestMethod -Uri 'https://api.cloudflare.com/client/v4/zones/%ZONE_ID%/dns_records?name=%DOMAIN%' -Headers @{Authorization='Bearer %TOKEN%'} | Select-Object -ExpandProperty result | Select-Object -First 1 | Select-Object -ExpandProperty id"') do (
    set RECORD_ID=%%i
)

:: 获取当前的公网 IP  备用ip.3322.net
for /f "delims=" %%i in ('curl -s https://api.ipify.org') do (
    set PUBLIC_IP=%%i
)

:: 更新 DNS 记录
curl -X PUT "https://api.cloudflare.com/client/v4/zones/%ZONE_ID%/dns_records/%RECORD_ID%" ^
     -H "Authorization: Bearer %TOKEN%" ^
     -H "Content-Type: application/json" ^
     --data "{\"type\":\"A\",\"name\":\"%DOMAIN%\",\"content\":\"%PUBLIC_IP%\",\"ttl\":120,\"proxied\":false}"

echo 更新完成: %DOMAIN% -> %PUBLIC_IP%

