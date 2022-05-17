local q  = vim.treesitter.query

local M = {
_lang = {
    r      = {sym = {}},
    latex  = {sym = {}},
    rnoweb = {sym = {}}
  }
}

M._lang.latex.queries = {
  replace = "(generic_command (command_name) @cmd)",
}

M._lang.rnoweb.queries = {
  replace = "(rinline (command_name) @cmd)",
}

-- Not many rnoweb queies available
M._lang.rnoweb.sym["\\Sexpr"]  = "ﳒ"

-- Lots of latex replacements
-- Start with the greeks
M._lang.latex.sym['\\alpha']    = "α"
M._lang.latex.sym['\\beta']     = "β"
M._lang.latex.sym["\\delta"]    = "δ"
M._lang.latex.sym["\\chi"]      = "χ"
M._lang.latex.sym['\\eta']      = "η"
M._lang.latex.sym['\\epsilon']  = "ε"
M._lang.latex.sym["\\gamma"]    = "γ"
M._lang.latex.sym["\\iota"]     = "ι"
M._lang.latex.sym["\\kappa"]    = "κ"
M._lang.latex.sym['\\lambda']   = "λ"
M._lang.latex.sym['\\mu']       = "μ"
M._lang.latex.sym['\\nu']       = "ν"
M._lang.latex.sym['\\omicron']  = "ο"
M._lang.latex.sym['\\omega']    = "ω"
M._lang.latex.sym['\\phi']      = "φ"
M._lang.latex.sym['\\pi']       = "π"
M._lang.latex.sym['\\psi']      = "ψ"
M._lang.latex.sym['\\rho']      = "ρ"
M._lang.latex.sym['\\sigma']    = "σ"
M._lang.latex.sym['\\tau']      = "τ"
M._lang.latex.sym["\\theta"]    = "θ"
M._lang.latex.sym["\\upsilon"]  = "υ"
M._lang.latex.sym['\\varsigma'] = "ς"
M._lang.latex.sym['\\xi']       = "ξ"
M._lang.latex.sym['\\zeta']     = "ζ"

M._lang.latex.sym['\\Delta']  = "Δ"
M._lang.latex.sym['\\Gamma']  = "Γ"
M._lang.latex.sym['\\Theta']  = "Θ"
M._lang.latex.sym['\\Lambda'] = "Λ"
M._lang.latex.sym['\\Omega']  = "Ω"
M._lang.latex.sym['\\Phi']    = "Φ"
M._lang.latex.sym['\\Pi']     = "Π"
M._lang.latex.sym['\\Psi']    = "Ψ"
M._lang.latex.sym['\\Sigma']  = "Σ"

-- Math things
M._lang.latex.sym['\\infty']       = "∞"
M._lang.latex.sym['\\times']       = ""
M._lang.latex.sym['\\geq']         = "≥"
M._lang.latex.sym['\\leq']         = "≤"
M._lang.latex.sym['\\approx']      = "≈"
M._lang.latex.sym['\\propto']      = "∝"
M._lang.latex.sym['\\sim']         = "∼"
M._lang.latex.sym['\\succcurlyeq'] = "≽"
M._lang.latex.sym['\\preccurlyeq'] = "≼"
M._lang.latex.sym['\\succ']        = "≻"
M._lang.latex.sym['\\prec']        = "≺"
M._lang.latex.sym['\\int']         = "∫"
M._lang.latex.sym['\\sum']         = "∑"
M._lang.latex.sym['\\ln']          = " ln"
M._lang.latex.sym['\\exp']         = "   e"
M._lang.latex.sym['\\in']          = "Є"
M._lang.latex.sym['\\lbrace']      = "{"
M._lang.latex.sym['\\rbrace']      = "}"

-- Non-greeks
M._lang.latex.sym['\\cdot']        = "•"
M._lang.latex.sym['\\footnote']    = "*"

-- Just remove some things
M._lang.latex.sym['\\noindent']  = ""
M._lang.latex.sym['\\textit']    = ""
M._lang.latex.sym['\\mathit']    = ""
M._lang.latex.sym['\\quad']      = ""
M._lang.latex.sym['\\;']         = ""
M._lang.latex.sym['\\!']         = ""
M._lang.latex.sym['\\textcite']  = ""
M._lang.latex.sym['\\parencite'] = ""
M._lang.latex.sym['\\left']      = ""
M._lang.latex.sym['\\right']     = ""

-- Latex mappings can also include the underscored
for k, _ in pairs(M._lang.latex.sym) do
  M._lang.latex.sym[k .. "_"] = M._lang.latex.sym[k] .. "_"
end

M.get = function(l, m)
  local lt = M._lang
  if lt[l].sym ~= nil then
    return M._lang[l].sym[m]
  else
    return nil
  end
end

M.queries = function(root, bufnr)
  local lt = M._lang
  local out = {}
  for lang, _ in pairs(lt) do
    if lt[lang].queries ~= nil then
      for name, query in pairs(lt[lang].queries) do
        query = q.parse_query(lang, query)
        out[#out+1] = {
          cmd   = name,
          lang  = lang,
          query = query:iter_captures(root, bufnr)
        }
      end
    end
  end
  return pairs(out)
end


return M
