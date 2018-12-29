#########################################################################
## Title: mfa.ps1
## Author: Mark Bixler
## Description: Script to Easily apply AWS credentials to config files
## Dependencies: 
##  -"aws_accounts.txt" to store Listing of prefered AWS Accounts
##  -Environment Variables for Keys (eg. AWS_ACCESS_KEY) 
#########################################################################

# Global Variables
$ACCESS_KEY = $env:AWS_ACCESS_KEY
$SECRET_ACCESS_KEY = $env:AWS_SECRET_ACCESS_KEY
$MFA_SERIAL = $env:AWS_MFA_SERIAL
$ASSUME_ROLE = "MyRoleForCrossAccountAccess"
$AWS_CREDS = "${env:USERPROFILE}/.aws/credentials"
$AWS_CONFIG = "${env:USERPROFILE}/.aws/config"

#########################################################################
function mainmenu{

    # Declare Function Variables
    $i = 1 #Function iterator
    $accounts = @() # Accounts Array

    Write-Host "--------------------------------------------"
    Write-Host " ACCOUNT LIST"

    foreach($acct in Get-Content aws_accounts.txt) {
        Write-Host "[$($i)] - $($acct)"
        $accounts += $acct.Split(" ")[0]
        $i += 1
    }
    Write-Host "--------------------------------------------"
    $selected_account = read-host "Select Account"

    # Return value based on selected option    
    if ($selected_account -le $accounts.Length) {
        $result_account = $accounts[$selected_account - 1]

    }
    else {
        Write-Host "Selection Invalid. Quitting"
        return "-1"
    }

    # Return Value back to Main
    return $result_account
}
#########################################################################

# Call Main Menu
$acct_id = mainmenu

if ( $acct_id -eq "-1" ) {
    Write-Host $acct_id
    exit
}

# Format AWS Files for MFA Token
Clear-Content $AWS_CREDS
Clear-Content $AWS_CONFIG

# ADD Default Keys to AWS Credentials File
Add-Content $AWS_CREDS "[default]"
Add-Content $AWS_CREDS "aws_access_key_id = $ACCESS_KEY"
Add-Content $AWS_CREDS "aws_secret_access_key = $SECRET_ACCESS_KEY"

# Add Default Values for AWS Config File
Add-Content $AWS_CONFIG "[default]"
Add-Content $AWS_CONFIG "region = us-west-1"
Add-Content $AWS_CONFIG "source_profile=default"

# Prompt for MFA token
$mfa = Read-Host -Prompt 'Enter Token Number'

# Run MFA Command
$aws_sts = (aws sts get-session-token --serial-number $MFA_SERIAL --token-code $mfa)

# Convert aws_sts array to string
$aws_sts_string = $aws_sts | Out-String

# Clear AWS Files again for New MFA Keys
Clear-Content $AWS_CREDS
Clear-Content $AWS_CONFIG

# Grab Data From STS command
$aws_sts_string
$new_access_key = $aws_sts_string.Split(',')[0].Substring($aws_sts_string.Split(',')[0].Length - 21,20)
$new_secret_access_key = $aws_sts_string.Split(',')[1].Substring($aws_sts_string.Split(',')[1].Length - 41,40)
$new_session_token = $aws_sts_string.Split(',')[2].Substring($aws_sts_string.Split(',')[2].Length - 293,292)

# Pass New Values to Credentials File
Add-Content $AWS_CREDS "[default]"
Add-Content $AWS_CREDS "aws_access_key_id = $new_access_key"
Add-Content $AWS_CREDS "aws_secret_access_key = $new_secret_access_key"
Add-Content $AWS_CREDS "aws_session_token = $new_session_token"

# Pass new Config Values
Add-Content $AWS_CONFIG "[default]"
Add-Content $AWS_CONFIG "region = us-west-1"
Add-Content $AWS_CONFIG "role_arn = arn:aws:iam::${acct_id}:role/${ASSUME_ROLE}"
Add-Content $AWS_CONFIG "source_profile=default"