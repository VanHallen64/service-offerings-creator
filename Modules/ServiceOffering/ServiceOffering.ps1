#------ Create Main Service Offering ------#

function New-ServiceOffering($ServiceId, $ServiceName) {
    # Get service info
    $Service = Invoke-RestMethod -Method 'Get' -Uri ("$Domain" + "TDWebApi/api/81/services/$ServiceId") -Headers $auth_headers # Call to the API needs to be done again as $Services does not contain all necessary data

    # Get tags from original service (not obtainable from API)
    Enter-SeUrl ("$Domain"+"TDClient/81/askit/Requests/ServiceDet?ID=$ServiceId") -Driver $Driver
    Find-SeElement -Driver $Driver -Wait -Timeout 60 -Id "servicesContent" | Out-null
    $ServiceTagsElements = Find-SeElement -Driver $Driver -XPath "//div[@id='ctl00_ctl00_cpContent_cpContent_divTags']/a"
    $ServiceTags = @()
    foreach ($tag in $ServiceTagsElements) {  
        $tagName = $tag.Text
        $ServiceTags += $tagName
    }
    
    # Start service creation
    Enter-SeUrl ("$Domain"+"TDClient/81/askit/Requests/ServiceOfferings/New?ServiceID=$ServiceId") -Driver $Driver
    Find-SeElement -Driver $Driver -Wait -Timeout 60 -Id "servicesContent" | Out-null
 
    # Copy form and settings from parent service
    $Checkbox = Find-SeElement -Wait -Timeout 3 -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_chkCopyServiceSettings"
    Invoke-SeClick -Element $Checkbox

    # Name
    $CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_txtName"
    Send-SeKeys -Element $CurrentField -Keys $ServiceName

    # Short Description
    $CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_txtShortDescription"
    Send-SeKeys -Element $CurrentField -Keys $Service.ShortDescription

    # Long Description
    $SourceBtn = Find-SeElement -Wait -Timeout 15 -Driver $Driver -Id "cke_16"
    $WebDriverWait = [OpenQA.Selenium.Support.UI.WebDriverWait]::new($Driver, (New-TimeSpan -Seconds 20))
    $Condition = [OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementToBeClickable($SourceBtn)
    $WebDriverWait.Until($Condition) | Out-null
    Invoke-SeClick -Element $SourceBtn
    $CurrentField = Find-SeElement -Wait -Timeout 10 -Driver $Driver -XPath '//div[@id="cke_1_contents"]//textarea'
    Send-SeKeys -Element $CurrentField -Keys $Service.LongDescription

    # Manager
    $CloseBtn = Find-SeElement -Driver $Driver -CssSelector ".closebutton"
    Invoke-SeClick -Element $CloseBtn
    $CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_taluManager_txtinput"
    if ($Service.ManagingGroupID -eq 0) { # If Manager is an individual
        Send-SeKeys -Element $CurrentField -Keys $Service.ManagerFullName
        $CurrentField = Find-SeElement -Driver $Driver -CssSelector "#ctl00_ctl00_cpContent_cpContent_taluManager_txttaluManager_feed > li[rel='$($Service.ManagerUid)']"
    } else { # If Manager is a group
        Send-SeKeys -Element $CurrentField -Keys $Service.ManagingGroupName
        $CurrentField = Find-SeElement -Driver $Driver -CssSelector "#ctl00_ctl00_cpContent_cpContent_taluManager_txttaluManager_feed > li[rel='$($Service.ManagingGroupID)']"
    }
    Invoke-SeClick -Element $CurrentField

    # Request Application Type
    $Option = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_ddlRequestApplication"
    $SelectElement = [OpenQA.Selenium.Support.UI.SelectElement]::new($Option)
    $SelectElement.SelectByValue($Service.RequestApplicationID)

    # Request Type ID
    $CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_taluRequestType_txtinput"
    Send-SeKeys -Element $CurrentField -Keys $Service.RequestTypeName
    $CurrentField = Find-SeElement -Driver $Driver -XPath "//ul[@id='ctl00_ctl00_cpContent_cpContent_taluRequestType_txttaluRequestType_feed']//li[@rel=$($Service.RequestTypeID)]"
    Invoke-SeClick -Element $CurrentField

    # Request Service Offering Text
    $CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_txtRequestText"
    Send-SeKeys -Element $CurrentField -Keys $($Service.RequestText)

    # Tags
    if($ServiceTags.count -gt 0) {
        foreach ($tag in $ServiceTags) {  
            $CurrentField = Find-SeElement -Driver $Driver -Id "s2id_autogen1"
            Send-SeKeys -Element $CurrentField -Keys $tag
            $CurrentField = $Driver.FindElements([OpenQA.Selenium.By]::classname("select2-result-selectable")) | Where-Object {$_.Text -eq $tag}
            Invoke-SeClick -Element $CurrentField
        }
    }

    # Save
    $SaveBtn = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_btnSave"
    Invoke-SeClick -Element $SaveBtn

    # Get newly created service offering ID
    $ServiceOfferingId = Find-SeElement -Wait -Timeout 5 -Driver $Driver -Id "divServiceID"
    $ServiceOfferingId = $ServiceOfferingId.Text
    $ServiceOfferingId = $ServiceOfferingId.Substring(21) # Remove 'Service Offering ID: ' from result

    return $ServiceOfferingId
}