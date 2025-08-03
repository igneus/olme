# olme - one line message editor

Single-purpose text editor designed to quickly enter short commit messages.

Write one line commit message.
`Enter` to save and close or
`Ctrl+B` to fall back to a full-featured text editor.

(Yes, it's basically just GNU Readline saving to a file. With a few extras.)

## Prerequisites

[Liberty Eiffel](https://www.liberty-eiffel.org/)

## Building

`$ se c olme.ace`

## Usage

With git it's suggested to set up olme in `~/.gitconfig` like

```
[core]
  editor = olme --git-history --auto-fallback
```

`--git-history` loads recent git commit messages
to readline history (browsed by up/down arrow keys).
In addition to git, olme provides similar support for Mercurial
(`--hg-history`)
and for a shell command providing the history entries
(e.g. `--history "tail ~/.bash_history"`).

`--auto-fallback` skips the olme prompt and immediately runs
the fallback editor if the edited file has more than one
non-empty line.
(Lines beginning with the shell comment sign `#` are considered empty.)

## Fallback editor

is looked for in this order:

- value of the `-f` option
- value of the `VISUAL` environment variable
- value of the `EDITOR` environment variable

If none is provided and the fallback action is triggered,
the program exits with an error message and exit code 1.

## Key bindings

olme uses GNU Readline for the input prompt,
so the [standard Readline key bindings](https://tiswww.cwru.edu/php/chet/readline/readline.html#Readline-Interaction),
familiar from the shell and elsewhere, are available.
Custom key bindings
[can be configured in `~/.inputrc`](https://tiswww.cwru.edu/php/chet/readline/readline.html#Readline-Init-File).

olme defines a single custom command, named `fallback-editor`,
which closes the simple input prompt and runs the fallback editor.
A custom key binding can be configured like this:

```inputrc
$if olme
Control-x: fallback-editor
$endif
```

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
