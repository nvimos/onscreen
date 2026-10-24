#!/bin/bash
# bashls (shellcheck): unquoted variable, if without then
if [ -n $1 ]
  echo x
fi
