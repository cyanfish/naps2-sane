# NAPS2.Sane

[![NuGet](https://img.shields.io/nuget/v/NAPS2.Sane)](https://www.nuget.org/packages/NAPS2.Sane/)

NAPS2.Sane provides precompiled [SANE](https://sane-project.org/) binaries for use with [NAPS2.Sdk](https://github.com/cyanfish/naps2/tree/master/NAPS2.Sdk).

Supported platforms:
- Mac 10.15+ arm64
- Mac 10.15+ x64

Linux binaries are not included as the expectation is to use the system-installed SANE.

Windows binaries are a work in progress. There are some limitations as SANE depends on Cygwin as a POSIX emulation layer, but Cygwin can't live in the same process as the .NET runtime.