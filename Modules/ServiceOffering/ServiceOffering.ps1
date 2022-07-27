#------ Create Main Service Offering ------#

function New-ServiceOffering {
    
    # Get tags
    Enter-SeUrl "https://langara.teamdynamix.com/SBTDClient/81/askit/Requests/ServiceDet?ID=$service_ID" -Driver $Driver
    $tags = Find-SeElement -Driver $Driver -XPath "//div[@id='ctl00_ctl00_cpContent_cpContent_divTags']/a"
    Write-Host ($ServiceTags | Format-List -Force | Out-String)
    
    Enter-SeUrl "https://langara.teamdynamix.com/SBTDClient/81/askit/Requests/ServiceOfferings/New?ServiceID=$service_ID" -Driver $Driver | Out-null
    Write-Host ($ServiceTags | Format-List -Force | Out-String)
    
    Find-SeElement -Driver $Driver -Wait -Timeout 60 -Id "servicesContent" | Out-null

    # Copy form and settings from parent service
    $Checkbox = Find-SeElement -Wait -Timeout 10 -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_chkCopyServiceSettings"
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

    # Manager
    $CloseBtn = Find-SeElement -Driver $Driver -CssSelector ".closebutton"
    Invoke-SeClick -Element $CloseBtn
    $CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_taluManager_txtinput"
    if ($service.ManagingGroupID -eq 0) { # If Manager is an individual
        Send-SeKeys -Element $CurrentField -Keys $service.ManagerFullName
        $CurrentField = Find-SeElement -Driver $Driver -CssSelector "#ctl00_ctl00_cpContent_cpContent_taluManager_txttaluManager_feed > li[rel='$($service.ManagerUid)']"
    } else { # If Manager is a group
        Send-SeKeys -Element $CurrentField -Keys $service.ManagingGroupName
        $CurrentField = Find-SeElement -Driver $Driver -CssSelector "#ctl00_ctl00_cpContent_cpContent_taluManager_txttaluManager_feed > li[rel='$($service.ManagingGroupID)']"
    }
    Invoke-SeClick -Element $CurrentField

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
    if($tags.count -gt 0) {
        foreach ($tag in $tags) {  
            $tagName = Get-SeElementAttribute -Element $tag -Attribute "title"
            $CurrentField = Find-SeElement -Driver $Driver -Id "s2id_autogen1"
            Send-SeKeys -Element $tagName
            $CurrentField = $Driver.FindElements([OpenQA.Selenium.By]::classname("select2-result-selectable")) | Where-Object {$_.Text -eq $tagName}
            Invoke-SeClick -Element $CurrentField
        }
    }

    # Save
    $SaveBtn = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_btnSave"
    Invoke-SeClick -Element $SaveBtn
}