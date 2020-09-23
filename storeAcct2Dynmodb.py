
#!/usr/bin/python2.7

from pprint import pprint
import boto3



############################################################################
# Purpose: Is run on an automation server, reads accounts.txt written by getaccounts2.ps1
#          and writes to a dynamodb table aws-accounts 

#
# Created By      : Bobby Boone
#
# Modification History  :
#         08/19/2020 - v1.0 - * Initial Version
#              
#
#
#
#Author   : Bobby Boone
#Copyright: Aflac Inc., All Rights reserved.
#



home = "c:/src/"

#file = open ("c:/src/accounts.txt", "r")



def put_account (AcctNbr, AcctName, dynamodb=None):
    if not dynamodb:
        dynamodb = boto3.resource('dynamodb')

    table = dynamodb.Table('AWS-Accounts')
    response = table.put_item(
       Item={
            'account': AcctNbr
#            'accountName': AcctName
#                 'account': AcctNbr            
           
        }
    )
    return response

with open(home+"accounts.txt", "r") as filestream:
	for line in filestream:
         currentline = line.split(",")		
         AcctNbr = currentline[0]
         AcctName = currentline[1]
         print ('Storing '+ AcctNbr)
         put_account(AcctNbr, AcctName)
#   		
#        print AcctNbr
#print file.read() 