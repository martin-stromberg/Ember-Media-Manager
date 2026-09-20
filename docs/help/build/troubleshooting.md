← [Back to overview](index.md)

# Troubleshooting

Known build problems and their solutions:

| Error message | Cause | Solution |
|---------------|-------|----------|
| `MSB3202: The project file "..\TheTVDBApi\src\TVDB\TVDB.csproj" was not found` | Outdated reference to a side-by-side checkout | Current state: `TVDB.csproj` lives under `TheTVDBApi\src\TVDB\` in the repository — solution and project references point there. |
| `MSB3644: The reference assemblies for ".NETFramework,Version=v4.8" were not found` | Package reference assemblies missing | Run `.nuget\NuGet.exe restore "Ember Media Manager.sln"`; `Directory.Build.props` then enables `FrameworkPathOverride` automatically. |
| "Package restore is disabled" / NuGet errors during restore | Outdated NuGet.exe (2.x) | `.nuget/NuGet.exe` was updated to 6.14.0; use `nuget restore` instead of `msbuild -t:restore` (the latter does not cover `packages.config`). |
| `MSB3073 ... xcopy ... AnyCPU` in the `EmberAPI` PostBuildEvent | Platform directory for native deps missing | The PostBuildEvent now only copies if `$(ProjectDir)$(PlatformName)` exists — AnyCPU has no native directory and is therefore harmless. |
| `BC31392: /platform:anycpu32bitpreferred can only be used with /t:exe ...` | `Prefer32Bit=true` in library projects | Set to `false` in the affected add-on projects (only allowed for `*-exe` outputs). |
