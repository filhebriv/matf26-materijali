# Makes `node`, `npm`, `npx` and `sls` in this PowerShell window run inside Docker.
#
#   Usage (from the project root):  .\bin\activate.ps1
#   Undo:                           close the window
#
# If PowerShell refuses to run scripts, paste this line instead:
#   $env:PATH = "$PWD\bin;$env:PATH"
if (-not (($env:PATH -split ";") -contains $PSScriptRoot)) {
    $env:PATH = "$PSScriptRoot;$env:PATH"
}
Write-Host "node, npm, npx and sls now run inside Docker (this window only)."
