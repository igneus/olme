# olme - one line message editor

Single-purpose text editor designed to quickly enter short commit messages.

Write one line commit message.
`Enter` to save and close or
`Ctrl+B` to fall back to a fallback editor (which should be a full-featured
text editor for the cases when a multi-line message is needed).

## Prerequisites

[Liberty Eiffel](https://www.liberty-eiffel.org/)

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

If none is provided and SIGINT is received,
the program exits with an error message and exit code 1.

## Why

For most commit messages running an editor like `vim` -
or typing out a command line option with a quoted argument `-m "The message"` -
is too much of a ceremony.
Text editor filling the whole terminal window is too much of a disturbance
of my terminal flow.
A simple prompt for a single line, editing finished by a single hit
of the `Enter` key - that's my idea of writing a commit message.

As a bonus olme offers (with the `--git-history` option)
a history of recent commit messages for reuse.

## License

GNU GPL v3
