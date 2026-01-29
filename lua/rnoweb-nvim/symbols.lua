local q  = vim.treesitter.query
local info  = require'rnoweb-nvim.info'
local super = require'rnoweb-nvim.super_list'
local h     = require'rnoweb-nvim.helpers'

-- Cache for compiled treesitter queries
local compiled_queries = {}

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

-- Rnoweb-specific queries
table.insert(M.queries.rnoweb, {
  fn    = "conceal_cmd",
  query = "(rinline) @cmd",
})

-- Rnoweb symbol for \Sexpr
M.sym.rnoweb["\\Sexpr"]  = {"ﳒ"}

-- PythonTeX symbols (these are LaTeX commands, so go in latex table)
-- \py{expr} - prints value of expression
M.sym.latex["\\py"]      = {{"", ""}}
-- \pyc{code} - executes code
M.sym.latex["\\pyc"]     = {{"⌘", ""}}
-- \pys{code} - substitution
M.sym.latex["\\pys"]     = {{"", ""}}
-- \pyb{code} - execute and prettyprint
M.sym.latex["\\pyb"]     = {{"", ""}}
-- \pyv{code} - prettyprint code only
M.sym.latex["\\pyv"]     = {{"", ""}}

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
    [
      (section)
      (subsection)
    ] @sec
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
    (superscript
      (curly_group
        (text)
      ) @tval (#set! @tval "kind" "superscript")
    )
  ]],
})

