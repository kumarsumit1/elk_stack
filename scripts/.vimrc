" =============================================================================
" Basic Vim Configuration .vimrc file
" -----------------------------------------------------------------------------
" 
" =============================================================================


" -----------------------------------------------------------------------------
" BEHAVIOR
" -----------------------------------------------------------------------------

set nocompatible            " Disable vi compatibility
"filetype on                 " filetype must be 'on' before setting it 'off'
                            "   otherwise it exits with a bad status and breaks
                            "   git commit.
"filetype off                " force reloading *after* pathogen loaded

" --- keys ---
set backspace=indent,eol,start  " allow backspacing over everything.
set esckeys                     " Allow cursor keys in insert mode.
set nostartofline               " Make j/k respect the columns


" -----------------------------------------------------------------------------
" UI
" -----------------------------------------------------------------------------
set t_Co=256
set termguicolors
set cursorline              " Highlight current line
set laststatus=2            " Always show status line
set number                  " Enable line numbers.
set numberwidth=5           " width of numbers line (default on gvim is 4)
set report=0                " Show all changes.
set showmode                " Show the current mode.
set showcmd                 " show partial command on last line of screen.
set showmatch               " higlight matching parenthesis
set splitbelow splitright   " how to split new windows.
set title                   " Show the filename in the window title bar.

set scrolloff=5             " Start scrolling n lines before horizontal
                            "   border of window.
set sidescrolloff=7         " Start scrolling n chars before end of screen.
set sidescroll=1            " The minimal number of columns to scroll
                            "   horizontally.
							
" --- command completion ---
set wildmenu                " Hitting TAB in command mode will
set wildchar=<TAB>          "   show possible completions.
set wildmode=list:longest

" --- folding---
set foldmethod=manual       " manual fold
set foldnestmax=3           " deepest fold is 3 levels
set nofoldenable            " don't fold by default

" --- remove sounds effects ---
set noerrorbells
set visualbell

" -----------------------------------------------------------------------------
" INDENTATION AND TEXT-WRAP
" -----------------------------------------------------------------------------

set expandtab                   " Expand tabs to spaces
set autoindent smartindent      " auto/smart indent
set copyindent                  " copy previous indentation on auto indent
set softtabstop=2               " Tab key results in # spaces
set tabstop=2                   " Tab is # spaces
set shiftwidth=2                " The # of spaces for indenting.
set smarttab                    " At start of line, <Tab> inserts shift width
                                "   spaces, <Bs> deletes shift width spaces.
set wrap                        " wrap lines
set textwidth=80
"set colorcolumn=+1             " Show large lines
set formatoptions=qrn1          " automatic formating.
set formatoptions-=o            " don't start new lines w/ comment leader on
                                "   pressing 'o'
set nomodeline                  " don't use modeline (security)
set pastetoggle=<leader>p       " paste mode: avoid auto indent, treat chars
                                "   as literal.