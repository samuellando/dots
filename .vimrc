"Disable arrow keys"
nnoremap <up>    <nop>
nnoremap <down>  <nop>
nnoremap <left>  <nop>
nnoremap <right> <nop>
inoremap <up>    <nop>
inoremap <down>  <nop>
inoremap <left>  <nop>
inoremap <right> <nop>

"Disable backspace and delete"
nnoremap <backspace> <nop>
inoremap <backspace> <nop>
nnoremap <del> <nop>
inoremap <del> <nop>

"---------------------- BASICS -----------------------------------------------"
syntax enable
set background=dark
set number relativenumber
set hlsearch
set colorcolumn=80
highlight ColorColumn ctermbg=4
set expandtab
set shiftwidth=2
set softtabstop=2
set autoindent
set smartindent

"For moving betweeen splits "
map <C-l> <C-w>l
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k

autocmd InsertEnter * silent !echo -ne '\e[5 q'
autocmd InsertLeave * silent !echo -ne '\e[1 q'
autocmd VimEnter * silent !echo -ne '\e[1 q'

"---------------------- IDE STUFF --------------------------------------------"
"Format the code"
map <F7> gg=G<C-o><C-o>
map <F6> :w !xclip -selection clipboard -i<CR><CR>
map <F5> :set spell spelllang=en_us<CR>

"---------------------------- PLUGINS ----------------------------------------"
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
call plug#end()

"------------------------------ PLUGINS CONFIG -------------------------------"
map <C-d> :NERDTreeToggle<CR>
