local M = {superscript = {}, subscript = {}, diacritics = {}}
M.superscript["0"] = '⁰'
M.superscript["1"] = '¹'
M.superscript["2"] = '²'
M.superscript["3"] = '³'
M.superscript["4"] = '⁴'
M.superscript["5"] = '⁵'
M.superscript["6"] = '⁶'
M.superscript["7"] = '⁷'
M.superscript["8"] = '⁸'
M.superscript["9"] = '⁹'
M.superscript["a"] = 'ᵃ'
M.superscript["b"] = 'ᵇ'
M.superscript["c"] = 'ᶜ'
M.superscript["d"] = 'ᵈ'
M.superscript["e"] = 'ᵉ'
M.superscript["f"] = 'ᶠ'
M.superscript["g"] = 'ᵍ'
M.superscript["h"] = 'ʰ'
M.superscript["i"] = 'ⁱ'
M.superscript["j"] = 'ʲ'
M.superscript["k"] = 'ᵏ'
M.superscript["l"] = 'ˡ'
M.superscript["m"] = 'ᵐ'
M.superscript["n"] = 'ⁿ'
M.superscript["o"] = 'ᵒ'
M.superscript["p"] = 'ᵖ'
M.superscript["r"] = 'ʳ'
M.superscript["s"] = 'ˢ'
M.superscript["t"] = 'ᵗ'
M.superscript["u"] = 'ᵘ'
M.superscript["v"] = 'ᵛ'
M.superscript["w"] = 'ʷ'
M.superscript["x"] = 'ˣ'
M.superscript["y"] = 'ʸ'
M.superscript["z"] = 'ᶻ'
M.superscript["A"] = 'ᴬ'
M.superscript["B"] = 'ᴮ'
M.superscript["D"] = 'ᴰ'
M.superscript["E"] = 'ᴱ'
M.superscript["G"] = 'ᴳ'
M.superscript["H"] = 'ᴴ'
M.superscript["I"] = 'ᴵ'
M.superscript["J"] = 'ᴶ'
M.superscript["K"] = 'ᴷ'
M.superscript["L"] = 'ᴸ'
M.superscript["M"] = 'ᴹ'
M.superscript["N"] = 'ᴺ'
M.superscript["O"] = 'ᴼ'
M.superscript["P"] = 'ᴾ'
M.superscript["R"] = 'ᴿ'
M.superscript["T"] = 'ᵀ'
M.superscript["U"] = 'ᵁ'
M.superscript["V"] = 'ⱽ'
M.superscript["W"] = 'ᵂ'
M.superscript[","] = '︐'
M.superscript[":"] = '︓'
M.superscript[";"] = '︔'
M.superscript["+"] = '⁺'
M.superscript["-"] = '⁻'
M.superscript["<"] = '˂'
M.superscript[">"] = '˃'
M.superscript["/"] = 'ˊ'
M.superscript["("] = '⁽'
M.superscript[")"] = '⁾'
M.superscript["."] = '˙'
M.superscript["="] = '˭'


M.subscript['0'] = '₀'
M.subscript['1'] = '₁'
M.subscript['2'] = '₂'
M.subscript['3'] = '₃'
M.subscript['4'] = '₄'
M.subscript['5'] = '₅'
M.subscript['6'] = '₆'
M.subscript['7'] = '₇'
M.subscript['8'] = '₈'
M.subscript['9'] = '₉'
M.subscript['a'] = 'ₐ'
M.subscript['e'] = 'ₑ'
M.subscript['h'] = 'ₕ'
M.subscript['i'] = 'ᵢ'
M.subscript['j'] = 'ⱼ'
M.subscript['k'] = 'ₖ'
M.subscript['l'] = 'ₗ'
M.subscript['m'] = 'ₘ'
M.subscript['n'] = 'ₙ'
M.subscript['o'] = 'ₒ'
M.subscript['p'] = 'ₚ'
M.subscript['r'] = 'ᵣ'
M.subscript['s'] = 'ₛ'
M.subscript['t'] = 'ₜ'
M.subscript['u'] = 'ᵤ'
M.subscript['v'] = 'ᵥ'
M.subscript['x'] = 'ₓ'
M.subscript[','] = '︐'
M.subscript['+'] = '₊'
M.subscript['-'] = '₋'
M.subscript['/'] = 'ˏ'
M.subscript['('] = '₍'
M.subscript[')'] = '₎'
M.subscript['.'] = '.'
M.subscript['\\beta'] = 'ᵦ'
M.subscript['\\delta'] ='ᵨ'
M.subscript['\\phi']   ='ᵩ'
M.subscript['\\gamma'] ='ᵧ'
M.subscript['\\chi']   ='ᵪ'

