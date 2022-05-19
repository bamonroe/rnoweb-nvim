local q  = vim.treesitter.query

local M = {
  sym = {
    r      = {},
    latex  = {},
    rnoweb = {},
  },
  queries = {
    r      = {},
    latex  = {},
    rnoweb = {},
  },
}

M.queries.latex = {
  conceal_cmd = "(generic_command (command_name) @cmd)",
  citation    = "(citation) @cite",
}

M.queries.rnoweb = {
  conceal_cmd = "(rinline (command_name) @cmd)",
}

-- Not many rnoweb queies available
M.sym.rnoweb["\\Sexpr"]  = "ﳒ"

-- Lots of latex replacements
-- Start with the greeks
M.sym.latex['\\alpha']    = {"α"}
M.sym.latex['\\beta']     = {"β"}
M.sym.latex["\\delta"]    = {"δ"}
M.sym.latex["\\chi"]      = {"χ"}
M.sym.latex['\\eta']      = {"η"}
M.sym.latex['\\epsilon']  = {"ε"}
M.sym.latex["\\gamma"]    = {"γ"}
M.sym.latex["\\iota"]     = {"ι"}
M.sym.latex["\\kappa"]    = {"κ"}
M.sym.latex['\\lambda']   = {"λ"}
M.sym.latex['\\mu']       = {"μ"}
M.sym.latex['\\nu']       = {"ν"}
M.sym.latex['\\omicron']  = {"ο"}
M.sym.latex['\\omega']    = {"ω"}
M.sym.latex['\\phi']      = {"φ"}
M.sym.latex['\\pi']       = {"π"}
M.sym.latex['\\psi']      = {"ψ"}
M.sym.latex['\\rho']      = {"ρ"}
M.sym.latex['\\sigma']    = {"σ"}
M.sym.latex['\\tau']      = {"τ"}
M.sym.latex["\\theta"]    = {"θ"}
M.sym.latex["\\upsilon"]  = {"υ"}
M.sym.latex['\\varsigma'] = {"ς"}
M.sym.latex['\\xi']       = {"ξ"}
M.sym.latex['\\zeta']     = {"ζ"}

M.sym.latex['\\Delta']  = {"Δ"}
M.sym.latex['\\Gamma']  = {"Γ"}
M.sym.latex['\\Theta']  = {"Θ"}
M.sym.latex['\\Lambda'] = {"Λ"}
M.sym.latex['\\Omega']  = {"Ω"}
M.sym.latex['\\Phi']    = {"Φ"}
M.sym.latex['\\Pi']     = {"Π"}
M.sym.latex['\\Psi']    = {"Ψ"}
M.sym.latex['\\Sigma']  = {"Σ"}

-- Math things
M.sym.latex['\\infty']       = {"∞"}
M.sym.latex['\\times']       = {""}
M.sym.latex['\\geq']         = {"≥"}
M.sym.latex['\\leq']         = {"≤"}
M.sym.latex['\\approx']      = {"≈"}
M.sym.latex['\\propto']      = {"∝"}
M.sym.latex['\\sim']         = {"∼"}
M.sym.latex['\\succcurlyeq'] = {"≽"}
M.sym.latex['\\preccurlyeq'] = {"≼"}
M.sym.latex['\\succ']        = {"≻"}
M.sym.latex['\\prec']        = {"≺"}
M.sym.latex['\\int']         = {"∫"}
M.sym.latex['\\sum']         = {"∑"}
M.sym.latex['\\ln']          = {"ln"}
M.sym.latex['\\exp']         = {"e"}
M.sym.latex['\\in']          = {"Є"}
M.sym.latex['\\forall']      = {"∀"}
M.sym.latex['\\exists']      = {"∃"}

M.sym.latex['\\lbrace']         = {"{"}
M.sym.latex['\\rbrace']         = {"}"}

