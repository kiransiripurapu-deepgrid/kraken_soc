@echo off
REM Vivado Setup and Full FPGA Flow for kraken_soc_func
REM Target: Arty A7-100T (xc7a100tcsg324-1)

setlocal enabledelayedexpansion

set VIVADO_DIR=C:\Xilinx\Vivado\2022.2
set VIVADO_EXE=!VIVADO_DIR!\bin\vivado.exe

if not exist "!VIVADO_EXE!" (
    echo ERROR: Vivado not found at !VIVADO_EXE!
    echo Please install Vivado 2022.2 or update the path
    exit /b 1
)

cd /d C:\Users\kiran\fpga_project\mini_kraken

echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║     KRAKEN SOC FULL FLOW - ARTY A7-100T                       ║
echo ║     Starting: Behavioral Sim ^> Synth ^> Impl ^> Bitstream      ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.

REM Call Vivado settings
call "!VIVADO_DIR!\settings64.bat"

REM Run full flow TCL script
echo [*] Running full implementation flow...
echo.

"!VIVADO_EXE!" -mode batch -source run_full_flow.tcl

echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║                    EXECUTION COMPLETE                          ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
echo [✓] Generated files:
echo     • Bitstream:  mini_kraken.runs\impl_1\kraken_soc_func.bit
echo     • Synth Log:  mini_kraken.runs\synth_1\runme.log
echo     • Impl Log:   mini_kraken.runs\impl_1\runme.log
echo.
echo [!] To program the FPGA:
echo     1. Open Vivado hardware manager
echo     2. Open target (Digilent USB-JTAG)
echo     3. Add bitstream: mini_kraken.runs\impl_1\kraken_soc_func.bit
echo     4. Program FPGA
echo.

endlocal
