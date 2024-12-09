#!/bin/bash

# Define the URL and Host header
URL="http://localhost:30630"
HOST="example.com"

# Infinite loop to call curl every 1/10th of a second
while true; do
  # Get the current human-readable timestamp with milliseconds
  timestamp=$(date +"%Y-%m-%d %H:%M:%S.%3N")
  
  # Perform the curl request and capture the status code
  status_code=$(curl -s -o /dev/null -w "%{http_code}" -H "Host: $HOST" $URL)
  
  # Output the status code and human-readable timestamp
  echo "$timestamp $status_code"
  
  # Wait for 1/10th of a second (0.1 seconds)
  sleep 0.1
done
