# MaintainAcctDB-DeployActionOnNewAcct
# GetAccounts2.ps1 maintains an account list in dynamodb and updates files accounts.txt and kms.txt (both which get updated when a new account is addded) 
# acctCountb4.txt is the number of accounts prior to the pull of accounts, and allows us to see if we have a new account
# it also runs AWS CLI command to share AMIs to all of the accounts.  ami.txt contains the list of AMI's to be shared. 
# if you want to share a new ami to all accounts, just update ami.txt and decrease integer contained in acctCountb4.txt by 1, which forces a push.

# kms.txt is an updated KMS policy for key 'KeyToShareAMI', you just copy and paste it in
# TODO - have the script update the key policy without human intervention.

