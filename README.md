# rnoweb-nvim

A Neovim plugin to conceal commands in Rnoweb, PythonTeX, and LaTeX documents using Treesitter and Extmarks.

The plugin aims to be substantially quicker than an equivalent using regular
regex concealing (e.g. with the illustrious
[VimTex](https://github.com/lervag/vimtex) plugin).

This plugin also aims to provide niceties to Rnoweb and PythonTeX documents. In
particular, inline code segments are replaced in-document provided that their
results have been compiled.

### Goals
- Be fast. This means using treesitter to do the heavy lifting
- Multi-character conceal
- Work with Rnoweb, PythonTeX, or stand-alone LaTeX
- Conceal latex symbols and provide interface for users to specify their own conceals

### Current Functionality
- Basic citation conceal
- Inline code substitution for Rnoweb (`\Sexpr{}`) and PythonTeX (`\py{}`)
- Equation numbering
- Figure numbering
- Footnote numbering
- Diacritic replacement
- Subscript/superscripts
- Replacement of in document text macros (`\newcommand`'s where the result of the command is only text)
- Lots of pre-defined conceals for common commands
- PythonTeX command concealment (`\py`, `\pyc`, `\pys`, `\pyb`, `\pyv`)

### Improvements
- Citation conceal with bibliography lookup and hopefully the anti-conceal functionality. Not doing this before anti-conceal is mainlined.
- Constant improvements in equation and environment numbering
- General environment numbering

# Installation and User Configuration

The following should work with packer. Note that I also configure some
user-specific replacements that appear in the following screenshots. There
aren't necessary for the plugin to work out of the box.

```lua
use { 'bamonroe/rnoweb-nvim',
  requires = {
    'nvim-lua/plenary.nvim'
  },
  ft = {'rnoweb', "latex", "tex"},
  dependencies = {
    'nvim-lua/plenary.nvim'
  },
  config = function()
    require('rnoweb-nvim').setup()

    -- Set some of my own symbols that are likely not in anyone else's docs
    local sym = require('rnoweb-nvim.symbols')
    sym.set_sym("latex", "\\gi",    {"g⁻¹"})
    sym.set_sym("latex", "\\@",     {""})
    sym.set_sym("latex", '\\CE',    {"CE"})
    sym.set_sym("latex", '\\CS',    {"ECS"})
    sym.set_sym("latex", '\\Pr',    {"Pr"})
    sym.set_sym("latex", '\\pr',    {"Pr(", ")"})
    sym.set_sym("latex", "\\email", {"✉ :", ""})
    sym.set_sym("latex", "\\gbar",  {"(",   " ︳", ")"})
    sym.set_sym("latex", "\\gbar*", {"",    " ︳", ""})

  end
}
```

The user-configuration function `set_sym` takes as first argument the name of
the language that tree-sitter will be using (basically always latex), and then
the command to be concealed, and finally a table with up to n + 1 entries where
n is the number of arguments for the command.

The first entry will replace the beginning of the command up to the first
brace, the second entry will replace the first closing argument brace and (if
applicable) the second opening brace, the third argument will replace the
second closing brace and (if applicable) the third opening brace, etc. Thus,
note that fields 2+ can only be of length 2 or less.

# PythonTeX Support

The plugin supports [PythonTeX](https://github.com/gpoore/pythontex) documents with the following features:

### Inline Code Substitution

After compiling your PythonTeX document, inline `\py{...}` commands will be
replaced with their computed results. The plugin reads from the
`pythontex-files-<jobname>/` directory that PythonTeX creates.

### Compilation

Use the `:CompilePythonTeX` command to compile your document. This runs
`latexmk -pdf -shell-escape` on the current file.

For automatic PythonTeX support with latexmk, add the following to your `~/.latexmkrc`:

```perl
# PythonTeX support for latexmk
add_cus_dep('pytxcode', 'tex', 0, 'pythontex');
sub pythontex {
    return system("pythontex \"$_[0]\"");
}

# Enable shell-escape by default (required for PythonTeX)
$pdflatex = 'pdflatex -shell-escape %O %S';
```

This tells latexmk to automatically run `pythontex` when the `.pytxcode` file
changes, handling the three-step compilation process (pdflatex → pythontex →
pdflatex) automatically.

### PythonTeX Commands

The following PythonTeX commands are concealed:

| Command | Conceal | Description |
|---------|---------|-------------|
| `\py{expr}` | Shows computed result | Inline expression |
| `\pyc{code}` | `⌘` | Execute code |
| `\pys{code}` | Hides braces | Substitution |
| `\pyb{code}` | Hides braces | Execute and prettyprint |
| `\pyv{code}` | Hides braces | Prettyprint only |

# Rnoweb Support

For Rnoweb documents, use the `:CompileRnw` command to compile. This runs
knitr followed by latexmk.

Inline `\Sexpr{}` results are read from the `./inline/` directory (you need to
configure knitr to output inline results there).

# Commands

| Command | Description |
|---------|-------------|
| `:CompileRnw` | Compile Rnoweb file (knitr + latexmk) |
| `:CompilePythonTeX` | Compile PythonTeX file (latexmk with pythontex) |

# Screenshots

Some example LaTeX without the plugin:

![Without Plugin](readme_media/off.png)

With the plugin, note numbered equations, sub and superscripts, numbered
footnotes, citation concealment, and inline replacement of `\newcommand` that
defines a text-only replacement:
![With Plugin](readme_media/on.png)
