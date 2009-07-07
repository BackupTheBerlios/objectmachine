@echo off

haxe Tester.hxml

if exist tester.n (
    neko tester.n
)
