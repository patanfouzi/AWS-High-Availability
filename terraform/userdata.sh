#!/bin/bash
aws s3 cp s3://my-bucket/user_data.sh /tmp/user_data.sh
chmod +x /tmp/user_data.sh
/tmp/user_data.sh
