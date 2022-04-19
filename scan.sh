#!/bin/bash

echo "Enter company folder name"
read -p 'Company Name: ' companyname

### SET VARIABLES ###
echo "Company Name = $companyname"
companypath=~/projects
mkdir -p $companypath
echo "Files stored in $companypath"
#cidr=`sed -z 's/\n/ -cidr /g' $companypath/inscope.txt | sed 's/.......$//g'`
#echo $cidr

echo "ENTER/VERIFY IN SCOPE IP ADDRESSES ONE ON EACH LINE IN CIDR NOTATION!!! Opening file in gedit please wait....."
sleep 3
gedit $companypath/inscope.txt

# if inscope does not exist then exit
if [ ! -f $companypath/inscope.txt ]
then
    echo "inscope.txt not found. Exiting!"
    exit 1
else
    echo "In scope file found."
fi

###Block Comment for troubleshooting ####
: <<'END'
END
#########################################

### nmap scans ##
mkdir -p $companypath/nmap
sudo nmap -T4 -Pn -iL $companypath/inscope.txt -p 21,22,23,25,53,80,82,111,139,445,389,443,500,513,621,623,1099,1433,1521,1502,1723,2049,3128,3129,3268,4500,4786,4848,5800,5900,5901,3306,3389,6129,8222,9100,8000,8080,8081,8181,8082,38292,49152,6666,6667,8443,9091,9002,9595,10000 --max-retries=3 --max-rtt-timeout=950ms -oA $companypath/nmap/quick
sudo grep 53/open/tcp $companypath/nmap/quick.gnmap | cut -d " " -f2 > $companypath/nmap/dns.txt
sudo grep 445/open/tcp $companypath/nmap/quick.gnmap | cut -d " " -f2 > $companypath/nmap/shares.txt
sudo grep 389/open/tcp $companypath/nmap/quick.gnmap | cut -d " " -f2 > $companypath/nmap/kerberos.txt
sudo grep 21/open/tcp $companypath/nmap/quick.gnmap | cut -d " " -f2 > $companypath/nmap/ftp.txt
sudo grep 22/open/tcp $companypath/nmap/quick.gnmap | cut -d " " -f2 > $companypath/nmap/ssh.txt

#sudo nmap -vv -sV -iL $companypath/inscope.txt -oA $companypath/nmap/normal

# eyewitness
cd $companypath/
sudo eyewitness -x $companypath/nmap/normal.xml --no-prompt --delay 5 -d $companypath/eyewitness



########### INACTIVE ############

#Metasploit
#Import Nmap XML file into Metasploit:
#Create a workspace: workspace -a <workspace name>
#Switch to use the workspace: workspace <workspace name>
#Import the file: db_import /path/to/xml/file


#ENUM4LINUX. - enum shares
#enum4linux -a 

##Convert nmap scan to CSV for spreadsheet
#python3 ~/scripts/xml2csv.py -f $companypath/nmap/$companyname.xml -csv $companypath/nmap/$companyname.csv


### AUTORECON ###
#echo "STARTING AUTORECON!!!"
#mkdir -p $companypath/autorecon
##cd $companypath/autorecon
#autorecon -t $companypath/inscope.txt -o $companypath/autorecon

## Sort Results ###

#Sort zone transfers
#cd $companypath/autorecon
#touch zone_transfer_temp.txt
#find -name *zone-transfer* -exec cat {} \; | grep ^'\.' | cut -f7 >> zone_transfer_temp.txt 
#cat zone_transfer_temp.txt | sort -u > zone_transfer.txt
#rm zone_transfer_temp.txt

echo "SCRIPT COMPLETED!!!"
