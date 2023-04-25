*** Settings ***
Documentation       Template robot main suite.

Library        RPA.Browser.Selenium    
Library        RPA.Robocorp.Vault


*** Tasks ***
Get credentials
    ${secret}    Get Secret    credentials_robotsparebin
    Log    ${secret}[password]