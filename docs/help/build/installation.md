← [Back to overview](index.md)

# Installation & Configuration

## Prerequisites

- Windows
- Visual Studio with MSBuild (or "Build Tools for Visual Studio")
- .NET Framework 4.8 **Runtime** — a Developer Pack is **not** required

## Restore

The solution uses classic `packages.config` NuGet. Restore runs via the NuGet CLI shipped in the repository (`.nuget/NuGet.exe`, version 6.14.0):

```bat
.nuget\NuGet.exe restore "Ember Media Manager.sln"
```

This places all packages into `packages/` — including `Microsoft.NETFramework.ReferenceAssemblies.net48`, which contains the .NET Framework 4.8 reference assemblies.

## Reference assemblies

`Directory.Build.props` in the repository root sets `FrameworkPathOverride` to the package directory `packages\Microsoft.NETFramework.ReferenceAssemblies.net48.1.0.3\build\.NETFramework\v4.8\` (only if the directory exists). MSBuild therefore compiles against the package reference assemblies instead of an installed Developer Pack.

## Build

```bat
msbuild "Ember Media Manager.sln" -p:Configuration=Release -p:Platform=x64
```

| Platform | Result |
|----------|--------|
| `x64` | `EmberMM - Release - x64\` (incl. native x64 dependencies) |
| `x86` | `EmberMM - Release - x86\` (incl. native x86 dependencies) |
| `Any CPU` | `EmberMM - Release - AnyCPU\` (without native dependencies) |

## External dependency TVDB

The C# library `TVDB` (`DanCooper/TheTVDBApi`, GPL-3.0) is included as vendored source under `TheTVDBApi/src/TVDB/` in the repository. The solution and both TVDB scraper projects reference this repo-internal path — a side-by-side checkout is no longer needed.
