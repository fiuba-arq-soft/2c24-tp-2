#!/bin/bash
export TARGET=http://$(cat ../node/lb_dns)
export DATADOG_API_KEY=
export DEBUG=plugin:publish-metrics:datadog-statsd
npm run artillery run $1.yaml
