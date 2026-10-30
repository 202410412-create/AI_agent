@echo off
setlocal
chcp 65001 >nul
title Bullet Matrix Server Launcher
cd /d "%~dp0"

echo ===================================================
echo  Bullet Matrix 서버 실행기
echo ===================================================
echo [현재 폴더] %cd%

where node >nul 2>&1
if errorlevel 1 (
    echo [오류] Node.js가 설치되어 있지 않거나 PATH에 등록되지 않았습니다.
    pause
    exit /b 1
)

if not exist "server.js" (
    echo [오류] 현재 폴더에서 server.js를 찾을 수 없습니다.
    pause
    exit /b 1
)

if not exist "node_modules\express" (
    echo [자동 설정] 필요한 모듈을 설치합니다...
    call npm install
    if errorlevel 1 (
        echo [오류] npm install에 실패했습니다.
        pause
        exit /b 1
    )
)

rem 실행할 때마다 미저장 랭킹 임시 기록을 초기화합니다.
type nul > "rank.pending.json"
echo [초기화] rank.pending.json 내용을 비웠습니다.

rem 이미 실행 중인 서버가 정상 응답하면 새로 띄우지 않고 브라우저만 엽니다.
powershell -NoProfile -Command "if ((Invoke-WebRequest -UseBasicParsing -TimeoutSec 2 http://127.0.0.1:3000/).StatusCode -eq 200) { exit 0 } else { exit 1 }" >nul 2>&1
if not errorlevel 1 (
    echo [안내] 서버가 이미 실행 중입니다. 브라우저를 엽니다.
    start "" "http://localhost:3000"
    exit /b 0
)

echo [서버 시작] http://localhost:3000
start "" "http://localhost:3000"
node server.js

if errorlevel 1 (
    echo.
    echo [오류] 서버가 종료되었습니다. 위 오류 내용을 확인해 주세요.
    pause
)

endlocal
