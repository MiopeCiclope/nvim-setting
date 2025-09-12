local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Pane navigation
map("n", "<c-k>", ":wincmd k<CR>", opts)
map("n", "<c-j>", ":wincmd j<CR>", opts)
map("n", "<c-l>", ":wincmd l<CR>", opts)
map("n", "<c-h>", ":wincmd h<CR>", opts)

-- Buffer navigation
map("n", "ö", ":bprevious<CR>", opts)
map("n", "ä", ":bnext<CR>", opts)
map("n", "<C-e>", ":bnext | bd #<CR>", opts)

-- Quick commands
map("n", "<C-a>", "ggVG", opts)
map("n", "<Leader>%", ":vsplit<CR>", opts)
map("n", '<Leader>"', ":split<CR>", opts)
map("n", "<Leader>l", "<Cmd>noh<CR>", opts)
map("n", "<C-x>", ":Explore<CR>", opts)

-- Movement remaps
map("i", "<C-v>", "<C-o>$", opts)
map("i", "<C-c>", "<C-o>0", opts)
map({ "n", "o", "v" }, "t", "$", opts)
map({ "n", "o", "v" }, "r", "^", opts)
map({ "n", "o", "v" }, "w", "b", opts)

-- Toggle diagnostics (from utils)
map("n", "<Leader>d", function()
	require("utils").toggle_diagnostics()
end, opts)

-- Search inside visual selection
map("x", "/", ":<C-u>/\\%V", opts)

-- tests
vim.cmd([[
" Ctrl+B for buffer search
nnoremap <Leader>b :call BufferSearch()<CR>

function! BufferSearch()
    let buffers = []
    for i in range(1, bufnr('$'))
        if buflisted(i) && bufexists(i)
            let name = bufname(i)
            if name != '' && name !~ '^term://'
                call add(buffers, {'filename': name, 'bufnr': i})
            endif
        endif
    endfor

    call setqflist(buffers)
    call SetupQuickfixMappings()
    copen
endfunction
" Grep search mapping
nnoremap <Leader>z :call FileGrep()<CR>

function! FileGrep()
    let pattern = input("Grep Search: ")
    if pattern == ""
        return
    endif

    execute "vimgrep /" . pattern . "/j **"
    call SetupQuickfixMappings()
    copen
endfunction

" Ctrl+P for file search
nnoremap <C-p> :call FileSearch()<CR>

function! FileSearch()
    call setqflist(map(systemlist('git ls-files'), {_, val -> {'filename': val}}))
    call SetupQuickfixMappings()
    copen
endfunction

function! SetupQuickfixMappings()
    " Set up mappings for quickfix window
    nnoremap <buffer> <CR> <CR>:cclose<CR>
    nnoremap <buffer> <Leader>l :call OpenInMainWindow()<CR>
endfunction

function! OpenInMainWindow()
    " Save current quickfix position
    let current_line = line('.')

    " Open the file in the main window
    execute "normal! \<CR>"

    " Return focus to quickfix window
    wincmd p

    " Restore cursor position in quickfix
    execute "normal! " . current_line . "G"
endfunction
]])
