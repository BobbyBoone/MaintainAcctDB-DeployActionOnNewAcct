
$now=get-date



# Variables
$Account            = '883754280884' # AWS Payer Account
$RoleName           = 'AWS-Enterprise-Automation' # Secret IAM Role
$RoleSession        = 'Testing-Automation'
$Region             = 'us-east-1'
$DesiredStatus      = 'ACTIVE' # Valid Options are ACTIVE and SUSPENDED

$homedir = "C:\src\"
$debugfile = $homedir+"debug.txt"
#$fullpath = $homedir+"accounts.txt"
$acctfile = $homedir+"accounts.txt"
$fullpathcntb4 = $homedir+"acctCountb4.txt"
$fullpathami = $homedir+"ami.txt"
$kmsfullpath = $homedir+"kms.txt"
$debuglvl = 2

Add-Content -Path $debugfile  -Value $now -Encoding ASCII
# Purpose: Obtain active accounts from Payer Account

# Obtain Credentials
$RoleARN            = 'arn:aws:iam::' + $Account + ':role/' + $RoleName
$AssumeRoleResponse = Use-STSRole -RoleArn $RoleARN -RoleSessionName "$RoleSession"
$Creds              = $AssumeRoleResponse.Credentials


 if ($debuglvl -ge 1 ) {Add-Content -Path $debugfile  -Value "getting accounts" -Encoding ASCII}
# Obtain the Account list
$AWSAccountList = Get-ORGAccountList -Credential $Creds | Sort-Object -Property Name -Descending


$KMSprefix = '{
    "Version": "2012-10-17",
    "Id": "key-consolepolicy-3",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::789335473777:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::789335473777:role/AWS-Enterprise-CloudAdmin"
            },
            "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": ['

$KMSMiddle = '
                ]
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": ['

$KMSSuffix = '
                ]
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
}'



$KMSdata = ''




# clear accounts.txt and kms.txt files
Remove-Item –path $acctfile
Remove-Item –path $kmsfullpath

ForEach ($Account in $AWSAccountList) {

    # Extract Account attributes
    $Id = $Account.Id
    $Name  = $Account.Name
    $Email = $Account.Email
    $Status = $Account.Status
    $IDname =  $id+','+$name 
    $KMSdata = $KMSdata + '"arn:aws:iam::'+$id+':root",'
 
    # Print information for only Active accounts
    if ($debuglvl -ge 1 ) {if ($Status -Eq $DesiredStatus ) { $Id+ "  "+$Name}}
    if ($debuglvl -ge 1 ) { $KMSdata}
#    if ( $Status -Eq $DesiredStatus ) {Add-Content -Path $homedir accounts.txt  -Value $line -Encoding ASCII } 
    if ( $Status -Eq $DesiredStatus ) {Add-Content -Path $acctfile  -Value $IDname -Encoding ASCII } 
   # this is to put out the simeple kms file
   # if ( $Status -Eq $DesiredStatus ) {Add-Content -Path $kmsfullpath -Value $KMSdata -Encoding ASCII } 

    # $ID, $Name, $Email, $Status

} # END ForEach $Account  

#get rid of the last comma
$strlen =  $KMSdata| measure-object -character | select -expandproperty characters
$KMSdataMunus1= $KMSdata.Substring(0,$strlen-1)

$fullkms = $KMSprefix + $KMSdataMunus1 + $KMSmiddle + $KMSdataMunus1+ $KMSsuffix 

$fullkms
Add-Content -Path $kmsfullpath -Value $fullkms -Encoding ASCII 


# update dynamodb database
$arglist = $homedir+"storeAcct2Dynmodb.py"
#Start-Process -NoNewWindow -Wait -FilePath "C:\Python27\python.exe" -ArgumentList $arglist


# example: ec2 modify-image-attribute --image-id ami-0b7f247f23ab0aae2 --launch-permission "Add=[{UserId="858198163815}]"
$ami = import-csv -Path $fullpathami -Delimiter ',' -header amiID
$Accounts = import-csv -Path $acctfile -Delimiter ',' -header Acct, Desc

# Read in the old number of accounts and compare to the number we just pulled
# of the number has not changed, do nothing, otherwise deployimages
$acctCountb4= [IO.File]::ReadAllText($fullpathcntb4)
# If there is a new account, Deploy Images

if ($debuglvl -ge 1 ) {"Nbr Accountsw now="+$Accounts.Count + "   Nbr before="+$acctCountb4}

$detail = "New account found  " + $Accounts.Count+"  "+$acctCountb4 
If ($Accounts.Count-gt $acctCountb4) {
 if ($debuglvl -ge 1 ) {Add-Content -Path $debugfile  -Value $detail -Encoding ASCII}





$ami.Count
$adx = 0

# Ok, we have a new account, so we are going to update the AMI's in all accounts.
# We use ami.txt file as a list of all amis to deploy
# example format of the ami.txt, amiID, descriptiion  
# ami-082236d91262051bc, Shared Windows 2019v106
for($a=0; $a -le $ami.Count -1 ; $a++){
    $idx = 0
    “Adding "+ $ami[$adx].amiID

     for($i=0; $i -le $Accounts[$i].Acct -1; $i++){
       # “Adding"+ $Accounts[$i].Acct
        #$arglist = 'ec2 modify-image-attribute --image-id ami-082236d91262051bc --launch-permission '+'"Add=[{UserId="'+$Accounts[$i].Acct + '}]"'
        #$arglist = 'ec2 modify-image-attribute --image-id '+  $ami[$adx].amiID+' --launch-permission '+'"Add=[{UserId="'+$Accounts[$i].Acct + '}]"'
        $arglist = 'ec2 modify-image-attribute --image-id '+  $ami[$adx].amiID+' --launch-permission '+'"Add=[{UserId='+$Accounts[$i].Acct + '}]"'
        if ($debuglvl -ge 1 ) {$arglist}
     
        Start-Process -NoNewWindow -Wait -FilePath "C:\Program Files\Amazon\AWSCLIV2\aws.exe" -ArgumentList $arglist
        #Start-Process -Wait -FilePath "C:\Program Files\Amazon\AWSCLIV2\aws.exe" -ArgumentList $arglist        
        #Add-Content -Path $debugfile  -Value $arglist -Encoding ASCII
        $idx++
        #$idx
        }
     $adx++
}

# Update the account count
$Accounts.Count >$fullpathcnt
 Add-Content -Path $debugfile  -Value "count updated" -Encoding ASCII
}


#getaccounts
#updatedb