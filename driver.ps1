# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
. "$PSScriptRoot\Modules\ServiceOffering\ServiceOffering.ps1"
. "$PSScriptRoot\Modules\GTSServiceOffering\GTSServiceOffering.ps1"
. "$PSScriptRoot\Modules\AutomationRule\NewAutomationRule.ps1"
. "$PSScriptRoot\functionTester.ps1"
Import-Module "$PSScriptRoot\Modules\Selenium\3.0.1\Selenium.psd1"
Import-Module "$PSScriptRoot\Modules\AnyBox\AnyBox.psd1"

# User prompts
$ProdInput = Show-AnyBox -Message 'Apply changes to:' -Buttons 'Sandbox', 'Production'
if ($ProdInput.Production) {
    $Domain = "https://langara.teamdynamix.com/"
} else {
    $Domain = "https://langara.teamdynamix.com/SB"
}

$prompt = New-AnyBoxPrompt -Name "Name" -Message 'Service name or service ID:' -ValidateNotEmpty
$ServiceNameInput = Show-AnyBox -Prompt $prompt -Buttons 'Submit', 'Cancel' -DefaultButton 'Submit' -CancelButton 'Cancel'
$ServiceName = $ServiceNameInput.Name

$prompt = New-AnyBoxPrompt -Name "Name" -Message 'Short name of the service for general support. This will generate General -shortname- Support:' -ValidateNotEmpty
$ServiceShortNameInput = Show-AnyBox -Prompt $prompt -Buttons 'Submit', 'Cancel' -DefaultButton 'Submit' -CancelButton 'Cancel'
$ServiceShortName = $ServiceShortNameInput.Name

$Prompt = New-AnyBoxPrompt -Name "Num" -Message 'GTS Automation Rule evaluation order:' -ValidateNotEmpty
$EvalOrderInput = Show-AnyBox -Prompt $Prompt -Buttons 'Submit', 'Cancel' -DefaultButton 'Submit' -CancelButton 'Cancel'
$EvalOrder = $EvalOrderInput.Num

if ($ServiceNameInput.Cancel -or $ServiceShortNameInput.Cancel) {
    Show-AnyBox -Message "No service information provided" -Buttons 'Ok'
    Exit
}

# Api connection
$LoginUrl = $Domain + "TDWebApi/api/auth/loginadmin"
$LoginBody = @{
    BEID = "1CC3FF6F-33A6-4148-B145-F5581A4F32BD"
    WebServicesKey = "A7DA41FD-189A-420C-841D-5BD13BAA4B41"
}
$token = Invoke-RestMethod -Method 'Post' -Uri $LoginUrl -Body $LoginBody
$auth_headers = @{
    Authorization="Bearer $token"
}
$Services = Invoke-RestMethod -Method 'Get' -Uri ("$Domain" + "TDWebApi/api/81/services") -Headers $auth_headers

# Service name and ID validation
if($ServiceName -notmatch '^\d+$') { # If input is a service name   
    $ServiceId = ($Services | Where-Object {$_.Name -eq $ServiceName}).ID
} else {
    $ServiceId = $ServiceName
}
$ServiceName = ($Services | Where-Object {$_.ID -eq $ServiceId}).Name
$GTSServiceOfferingName = "General $ServiceShortName Support"

# Start browser
$Driver = Start-SeFirefox
$WindowSize = [System.Drawing.Size]::new(800, 700)
$driver.Manage().Window.Size = $WindowSize

# Create new service offering
$ServiceOfferingId = New-ServiceOffering $ServiceId

# Create new General Technical Support service offering
$GTSServiceOfferingId = New-GTSServiceOffering $ServiceId $GTSServiceOfferingName

# Create GTS Automation Rule
New-AutomationRule $ServiceOfferingId $GTSServiceOfferingId $GTSServiceOfferingName $ServiceName $EvalOrder

# Close driver
Stop-SeDriver -Driver $Driver
