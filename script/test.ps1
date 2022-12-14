#!/usr/bin/env pwsh
#Requires -Version 7

<#
.SYNOPSIS
Test the configuration for each device file.

.PARAMETER File
Optional device file to test.
#>

param (
  [string] $File
)

# Init
Set-StrictMode -version 'Latest'
$ErrorActionPreference = 'Stop'

#
# Utils
#

# Return full name of devices to test
function Get-DeviceFiles {
  Get-ChildItem -Path '.' -Filter 'device.*.yaml' | ForEach-Object { $_.FullName }
}

# Test an individual device
function Test-Device {
  process {
    & esphome config $_

    # Abort on error
    if ($LastExitCode -ne 0) {
      throw "Configuration error for device $_"
    }
  }
}

#
# Main
#

# If needed, restore the secrets.yaml file from the stub
if (-Not (Test-Path -Path 'secrets.yaml')) {
  Copy-Item -Path '.secrets.yaml' -Destination 'secrets.yaml'
}

# Test one device
if ($File -and (Test-Path $File -PathType 'Leaf')) {
  $File | Test-Device
}

# Test all devices
else {
  Get-DeviceFiles | Test-Device
}
