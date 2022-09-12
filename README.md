# rnoweb-nvim

A Neovim plugin to conceal commands in Rnoweb and LaTeX documents using Treesitter and Extmarks.

The plugin aims to be substantially quicker than an equivalent using regular
regex concealing (e.g. with the illustrious
[VimTex](https://github.com/lervag/vimtex) plugin).

This plugin also aims to provide niceties to Rnoweb documents (the main reason
I created it). In particular, inline code segments are replaced in-document
provided that their results are included in a `inline` directory.

### Goals
[🗸] - Be fast. This means using treesitter to do the heavy lifting  
[🗸] - Multi-character conceal  
[🗸] - Work with Rnoweb or stand-alone Latex  
[🗸] - Conceal latex symbols and provide interface for users to specify their own conceals  
[🗸] - Basic citation conceal  
[🗸] - Inline code substitution for rnoweb  
[x] - Equation numbering  
[ ] - Figure numbering  
[ ] - General environment numbering  

### Improvements
[ ] - Citation conceal with bibliography lookup and hopefully the anti-conceal functionality. Not doing this before anti-conceal is mainlined.  
[ ] - Constant improvements in equation and environment numbering  

# Installation and User Configuration

The following should work with packer. Note that I also configure some
user-specific replacements that appear in the following screenshots. There
aren't necessary for the plugin to work out of the box.

```{lua}

use { 'bamonroe/rnoweb-nvim',
  requires = {
    'nvim-lua/plenary.nvim'
  },
  config = function()  
		local rnw = require('rnoweb-nvim')
		rnw.setup()
		-- Below is user-specific, put your own replacements here
		rnw.symbols.set_sym("latex", "\\gi",    {"g⁻¹"})
		rnw.symbols.set_sym("latex", "\\@",     {""})
		rnw.symbols.set_sym("latex", '\\CE',    {"CE"})
		rnw.symbols.set_sym("latex", '\\CS',    {"CS"})
		rnw.symbols.set_sym("latex", '\\Pr',    {"Pr"})
		rnw.symbols.set_sym("latex", '\\pr',    {"Pr(", ")"})
		rnw.symbols.set_sym("latex", "\\email", {"✉ :", ""})
		rnw.symbols.set_sym("latex", "\\gbar",  {"(",   " ︳", ")"})
		rnw.symbols.set_sym("latex", "\\gbar*", {"",    " ︳", ""})

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


# Screenshots

Some text from an article I'm writing showing off the citation replacement:

Without Plugin:  
![Without Plugin](citation_noplugin.png)

With Plugin:  
![With Plugin](citation_plugin.png)


Some equation environments from the same article. Note the attempt at counting
equation numbers and displaying the numbers in virtual text.

Without Plugin:  
![Without Plugin](math_noplugin.png)

With Plugin:  
![With Plugin](math_plugin.png)

