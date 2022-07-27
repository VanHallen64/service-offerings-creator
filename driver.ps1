. "$PSScriptRoot\Modules\ServiceOffering\ServiceOffering.ps1"
. "$PSScriptRoot\Modules\GTSServiceOffering\GTSServiceOffering.ps1"
. "$PSScriptRoot\functionTester.ps1"
Import-Module "$PSScriptRoot\Modules\Selenium\3.0.1\Selenium.psd1"

# Get service name
$ServiceInput = Read-Host "Enter service name or service ID"

# Short name for General Support
$ServiceShortName = Read-Host "Enter a short name for the service for general support"

# Api connection
$LoginUrl = "https://langara.teamdynamix.com/SBTDWebApi/api/auth/loginadmin"
$LoginBody = @{
    BEID = "1CC3FF6F-33A6-4148-B145-F5581A4F32BD"
    WebServicesKey = "A7DA41FD-189A-420C-841D-5BD13BAA4B41"
}
$token = Invoke-RestMethod -Method 'Post' -Uri $LoginUrl -Body $LoginBody
$auth_headers = @{
    Authorization="Bearer $token"
}
$Services = Invoke-RestMethod -Method 'Get' -Uri "https://langara.teamdynamix.com/SBTDWebApi/api/81/services" -Headers $auth_headers

# Get original service data
if($ServiceInput -notmatch '^\d+$') { # If input is a service name   
    $service_ID = ($Services | Where-Object {$_.Name -eq $ServiceInput}).ID
} else {
    $service_ID = $ServiceInput
}
$service = Invoke-RestMethod -Method 'Get' -Uri "https://langara.teamdynamix.com/SBTDWebApi/api/81/services/$service_ID" -Headers $auth_headers # Call to the API needs to be done again as $Services does not contain all necessary data
# Write-Host ($service | Format-List -Force | Out-String)

# Start browser
$Driver = Start-SeFirefox
$WindowSize = [System.Drawing.Size]::new(800, 700)
$driver.Manage().Window.Size = $WindowSize

# Create new service offering
New-ServiceOffering

# Open new tab
$Driver.ExecuteScript("window.open()")
$Windows = Get-SeWindow -Driver $Driver
Switch-SeWindow -Driver $Driver -Window $Windows[1]

# Create new General Technical Support service offering
New-GTSServiceOffering

# Close driver
Stop-SeDriver -Driver $Driver
