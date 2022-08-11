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

$PromptBox = New-Object AnyBox.AnyBox
$PromptBox.Title = 'Service Creator'
$PromptBox.Prompts = @(
    New-AnyBoxPrompt -Name "ServiceName" -Message 'Service name or service ID to copy from:' -ValidateNotEmpty
    New-AnyBoxPrompt -Name "ServiceOfferingName" -Message 'Name of the new service offering:' -ValidateNotEmpty
    New-AnyBoxPrompt -Name "GTSOfferingName" -Message 'Short name of general support service offering. This will generate General -shortname- Support:' -ValidateNotEmpty
    New-AnyBoxPrompt -Name "EvalOrder" -Message 'GTS Automation Rule evaluation order:' -ValidateNotEmpty
)
$PromptBox.Buttons = @(
    New-AnyBoxButton -Text 'Submit' -IsDefault
    New-AnyBoxButton -Text 'Cancel' -IsCancel
)
$UserInput = $PromptBox | Show-AnyBox

$ServiceName = $UserInput.ServiceName
$ServiceShortName = $UserInput.GTSOfferingName
$EvalOrder = $UserInput.EvalOrder

if ($UserInput.Cancel) {
    Show-AnyBox -Message "Operation cancelled" -Buttons 'Ok'
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
$ServiceOfferingId = New-ServiceOffering $ServiceId $ServiceName

# Create new General Technical Support service offering
$GTSServiceOfferingId = New-GTSServiceOffering $ServiceId $GTSServiceOfferingName

# Create GTS Automation Rule
New-AutomationRule $ServiceOfferingId $GTSServiceOfferingId $GTSServiceOfferingName $ServiceName $EvalOrder

# Stop driver
Stop-SeDriver -Driver $Driver
Show-AnyBox -Message "Service created" -Button "Ok" -DefaultButton "Ok"
