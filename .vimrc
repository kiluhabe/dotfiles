" shoe line number
set number
" 文脈によって解釈が異なる全角文字の幅を、2に固定する
set ambiwidth=double
" fix tab as 2 spaces
set tabstop=2
" insert tab as spaces
set expandtab
" 改行時などに、自動でインデントを設定してくれる
set smartindent
" 空白文字の可視化
set list
" 可視化した空白文字の表示形式
set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%
" 0で始まる数値を、8進数として扱わないようにする
set nrformats-=octal
" ファイルの保存をしていなくても、べつのファイルを開けるようにする
set hidden
" 文字のないところにカーソル移動できるようにする
set virtualedit=block
" カーソルの回り込みができるようになる
set whichwrap=b,s,[,],<,>
" カーソルの回り込みができるようになる
set backspace=indent,eol,start


"文字コードをUFT-8に設定
set fenc=utf-8
" バックアップファイルを作らない
set nobackup
" スワップファイルを作らない
set noswapfile
" 編集中のファイルが変更されたら自動で読み直す
set autoread
" 入力中のコマンドをステータスに表示する
set showcmd

" 括弧入力時の対応する括弧を表示
set showmatch
" コマンドラインの補完
set wildmode=list:longest

set mouse=v

" vim-plugin
call plug#begin()

" color scheme
Plug 'tomasiser/vim-code-dark'

" nerdtree
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

Plug 'jistr/vim-nerdtree-tabs'

Plug 'Shougo/neocomplete'

Plug 'Townk/vim-autoclose'

call plug#end()

colorscheme codedark

map <C-l> :NERDTreeTabsToggle<CR>
map <C-w> :tabclose<CR>
map <C-q> :q<CR>
map <C-z> :u<CR>
map <C-y> <C-r>

fun! Alias(from, to)
  exec 'cnoreabbrev <expr> '.a:from
  \ .' ((getcmdtype() is# ":" && getcmdline() is# "'.a:from.'")'
  \ .'? ("'.a:to.'") : ("'.a:from.'"))'
endfun

call Alias('reload', 'source\ ~/.vimrc')
call Alias('tn', 'tabnext')
call Alias('tb', 'tabprevious')
call Alias('pi', 'PlugInstall')

autocmd vimenter * NERDTreeToggle
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

autocmd vimenter * NeoCompleteEnable
