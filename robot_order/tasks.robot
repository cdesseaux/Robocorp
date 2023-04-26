*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.Tables
Library             RPA.HTTP
Library             String
Library             RPA.Windows
Library             RPA.PDF
Library             RPA.Archive


*** Variables ***
${CSV_URL}      https://robotsparebinindustries.com/orders.csv


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Get orders from CSV
    Open the robot order website
    Complete each order
    Create ZIP
    [Teardown]    Close Browser


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Click Button    OK

Get orders from CSV
    Download    ${CSV_URL}    overwrite=${True}
    ${table_orders}=    Read table from CSV    ${OUTPUT_DIR}${/}orders.csv
    ...    header=${True}
    RETURN    ${table_orders}

Complete each order
    ${orders}=    Get orders from CSV
    FOR    ${order}    IN    @{orders}
        Fill out the form    ${order}
        Preview robot    ${order}
        Submit the order until confirmed    ${order}
        Create PDF    ${order}
    END

Fill out the form
    [Arguments]    ${order}
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input
    ...    ${order}[Legs]
    Input Text    address    ${order}[Address]

 Preview robot
    [Arguments]    ${order}
    Click Button    preview
    Capture Element Screenshot    robot-preview
    ...    ${OUTPUT_DIR}${/}receipts${/}image-${order}[Order number].png

Submit the order until confirmed
    [Arguments]    ${order}
    Wait Until Keyword Succeeds    5x    1s    Submit order    ${order}

Submit order
    [Arguments]    ${order}
    Click Button    order
    Wait Until Keyword Succeeds    3x    1s    Capture Element Screenshot
    ...    receipt
    ...    ${OUTPUT_DIR}${/}receipts${/}receipt-${order}[Order number].png
    Click Button    order-another
    Click Button    OK

Create PDF
    [Arguments]    ${order}
    ${files}=    Create List
    ...    ${OUTPUT_DIR}${/}receipts${/}image-${order}[Order number].png
    ...    ${OUTPUT_DIR}${/}receipts${/}receipt-${order}[Order number].png
    Add Files To Pdf
    ...    ${files}    ${OUTPUT_DIR}${/}pdf${/}pdf-${order}[Order number].pdf

Create ZIP
    Archive Folder With Zip    ${OUTPUT_DIR}${/}pdf
    ...    ${OUTPUT_DIR}${/}Pdf${/}pdf.zip
