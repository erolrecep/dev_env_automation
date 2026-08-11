" Enable filetype detection and plugins
filetype plugin indent on

" Use smart indentation (Python requires specific indentation)
set autoindent
set smartindent

" Show line numbers
set nu

" Enable syntax highlighting
syntax on

" Python Specific Configuration

" Set a default of 4 spaces for a tab stop
set tabstop=4

" Set the number of spaces used for auto-indenting (shifting)
set shiftwidth=4

" When you press 'tab', insert spaces instead of a tab character
set expandtab

" Define a custom command to build with the 'torch' Conda environment
command! BWtorch execute "!/opt/homebrew/Caskroom/miniforge/base/envs/torch/bin/python %"

" =======================================
" VUNDLE SETUP
" =======================================

" Set runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" The following line is essential!
" Let Vundle manage Vundle itself
Plugin 'VundleVim/Vundle.vim'

" Dracula theme setup
Plugin 'dracula/vim', { 'name': 'dracula' }

" All non-plugin configurations go after call vundle#end()
call vundle#end()

" =======================================
" END VUNDLE SETUP
" =======================================
