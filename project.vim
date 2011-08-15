set errorformat+=\|\|\ ERR:\ %f:%l(%m

function! MakeOnly()
    set makeprg=haxe\ compile.hxml
    silent make
endfunction

function! MakeAndLaunch()
    set makeprg=haxe\ -cmd\ \"chromium-browser\ main.swf\"\ compile.hxml
    silent make
endfunction

function! MakeAndRunTests()
    set makeprg=haxe\ -cmd\ \"chromium-browser\ unittest.swf\"\ compile.hxml
    "set errorformat=%f:%l:%m
    silent make
endfunction

function! MakeAndRunLocalTests()
    set makeprg=haxe\ -cmd\ \"neko\ unittest.n\"\ compile.hxml
    "set errorformat=ERR:\ %f:%l(%m
    silent make
endfunction


nmap <F5> :call MakeAndLaunch()<cr>
nmap <F4> :call MakeOnly()<cr>
nmap <F3> :call MakeAndRunTests()<cr>
nmap <F2> :call MakeAndRunLocalTests()<cr>

