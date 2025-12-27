@echo off
REM MCP Inspector - Interactive Testing for medium-mcp-server
REM This script launches the MCP Inspector UI for interactive testing

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
echo Launching MCP Inspector...
echo UI will be available at http://localhost:6274
echo.

REM Launch MCP Inspector with our server
if "%1"=="--config" (
    npx @modelcontextprotocol/inspector --config "%SCRIPT_DIR%mcp-config.json" --server medium-mcp-server
) else (
    npx @modelcontextprotocol/inspector -e MEDIUM_CLIENT_ID=%MEDIUM_CLIENT_ID% -e MEDIUM_CLIENT_SECRET=%MEDIUM_CLIENT_SECRET% node dist/index.js
)

endlocal
