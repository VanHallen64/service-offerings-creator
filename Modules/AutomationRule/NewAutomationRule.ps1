#------ Create General Service Offering ------#

function New-AutomationRule($ServiceOfferingId, $GTSServiceOfferingId, $GTSServiceOfferingName, $ServiceName, $EvalOrder) {
    # Get form name
    Enter-SeUrl ("$Domain"+"TDClient/81/askit/Requests/ServiceOfferingDet?ID=$ServiceOfferingId") -Driver $Driver
    $EditBtn = Find-SeElement -Wait -Timeout 60 -Driver $Driver -XPath "//span[@id='ctl00_ctl00_cpContent_cpContent_lnkEdit']//a"
    Invoke-SeClick -Element $EditBtn
    $GoToForm = Find-SeElement -Driver $Driver -XPath "//ul[@class='nav nav-shelf']//li//a[contains(@href,'Form')]"
    Invoke-SeClick -Element $GoToForm
    $FormName = Find-SeElement -Driver $Driver -XPath "//div[@id='ctl00_ctl00_ctl00_cpContent_cpContent_cpContent_divSettingsPanel']/h2"
    $FormName = $FormName.Text
    
    # Get responsible ID
    Enter-SeUrl ("$Domain"+"TDAdmin/1CC3FF6F-33A6-4148-B145-F5581A4F32BD/82/Service/Forms.aspx?ComponentID=9") -Driver $Driver
    $CurrentField = Find-SeElement -Driver $Driver -Id "txtSearch"
    Send-SeKeys -Element $CurrentField -Keys $FormName
    $SearchBtn = Find-SeElement -Driver $Driver -Id "btnSearch"
    Invoke-SeClick -Element $SearchBtn
    $SelectForm = Find-SeElement -Driver $Driver -XPath "//td//a[contains(text(),'$FormName')]"
    Invoke-SeClick -Element $SelectForm
    $Windows = Get-SeWindow -Driver $Driver
    Switch-SeWindow -Driver $Driver -Window $Windows[1]
    $ResponsibleId = Find-SeElement -Driver $Driver -Id "a_1279-value"
    $ResponsibleId = Get-SeElementAttribute -Element $ResponsibleId -Attribute "value"

    # Get responsible name
    try {
        $Responsible = Invoke-RestMethod -Method 'Get' -Uri ("$Domain" + "TDWebApi/api/groups/$ResponsibleId") -Headers $auth_headers
    }
    catch {
        $Responsible = Invoke-RestMethod -Method 'Get' -Uri ("$Domain" + "TDWebApi/api/people/$ResponsibleId") -Headers $auth_headers
    }
    $Responsible = $Responsible.Name
    $Driver.Close()
    Switch-SeWindow -Driver $Driver -Window $Windows[0]

    # New rule
    Enter-SeUrl ("$Domain"+"TDAdmin/1cc3ff6f-33a6-4148-b145-f5581a4f32bd/82/AutomationRules/Index?Component=9") -Driver $Driver
    $NewBtn = Find-SeElement -Wait -Timeout 60 -Driver $Driver -XPath '//a[@class="btn btn-primary"]'
    Invoke-SeClick -Element $NewBtn

    # Name
    $CurrentField = Find-SeElement -Driver $Driver -Id "Name"
    Send-SeKeys -Element $CurrentField -Keys "GTS $ServiceName - Assign to $Responsible"

    # Order
    $CurrentField = Find-SeElement -Driver $Driver -Id "Order"
    $CurrentField.SendKeys([OpenQA.Selenium.Keys]::Backspace)
    Send-SeKeys -Element $CurrentField -Keys $EvalOrder

    # Stop on Match
    $Checkbox = Find-SeElement -Wait -Timeout 10 -Driver $Driver -Id "ShouldStopOnMatch"
    Invoke-SeClick -Element $Checkbox

    # Description
    $CurrentField = Find-SeElement -Driver $Driver -Id "Description"
    Send-SeKeys -Element $CurrentField -Keys "This rule assigns General Technical Support tickets created under the $ServiceName service to $Responsible."

    # Save
    $SaveBtn = Find-SeElement -Driver $Driver -XPath '//div[@id="divButtons"]//button//span[text()="Save"]'
    Invoke-SeClick -Element $SaveBtn

    # Edit
    $EditBtn = Find-SeElement -Wait -Timeout 60 -Driver $Driver -XPath '//button[@class="btn btn-primary"]'
    Invoke-SeClick -Element $EditBtn

    # Is Active
    $Checkbox = Find-SeElement -Wait -Timeout 10 -Driver $Driver -Id "Rule_IsActive"
    Invoke-SeClick -Element $Checkbox

    # Automation Conditions
    $Option = Find-SeElement -Driver $Driver -Id "filter_column_0"
    $SelectElement = [OpenQA.Selenium.Support.UI.SelectElement]::new($Option)
    $SelectElement.SelectByValue(5315)
    $CurrentField = Find-SeElement -Driver $Driver -Id "lu_text_0"
    $SearchBtn = Find-SeElement -Driver $Driver -XPath "//table//tbody//tr//td//div//span//a[@data-textid='lu_text_0']"
    Invoke-SeClick -Element $SearchBtn
    $Windows = Get-SeWindow -Driver $Driver
    Switch-SeWindow -Driver $Driver -Window $Windows[1]
    $CurrentField = Find-SeElement -Wait -Timeout 3 -Driver $Driver -Id "searchText"
    Send-SeKeys -Element $CurrentField -Keys $GTSServiceOfferingName
    $SearchBtn = Find-SeElement -Driver $Driver -XPath "//button[@title='Search']"
    Invoke-SeClick -Element $SearchBtn
    $WebDriverWait = [OpenQA.Selenium.Support.UI.WebDriverWait]::new($Driver, (New-TimeSpan -Seconds 20))
    $Condition = [OpenQA.Selenium.Support.UI.ExpectedConditions]::InvisibilityOfElementLocated(([OpenQA.Selenium.By]::ClassName("WhiteOut")))
    $WebDriverWait.Until($Condition) | Out-null
    $ServiceCheckbox = Find-SeElement -Wait -Timeout 3 -Driver $Driver -Id $GTSServiceOfferingId
    Invoke-SeClick -Element $ServiceCheckbox
    $InsertBtn = Find-SeElement -Driver $Driver -XPath "//div[@class='pull-left']//button[2]"
    Invoke-SeClick -Element $InsertBtn
    Switch-SeWindow -Driver $Driver -Window $Windows[0]

    # Automation Actions
    $CurrentField = Find-SeElement -Driver $Driver -Id "select2-chosen-7"
    Invoke-SeClick -Element $CurrentField
    $CurrentField = Find-SeElement -Driver $Driver -Id "s2id_autogen7_search"
    Send-SeKeys -Element $CurrentField -Keys $Responsible
    $Selection = Find-SeElement -Driver $Driver -XPath "//div[@class='select2-result-label']//div[contains(text(),'$Responsible')]"
    Invoke-SeClick -Element $Selection

    # Save edit
    $SaveBtn = Find-SeElement -Driver $Driver -XPath "//div[@id='divButtons']//button[@class='btn btn-primary']"
    Invoke-SeClick -Element $SaveBtn
}