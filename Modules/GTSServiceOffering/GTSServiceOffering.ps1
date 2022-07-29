#------ Create General Service Offering ------#

function New-GTSServiceOffering($ServiceId, $GTSServiceOfferingName) {
    Enter-SeUrl ("$Domain"+"TDClient/81/askit/Requests/ServiceOfferings/New?ServiceID=$ServiceId") -Driver $Driver
    Find-SeElement -Driver $Driver -Wait -Timeout 60 -Id "servicesContent" | Out-null

    # Name
    $CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_txtName"
    Send-SeKeys -Element $CurrentField -Keys $GTSServiceOfferingName

    # Short Description
    $CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_txtShortDescription"
    Send-SeKeys -Element $CurrentField -Keys "If you haven't found the $ServicShortName service that you want, you can submit a $GTSServiceOfferingName ticket."

    # Long Description
    $SourceBtn = Find-SeElement -Wait -Timeout 15 -Driver $Driver -Id "cke_16"
    $WebDriverWait = [OpenQA.Selenium.Support.UI.WebDriverWait]::new($Driver, (New-TimeSpan -Seconds 20))
    $Condition = [OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementToBeClickable($SourceBtn)
    $WebDriverWait.Until($Condition) | Out-null
    Invoke-SeClick -Element $SourceBtn
    $CurrentField = Find-SeElement -Wait -Timeout 10 -Driver $Driver -XPath '//div[@id="cke_1_contents"]//textarea'
    Send-SeKeys -Element $CurrentField -Keys "If you haven't found the $ServicShortName service that you want, you can submit a $GTSServiceOfferingName ticket."
    
    # Order
    $CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_txtOrder"
    $CurrentField.SendKeys([OpenQA.Selenium.Keys]::Up)

    # Manager
    $CloseBtn = Find-SeElement -Driver $Driver -CssSelector ".closebutton"
    Invoke-SeClick -Element $CloseBtn
    $CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_taluManager_txtinput"
    Send-SeKeys -Element $CurrentField -Keys "Client Services - Leadership"
    $CurrentField = Find-SeElement -Driver $Driver -CssSelector "#ctl00_ctl00_cpContent_cpContent_taluManager_txttaluManager_feed > li[rel='216']"
    Invoke-SeClick -Element $CurrentField

    # Request Application Type
    $Option = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_ddlRequestApplication"
    $SelectElement = [OpenQA.Selenium.Support.UI.SelectElement]::new($Option)
    $SelectElement.SelectByValue("82")

    # Request Type ID
    $CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_taluRequestType_txtinput"
    Send-SeKeys -Element $CurrentField -Keys "IT Service Delivery and Support"
    $CurrentField = Find-SeElement -Driver $Driver -XPath "//ul[@id='ctl00_ctl00_cpContent_cpContent_taluRequestType_txttaluRequestType_feed']//li[@rel='757']"
    Invoke-SeClick -Element $CurrentField

    # Request Service Offering Text
    $CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_txtRequestText"
    Send-SeKeys -Element $CurrentField -Keys $GTSServiceOfferingName

    # Tags
    $GeneralTags = @("general", "technical", "support", "GTS")

    foreach ($tag in $GeneralTags) {
        $CurrentField = Find-SeElement -Driver $Driver -Id "s2id_autogen1"
        Send-SeKeys -Element $CurrentField $tag
        $CurrentField = $Driver.FindElements([OpenQA.Selenium.By]::classname("select2-result-selectable")) | Where-Object {$_.Text -eq $tag}
        Invoke-SeClick -Element $CurrentField
    }

    # Save service
    $SaveBtn = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_btnSave"
    Invoke-SeClick -Element $SaveBtn

    # Get newly created service offering ID
    $GTSServiceId = Find-SeElement -Wait -Timeout 5 -Driver $Driver -Id "divServiceID"
    $GTSServiceId = $GTSServiceId.Text
    $GTSServiceId = $GTSServiceId.Substring(21) # Remove 'Service Offering ID: ' from result

    # Select form
    $EditBtn = Find-SeElement -Driver $Driver -Wait -Timeout 60 -XPath "//span[@id='ctl00_ctl00_cpContent_cpContent_lnkEdit']/a"
    Invoke-SeClick -Element $EditBtn
    $FormBtn = Find-SeElement -Driver $Driver -Wait -Timeout 60 -XPath "//a[text()='Form']"
    Invoke-SeClick -Element $FormBtn
    $SelectFormRadio = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_ctl00_cpContent_cpContent_cpContent_rbUseExistingForm"
    Invoke-SeClick -Element $SelectFormRadio
    $Option = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_ctl00_cpContent_cpContent_cpContent_ddlRequestForm"
    $SelectElement = [OpenQA.Selenium.Support.UI.SelectElement]::new($Option)
    $SelectElement.SelectByValue(375) # 'Request a Service' form ID is 375

    # Save form
    $SaveBtn = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_ctl00_cpContent_cpContent_cpContent_btnSaveNew"
    Invoke-SeClick -Element $SaveBtn

    return $GTSServiceId
}