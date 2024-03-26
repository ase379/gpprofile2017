[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)

# Introduction #

GpProfile is a source code instrumenting profiler for Delphi. It allows you to easily find bottlenecks and significantly improves perfomance of your Delphi applications. It is a must-have tool for any Delphi developer.

Features are:

- New shiny UI with high DPI support.
- Applying project defines in the parser to support multi-target code.
- A whole lot of bug fixes
- Using NameThreadForDebugging() for tracing the thread names in the result files.
- The PRF output filename can be now be configured using several placeholders, e.g. the ModuleName or the ProcessName and ID.
- 32 and 64 Bit support.
- Low performance impact on the subject that is instrumented.

The generated instrumentation code works with Delphi 2 to the latest version.

# How-To #
## Instrumentation approach ##
Easy as 1-2-3:

1) Start gpprof.exe and open your Delphi project file (.dpr)

2) Check procedures, for which you want to measure execution time. Click "Instrument" button. Special calls will be added in each chosen procedure.

3) Copy the content of the include dir into your application sources folder or add the include dir to the search path. Build your application in Delphi, run it, do some tasks and close.

After that return to GpProfile window and enjoy the results! :)
## Measure Points ##
Since Version 1.6.0, you can add measurePoints:
Use gpprof.CreateMeasurePointScope() to obtain a measure point. Upon disposal, the measure point will write out the timings.

A sample can be found in the GProfTester project (in TTestThread.Execute())  

# Credits #

Original copyright: Primoz Gabrijelcic (gabr@17slon.com)

Small changes to make it work with Delphi 2009, 2010, XE: Anton Alisov (alan008@bk.ru)

Small changes to make it work with Delphi XE2, XE3: Johan Bontes (johan@digitsolutions.nl)

The original project gpprof2011 can be found here: https://code.google.com/archive/p/gpprofile2011/.

It was released under the GPLv2.

# Building the sources # 

Go [here](./buildSources.md) for more details.
