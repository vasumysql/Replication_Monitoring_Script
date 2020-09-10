MySQL Replication check monitoring

#!/bin/bash

####################################################################################################
# Checks MySQL Replication status. Sends user(s) a notification when the replication goes down     #
####################################################################################################

status=0
MasterHost="DB master server"
SlaveHost="DB slave Server"
emails="test-db@gmail.com"  # Multiple emails space separated
Subject="Replication status - Down"

###################################################################################
#Grab the lines for each and use Gawk to get the last part of the string(Yes/No)  #
###################################################################################

SQLresponse=`mysql --login-path=local -e "show slave status \G" |grep -i "Slave_SQL_Running"|gawk '{print $2}'`
IOresponse=`mysql --login-path=local -e "show slave status \G" |grep -i "Slave_IO_Running"|gawk '{print $2}'`

if [ "$SQLresponse" = "No" ]; then

error="Replication on the slave MySQL server($SlaveHost) has stopped working. Slave_SQL_Running: No"
status=1
fi

if [ "$IOresponse" = "No" ]; then
error="Replication on the slave MySQL server($SlaveHost) has stopped working. Slave_IO_Running: No"
status=1
fi

##########################################
# If the replication is not working      #
##########################################

if [ $status = 1 ]; then
for address in $emails; do
echo -e $error | mail -s "$Subject" $address
echo "Replication down, sent email to $address"
done
fi
