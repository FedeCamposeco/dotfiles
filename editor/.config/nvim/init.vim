" Plugins ----------------------------------------------------------------------
call plug#begin('~/.config/nvim/plugged')
  " Basic editing enhancement --------------------------------------------------
  " Align text using 'gaX' command.
  Plug 'junegunn/vim-easy-align'
  " Auto parenthesis closing
  Plug 'jiangmiao/auto-pairs'
  " Comment code.
  Plug 'tomtom/tcomment_vim'
  " No interruptions of 'file changed', just a warning instead.
  Plug 'vim-utils/vim-interruptless'
  " Add unix utility commands.
  Plug 'tpope/vim-eunuch'
  " Serach enhancements --------------------------------------------------------
  " Hihgligh search pattern while typing and nexting it.
  Plug 'haya14busa/is.vim'
  " Enable visual mode '*' search.
  Plug 'haya14busa/vim-asterisk'
  " Count number of matches.
  Plug 'osyo-manga/vim-anzu'
  " Highligh current searched item.
  Plug 'inside/vim-search-pulse'
  """ Manage per-project vim settings (used once for fortran, perhaps useless)
  """ TODO: It takes quite a bit to load, somehow. Disabled for now.
  """ Plug 'LucHermitte/local_vimrc' | Plug 'LucHermitte/lh-vim-lib'
  " fzf integration ------------------------------------------------------------
  " Fzf fuzzy finder for files, tags, and output of rg, ag, etc.
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  " Funcionality to integrate fzf to various vim concepts.
  Plug 'junegunn/fzf.vim'
  " Tmux integration -----------------------------------------------------------
  " Navigate windows, traverse tmux panes seamlessly.
  Plug 'christoomey/vim-tmux-navigator'
  " Fix focus events s.t autoread works (as well as GitGutter and Fugitive).
  Plug 'tmux-plugins/vim-tmux-focus-events'
  " Text objects and motions ---------------------------------------------------
  " New text objects.
  Plug 'kana/vim-textobj-user'
  " Text object function body and body + declaration.
  Plug 'kana/vim-textobj-function'
  " Text object function argument.
  Plug 'sgur/vim-textobj-parameter'
  " Flash the region that was yanked.
  Plug 'machakann/vim-highlightedyank'
  " Add 's' operator to replace a {motion} with register.
  Plug 'kana/vim-operator-replace' | Plug 'kana/vim-operator-user'
  " File browser.
  Plug 'justinmk/vim-dirvish'
  " Adds the 'cx' exchange operator.
  Plug 'tommcdo/vim-exchange'
  " Make T,t,F,t behave a bit smarter.
  Plug 'rhysd/clever-f.vim'
  " Mappings and commands for convenience --------------------------------------
  " Avoid overusing j/k, use <A-j/k>.
  Plug 'haya14busa/vim-signjk-motion'
  " Smart close buffers with <leader>d.
  Plug 'cespare/vim-sbd'
  " Move code lines with <M-k/j>.
  Plug 'matze/vim-move'
  " Use jk/kj to exit insert mode.
  Plug 'fedeDev/vim-easyescape'
  " Change to git root using <leader>rp, change to buffer with <leader>cd.
  Plug 'airblade/vim-rooter'
  " Toggle quickfix and loclist with tl and tq.
  Plug 'Valloric/ListToggle'
  " Swap windows with <leader>W
  Plug 'wesQ3/vim-windowswap'
  " Sidebars -------------------------------------------------------------------
  " Adds a window pane that shows the classes and methods on buffer.
  Plug 'majutsushi/tagbar'
  " Use a key to show the undo tree of VIM. Amazing.
  Plug 'simnalamburt/vim-mundo'
  " Visuals --------------------------------------------------------------------
  " Colorscheme.
  Plug 'arcticicestudio/nord-vim', { 'branch': 'develop' }
  " Status line.
  Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'
  " Dim inactive windows.
  Plug 'blueyed/vim-diminactive'
  " When scrolling with <C-U/D/B/F>, use smooth scrolling.
  Plug 'yuttie/comfortable-motion.vim'
  " Startup page.
  Plug 'mhinz/vim-startify'
  " Autocompletion and Code Indexing -------------------------------------------
  Plug 'ludovicchabant/vim-gutentags'
  " Interface with Language Server Protocols.
  Plug 'autozimu/LanguageClient-neovim', {
      \     'for' : ['c', 'cpp'],
      \  'branch' : 'next',
      \      'do' : 'bash install.sh',
      \ }
  " Autocompletion manager
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  " Autocomplete from syntax
  Plug 'Shougo/neco-syntax'
  " Autocomplete includes
  Plug 'Shougo/neoinclude.vim', {'for' : ['c', 'cpp']}
  " Linting and Formatting -----------------------------------------------------
  Plug 'w0rp/ale'
  " Clang style.
  Plug 'sbdchd/neoformat', {'for' : ['cpp', 'fortran', 'python']}
  " C++ ------------------------------------------------------------------------
  " Enhanced C++ syntax.
  Plug 'octol/vim-cpp-enhanced-highlight', {'for' : 'cpp'}
  " Latex ----------------------------------------------------------------------
  " Everything we need and want for \latex.
  Plug 'lervag/vimtex', { 'for' : 'tex' }
  " Git ------------------------------------------------------------------------
  " Amazing plugin to use git inside vim, also add git commit types etc.
  Plug 'tpope/vim-fugitive'
  " Add :GV command for browsing git repo.
  Plug 'junegunn/gv.vim'
  " Official syntax, indent, and filetypes plugin for git.
  Plug 'tpope/vim-git'
  " Show git status info on gutter.
  Plug 'mhinz/vim-signify'
call plug#end()

" General settings, mappings and plugin setup is done in aux files -------------
source $HOME/.config/nvim/startup/settings.vim
source $HOME/.config/nvim/startup/mappings.vim
source $HOME/.config/nvim/startup/autocommands.vim
source $HOME/.config/nvim/startup/plugins.vim
