# **Introduction**

Small PowerShell script to automate the process of entering authenticated session tokens to run local aws cli commands. This PowerShell script was based upon a Windows 10 build.

## Getting Started

1. `aws cli` already installed
    - Script assumes aws is installed in default `$USER/.aws` directory
2. The files from this repo:
   - mfa.ps1
   - aws_accounts.txt //need to update to your real account id's
3. AWS Account Key's
4. Assumed Role in AWS

## Running

```powershell
./mfa.ps1
```

## Dependencies

#### mfa.ps1

##### Environment Variables

Environment variables need to be stored with the following names:

`The values of the variables will match your default aws key's.`

- AWS_ACCESS_KEY
- AWS_SECRET_ACCESS_KEY
- AWS_MFA_SERIAL

##### Assumed Role

- Change the line `$ASSUME_ROLE = "MyRoleForCrossAccountAccess"`to your proper assumed role in AWS.


#### aws_accounts.txt

Text Formatting As Follows:

```
555551111222 ## FAKE ACCOUNT 1 ##
123456789012 ## FAKE ACCOUNT 2 ##
```

The script splits line by line by white space and stores first string into an array for further processing.

