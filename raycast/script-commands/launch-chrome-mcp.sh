#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Launch Chrome (MCP debugging)
# @raycast.mode silent
# @raycast.icon 🌐
# @raycast.packageName MCP
# @raycast.description Launches Chrome with remote debugging on :9222 for Claude's Chrome DevTools MCP. Uses a dedicated, isolated profile.

killall "Google Chrome" 2>/dev/null
sleep 0.5

/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --remote-debugging-port=9222 \
  --user-data-dir="$HOME/Library/Application Support/Claude-MCP-Chrome" \
  http://localhost:3000 &
