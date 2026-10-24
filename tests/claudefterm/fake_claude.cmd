@echo off
rem Stands in for claude in tests/claudefterm: logs its cwd and args to %FAKE_LOG%, then idles.
rem Headless nvim on Windows sends terminal output to the outer console, hence the log file.
>>"%FAKE_LOG%" echo start cwd=%CD% args=%*
echo fake-claude
rem ends on its own after ~2 min, in case FloatermKill leaves it behind; full path: PATH may have another ping
"%SystemRoot%\System32\PING.EXE" -n 120 127.0.0.1 >nul