-- Arrows
M.sym.latex['\\leftarrow']          = {"← "}
M.sym.latex['\\longleftarrow']      = {"⟵  "}
M.sym.latex['\\uparrow']            = {"↑ "}
M.sym.latex['\\Leftarrow']          = {"⇐ "}
M.sym.latex['\\Longleftarrow']      = {"⟸  "}
M.sym.latex['\\Uparrow']            = {"⇑ "}
M.sym.latex['\\rightarrow']         = {"→ "}
M.sym.latex['\\longrightarrow']     = {"⟶  "}
M.sym.latex['\\downarrow']          = {"↓ "}
M.sym.latex['\\Rightarrow']         = {"⇒ "}
M.sym.latex['\\Longrightarrow']     = {"⟹  "}
M.sym.latex['\\Downarrow']          = {"⇓ "}
M.sym.latex['\\leftrightarrow']     = {"↔ "}
M.sym.latex['\\longleftrightarrow'] = {"⟷  "}
M.sym.latex['\\updownarrow']        = {"↕ "}
M.sym.latex['\\Leftrightarrow']     = {"⇔ "}
M.sym.latex['\\Longleftrightarrow'] = {"⟺  "}
M.sym.latex['\\Updownarrow']        = {"⇕ "}
M.sym.latex['\\mapsto']             = {"↦ "}
M.sym.latex['\\longmapsto']         = {"⟼  "}
M.sym.latex['\\nearrow']            = {"↗ "}
M.sym.latex['\\hookleftarrow']      = {"↩ "}
M.sym.latex['\\hookrightarrow']     = {"↪ "}
M.sym.latex['\\searrow']            = {"↘ "}
M.sym.latex['\\leftharpoonup']      = {"↼ "}
M.sym.latex['\\rightharpoonup']     = {"⇀ "}
M.sym.latex['\\swarrow']            = {"↙ "}
M.sym.latex['\\leftharpoondown']    = {"↽ "}
M.sym.latex['\\rightharpoondown']   = {"⇁ "}
M.sym.latex['\\nwarrow']            = {"↖ "}
M.sym.latex['\\rightleftharpoons']  = {"⇌ "}

-- Non-greeks
M.sym.latex['\\cdot']     = {"•"}
M.sym.latex['\\footnote'] = {"*"}

-- Spacing commands
M.sym.latex['\\qquad'] = {"    "}
M.sym.latex['\\quad']  = {"   "}
M.sym.latex['\\;']     = {"  "}
M.sym.latex['\\,']     = {" "}
M.sym.latex['\\:']     = {" "}
M.sym.latex['\\>']     = {" "}
M.sym.latex['\\space'] = {" "}
M.sym.latex['\\!']     = {""}

-- Just remove some things
M.sym.latex['\\noindent']  = {""}
M.sym.latex['\\textcite']  = {""}
M.sym.latex['\\parencite'] = {""}
M.sym.latex['\\left']      = {""}
M.sym.latex['\\right']     = {""}

-- Commands with arguments
M.sym.latex["\\enquote"]  = {"“", "”"}
M.sym.latex["\\textelp"]  = {"…", ""}
M.sym.latex["\\textins"]  = {"[", "]"}
M.sym.latex["\\textit"]   = {"",  ""}
M.sym.latex["\\mathit"]   = {"",  ""}
M.sym.latex["\\text"]     = {"",  ""}
M.sym.latex["\\frac"]     = {"",  " ⁄", ""}
M.sym.latex["\\nicefrac"] = {"",  " ⁄", ""}
M.sym.latex["\\dfrac"]    = {"",  " ⁄", ""}
M.sym.latex["\\gbar"]     = {"(", " |", ")"}
M.sym.latex["\\gbar*"]    = {"",  " |", ""}

-- Latex mappings can also include the underscored
for k, _ in pairs(M.sym.latex) do
  M.sym.latex[k .. "_"] = {M.sym.latex[k][1] .. "_"}
end

M.set_sym = function(lang, key, sym)
  if M.sym[lang] == nil then
    M.sym[lang] = {}
  end
  M.sym[lang][key] = sym
  M.sym[lang][key .. "_"] = sym .. "_"
end

M.get_sym = function(l, m)
  local lt = M.sym[l]
  if lt[m] ~= nil then
    return M.sym[l][m]
  else
    return nil
  end
end

M.set_query = function(lang, key, query)
  if M.sym[lang] == nil then
    M.sym[lang] = {}
  end
  M.sym[lang][key] = query
end

M.get_queries = function(root, bufnr)
  local lt = M.queries
  local out = {}
  for lang, _ in pairs(lt) do
    for name, query in pairs(lt[lang]) do
      query = q.parse_query(lang, query)
      out[#out+1] = {
        cmd   = name,
        lang  = lang,
        query = query:iter_captures(root, bufnr)
      }
    end
  end
  return pairs(out)
end

return M
