#!/bin/bash
INSTANCE_NAME=("web","user","Catalogue")
IMAGE_ID="ami-02db68a01488594c5"
INSTANCE_TYPE='t3.micro'
SECURITY_GROUP_IDS="sg-06c8e46fed96c970d"
KEY_NAME="Ansible.pem"
ZONE_ID="Z02733572PIKGQZR8W2GI"
DOMAIN_NAME="joindevopstest.online"
for i=0 in "${INSTANCE_NAME[@]}"; 
do
    (aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --key-name $KEY_NAME --security-group-ids $SECURITY_GROUP_IDS  
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i: $IP_ADDRESS"


     aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
        '

done


