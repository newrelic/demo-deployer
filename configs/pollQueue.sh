#!/bin/bash 

me="$(basename "$0")";
running=$(ps h -C "$me" | grep -wv $$ | wc -l);
[[ $running > 1 ]] && echo "already running, skipping" && exit;

while sleep 1; do 
  MSG=$(aws sqs receive-message --queue-url $AWS_QUEUE_URL --wait-time-seconds 50)
  if [ ! -z "$MSG"  ]; then
    # echo "MSG:$MSG"
    RECEIPT_HANDLE=$(echo $MSG | jq -r '.Messages[] | .ReceiptHandle')
    aws sqs delete-message --queue-url $AWS_QUEUE_URL --receipt-handle $RECEIPT_HANDLE
    BODY=$(echo $MSG | jq -r '.Messages[] | .Body')
    MESSAGE_ID=$(echo $MSG | jq -r '.Messages[] | .MessageId')
    echo "MESSAGE_ID:$MESSAGE_ID"
    cd ~/demo-deployer
    echo "$BODY" >> "$MESSAGE_ID.local.json"
    ruby main.rb -c configs/templates/user.env-aws.json -d "$MESSAGE_ID.local.json"
    RC=$(echo $?)
    echo "exit code:$RC"
    EXPIRATION_TIME=$(date +%s)
    EXPIRATION_TIME=$(($EXPIRATION_TIME+3600))
    JSON=$(echo "{\"MessageId\":{\"S\":\"$MESSAGE_ID\"},\"Code\":{\"N\":\"$RC\"},\"ExpirationTime\":{\"N\":\"$EXPIRATION_TIME\"}}")
    echo "JSON:$JSON"
    aws dynamodb put-item --table-name DeployResponse --item $JSON
    # cleanup
    ruby main.rb -c configs/templates/user.env-aws.json -d "$MESSAGE_ID.local.json" -t
    rm "$MESSAGE_ID.local.json"
  fi
done
