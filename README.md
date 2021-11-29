# NotesArchive

A Swift package for reading and writing an undocumented interchange format for the Apple Notes app in macOS 12 Monterey[^1].

## Enabling the Debug Menu in Notes

```shell
$ defaults write com.apple.Notes alexandria -bool YES
```

Notes archives (read from and written to by the `Archive` type in this package) can be imported into Notes by double-clicking them, or can be used with Quick Look.

Enabling the debug menu in the app enables importing to or exporting from specific folders, as well as some fun (and dangerous!) additional functionality.

[^1]: The functionality seems to be there on macOS 11 Big Sur too, but hasn't been tested there.
