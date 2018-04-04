if exists("g:loaded_iota") | finish | endif
let g:loaded_iota = 1

if has('nvim')
  " These hacks don't work in neovim, nor are they necessary if terminal is
  " theconfigured according to specification used by libtermkey/libtickit.
  finish
elseif &term =~ '8bit'
  " If the terminal is running in 8-bit mode (e.g. rxvt --meta8), most keys
  " should just work without any further configuration.
  finish
endif

if &term =~ 'xterm\|tmux\|screen\|builtin_gui'
  " Most modern terminals run in 7-bit mode, representing a Meta modifier by
  " prepending an Esc byte (0x1B). Set some Meta key options accordingly.
  " Note: <M-O> is not possible without breaking arrows in Insert mode.
  let s:chars = [
  \ '&', "'", '(', '*', '+', ',', '-', '/', '0', '1', '2',
  \ '3', '4', '5', '6', '7', '8', '9', ':', ';', '=', '?',
  \ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',
  \ 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W',
  \ 'X', 'Y', 'Z', '_', 'a', 'b', 'c', 'd', 'e', 'f', 'g',
  \ 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r',
  \ 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '{', '}']
  for s:c in s:chars
    exec "set <M-".s:c.">=\<Esc>".s:c
  endfor
  unlet s:c s:chars
  " These keys can't be set using exec
  set <M-)>=)
  set <M-.>=.
  set <M-CR>=
  " <M-Space> requires special handling
  let &t_F3="\<Esc> "
  map  <F13> <M-Space>
  map! <F13> <M-Space>

  " Codes conform to libtermkey (now in libtickit) specification.
  " Most modified keys are encoded as: CSI[codepoint];[modifier]u
  " See: http://www.leonerd.org.uk/hacks/fixterms for full spec.
  let s:keys = [
  \ ['<S-Space>', '[32;2u', '<F14>'],
  \ ['<S-CR>'   , '[13;2u', '<F15>'],
  \ ['<C-CR>'   , '[13;5u', '<F16>'],
  \ ['<C-,>'    , '[44;5u', '<F17>'],
  \ ['<C-.>'    , '[46;5u', '<F18>'] ]
  for [s:key, s:escSeq, s:fnkey] in s:keys
    exec 'set  '. s:fnkey .'='. s:escSeq
    exec 'map  '. s:fnkey .' '. s:key
    exec 'map! '. s:fnkey .' '. s:key
  endfor
  unlet s:key s:escSeq s:fnkey s:keys
endif

" extended mouse mode
if &term =~ '^\%(tmux\|screen\)'
  set ttymouse=xterm2
  " Fix behavior of modified arrows in tmux.
  set    <xUp>=[1;*A
  set  <xDown>=[1;*B
  set <xRight>=[1;*C
  set  <xLeft>=[1;*D
  " Fix true color in tmux
  set t_8f=[38;2;%lu;%lu;%lum
  set t_8b=[48;2;%lu;%lu;%lum
endif
