# gpprofile2017

Automatically exported from code.google.com/p/gpprofile2011.

Fork with proper support for Delphi unicode versions (Delphi 2010 and higher). The fork starts with version 1.4.0.

Unit names with namespaces are supported now.

Tested with Delphi Seattle.

Additional features are:

- Using NameThreadForDebugging() for tracing the thread names in the result files.
- The PRF output filename can be now be configured using several placeholders, e.g. the ModuleName or the ProcessName and ID.
- The help system now uses CHM instead of HLP. HLP is not supported anymore by modern OSes.

# Project Home Info

GpProfile allows easily find bottlenecks and significantly improve perfomance of your Delphi applications. It is a must-have tool for any Delphi developer.

Original copyright: Primoz Gabrijelcic (gabr@17slon.com)

Small changes to make it work with Delphi 2009, 2010, XE: Anton Alisov (alan008@bk.ru)

Small changes to make it work with Delphi XE2, XE3: Johan Bontes (johan@digitsolutions.nl)

Note: source code must be compiled with Delphi XE or higher, as generics are used.

You can support the project by [Donating](http://emorio.com).

You may also like:

[OmniThreadLibrary](https://code.google.com/p/omnithreadlibrary) - incredible multithreading library for Delphi

[SapMM](https://code.google.com/p/sapmm) - outstanding and mega-fast scalable memory manager for multithreaded Delphi applications.

# Introduction #

GpProfile is a source code instrumenting profiler for Delphi.

Source codes for gpprofile2017 can be compiled using Delphi XE and higher.

Executable file (gpprof.exe) is able to work and profile sources for Delphi and higher.

# Details #

Easy as 1-2-3:

1) Start gpprof.exe and open your Delphi project file (.dpr)

2) Check procedures, for which you want to measure execution time. Click "Instrument" button. Special calls will be added in each chosen procedure.

3) Copy gpprof.pas and gpprofh.pas into your application sources folder or add the include dir to the search path. Build your application in Delphi, run it, do some tasks and close.

After that return to GpProfile window and enjoy the results! :)
