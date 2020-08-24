#!/bin/sh
/bin/curl -X PUT -d '{"id": "'$MY_POD_NAME'","name": "node-exporter","address": "'$MY_POD_IP'","port": 9100,"meta":{"exporter":"node"},"tags": ["node-exporter"],"checks": [{"http": "http://'$MY_POD_IP':9100/metrics", "interval": "5s"}]}'  http://consul:8500/v1/agent/service/register
/bin/node_exporter