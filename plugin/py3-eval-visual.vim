function! s:get_visual_selection()
  " http://stackoverflow.com/a/6271254/371334
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\n")
  return lines
endfunction

function! s:get_output()
  let snippet = s:get_visual_selection()
  return py3eval(snippet)

" run selection
function! Py3_run_visual()
  call s:get_output()
endfunction
xnoremap <leader>m :<c-h><c-h><c-h><c-h><c-h>call Py3_run_visual()<CR>

" run selection and write output on next line
" the output is a vimscript object
function! Py3_append_visual()
  let out = s:get_output()
  if out
    call append(getpos("'>")[1], split(string(out), "\n"))
  endif
endfunction
xnoremap <leader>M :<c-h><c-h><c-h><c-h><c-h>call Py3_append_visual()<CR>