-- diacritics
--[[

`{}
'{}
^{}
"{}
H{}
~{}
c{}
k{}
l{}
={}
b{}
.{}
d{}
r{}
u{}
v{}
t{}
o{}
i{}

--]]

M.diacritics["a"] = {
  ["\\`"] = "à",
  ["\\'"] = "á",
  ["\\^"] = "â",
  ["\\~"] = "ã",
  ['\\"'] = "ä",
  ["\\r"] = "å",
}

M.diacritics["c"] = {
  ["\\'"] = "ć",
  ["\\^"] = "ĉ",
  ["\\."] = "ċ",
  ["\\c"] = "ç",
  ['\\v'] = "č",
}

M.diacritics["d"] = {
  ["\\'"] = "ď",
}

M.diacritics["e"] = {
  ["\\`"] = "è",
  ["\\'"] = "é",
  ["\\^"] = "ê",
  ['\\"'] = "ë",
  ['\\.'] = "ė",
  ['\\='] = "ē",
  ['\\c'] = "ę",
  ['\\u'] = "ĕ",
  ['\\v'] = "ě",
}

M.diacritics["g"] = {
  ["\\'"] = "ģ",
  ["\\^"] = "ĝ",
  ['\\.'] = "ġ",
  ['\\u'] = "ğ",
}

M.diacritics["h"] = {
  ["\\^"] = "ĥ",
  ['\\='] = "ħ",
}

M.diacritics["i"] = {
  ["\\`"] = "ì",
  ["\\'"] = "í",
  ["\\^"] = "î",
  ['\\"'] = "ï",
  ['\\~'] = "ĩ",
  ['\\='] = "ī",
  ['\\c'] = "į",
  ['\\u'] = "ĭ",
  ['\\i'] = "ı",
}

M.diacritics["j"] = {
  ["\\^"] = "ĵ",
}

M.diacritics["l"] = {
  ["\\`"] = "ļ",
  ["\\'"] = "ĺ",
  ['\\o'] = "ł",
  ['\\.'] = "ŀ",
}

M.diacritics["n"] = {
  ["\\~"] = "ñ",
}

M.diacritics["o"] = {
  ["\\`"] = "ò",
  ["\\'"] = "ó",
  ["\\^"] = "ô",
  ["\\~"] = "õ",
  ['\\"'] = "ö",
  ['\\o'] = "ø",
}

M.diacritics["u"] = {
  ["\\`"] = "ù",
  ["\\'"] = "ú",
  ["\\^"] = "û",
  ['\\"'] = "ü",
}

M.diacritics["y"] = {
  ["\\`"] = "ý",
  ['\\"'] = "ÿ",
}

M.get_diacritic = function(cmd, txt, node)
  -- If we're in this command, we already know exactly where the thing we want to use is
  local cc = node:child_count()
  local brow, bcol, erow, ecol = node:range()
  local nt
  if cc > 1 then
    nt = vim.treesitter.get_node_text(node:child(1):child(1), 0)
  else
    local line = vim.api.nvim_buf_get_lines(0, erow, erow + 1, true)
    nt = string.sub(line[1], ecol+1, ecol + 1)
    ecol = ecol + 1

  end

  if M.diacritics[nt] ~= nil then
    if M.diacritics[nt][cmd] ~= nil then
      local val = {txt = {M.diacritics[nt][cmd]}, full = true, bcol = bcol, ecol = ecol}
      return val
    end
  end
  return txt
end


return M