---[===[
table.insert(M.queries.latex, {
  fn    = "subsuper",
  query = [[
    (subscript
      (curly_group
        (text)
      ) @tval (#set! @tval "kind" "subscript")
    )
  ]],
})

table.insert(M.queries.latex, {
  fn = "subsuper",
  query = [[
    (superscript
    (_) @tval
    (#set! @tval "kind" "superscript")
    )
  ]],
})

table.insert(M.queries.latex, {
  fn = "subsuper",
  query = [[
    (subscript
    (_) @tval
    (#set! @tval "kind" "subscript")
    )
  ]],
})

--]===]


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

M.sym.latex["\\varepsilon"]  = {{"ε"}}
M.sym.latex["\\backepsilon"] = {{"϶"}}
M.sym.latex["\\varphi"]      = {{"φ"}}
M.sym.latex["\\vartheta"]    = {{"ϑ"}}
M.sym.latex["\\varpi"]       = {{"ϖ"}}
M.sym.latex["\\digamma"]     = {{"ϝ"}}
M.sym.latex["\\varkappa"]    = {{"ϰ"}}
M.sym.latex["\\varrho"]      = {{"ϱ"}}

M.sym.latex['\\Delta']   = {{"Δ"}}
M.sym.latex['\\Gamma']   = {{"Γ"}}
M.sym.latex['\\Theta']   = {{"Θ"}}
M.sym.latex['\\Lambda']  = {{"Λ"}}
M.sym.latex['\\Omega']   = {{"Ω"}}
M.sym.latex['\\Phi']     = {{"Φ"}}
M.sym.latex['\\Pi']      = {{"Π"}}
M.sym.latex['\\Psi']     = {{"Ψ"}}
M.sym.latex['\\Sigma']   = {{"Σ"}}
M.sym.latex["\\Xi"]      = {{"Ξ"}}
M.sym.latex["\\Upsilon"] = {{"Υ"}}

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
M.sym.latex["\\land"]     = {{"∧"}}
M.sym.latex["\\lor"]      = {{"∨"}}

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
M.sym.latex["\\owns"]       = {{"∋"}}
M.sym.latex["\\le"]         = {{"≤"}}
M.sym.latex["\\ge"]         = {{"≥"}}
M.sym.latex["\\ne"]         = {{"≠"}}
M.sym.latex["\\leqq"]       = {{"≦"}}
M.sym.latex["\\geqq"]       = {{"≧"}}
M.sym.latex["\\ngtr"]       = {{"≯"}}
M.sym.latex["\\nleq"]       = {{"≰"}}
M.sym.latex["\\ngeq"]       = {{"≱"}}
M.sym.latex["\\lesssim"]    = {{"≲"}}
M.sym.latex["\\gtrsim"]     = {{"≳"}}
M.sym.latex["\\nlesssim"]   = {{"≴"}}
M.sym.latex["\\ngtrsim"]    = {{"≵"}}
M.sym.latex["\\lessgtr"]    = {{"≶"}}
M.sym.latex["\\gtrless"]    = {{"≷"}}
M.sym.latex["\\nlessgtr"]   = {{"≸"}}
M.sym.latex["\\ngtrless"]   = {{"≹"}}
M.sym.latex["\\precsim"]    = {{"≾"}}
M.sym.latex["\\succsim"]    = {{"≿"}}
M.sym.latex["\\nprec"]      = {{"⊀"}}
M.sym.latex["\\nsucc"]      = {{"⊁"}}
M.sym.latex["\\nsubset"]    = {{"⊄"}}
M.sym.latex["\\nsupset"]    = {{"⊅"}}
M.sym.latex["\\nsubseteq"]  = {{"⊈"}}
M.sym.latex["\\nsupseteq"]  = {{"⊉"}}
M.sym.latex["\\subsetneq"]  = {{"⊊"}}
M.sym.latex["\\supsetneq"]  = {{"⊋"}}

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
M.sym.latex["\\gets"]               = {{"←"}}
M.sym.latex["\\to"]                 = {{"→"}}
M.sym.latex["\\nleftarrow"]          = {{"↚"}}
M.sym.latex["\\nrightarrow"]         = {{"↛"}}
M.sym.latex["\\twoheadleftarrow"]    = {{"↞"}}
M.sym.latex["\\twoheadrightarrow"]   = {{"↠"}}
M.sym.latex["\\leftarrowtail"]       = {{"↢"}}
M.sym.latex["\\rightarrowtail"]      = {{"↣"}}
M.sym.latex["\\mapsfrom"]            = {{"↤"}}
M.sym.latex["\\looparrowleft"]       = {{"↫"}}
M.sym.latex["\\looparrowright"]      = {{"↬"}}
M.sym.latex["\\leftrightsquigarrow"] = {{"↭"}}
M.sym.latex["\\nleftrightarrow"]     = {{"↮"}}
M.sym.latex["\\curvearrowleft"]    = {{"↶"}}
M.sym.latex["\\curvearrowright"]   = {{"↷"}}
M.sym.latex["\\circlearrowleft"]   = {{"↺"}}
M.sym.latex["\\circlearrowright"]  = {{"↻"}}
M.sym.latex["\\upharpoonright"]    = {{"↾"}}
M.sym.latex["\\restriction"]       = {{"↾"}}
M.sym.latex["\\upharpoonleft"]     = {{"↿"}}
M.sym.latex["\\downharpoonright"]  = {{"⇂"}}
M.sym.latex["\\downharpoonleft"]   = {{"⇃"}}
M.sym.latex["\\rightleftarrows"]   = {{"⇄"}}
M.sym.latex["\\updownarrows"]      = {{"⇅"}}
M.sym.latex["\\leftrightarrows"]   = {{"⇆"}}
M.sym.latex["\\leftleftarrows"]    = {{"⇇"}}
M.sym.latex["\\upuparrows"]        = {{"⇈"}}
M.sym.latex["\\rightrightarrows"]  = {{"⇉"}}
M.sym.latex["\\downdownarrows"]    = {{"⇊"}}
M.sym.latex["\\leftrightharpoons"] = {{"⇋"}}
M.sym.latex["\\nLeftarrow"]        = {{"⇍"}}
M.sym.latex["\\nLeftrightarrow"]   = {{"⇎"}}
M.sym.latex["\\nRightarrow"]       = {{"⇏"}}
M.sym.latex["\\Nwarrow"]           = {{"⇖"}}
M.sym.latex["\\Nearrow"]           = {{"⇗"}}
M.sym.latex["\\Searrow"]           = {{"⇘"}}
M.sym.latex["\\Swarrow"]           = {{"⇙"}}
M.sym.latex["\\Lleftarrow"]        = {{"⇚"}}
M.sym.latex["\\Rrightarrow"]       = {{"⇛"}}
M.sym.latex["\\leftsquigarrow"]    = {{"⇜"}}
M.sym.latex["\\rightsquigarrow"]   = {{"⇝"}}
M.sym.latex["\\dashleftarrow"]     = {{"⇠"}}
M.sym.latex["\\dashrightarrow"]    = {{"⇢"}}
M.sym.latex["\\LeftArrowBar"]      = {{"⇤"}}
M.sym.latex["\\RightArrowBar"]     = {{"⇥"}}
M.sym.latex["\\downuparrows"]      = {{"⇵"}}
M.sym.latex["\\Lsh"]               = {{"↰"}}
M.sym.latex["\\Rsh"]               = {{"↱"}}

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
M.sym.latex["\\sqrt[3]"]     = {{"∛"}}
M.sym.latex["\\sqrt[4]"]     = {{"∜"}}

M.sym.latex['\\cos']    = {{"cos"}}
M.sym.latex['\\tan']    = {{"tan"}}
M.sym.latex['\\sin']    = {{"sin"}}
M.sym.latex['\\arccos'] = {{"arccos"}}
M.sym.latex['\\arctan'] = {{"arctan"}}
M.sym.latex['\\arcsin'] = {{"arcsin"}}

M.sym.latex['\\lbrace'] = {{"{"}}
M.sym.latex['\\rbrace'] = {{"}"}}
M.sym.latex['\\{']      = {{"{"}}
M.sym.latex['\\}']      = {{"}"}}


-- Non-greeks
M.sym.latex["\\therefore"] = {{"∴"}}
M.sym.latex["\\ldots"]   = {{"…"}}
M.sym.latex["\\\\"]      = {{"↲ "}}
M.sym.latex["\\nabla"]   = {{"∇"}}
M.sym.latex["\\because"] = {{"∵"}}
M.sym.latex["\\vdots"]   = {{"⋮"}}
M.sym.latex["\\cdots"]   = {{"⋯"}}
M.sym.latex["\\ddots"]   = {{"⋱"}}

M.sym.latex["\\ntrianglerighteq"] = {{"⋭"}}
M.sym.latex["\\hermitconjmatrix"] = {{"⊹"}}
M.sym.latex["\\vartriangleright"] = {{"⊳"}}
M.sym.latex["\\sphericalangle"] = {{"∢"}}
M.sym.latex["\\smallsetminus"] = {{"∖"}}
M.sym.latex["\\measuredangle"] = {{"∡"}}
M.sym.latex["\\fallingdotseq"] = {{"≒"}}
M.sym.latex["\\risingdotseq"] = {{"≓"}}
M.sym.latex["\\corresponds"] = {{"≙"}}
M.sym.latex["\\circledcirc"] = {{"⊚"}}

M.sym.latex["\\circledast"] = {{"⊛"}}
M.sym.latex["\\complement"] = {{"∁"}}
M.sym.latex["\\varnothing"] = {{"∅"}}

M.sym.latex["\\nexists"]  = {{"∄"}}
M.sym.latex["\\notin"]    = {{"∉"}}
M.sym.latex["\\prod"]     = {{"∏"}}
M.sym.latex["\\coprod"]   = {{"∐"}}
M.sym.latex["\\minus"]    = {{"−"}}
M.sym.latex["\\dotplus"]  = {{"∔"}}
M.sym.latex["\\divslash"] = {{"∕"}}
M.sym.latex["\\angle"]    = {{"∠"}}
M.sym.latex["\\iint"]     = {{"∬"}}
M.sym.latex["\\iiint"]    = {{"∭"}}
M.sym.latex["\\oint"]     = {{"∮"}}
M.sym.latex["\\backsim"]  = {{"∽"}}
M.sym.latex["\\nsim"]     = {{"≁"}}
M.sym.latex["\\eqsim"]    = {{"≂"}}
M.sym.latex["\\napprox"]  = {{"≉"}}
M.sym.latex["\\approxeq"] = {{"≊"}}
M.sym.latex["\\Bumpeq"]   = {{"≎"}}
M.sym.latex["\\bumpeq"]   = {{"≏"}}
M.sym.latex["\\coloneq"]  = {{"≔"}}
M.sym.latex["\\eqcolon"]  = {{"≕"}}
M.sym.latex["\\eqcirc"]   = {{"≖"}}
M.sym.latex["\\circeq"]   = {{"≗"}}
M.sym.latex["\\top"]      = {{"⊤"}}
M.sym.latex["\\bot"]      = {{"⊥"}}
M.sym.latex["\\vDash"]    = {{"⊨"}}
M.sym.latex["\\Vvdash"]   = {{"⊪"}}
M.sym.latex["\\VDash"]    = {{"⊫"}}
M.sym.latex["\\nvdash"]   = {{"⊬"}}
M.sym.latex["\\nvDash"]   = {{"⊭"}}
M.sym.latex["\\nVdash"]   = {{"⊮"}}
M.sym.latex["\\nVDash"]   = {{"⊯"}}
M.sym.latex["\\prurel"]   = {{"⊰"}}

M.sym.latex["\\vartriangleleft"] = {{"⊲"}}
M.sym.latex["\\trianglerighteq"] = {{"⊵"}}
M.sym.latex["\\trianglelefteq"]  = {{"⊴"}}
M.sym.latex["\\original"]        = {{"⊶"}}
M.sym.latex["\\image"]           = {{"⊷"}}
M.sym.latex["\\multimap"]        = {{"⊸"}}
M.sym.latex["\\intercal"]        = {{"⊺"}}
M.sym.latex["\\veebar"]          = {{"⊻"}}
M.sym.latex["\\barwedge"]        = {{"⊼"}}
M.sym.latex["\\barvee"]          = {{"⊽"}}
M.sym.latex["\\rightanglearc"]   = {{"⊾"}}
M.sym.latex["\\varlrtriangle"]   = {{"⊿"}}
M.sym.latex["\\bigwedge"]        = {{"⋀"}}
M.sym.latex["\\bigvee"]          = {{"⋁"}}
M.sym.latex["\\bigcap"]          = {{"⋂"}}
M.sym.latex["\\bigcup"]          = {{"⋃"}}
M.sym.latex["\\divideontimes"]   = {{"⋇"}}
M.sym.latex["\\ltimes"]          = {{"⋉"}}
M.sym.latex["\\rtimes"]          = {{"⋊"}}
M.sym.latex["\\leftthreetimes"]  = {{"⋋"}}
M.sym.latex["\\rightthreetimes"] = {{"⋌"}}
M.sym.latex["\\backsimeq"]       = {{"⋍"}}
M.sym.latex["\\curlyvee"]        = {{"⋎"}}
M.sym.latex["\\curlywedge"]      = {{"⋏"}}
M.sym.latex["\\Subset"]          = {{"⋐"}}
M.sym.latex["\\Supset"]          = {{"⋑"}}
M.sym.latex["\\Cap"]             = {{"⋒"}}
M.sym.latex["\\Cup"]             = {{"⋓"}}
M.sym.latex["\\pitchfork"]       = {{"⋔"}}
M.sym.latex["\\equalparallel"]   = {{"⋕"}}
M.sym.latex["\\lessdot"]         = {{"⋖"}}
M.sym.latex["\\gtrdot"]          = {{"⋗"}}
M.sym.latex["\\lll"]             = {{"⋘"}}
M.sym.latex["\\llless"]          = {{"⋘"}}
M.sym.latex["\\ggg"]             = {{"⋙"}}
M.sym.latex["\\gggtr"]           = {{"⋙"}}
M.sym.latex["\\lesseqgtr"]       = {{"⋚"}}
M.sym.latex["\\gtreqless"]       = {{"⋛"}}
M.sym.latex["\\eqless"]          = {{"⋜"}}
M.sym.latex["\\eqgtr"]           = {{"⋝"}}
M.sym.latex["\\curlyeqprec"]     = {{"⋞"}}
M.sym.latex["\\curlyeqsucc"]     = {{"⋟"}}
M.sym.latex["\\npreccurlyeq"]    = {{"⋠"}}
M.sym.latex["\\nsucccurlyeq"]    = {{"⋡"}}
M.sym.latex["\\nsqsubseteq"]     = {{"⋢"}}
M.sym.latex["\\nsqsupseteq"]     = {{"⋣"}}
M.sym.latex["\\sqsubsetneq"]     = {{"⋤"}}
M.sym.latex["\\sqsupsetneq"]     = {{"⋥"}}
M.sym.latex["\\lnsim"]           = {{"⋦"}}
M.sym.latex["\\gnsim"]           = {{"⋧"}}
M.sym.latex["\\precnsim"]        = {{"⋨"}}
M.sym.latex["\\succnsim"]        = {{"⋩"}}
M.sym.latex["\\ntriangleleft"]   = {{"⋪"}}
M.sym.latex["\\ntriangleright"]  = {{"⋫"}}
M.sym.latex["\\ntrianglelefteq"] = {{"⋬"}}
M.sym.latex["\\udots"]           = {{"⋰"}}

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
M.sym.latex['\\mathrm']       = {{"", ""}}

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

-- These commands look to replace the full command + text
M.sym.latex['\\`'] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex["\\'"] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex['\\^'] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex['\\"'] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex['\\H'] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex['\\~'] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex['\\c'] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex['\\k'] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex['\\l'] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex['\\='] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex['\\b'] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex['\\.'] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex['\\d'] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex['\\r'] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex['\\u'] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex['\\v'] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex['\\t'] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex['\\o'] = {txt = {"",  ""}, fn = super.get_diacritic}
M.sym.latex['\\i'] = {txt = {"",  ""}, fn = super.get_diacritic}

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
  local cfn   = cdict["fn"]
  local text  = cdict["txt"]

  -- If no function is defined, then return the first element as the text table
  if cfn == nil then
    return cdict[1]
  end

  local new_text = cfn(cmd, text, node)

  return new_text


end

M.set_query = function(lang, key, query)
  if M.sym[lang] == nil then
    M.sym[lang] = {}
  end
  M.sym[lang][key] = query
end


-- Sometimes I define new macros that are just text shortcuts
-- Let's find those newcommands and define them as simple conceals
-- Cached query for inline text macros
local inline_macro_query = nil

local get_inline_text_macros = function(root, bufnr)
  -- Only re-scan if buffer has changed since last scan
  local tick = vim.api.nvim_buf_get_changedtick(bufnr)
  if tick == info.last_macro_tick then
    return  -- Skip if buffer unchanged
  end
  info.last_macro_tick = tick

  -- Cache the query on first use
  if not inline_macro_query then
    inline_macro_query = q.parse("latex", [[
      (new_command_definition
        (curly_group_command_name
          (command_name) @cname
        )
        (curly_group
          (text) @text
        )
      )
    ]])
  end

  for _, match, _ in inline_macro_query:iter_matches(root, bufnr) do
    local key = ""
    for id, node in pairs(match) do

      node = node[1]

      if id == 1 then
        key = h.gtext(node)
        M.sym.latex[key] = {}
      else
        local val = h.gtext(node)

        local klen = string.len(key)
        local vlen = string.len(val)

        if vlen > klen then
          val = string.sub(val, 1, klen)
        end

        -- I'm making this two arguments to get rid of possible braces
        M.sym.latex[key] = {{val, ""}}
      end
    end
  end

end

-- Get the queries applicable to this filetype
M.get_queries = function(root, bufnr)

  -- Get any inline latex macros
  get_inline_text_macros(root, bufnr)

  local out = {}
  local langs = M.lang_queries[info.ft]
  if langs == nil then
    return pairs(out)
  end
  for _, lang in pairs(langs) do
    for _, k in ipairs(M.queries[lang]) do
      local name  = k["fn"]
      local query_str = k["query"]

      -- Cache compiled queries by lang:name key
      local cache_key = lang .. ":" .. name
      if not compiled_queries[cache_key] then
        compiled_queries[cache_key] = q.parse(lang, query_str)
      end
      local query = compiled_queries[cache_key]

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
