" To use defaults instead
"unlet! skip_defaults_vim
"source $VIMRUNTIME/defaults.vim

filetype plugin on
syntax on

if filereadable(expand("~/.vimrc.bundles"))
    source ~/.vimrc.bundles
endif

" -- General ----------------------------------------

set encoding=UTF-8
set autoindent
set autoread                                " reload files when changed on disk, i.e. via `git checkout`
set backspace=2                             " Fix broken backspace in some setups
set backupcopy=yes                          " see :help crontab
set clipboard=unnamedplus                   " yank and paste with the system clipboard
set directory-=.                            " don't store swapfiles in the current directory
set encoding=utf-8
set ignorecase                              " case-insensitive search
set laststatus=2                            " always show statusline
set list                                    " show trailing whitespace
set listchars=tab:▸\ ,trail:▫
set number                                  " show line numbers
set ruler                                   " show where you are
set scrolloff=3                             " show context above/below cursorline
set showcmd
set tabstop=8                               " actual tabs occupy 8 characters
set wildignore=log/**,node_modules/**,target/**,tmp/**,*.rbc
set wildmenu                                " show a navigable menu for tab completion
set wildmode=longest,list,full
"set nocursorline                            " don't highlight current line
set expandtab                               " expand tabs to spaces - https://vim.fandom.com/wiki/Indenting_source_code
set shiftwidth=4                            " normal mode indentation commands use 2 spaces
set softtabstop=4                           " insert mode tab and backspace use 2 spaces
set ignorecase                              " Search
set smartcase                               " case-sensitive search if any caps
set incsearch                               " search as you type
set wrapscan
set hlsearch

" Enable basic mouse behavior such as resizing buffers.
set mouse=a
if exists('$TMUX')  " Support resizing in tmux
    set ttymouse=xterm2
endif
"nmap <leader>hl :let @/ = ""<CR>


" -- Shortcuts ----------------------------------------

inoremap jj <ESC>
let mapleader = ','
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
nnoremap <leader>b :CtrlPBuffer<CR>
nnoremap <leader>d :NERDTreeToggle<CR>
nnoremap <leader>t :CtrlP<CR>
nnoremap <leader>T :CtrlPClearCache<CR>:CtrlP<CR>
nnoremap <leader>] :TagbarToggle<CR>
"nnoremap <leader><space> :call whitespace#strip_trailing()<CR>
nnoremap <leader>g :GitGutterToggle<CR>
noremap <silent> <leader>V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>

" in case you forgot to sudo
cnoremap w!! %!sudo tee > /dev/null %

" plugin settings
let g:ctrlp_match_window = 'order:ttb,max:20'
"let g:NERDSpaceDelims=1
let g:gitgutter_enabled = 0


" -- Integrations ----------------------------------------

function! FzyCommand(choice_command, vim_command)
  try
    let output = system(a:choice_command . " | fzy ")
  catch /Vim:Interrupt/
    " Swallow errors from ^C, allow redraw! below
  endtry
  redraw!
  if v:shell_error == 0 && !empty(output)
    exec a:vim_command . ' ' . output
  endif
endfunction

nnoremap <leader>e :call FzyCommand("find . -type f", ":e")<cr>
nnoremap <leader>v :call FzyCommand("find . -type f", ":vs")<cr>
nnoremap <leader>s :call FzyCommand("find . -type f", ":sp")<cr>

" -- Appearance ----------------------------------------

set termguicolors
set background=dark

" Colorscheme; see :help gruvbox-material-configuration
let g:gruvbox_material_background = 'hard'
"let g:gruvbox_material_enable_italic = 1 " https://github.com/sainnhe/icursive-nerd-font
let g:gruvbox_material_transparent_background = 1
let g:airline_theme = 'gruvbox_material'
let g:gruvbox_material_enable_bold = 1
let g:gruvbox_material_visual = 'reverse'
colorscheme gruvbox-material
hi clear Comment

" Fix Cursor in TMUX
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" Vim transparency equal to terminal's
hi Normal guibg=NONE ctermbg=NONE

set term=screen-256color

let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"


" -- Functions ----------------------------------------

" Source: https://news.ycombinator.com/item?id=22280267
command! -nargs=* Date call s:RunDate()

function! s:RunDate()
  let s:tm = strftime("%a %d %b %Y") . "\n"
  execute "normal! i" . s:tm
  execute "startinsert"
endfunction

command! -nargs=* Timestamp call s:RunTimestamp()

function! s:RunTimestamp()
  " %c - https://vim.fandom.com/wiki/Insert_current_date_or_time
  let s:tm = strftime("%c")
  execute "normal! i" . s:tm
endfunction
