
M = {}

M.sym = {}
M.sym['\\alpha']    = "α"
M.sym['\\beta']     = "β"
M.sym["\\delta"]    = "δ"
M.sym["\\chi"]      = "χ"
M.sym['\\eta']      = "η"
M.sym['\\epsilon']  = "ε"
M.sym["\\gamma"]    = "γ"
M.sym["\\iota"]     = "ι"
M.sym["\\kappa"]    = "κ"
M.sym['\\lambda']   = "λ"
M.sym['\\mu']       = "μ"
M.sym['\\nu']       = "ν"
M.sym['\\omicron']  = "ο"
M.sym['\\omega']    = "ω"
M.sym['\\phi']      = "φ"
M.sym['\\pi']       = "π"
M.sym['\\psi']      = "ψ"
M.sym['\\rho']      = "ρ"
M.sym['\\sigma']    = "σ"
M.sym['\\tau']      = "τ"
M.sym["\\theta"]    = "θ"
M.sym["\\upsilon"]  = "υ"
M.sym['\\varsigma'] = "ς"
M.sym['\\xi']       = "ξ"
M.sym['\\zeta']     = "ζ"

M.sym['\\Delta']      = "Δ"
M.sym['\\Gamma']      = "Γ"
M.sym['\\Theta']      = "Θ"
M.sym['\\Lambda']     = "Λ"
M.sym['\\Omega']      = "Ω"
M.sym['\\Phi']        = "Φ"
M.sym['\\Pi']         = "Π"
M.sym['\\Psi']        = "Ψ"
M.sym['\\Sigma']      = "Σ"

-- Math things
M.sym['\\infty']       = "∞"
M.sym['\\times']       = ""
M.sym['\\geq']         = "≥"
M.sym['\\leq']         = "≤"
M.sym['\\approx']      = "≈"
M.sym['\\propto']      = "∝"
M.sym['\\sim']         = "∼"
M.sym['\\succcurlyeq'] = "≽"
M.sym['\\preccurlyeq'] = "≼"
M.sym['\\succ']        = "≻"
M.sym['\\prec']        = "≺"
M.sym['\\int']         = "∫"
M.sym['\\sum']         = "∑"
M.sym['\\ln']          = "ln"
M.sym['\\exp']         = "   e"
M.sym['\\in']          = "Є"
M.sym['\\lbrace']      = "{"
M.sym['\\rbrace']      = "}"

-- Non-greeks
M.sym['\\cdot']        = "•"
M.sym['\\footnote']    = "*"

-- Just remove some things
M.sym['\\noindent']  = ""
M.sym['\\textit']    = ""
M.sym['\\mathit']    = ""
M.sym['\\quad']      = ""
M.sym['\\;']         = ""
M.sym['\\!']         = ""
M.sym['\\textcite']  = ""
M.sym['\\parencite'] = ""

-- Make a map that points to the keys of sym
M.map = {}
for k, _ in pairs(M.sym) do
  M.map[k]         = k
  -- Map underscored chars to the same keys
  M.map[k .. "_" ] = k
end

-- Some left/right commands
M.sym['\\left\\lbrace']  = "\\lbrace"
M.sym['\\right\\rbrace'] = "\\rbrace"


M.get = function(m)
  return M.sym[M.map[m]]
end


return M
