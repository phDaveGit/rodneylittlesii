<#
.SYNOPSIS
This is a Powershell script to bootstrap a Cake build.
.DESCRIPTION
This Powershell script will download NuGet if missing, restore NuGet tools (including Cake)
and execute your Cake build script with the parameters you provide.
.PARAMETER Target
The build script target to run.
.PARAMETER Configuration
The build configuration to use.
.PARAMETER Verbosity
Specifies the amount of information to be displayed.
.PARAMETER WhatIf
Performs a dry run of the build script.
No tasks will be executed.
.PARAMETER ScriptArgs
Remaining arguments are added here.
.LINK
https://cakebuild.net
#>

[CmdletBinding()]
Param(
    [string]$Target = "Default",
    [ValidateSet("Release", "Debug")]
    [string]$Configuration = "Release",
    [ValidateSet("Quiet", "Minimal", "Normal", "Verbose", "Diagnostic")]
    [string]$Verbosity = "Verbose",
    [switch]$WhatIf,
    [Parameter(Position=0,Mandatory=$false,ValueFromRemainingArguments=$true)]
    [string[]]$ScriptArgs
)

$CakeVersion = "0.32.1";
$WyamVersion = "2.1.3";
$DotNetChannel = "preview";
$DotNetVersion = "2.1.500";
$DotNetInstallerUri = "https://dot.net/v1/dotnet-install.ps1";

# Make sure tools folder exists
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$ToolPath = [Environment]::GetEnvironmentVariable("CAKE_TOOLS_PATH", "User")

if($ToolPath -eq $null)
{
    $ToolPath = Join-Path $PSScriptRoot "tools"
}

if (!(Test-Path $ToolPath)) {
    Write-Verbose "Creating tools directory..."
    New-Item -Path $ToolPath -Type directory | out-null
}

Function Remove-PathVariable([string]$VariableToRemove)
{
    $path = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($path -ne $null)
    {
        $newItems = $path.Split(';', [StringSplitOptions]::RemoveEmptyEntries) | Where-Object { "$($_)" -inotlike $VariableToRemove }
        [Environment]::SetEnvironmentVariable("PATH", [System.String]::Join(';', $newItems), "User")
    }

    $path = [Environment]::GetEnvironmentVariable("PATH", "Process")
    if ($path -ne $null)
    {
        $newItems = $path.Split(';', [StringSplitOptions]::RemoveEmptyEntries) | Where-Object { "$($_)" -inotlike $VariableToRemove }
        [Environment]::SetEnvironmentVariable("PATH", [System.String]::Join(';', $newItems), "Process")
    }
}

###########################################################################
# INSTALL .NET CORE CLI
###########################################################################

# Get .NET Core CLI path if installed.
$FoundDotNetCliVersion = $null;
if (Get-Command dotnet -ErrorAction SilentlyContinue) {
    $FoundDotNetCliVersion = dotnet --version;
}

if($FoundDotNetCliVersion -ne $DotNetVersion) {
    $InstallPath = Join-Path $PSScriptRoot ".dotnet"
    if (!(Test-Path $InstallPath)) {
        mkdir -Force $InstallPath | Out-Null;
    }
    (New-Object System.Net.WebClient).DownloadFile($DotNetInstallerUri, "$InstallPath\dotnet-install.ps1");
    & $InstallPath\dotnet-install.ps1 -Channel $DotNetChannel -Version $DotNetVersion -InstallDir $InstallPath;

    Remove-PathVariable "$InstallPath"
    $env:PATH = "$InstallPath;$env:PATH"
    $env:DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
    $env:DOTNET_CLI_TELEMETRY_OPTOUT=1
}

###########################################################################
# INSTALL WYAM
###########################################################################

# Get Wyam path if installed.
$FoundWyamVersion = $null;
if (Get-Command wyam -ErrorAction SilentlyContinue) {
    $FoundWyamVersion = wyam --version;
}

$InstallPath = Join-Path $PSScriptRoot ".dotnet\tools"
if (!(Test-Path $InstallPath)) {
    mkdir -Force $InstallPath | Out-Null;
}

if($FoundWyamVersion -ne $WyamVersion) {
    Write-Host "Installing Wyam..."
    Invoke-Expression "dotnet tool install -g Wyam.Tool --version $WyamVersion"
}

###########################################################################
# INSTALL CAKE
###########################################################################

# Make sure Cake has been installed.
$CakePath = Join-Path $ToolPath "Cake.$CakeVersion/Cake.exe"
if (!(Test-Path $CakePath)) {
    Write-Host "Installing Cake..."
    Invoke-Expression "dotnet tool install -g Cake.Tool --version $CakeVersion"
}

###########################################################################
# RUN BUILD SCRIPT
###########################################################################

# Build the argument list.
$Arguments = @{
    target=$Target;
    configuration=$Configuration;
    verbosity=$Verbosity;
    dryrun=$WhatIf;
}.GetEnumerator() | %{"--{0}=`"{1}`"" -f $_.key, $_.value };

# Start Cake
Write-Host "Running build script..."
Invoke-Expression "dotnet-cake `"build.cake`" $Arguments $ScriptArgs"
exit $LASTEXITCODE