#------ Create General Service Offering ------#

function New-GTSServiceOffering {
    Enter-SeUrl "https://langara.teamdynamix.com/SBTDClient/81/askit/Requests/ServiceOfferings/New?ServiceID=$service_ID" -Driver $Driver
    Find-SeElement -Driver $Driver -Wait -Timeout 60 -Id "servicesContent" | Out-null

    # Name
    $CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_txtName"
    Send-SeKeys -Element $CurrentField -Keys "General $ServiceShortName Support"

    # Short Description
    $CurrentField = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_txtShortDescription"
    Send-SeKeys -Element $CurrentField -Keys "If you haven't found the $ServicShortName service that you want, you can submit a General $ServiceShortName Support ticket."

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
    Send-SeKeys -Element $CurrentField -Keys $ServiceShortName

    # Tags
    $tags = @("general", "technical", "support")

    foreach ($tag in $tags) {
        $CurrentField = Find-SeElement -Driver $Driver -Id "s2id_autogen1"
        Send-SeKeys -Element $CurrentField $tag
        $CurrentField = $Driver.FindElements([OpenQA.Selenium.By]::classname("select2-result-selectable")) | Where-Object {$_.Text -eq $tag}
        Invoke-SeClick -Element $CurrentField
    }

    # Save
    $SaveBtn = Find-SeElement -Driver $Driver -Id "ctl00_ctl00_cpContent_cpContent_btnSave"
    Invoke-SeClick -Element $SaveBtn
}