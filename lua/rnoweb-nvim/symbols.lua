local ts = vim.treesitter
local q  = vim.treesitter.query
local info  = require'rnoweb-nvim.info'

local M = {
  sym = {
    r      = {},
    latex  = {},
    rnoweb = {},
  },
  lang_queries = {
    rnoweb = {"rnoweb", "r", "latex"},
    latex = {"latex"},
  },
  queries = {
    r      = {},
    latex  = {},
    rnoweb = {},
  },
}

-- Not many rnoweb queies available
table.insert(M.queries.rnoweb, {
  fn    = "conceal_cmd",
  query = "(rinline) @cmd",
})

M.sym.rnoweb["\\Sexpr"]  = {"ﳒ"}

-- Lots for Latex
table.insert(M.queries.latex, {
  fn    = "conceal_cmd",
  query = "(generic_command (command_name)) @cmd",
})

table.insert(M.queries.latex, {
  fn    = "citation",
  query = "(citation) @cite",
})
table.insert(M.queries.latex, {
  fn    = "mdelimit",
  query = "(math_delimiter) @math",
})

table.insert(M.queries.latex, {
  fn    = "text_mode",
  query = [[
    (text_mode) @cmd
  ]],
})

table.insert(M.queries.latex, {
  fn    = "single_hat",
  query = [[
    (generic_command
      (command_name) @cmd (#eq? @cmd "\\hat") (#set! @cmd "ignore" "true")
      (curly_group
        (text) @tval (#any-of? @tval "a" "A" "c" "C" "e" "E" "g" "G" "i" "I" "o" "O" "s" "S" "u" "U" "w" "W" "y" "Y")
      )
    )
  ]],
})

table.insert(M.queries.latex, {
  fn    = "footnote",
  query = [[
    (generic_command
     (command_name) @cmd (#eq? @cmd "\\footnote")
    )
  ]],
})

table.insert(M.queries.latex, {
  fn    = "fig_lab_count",
  query = [[
    (generic_environment
      (begin
        (curly_group_text
          (text
            (word) @ename (#eq? @ename "figure") (#set! @ename "ignore" "true")
          )
        )
      )
      (label_definition
        (curly_group_text
          (text) @figlab
        )
      )
    )
  ]],
})

table.insert(M.queries.latex, {
  fn    = "section_count",
  query = [[
    (section) @sec
  ]],
})

table.insert(M.queries.latex, {
  fn    = "math_count",
  query = [[
    (math_environment) @sec
  ]],
})

table.insert(M.queries.latex, {
  fn    = "ref",
  query = [[
    (label_reference
      (curly_group_text_list
        (text)
      )
    ) @ref
  ]],
})



-- Sub/superscripts are a bit of a pain to capture

table.insert(M.queries.latex, {
  fn    = "subsuper",
  query = [[
    (inline_formula
      (text (word) @formula (#match? @formula ".*\\^") (#set! @formula "ignore" "true"))
      (curly_group) @tval (#set! @tval "kind" "superscript")
    )
  ]],
})
table.insert(M.queries.latex, {
  fn    = "subsuper",
  query = [[
    (inline_formula
      (text (word) @formula (#match? @formula ".*_") (#set! @formula "ignore" "true"))
      (curly_group) @tval (#set! @tval "kind" "subscript")
    )
  ]],
})
table.insert(M.queries.latex, {
  fn    = "subsuper",
  query = [[
    (inline_formula
      (text (word) @formula (#match? @formula ".*\\^.") (#set! @formula "kind" "superscript"))
    )
  ]],
})
table.insert(M.queries.latex, {
  fn    = "subsuper",
  query = [[
    (inline_formula
      (text (word) @formula (#match? @formula ".*_.") (#set! @formula "kind" "subscript"))
    )
  ]],
})


table.insert(M.queries.latex, {
  fn    = "subsuper",
  query = [[
    (math_environment
      (text (word) @formula (#match? @formula ".*\\^") (#set! @formula "ignore" "true"))
      (curly_group) @tval (#set! @tval "kind" "superscript")
    )
  ]],
})
table.insert(M.queries.latex, {
  fn    = "subsuper",
  query = [[
    (math_environment
      (text (word) @formula (#match? @formula ".*_") (#set! @formula "ignore" "true"))
      (curly_group) @tval (#set! @tval "kind" "subscript")
    )
  ]],
})
table.insert(M.queries.latex, {
  fn    = "subsuper",
  query = [[
    (math_environment
      (text (word) @formula (#match? @formula ".*\\^.") (#set! @formula "kind" "superscript"))
    )
  ]],
})
table.insert(M.queries.latex, {
  fn    = "subsuper",
  query = [[
    (math_environment
      (text (word) @formula (#match? @formula ".*_.") (#set! @formula "kind" "subscript"))
    )
  ]],
})

table.insert(M.queries.latex, {
  fn    = "subsuper",
  query = [[
    (math_delimiter
      (text (word) @formula (#match? @formula ".*\\^") (#set! @formula "ignore" "true"))
      (curly_group) @tval (#set! @tval "kind" "superscript")
    )
  ]],
})
table.insert(M.queries.latex, {
  fn    = "subsuper",
  query = [[
    (math_delimiter
      (text (word) @formula (#match? @formula ".*_") (#set! @formula "ignore" "true"))
      (curly_group) @tval (#set! @tval "kind" "subscript")
    )
  ]],
})
table.insert(M.queries.latex, {
  fn    = "subsuper",
  query = [[
    (math_delimiter
      (text (word) @formula (#match? @formula ".*\\^.") (#set! @formula "kind" "superscript"))
    )
  ]],
})
table.insert(M.queries.latex, {
  fn    = "subsuper",
  query = [[
    (math_delimiter
      (text (word) @formula (#match? @formula ".*_.") (#set! @formula "kind" "subscript"))
    )
  ]],
})



-- Lots of latex replacements
-- Start with the greeks
M.sym.latex['\\alpha']    = {{"α"}}
M.sym.latex['\\beta']     = {{"β"}}
M.sym.latex["\\delta"]    = {{"δ"}}
M.sym.latex["\\chi"]      = {{"χ"}}
M.sym.latex['\\eta']      = {{"η"}}
M.sym.latex['\\epsilon']  = {{"ε"}}
M.sym.latex["\\gamma"]    = {{"γ"}}
M.sym.latex["\\iota"]     = {{"ι"}}
M.sym.latex["\\kappa"]    = {{"κ"}}
M.sym.latex['\\lambda']   = {{"λ"}}
M.sym.latex['\\mu']       = {{"μ"}}
M.sym.latex['\\nu']       = {{"ν"}}
M.sym.latex['\\omicron']  = {{"ο"}}
M.sym.latex['\\omega']    = {{"ω"}}
M.sym.latex['\\phi']      = {{"φ"}}
M.sym.latex['\\pi']       = {{"π"}}
M.sym.latex['\\psi']      = {{"ψ"}}
M.sym.latex['\\rho']      = {{"ρ"}}
M.sym.latex['\\sigma']    = {{"σ"}}
M.sym.latex['\\tau']      = {{"τ"}}
M.sym.latex["\\theta"]    = {{"θ"}}
M.sym.latex["\\upsilon"]  = {{"υ"}}
M.sym.latex['\\varsigma'] = {{"ς"}}
M.sym.latex['\\xi']       = {{"ξ"}}
M.sym.latex['\\zeta']     = {{"ζ"}}

M.sym.latex['\\Delta']  = {{"Δ"}}
M.sym.latex['\\Gamma']  = {{"Γ"}}
M.sym.latex['\\Theta']  = {{"Θ"}}
M.sym.latex['\\Lambda'] = {{"Λ"}}
M.sym.latex['\\Omega']  = {{"Ω"}}
M.sym.latex['\\Phi']    = {{"Φ"}}
M.sym.latex['\\Pi']     = {{"Π"}}
M.sym.latex['\\Psi']    = {{"Ψ"}}
M.sym.latex['\\Sigma']  = {{"Σ"}}

-- Binary operation symbols
M.sym.latex['\\pm']     = {{"±"}}
M.sym.latex['\\mp']     = {{"∓ "}}
M.sym.latex['\\times']  = {{""}}
M.sym.latex['\\div']    = {{"÷"}}
M.sym.latex['\\ast']    = {{"∗ "}}
M.sym.latex['\\star']   = {{"⋆"}}
M.sym.latex['\\circ']   = {{"◦"}}
M.sym.latex['\\bullet'] = {{"•"}}
M.sym.latex['\\cdot']   = {{"·"}}

M.sym.latex['\\cap']      = {{"∩"}}
M.sym.latex['\\cup']      = {{"∪"}}
M.sym.latex['\\uplus']    = {{"⊎"}}
M.sym.latex['\\sqcap']    = {{"⊓"}}
M.sym.latex['\\sqcup']    = {{"⊔"}}
M.sym.latex['\\vee']      = {{"⋁ "}}
M.sym.latex['\\wedge']    = {{"⋀ "}}
M.sym.latex['\\setminus'] = {{"\\"}}
M.sym.latex['\\wr']       = {{"≀"}}

M.sym.latex['\\diamond']         = {{"⋄"}}
M.sym.latex['\\bigtriangleup']   = {{"△ "}}
M.sym.latex['\\bigtriangledown'] = {{"▽"}}
M.sym.latex['\\triangleleft']    = {{"◃"}}
M.sym.latex['\\triangleright']   = {{"▹"}}
M.sym.latex['\\lhd']             = {{"◁ "}}
M.sym.latex['\\rhd']             = {{"▷ "}}
M.sym.latex['\\unlhd']           = {{"⊴ "}}
M.sym.latex['\\unrhd']           = {{"⊵ "}}

M.sym.latex['\\oplus']   = {{"⊕ "}}
M.sym.latex['\\ominus']  = {{"⊖ "}}
M.sym.latex['\\otimes']  = {{"⊗ "}}
M.sym.latex['\\oslash']  = {{"⊘ "}}
M.sym.latex['\\odot']    = {{"⊙ "}}
M.sym.latex['\\bigcirc'] = {{"◯ "}}
M.sym.latex['\\dagger']  = {{"†"}}
M.sym.latex['\\ddagger'] = {{"‡"}}
M.sym.latex['\\amalg']   = {{"⨿"}}

-- Relation symbols
M.sym.latex['\\leq']        = {{"≤"}}
M.sym.latex['\\prec']       = {{"≺ "}}
M.sym.latex['\\ll']         = {{"≪ "}}
M.sym.latex['\\preceq']     = {{"⪯ "}}
M.sym.latex['\\subset']     = {{"⊂ "}}
M.sym.latex['\\supseteq']   = {{"⊇ "}}
M.sym.latex['\\sqsubset']   = {{"⊏ "}}
M.sym.latex['\\sqsubseteq'] = {{"⊑ "}}
M.sym.latex['\\in']         = {{"∈ "}}
M.sym.latex['\\vdash']      = {{"⊢ "}}

M.sym.latex['\\geq']        = {{"≥"}}
M.sym.latex['\\succ']       = {{"≻ "}}
M.sym.latex['\\succeq']     = {{"⪰ "}}
M.sym.latex['\\gg']         = {{"≫ "}}
M.sym.latex['\\supset']     = {{"⊃ "}}
M.sym.latex['\\subseteq']   = {{"⊆ "}}
M.sym.latex['\\sqsupset']   = {{"⊐ "}}
M.sym.latex['\\sqsupseteq'] = {{"⊒ "}}
M.sym.latex['\\ni']         = {{"∋ "}}
M.sym.latex['\\dashv']      = {{"⊣ "}}

M.sym.latex['\\equiv']  = {{"≡ "}}
M.sym.latex['\\sim']    = {{"∼ "}}
M.sym.latex['\\simeq']  = {{"≃ "}}
M.sym.latex['\\asymp']  = {{"≍ "}}
M.sym.latex['\\approx'] = {{"≈"}}
M.sym.latex['\\cong']   = {{"≅"}}
M.sym.latex['\\neq']    = {{"≠"}}
M.sym.latex['\\doteq']  = {{"≐ "}}
M.sym.latex['\\propto'] = {{"∝"}}

M.sym.latex['\\models']   = {{"⊧"}}
M.sym.latex['\\perp']     = {{"⊥ "}}
M.sym.latex['\\mid']      = {{"|"}}
M.sym.latex['\\parallel'] = {{"∥"}}
M.sym.latex['\\bowtie']   = {{"⨝ "}}
M.sym.latex['\\Join']     = {{"⋈ "}}
M.sym.latex['\\smile']    = {{"⌣ "}}
M.sym.latex['\\frown']    = {{"⌢ "}}

-- Arrows
M.sym.latex['\\leftarrow']          = {{"← "}}
M.sym.latex['\\longleftarrow']      = {{"⟵  "}}
M.sym.latex['\\uparrow']            = {{"↑ "}}
M.sym.latex['\\Leftarrow']          = {{"⇐ "}}
M.sym.latex['\\Longleftarrow']      = {{"⟸  "}}
M.sym.latex['\\Uparrow']            = {{"⇑ "}}
M.sym.latex['\\rightarrow']         = {{"→ "}}
M.sym.latex['\\longrightarrow']     = {{"⟶  "}}
M.sym.latex['\\downarrow']          = {{"↓ "}}
M.sym.latex['\\Rightarrow']         = {{"⇒ "}}
M.sym.latex['\\Longrightarrow']     = {{"⟹  "}}
M.sym.latex['\\Downarrow']          = {{"⇓ "}}
M.sym.latex['\\leftrightarrow']     = {{"↔ "}}
M.sym.latex['\\longleftrightarrow'] = {{"⟷  "}}
M.sym.latex['\\updownarrow']        = {{"↕ "}}
M.sym.latex['\\Leftrightarrow']     = {{"⇔ "}}
M.sym.latex['\\Longleftrightarrow'] = {{"⟺  "}}
M.sym.latex['\\Updownarrow']        = {{"⇕ "}}
M.sym.latex['\\mapsto']             = {{"↦ "}}
M.sym.latex['\\longmapsto']         = {{"⟼  "}}
M.sym.latex['\\nearrow']            = {{"↗ "}}
M.sym.latex['\\hookleftarrow']      = {{"↩ "}}
M.sym.latex['\\hookrightarrow']     = {{"↪ "}}
M.sym.latex['\\searrow']            = {{"↘ "}}
M.sym.latex['\\leftharpoonup']      = {{"↼ "}}
M.sym.latex['\\rightharpoonup']     = {{"⇀ "}}
M.sym.latex['\\swarrow']            = {{"↙ "}}
M.sym.latex['\\leftharpoondown']    = {{"↽ "}}
M.sym.latex['\\rightharpoondown']   = {{"⇁ "}}
M.sym.latex['\\nwarrow']            = {{"↖ "}}
M.sym.latex['\\rightleftharpoons']  = {{"⇌ "}}

-- Math things
M.sym.latex['\\over']        = {{"/"}}
M.sym.latex['\\partial']     = {{"∂"}}
M.sym.latex['\\infty']       = {{"∞"}}
M.sym.latex['\\succcurlyeq'] = {{"≽"}}
M.sym.latex['\\preccurlyeq'] = {{"≼"}}
M.sym.latex['\\int']         = {{"∫"}}
M.sym.latex['\\sum']         = {{"∑"}}
M.sym.latex['\\ln']          = {{"ln"}}
M.sym.latex['\\exp']         = {{"ℯ"}}
M.sym.latex['\\forall']      = {{"∀"}}
M.sym.latex['\\exists']      = {{"∃"}}
M.sym.latex['\\sqrt']        = {{"√"}}

M.sym.latex['\\lbrace'] = {{"{"}}
M.sym.latex['\\rbrace'] = {{"}"}}
M.sym.latex['\\{']      = {{"{"}}
M.sym.latex['\\}']      = {{"}"}}


-- Non-greeks
--M.sym.latex['\\footnote'] = {"*"}
M.sym.latex["\\ldots"]    = {{"…"}}
M.sym.latex["\\\\"]       = {{"↲ "}}

-- Spacing commands
M.sym.latex['\\qquad'] = {{"    "}}
M.sym.latex['\\quad']  = {{"   "}}
M.sym.latex['\\;']     = {{"  "}}
M.sym.latex['\\,']     = {{" "}}
M.sym.latex['\\:']     = {{" "}}
M.sym.latex['\\>']     = {{" "}}
M.sym.latex['\\space'] = {{" "}}
M.sym.latex['\\ ']     = {{" "}}
M.sym.latex['\\!']     = {{""}}

-- Hide the escaping backslash with some
M.sym.latex['\\%']     = {{"%"}}
M.sym.latex['\\&']     = {{"&"}}

-- Just remove some things
M.sym.latex['\\displaystyle'] = {{""}}
M.sym.latex['\\noindent']     = {{""}}
M.sym.latex['\\textcite']     = {{""}}
M.sym.latex['\\parencite']    = {{""}}
M.sym.latex['\\left']         = {{""}}
M.sym.latex['\\right']        = {{""}}
M.sym.latex['\\textbf']       = {{"", ""}}

-- Commands with arguments
M.sym.latex["\\enquote"]  = {{"“", "”"}}
M.sym.latex["\\textelp"]  = {{"…", ""}}
M.sym.latex["\\textins"]  = {{"[", "]"}}
M.sym.latex["\\textit"]   = {{"",  ""}}
M.sym.latex["\\mathit"]   = {{"",  ""}}
M.sym.latex["\\text"]     = {{"",  ""}}
M.sym.latex["\\begin"]    = {{"[",  "]"}}
M.sym.latex["\\frac"]     = {{"(",  "╱ ", ")"}}
M.sym.latex["\\nicefrac"] = {{"(",  "╱ ", ")"}}
M.sym.latex["\\dfrac"]    = {{"(",  "╱ ", ")"}}
M.sym.latex["\\'"]        = {{"",  ""}}

-- Latex mappings can also include the underscored
--for k, _ in pairs(M.sym.latex) do
--  M.sym.latex[k .. "_"] = {M.sym.latex[k][1] .. "_"}
--end

-- I use this to set project specific replacements
M.set_sym = function(lang, key, sym)
  if M.sym[lang] == nil then
    M.sym[lang] = {}
  end

  M.sym[lang][key] = sym
end

M.get_sym_text = function(lang, cmd, node)
  local ldict = M.sym[lang]
  if ldict[cmd] == nil then
    return nil
  end
  local cdict = M.sym[lang][cmd]
  if #cdict == 1 or cdict["fn"] == nil then
    return cdict[1]
  end
end

M.set_query = function(lang, key, query)
  if M.sym[lang] == nil then
    M.sym[lang] = {}
  end
  M.sym[lang][key] = query
end


-- Sometimes I define new macros that are just text shortcuts
-- Let's find those newcommands and define them as simple conceals
local get_inline_text_macros = function(root, bufnr)

  local query = [[
    (new_command_definition
      (curly_group_command_name
        (command_name) @cname
      )
      (curly_group
        (text) @text
      )
    )
  ]]
  query = q.parse("latex", query)

  for _, match, _ in query:iter_matches(root, bufnr) do
    local key = ""
    for id, node in pairs(match) do
      if id == 1 then
        key = ts.get_node_text(node, 0)
        M.sym.latex[key] = {}
      else
        local val = ts.get_node_text(node, 0)

        local klen = string.len(key)
        local vlen = string.len(val)

        if vlen > klen then
          val = string.sub(val, 1, klen)
        end

        -- I'm making this two arguments to get rid of possible braces
        M.sym.latex[key] = {val, ""}
      end
    end
  end

end

-- Get the queries applicable to this filetype
M.get_queries = function(root, bufnr)

  -- Get any inline latex macros
  get_inline_text_macros(root, bufnr)

  local out = {}
  for _, lang in pairs(M.lang_queries[info.ft]) do
    for _, k in ipairs(M.queries[lang]) do
      local name  = k["fn"]
      local query = k["query"]
      query = q.parse(lang, query)
      out[#out+1] = {
        cmd   = name,
        lang  = lang,
        match = query:iter_matches(root, bufnr)
      }
    end
  end
  return pairs(out)
end

return M
