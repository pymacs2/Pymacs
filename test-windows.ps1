<#
.SYNOPSIS
Test Pymacs with various Emacs versions.
.PARAMETER EmacsVersion
Emacs version to download (if not already) and use
.PARAMETER PythonVersion
Python version to download (if not already) and use
.EXAMPLE
./test-windows.ps1 -EmacsVersion 22.3-bin-i386 -PythonVersion 2.7.18
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)][String]$EmacsVersion,
    [Parameter(Mandatory)][String]$PythonVersion
)

Set-Variable zip -option Constant -value "emacs-$EmacsVersion.zip"
Set-Variable zipUrl -option Constant -value "https://ftpmirror.gnu.org/emacs/windows/emacs-$($EmacsVersion.split('.')[0])/$zip"
Set-Variable msi -option Constant -value "python-$PythonVersion.amd64.msi"
Set-Variable msiUrl -option Constant -value "https://www.python.org/ftp/python/$PythonVersion/$msi"
Set-Variable PPPP -option Constant -value "pppp", "-C", "ppppconfig.py"

function Download-Try-Resume([uri]$url) {
    $file = $url.Segments[-1]
    if (Test-Path -Path $file -PathType Leaf) {
        Write-Output "Found cached $file"
    } else {
        Write-Output "About to download $url"
        & curl.exe -L --progress-bar -C - $url -o "$file.incomplete"
        if ($LastExitCode -ne 0) {
            throw "oopsie!"
        }
        Rename-Item -Path "$file.incomplete" -NewName $file
    }
}


Download-Try-Resume($msiUrl)

if (Test-Path -Path "C:\Python27" -PathType Container) {
    Write-Output "Found existing C:\Python27\ folder. Skipping installation. "
} else {
    Write-Output "Installing $msi"
    $log = "install.log"
    $msiPath = Resolve-Path $msi
    $log = Join-Path (Resolve-Path .) $log
    Start-Process "msiexec" "/i $msiPath /quiet /passive /qn /l*! $log" -NoNewWindow -Wait
}

if (-not $Env:PATH.Contains("C:\Python27")) {
    $Env:PATH = "C:\Python27;C:\Python27\Scripts;" + $Env:PATH
}

Write-Output "Checking Python version"
& python -V

# Download-Try-Resume($zipUrl)
# if (Test-Path -Path "emacs" -PathType Container) {
#     Write-Output "Found unpacked Emacs zip"
# } else {
#     Expand-Archive -LiteralPath $zip -DestinationPath emacs
# }

& python -m pip install --upgrade "pip < 21.0"
& python -m pip install coverage
& python -m pip install .

& python ${PPPP} Pymacs.py.in pppp.rst.in pymacs.el.in pymacs.rst.in contrib tests
Push-Location tests

#$Env:EMACS = "../emacs/bin/emacs"
#$Env:PYMACS_OPTIONS = "-d debug-protocol -s debug-signals"
#$Env:PYTHONUTF8 = 1         # Python 3.7+

& coverage run pytest -f t

Pop-Location
