function Get-CurrentLineNumber { # To debug random prints
    $MyInvocation.ScriptLineNumber
}

# Get service name
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

#------ Create Main Service Offering ------#

# Get original service data
$services = Invoke-RestMethod -Method 'Get' -Uri "https://langara.teamdynamix.com/SBTDWebApi/api/81/services" -Headers $auth_headers

if($service_input -notmatch '^\d+$') { # If input is a service name   
    $service_ID = ($services |?{$_.Name -eq $service_input}).ID
} else {
    $service_ID = $service_input
}

$service = Invoke-RestMethod -Method 'Get' -Uri "https://langara.teamdynamix.com/SBTDWebApi/api/81/services/$service_ID" -Headers $auth_headers # Call to the API needs to be done again as $services does not contain all necessary data
#Write-Host ($service | Format-List -Force | Out-String)

#--- Create new offering, fill out and save
$Driver = Start-SeFirefox
Enter-SeUrl "https://langara.teamdynamix.com/SBTDClient/81/askit/Requests/ServiceOfferings/New?ServiceID=$service_ID" -Driver $Driver
Find-SeElement -Driver $Driver -Wait -Timeout 60 -Id "servicesContent" | Out-null

# Copy form and settings from parent service
$Checkbox = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_chkCopyServiceSettings"
Invoke-SeClick -Element $Checkbox

# Name
$CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_txtName"
Send-SeKeys -Element $CurrentField -Keys $service.Name

# Short Description
$CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_txtShortDescription"
Send-SeKeys -Element $CurrentField -Keys $service.ShortDescription

# Long Description
$SourceBtn = Find-SeElement -Wait -Timeout 15 -Driver $Driver -Id "cke_16"
$WebDriverWait = [OpenQA.Selenium.Support.UI.WebDriverWait]::new($Driver, (New-TimeSpan -Seconds 20))
$Condition = [OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementToBeClickable($SourceBtn)
$WebDriverWait.Until($Condition) | Out-null
Invoke-SeClick -Element $SourceBtn
$CurrentField = Find-SeElement -Wait -Timeout 10 -Driver $Driver -XPath '//div[@id="cke_1_contents"]//textarea'
Send-SeKeys -Element $CurrentField -Keys $service.LongDescription

# Request Application Type
$Option = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_ddlRequestApplication"
$SelectElement = [OpenQA.Selenium.Support.UI.SelectElement]::new($Option)
$SelectElement.SelectByValue($service.RequestApplicationID)

# Request Type ID
$CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_taluRequestType_txtinput"
Send-SeKeys -Element $CurrentField -Keys $service.RequestTypeName
$CurrentField = Find-SeElement -Driver $Driver -XPath "//ul[@id='ctl00_ctl00_cpContent_cpContent_taluRequestType_txttaluRequestType_feed']//li[@rel=$($service.RequestTypeID)]"
Invoke-SeClick -Element $CurrentField

# Request Service Offering Text
$CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_txtRequestText"
Send-SeKeys -Element $CurrentField -Keys $($service.RequestText)

# Tags
$tags = @()
do {
    $tag = (Read-Host "Please enter the tags. Enter '-' to finish")
    if ($tag -match '[a-zA-z]') {
        $tags += $tag
    } elseif($tag -ne '-') {
        Write-Host "Tag not added -invalid"
    }
} until ($tag -eq '-')

foreach ($tag in $tags) {
    Write-Host $tag
    $CurrentField = Find-SeElement -Driver $Driver -Id "s2id_autogen1"
    Send-SeKeys -Element $CurrentField $tag
    $CurrentField = $Driver.FindElements([OpenQA.Selenium.By]::classname("select2-result-selectable")) |?{$_.Text -eq $tag}
    Invoke-SeClick -Element $CurrentField
}

# Save
$SaveBtn = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_btnSave"
Invoke-SeClick -Element $SaveBtn

#------ Create General Service Offering ------#

# Enter-SeUrl "https://langara.teamdynamix.com/SBTDClient/81/askit/Requests/ServiceOfferings/New?ServiceID=$service_ID" -Driver $Driver
# Find-SeElement -Driver $Driver -Wait -Timeout 60 -Id "servicesContent" | Out-null