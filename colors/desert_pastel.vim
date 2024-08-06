" desert_pastel.vim

if version > 580
  if exists("b:current_syntax")
    finish
  endif
  syntax reset
endif
let g:colors_name = "desert_pastel"

" Pastel colors
highlight Normal       guifg=#D3D3D3 guibg=#2E2E2E
highlight Comment      guifg=#A0C0FF
highlight Constant     guifg=#FFA07A
highlight Special      guifg=#FFFFFF
highlight Identifier   guifg=#edb1fa
highlight Statement    guifg=#00CED1
highlight PreProc      guifg=#DA70D6
highlight Type         guifg=#AFEEEE
highlight Underlined   guifg=#98FB98
highlight Todo         guifg=#B0C4DE guibg=#4682B4
highlight String       guifg=#FFC0CB
highlight Function     guifg=#00FA9A
highlight Conditional  guifg=#EEE8AA
highlight Repeat       guifg=#FFDAB9
highlight Operator     guifg=#F0E68C
highlight Structure    guifg=#ADD8E6
highlight LineNr       guifg=#5F9EA0 guibg=#2E2E2E
highlight CursorLineNr guifg=#FFD700 guibg=#2E2E2E
highlight Comment      guifg=#B0C4DE

" Pmenu and PmenuSel
highlight Pmenu        guibg=#2E2E2E guifg=#FFFFFF  " Neutral background for Pmenu
highlight PmenuSel     guibg=#FFFACD guifg=#2E2E2E  " Light yellow for selected item

" Telescope highlights
highlight TelescopeSelection guibg=#EEE8AA guifg=#000000
highlight TelescopeMatching guifg=#FF8080
highlight TelescopePromptCounter guifg=#ADD8E6

" Tree-sitter specific highlights
highlight! link @tag                Type
highlight! link @tag.attribute      Identifier
highlight! link @property           Identifier
highlight! link @variable           Identifier
highlight! link @variable.builtin   Identifier
highlight! link @function           Function
highlight! link @function.builtin   Function
highlight! link @keyword            Statement
highlight! link @string             String
highlight! link @comment            Comment

if has("unix")
 if v:version<600
  highlight Normal ctermfg=252 ctermbg=235 cterm=NONE guifg=#E0E0E0 guibg=#808080 gui=NONE
  highlight Search ctermfg=235 ctermbg=210 cterm=bold guifg=#808080 guibg=#FF8080 gui=bold
  highlight Visual ctermfg=235 ctermbg=230 cterm=bold guifg=#B0B0B0 gui=bold
  highlight Special ctermfg=153 cterm=NONE guifg=#A0C0FF gui=NONE
  highlight Comment ctermfg=153 cterm=NONE guifg=#A0C0FF gui=NONE
 endif
endif

highlight CursorLine cterm=NONE guibg=#5c5c5c ctermfg=NONE guibg=#5c5c5c guifg=NONE
highlight FloatBorder guifg=white guibg=#1f2335
