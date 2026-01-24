#!/bin/bash

# Test Graylog HTTP endpoint
curl -X POST -H "Content-Type: application/json" \
    -d '{"short_message": "hello", "host": "test-script", "level": 6}' \
    http://localhost:12201/gelf

