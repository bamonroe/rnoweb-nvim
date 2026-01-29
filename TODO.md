# TODO

## In Progress

## Bugs

## Features

- [ ] Citation conceal with bibliography lookup (blocked: waiting for anti-conceal in Neovim)
- [ ] Improved equation/environment numbering
- [ ] General environment numbering

## Ideas / Future Work

## Completed

- [x] Math conceal doesn't unconceal on cursor line
  - Restored `virt_text_hide` option removed during performance refactor
  - Set `concealcursor` to empty string for all-mode unconcealing
- [x] Equation/figure/footnote counts not resetting on refresh
  - Fixed by resetting count values in place instead of creating new table
- [x] Subsection counting and label support
  - Labels now show as "section.subsection" format (e.g., "5.2")
  - Sections and subsections processed in document order
