[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)

# gpprofile2017

Automatically exported from code.google.com/p/gpprofile2011.

Fork with proper support for Delphi unicode versions (Delphi XE and higher). The fork starts with version 1.4.0.

Unit names with namespaces are supported now.

Tested with Delphi Seattle.

Additional features are:

- Using NameThreadForDebugging() for tracing the thread names in the result files.
- The PRF output filename can be now be configured using several placeholders, e.g. the ModuleName or the ProcessName and ID.
- The help system now uses CHM instead of HLP. HLP is not supported anymore by modern OSes.

# Credits #

GpProfile allows easily find bottlenecks and significantly improve perfomance of your Delphi applications. It is a must-have tool for any Delphi developer.

Original copyright: Primoz Gabrijelcic (gabr@17slon.com)

Small changes to make it work with Delphi 2009, 2010, XE: Anton Alisov (alan008@bk.ru)

Small changes to make it work with Delphi XE2, XE3: Johan Bontes (johan@digitsolutions.nl)

Note: source code must be compiled with Delphi XE7 or higher, as generics and tasks are used.

The original project gpprof2011 can be found here: https://code.google.com/archive/p/gpprofile2011/.

It was released under the GPLv2.

# Introduction #

GpProfile is a source code instrumenting profiler for Delphi.

The source codes for the UI of gpprofile2017 can be compiled using Delphi XE7 and higher. For proper high DPI support, you should use Delphi Tokyo or above.

The executable file (gpprof.exe) is able to work and profile sources for Delphi XE and higher.

# How-To #

Easy as 1-2-3:

1) Start gpprof.exe and open your Delphi project file (.dpr)

2) Check procedures, for which you want to measure execution time. Click "Instrument" button. Special calls will be added in each chosen procedure.

3) Copy the content of the include dir into your application sources folder or add the include dir to the search path. Build your application in Delphi, run it, do some tasks and close.

After that return to GpProfile window and enjoy the results! :)
