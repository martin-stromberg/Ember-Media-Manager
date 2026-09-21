← [Back to overview](index.md)

# Description

Ember Media Manager is built as a Visual Studio solution (`Ember Media Manager.sln`). All ~30 projects of the solution — main application, `EmberAPI`, `KodiAPI`, `Trakttv` and all add-on modules — uniformly target **.NET Framework 4.8**.

After a fresh `git clone`, two steps suffice to compile the complete solution: restore NuGet packages and build the solution with MSBuild. Neither a separate .NET Framework 4.8 Developer Pack nor an external checkout of the TVDB library is required — both ship in the repository or are fetched via NuGet.

The supported output platforms are **x86** and **x64**; only these ship the platform-specific native dependencies. `Any CPU` compiles as well but contains no native components.

## Example

```bat
.nuget\NuGet.exe restore "Ember Media Manager.sln"
msbuild "Ember Media Manager.sln" -p:Configuration=Release -p:Platform=x64
```

The finished build output then resides under `EmberMM - Release - x64\`.

> **Note:** Locally built executables show "Version 0.0.0" — the checked-in `AssemblyInfo.vb` files carry the placeholder `0.0.0.0`. Only CI release builds stamp the actual release version into the assemblies (see [CI/CD & Git Hooks](../ci-cd/index.md)).
