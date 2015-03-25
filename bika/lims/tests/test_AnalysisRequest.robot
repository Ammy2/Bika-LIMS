*** Settings ***

Library          BuiltIn
Library          Selenium2Library  timeout=5  implicit_wait=0.2
Library          String
Resource         keywords.txt
Library          bika.lims.testing.Keywords
Variables        plone/app/testing/interfaces.py
Variables        bika/lims/tests/variables.py
Suite Setup      Start browser
Suite Teardown   Close All Browsers

*** Variables ***

${ar_factory_url}  portal_factory/AnalysisRequest/Request%20new%20analyses/ar_add

*** Test Cases ***

Analysis Request with no samping or preservation workflow
    Log in                              test_labmanager         test_labmanager
    wait until page contains     logged in
    Disable Print Page
    Go to                     ${PLONEURL}/clients/client-1
    Click Link                Add
    ${ar_id}=                 Complete ar_add form with template Bore
    Go to                     ${PLONEURL}/clients/client-1/analysisrequests
    Execute transition receive on items in form_id analysisrequests
    Log out
    Log in                    test_analyst    test_analyst
    Go to                     ${PLONEURL}/clients/client-1/${ar_id}/manage_results
    Submit results with out of range tests
    Log out
    Log in                    test_labmanager1    test_labmanager1
    wait until page contains     logged in
    Go to                     ${PLONEURL}/clients/client-1/${ar_id}/manage_results
    Add new Copper analysis to ${ar_id}
    ${ar_id} state should be sample_received
    Go to                     ${PLONEURL}/clients/client-1/${ar_id}/base_view
    Execute transition verify on items in form_id lab_analyses
    Log out
    Log in                    test_labmanager1    test_labmanager1
    wait until page contains     logged in
    # There is no "retract" transition on verified analyses - but there should/will be.
    # Go to                     ${PLONEURL}/clients/client-1/${ar_id}/base_view
    # Execute transition retract on items in form_id lab_analyses

Create two different ARs from the same sample.
    Log in                              test_labmanager         test_labmanager
    wait until page contains     logged in
    Disable Print Page
    Create Primary AR
    Create Secondary AR
    In a client context, only allow selecting samples from that client.

*** Keywords ***

Create Primary AR
    @{time} =                   Get Time        year month day hour min sec
    Go to                       ${PLONEURL}/clients/client-1
    Wait until page contains element    css=body.portaltype-client
    Click Link                  Add
    Wait until page contains    Request new analyses
    Select from dropdown        css=#Contact-0                Rita
    Select from dropdown        css=#Template-0               Bore
    Select Date                 css=#SamplingDate-0           @{time}[2]
    Set Selenium Timeout        30
    Click Button                Save
    Set Selenium Timeout        10
    Wait until page contains    created
    ${ar_id} =                  Get text      //dl[contains(@class, 'portalMessage')][2]/dd
    ${ar_id} =                  Set Variable  ${ar_id.split()[2]}
    Go to                       http://localhost:55001/plone/clients/client-1/analysisrequests
    Wait until page contains    ${ar_id}
    Select checkbox             xpath=//input[@item_title="${ar_id}"]
    Click button                xpath=//input[@value="Receive sample"]
    Wait until page contains    saved
    [return]                    ${ar_id}

Create Secondary AR
    Log in                      test_labmanager  test_labmanager
    wait until page contains     logged in
    @{time} =                   Get Time        year month day hour min sec
    Go to                       ${PLONEURL}/clients/client-1
    Wait until page contains element    css=body.portaltype-client
    Click Link                  Add
    Wait until page contains    Request new analyses
    Select from dropdown        css=#Contact-0                Rita
    Select from dropdown        css=#Template-0               Bruma
    select from dropdown        css=#Sample-0
    Set Selenium Timeout        30
    Click Button                Save
    Set Selenium Timeout        2
    Wait until page contains    created
    ${ar_id} =                  Get text      //dl[contains(@class, 'portalMessage')][2]/dd
    ${ar_id} =                  Set Variable  ${ar_id.split()[2]}
    [return]                    ${ar_id}


In a client context, only allow selecting samples from that client.
    Log in                      test_labmanager  test_labmanager
    wait until page contains     logged in
    @{time} =                   Get Time        year month day hour min sec
    Go to                       ${PLONEURL}/clients/client-2
    Wait until page contains element    css=body.portaltype-client
    Click Link                  Add
    Wait until page contains    Request new analyses
    Select from dropdown        css=#Contact-0               Johanna
    Select from dropdown        css=#Template-0              Bore    1
    Run keyword and expect error
    ...   ValueError: Element locator 'xpath=//div[contains(@class,'cg-colItem')][1]' did not match any elements.
    ...   Select from dropdown        css=#Sample-0


Complete ar_add form with template ${template}
    Wait until page contains    Request new analyses
    @{time} =                   Get Time        year month day hour min sec
    SelectDate                  css=#SamplingDate-0   @{time}[2]
    Select from dropdown        css=#Contact-0       Rita
    Select from dropdown        css=#Priority-0           High
    Select from dropdown        css=#Template-0       ${template}
    Sleep                       5
    Click Button                Save
    Wait until page contains    created
    ${ar_id} =                  Get text      //dl[contains(@class, 'portalMessage')][2]/dd
    ${ar_id} =                  Set Variable  ${ar_id.split()[2]}
    [return]                    ${ar_id}

