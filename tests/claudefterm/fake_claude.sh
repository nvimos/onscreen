#!/bin/sh
# Stands in for claude in tests/claudefterm: logs its cwd and args to $FAKE_LOG, then idles.
echo "start cwd=$(pwd) args=$*" >> "$FAKE_LOG"
echo fake-claude
# ends on its own after ~2 min, in case FloatermKill leaves it behind
sleep 120
