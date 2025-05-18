# olme - one line message editor

Single-purpose text editor designed to quickly enter short commit messages.

Write one line commit message.
`Enter` to save and close or
SIGINT (`Ctrl+C`) to fall back to a fallback editor (which should be a full-featured
text editor for the cases when a multi-line message is needed).

## Prerequisites

Liberty Eiffel

## Building

`$ se c olme.ace` - the safest build with all checks enabled

`$ se c olme-fast.ace` - build with reduced runtime checks
of Liberty Eiffel library classes for better performance

## Usage

With git it's suggested to set up olme in `~/.gitconfig` like

```
[core]
  editor = olme --git-history --auto-fallback
```

## Fallback editor

is looked for in this order:

- value of the `-f` option
- value of the `VISUAL` environment variable
- value of the `EDITOR` environment variable

If none is provided, the program exits with an error message and exit code 1.

## License

GNU GPL v3
