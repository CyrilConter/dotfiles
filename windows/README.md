# Windows

Move your existing `install.ps1` and `powershell/` content here when
you merge the reorganization branch.

Expected structure after migration:

```
windows/
├── install.ps1            (your existing PowerShell installer)
└── powershell/            (your existing PowerShell + Oh My Posh config)
```

You may also want to update paths inside `install.ps1` so they
reference `windows/powershell/` from the repo root, instead of a
top-level `powershell/`.
