#/bin/sh
curl --request PUT http://consul:8500/v1/agent/service/deregister/$HOSTNAME