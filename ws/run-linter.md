type somefile.lua | cmd.exe /C gitleaks stdin --report-format=json --report-path=- --exit-code=0 somefile.lua

type README.md | cmd.exe /C vale --no-exit --output JSON --ext .md
