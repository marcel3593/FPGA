@echo off
REM ****************************************************************************
REM Vivado (TM) v2018.3 (64-bit)
REM
REM Filename    : elaborate.bat
REM Simulator   : Mentor Graphics Questa Advanced Simulator
REM Description : Script for elaborating the compiled design
REM
REM Generated by Vivado on Sun Feb 12 17:00:00 +0800 2023
REM SW Build 2405991 on Thu Dec  6 23:38:27 MST 2018
REM
REM Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
REM
REM usage: elaborate.bat
REM
REM ****************************************************************************
set bin_path=D:\\questasim64_10.6c\\win64
call %bin_path%/vsim  -c -do "do {tb_elaborate.do}" -l elaborate.log
if "%errorlevel%"=="1" goto END
if "%errorlevel%"=="0" goto SUCCESS
:END
exit 1
:SUCCESS
exit 0
