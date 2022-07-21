#Get service name
$service_input= Read-Host "Enter service name or service ID"

$LoginUrl = "https://langara.teamdynamix.com/SBTDWebApi/api/auth/loginadmin"
$LoginBody = @{
    BEID = "1CC3FF6F-33A6-4148-B145-F5581A4F32BD"
    WebServicesKey = "A7DA41FD-189A-420C-841D-5BD13BAA4B41"
}
$token = Invoke-RestMethod -Method 'Post' -Uri $LoginUrl -Body $LoginBody
$auth_headers = @{
    Authorization="Bearer $token"
}

# Get service data
$services = Invoke-RestMethod -Method 'Get' -Uri "https://langara.teamdynamix.com/SBTDWebApi/api/81/services" -Headers $auth_headers

if($service_input -notmatch '^\d+$') { # If input is a service name   
    $service_ID = ($services |?{ $_.Name -eq $service_input}).ID
} else {
    $service_ID = $service_input
}

$service = Invoke-RestMethod -Method 'Get' -Uri "https://langara.teamdynamix.com/SBTDWebApi/api/81/services/$service_ID" -Headers $auth_headers
Write-Host $service_ID
Write-Host ($service | Format-List -Force | Out-String)
$fields = @{
    name=$service.Name
    shortDescription=$service.ShortDescription
    longDescription=$service.LongDescription
    requestApplicationID=$service.RequestApplicationID
    requestTypeID=$service.RequestTypeID
    requestTypeName=$service.RequestTypeName
    requestText=$service.RequestText
}

# New offering, fill out and save
$Driver = Start-SeFirefox
Enter-SeUrl "https://langara.teamdynamix.com/SBTDClient/81/askit/Requests/ServiceOfferings/New?ServiceID=$service_ID" -Driver $Driver
Find-SeElement -Driver $Driver -Wait -Timeout 60 -Id "servicesContent" | Out-null

### Name
$CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_txtName"
Send-SeKeys -Element $CurrentField -Keys $fields.name

### Short Description
$CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_txtShortDescription"
Send-SeKeys -Element $CurrentField -Keys $fields.shortDescription

### Long Description
$SourceBtn = Find-SeElement -Wait -Timeout 15 -Driver $Driver -Id "cke_16"
Write-Host ($SourceBtn | Format-List -Force | Out-String) # Makes btn usable
Invoke-SeClick -Element $SourceBtn
$CurrentField = Find-SeElement -Driver $Driver -XPath '/html/body/form/main/div/div[2]/div/div/div[4]/div/div/div/textarea'
Send-SeKeys -Element $CurrentField -Keys $fields.longDescription

### Request Application Type
$Option = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_ddlRequestApplication"
$SelectElement = [OpenQA.Selenium.Support.UI.SelectElement]::new($Option)
$SelectElement.SelectByValue($fields.requestApplicationID)

### Request Type ID
$CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_taluRequestType_txtinput"
Send-SeKeys -Element $CurrentField -Keys $fields.requestTypeName
$CurrentField = Find-SeElement -Driver $Driver -XPath "/html/body/form/main/div/div[2]/div/div/div[10]/div[2]/div/div/div/div[2]/ul/li"
Invoke-SeClick -Element $CurrentField

## Request Service Offering Text
$CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_txtRequestText"
Send-SeKeys -Element $CurrentField -Keys "General $($fields.requestText) Support"

## Save
$SaveBtn = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_btnSave"
Invoke-SeClick -Element $SaveBtn

Stop-SeDriver