Complete ar_add form Without template
    @{time} =                  Get Time        year month day hour min sec
    SelectDate                 css=#SamplingDate-0   @{time}[2]
    Select From Dropdown       css=#SampleType-0    Water
    Select from dropdown       css=#Contact-0       Rita
    Select from dropdown       css=#Priority-0           High

    click element              css=table[form_id='lab'] th[cat='Water Chemistry']
    wait until page contains element    css=tr[title='Moisture'] td[class*='ar.0'] input[type='checkbox']
    Select Checkbox                     css=tr[title='Moisture'] td[class*='ar.0'] input[type='checkbox']
    click element              css=table[form_id='lab'] th[cat='Metals']
    wait until page contains element    css=tr[title='Calcium'] td[class*='ar.0'] input[type='checkbox']
    Select Checkbox                     css=tr[title='Calcium'] td[class*='ar.0'] input[type='checkbox']
    Select Checkbox                     css=tr[title='Phosphorus'] td[class*='ar.0'] input[type='checkbox']
    click element              css=table[form_id='lab'] th[cat='Microbiology']
    wait until page contains element    css=tr[title='Clostridia'] td[class*='ar.0'] input[type='checkbox']
    Select Checkbox                     css=tr[title='Clostridia'] td[class*='ar.0'] input[type='checkbox']
    Select Checkbox                     css=tr[title='Ecoli'] td[class*='ar.0'] input[type='checkbox']
    Select Checkbox                     css=tr[title='Enterococcus'] td[class*='ar.0'] input[type='checkbox']
    Select Checkbox                     css=tr[title='Salmonella'] td[class*='ar.0'] input[type='checkbox']

    Set Selenium Timeout       60
    Click Button               Save
    Wait until page contains   created
    ${ar_id} =                 Get text      //dl[contains(@class, 'portalMessage')][2]/dd
    ${ar_id} =                 Set Variable  ${ar_id.split()[2]}
    [return]                   ${ar_id}

Submit results with out of range tests
    [Documentation]   Complete all received analysis result entry fields
    ...               Do some out-of-range checking, too

    ${count} =                 Get Matching XPath Count    //input[@type='text' and @field='Result']
    ${count} =                 Convert to integer    ${count}
    :FOR    ${index}           IN RANGE    1   ${count+1}
    \    TestResultsRange      xpath=(//input[@type='text' and @field='Result'])[${index}]       5   10
    Sleep                      5s
    Click Element              xpath=//input[@value='Submit for verification'][1]
    Wait Until Page Contains   Changes saved.

Submit results
    [Documentation]   Complete all received analysis result entry fields

    ${count} =                 Get Matching XPath Count    //input[@type='text' and @field='Result']
    ${count} =                 Convert to integer    ${count}
    :FOR    ${index}           IN RANGE    1   ${count+1}
    \    Input text            xpath=(//input[@type='text' and @field='Result'])[${index}]   10
    Sleep                      5s
    Click Element              xpath=//input[@value='Submit for verification'][1]
    Wait Until Page Contains   Changes saved.

Add new ${service} analysis to ${ar_id}
    Go to                      ${PLONEURL}/clients/client-1/${ar_id}/analyses
    select checkbox            xpath=//input[@alt='Select ${service}']
    click element              save_analyses_button_transition
    wait until page contains   saved.

${ar_id} state should be ${state_id}
    Go to                        ${PLONEURL}/clients/client-1/${ar_id}
    log     span.state-${state_id}   warn
    Page should contain element  css=span.state-${state_id}

TestResultsRange
    [Arguments]  ${locator}=
    ...          ${badResult}=
    ...          ${goodResult}=

    # Log  Testing Result Range for ${locator} -:- values: ${badResult} and ${goodResult}  WARN

    Input Text          ${locator}  ${badResult}
    Press Key           ${locator}   \\9
    Expect exclamation
    Input Text          ${locator}  ${goodResult}
    Press Key           ${locator}   \\9
    Expect no exclamation

Expect exclamation
    sleep  .5
    Page should contain Image   ${PLONEURL}/++resource++bika.lims.images/exclamation.png

Expect no exclamation
    sleep  .5
    Page should not contain Image  ${PLONEURL}/++resource++bika.lims.images/exclamation.png

TestSampleState
    [Arguments]  ${locator}=
    ...          ${sample}=
    ...          ${expectedState}=

    ${VALUE}  Get Value  ${locator}
    Should Be Equal  ${VALUE}  ${expectedState}  ${sample} Workflow States incorrect: Expected: ${expectedState} -
    # Log  Testing Sample State for ${sample}: ${expectedState} -:- ${VALUE}  WARN

Enable Sampling Workflow
    Go to               ${PLONEURL}/bika_setup/edit
    Click Link          id=fieldsetlegend-analyses
    Select Checkbox     id=SamplingWorkflowEnabled
    Click Button        Save
    Wait until page contains    Changes saved.

Save a Sampler and DateSampled on AR
    @{time} =           Get Time    year month day hour min sec
    Select Date         DateSampled    @{time}[2]
    Select From List    Sampler  Lab Sampler 1
    Click Button        Save
    Page Should Contain  Changes saved.

Define container ${container} and preservation ${preservation} from Sample Partitions
    Select From List    //span[2]/select    ${container}
    Select From List    //td[4]/span[2]/select    ${preservation}
    Click Button        save_partitions_button_transition
