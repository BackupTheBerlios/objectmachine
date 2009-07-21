@echo off

echo Compiling
haxe Tester.hxml

if exist tester.n (
   echo.
   echo Running tests
   neko tester.n
)

if exist server.n (
   echo.
   echo Test server running - hit ctrl-c when finished testing
   neko server.n
   echo Exited
)