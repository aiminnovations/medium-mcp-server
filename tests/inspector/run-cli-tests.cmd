@echo off
REM MCP Inspector CLI Tests for medium-mcp-server
REM Automated testing using MCP Inspector CLI mode

setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..\..

REM Load environment variables from .env if exists
if exist "%PROJECT_ROOT%\.env" (
    for /f "usebackq tokens=1,* delims==" %%a in ("%PROJECT_ROOT%\.env") do (
        set "%%a=%%b"
    )
)

REM Build the project first
echo Building the project...
cd /d "%PROJECT_ROOT%"
call npm run build

echo.
echo ========================================
echo   MCP Inspector CLI Tests
echo ========================================
echo.

set PASS=0
set FAIL=0

echo --- Tool Discovery Tests ---

REM Test: List all tools
echo Testing: List all tools...
npx @modelcontextprotocol/inspector --cli node dist/index.js --method tools/list > nul 2>&1
if !errorlevel! equ 0 (
    echo   PASS
    set /a PASS+=1
) else (
    echo   FAIL
    set /a FAIL+=1
)

REM Verbose mode
if "%1"=="--verbose" (
    echo.
    echo --- Verbose Tool Tests ---
    echo.

    echo Testing: List tools (verbose)
    npx @modelcontextprotocol/inspector --cli -e MEDIUM_CLIENT_ID=%MEDIUM_CLIENT_ID% -e MEDIUM_CLIENT_SECRET=%MEDIUM_CLIENT_SECRET% node dist/index.js --method tools/list
    echo.

    echo Testing: Get publications
    npx @modelcontextprotocol/inspector --cli -e MEDIUM_CLIENT_ID=%MEDIUM_CLIENT_ID% -e MEDIUM_CLIENT_SECRET=%MEDIUM_CLIENT_SECRET% node dist/index.js --method tools/call --tool-name get-publications
    echo.
)

echo.
echo ========================================
echo   Test Summary
echo ========================================
echo Passed: %PASS%
echo Failed: %FAIL%
echo.

if %FAIL% gtr 0 exit /b 1

endlocal
