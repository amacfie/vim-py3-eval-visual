if exists("g:loaded_run_python3") || v:version < 700
  finish
endif
let g:loaded_run_python3 = 1

python3 << _EOF_
import ast

__run_python3__out = None

# https://stackoverflow.com/a/47130538
def __run_python3__repl_exec(script, globals=None, locals=None):
    stmts = list(ast.iter_child_nodes(ast.parse(script)))
    if not stmts:
        return None
    if isinstance(stmts[-1], ast.Expr):
        # the last one is an expression and we will try to return the results
        # so we first execute the previous statements
        if len(stmts) > 1:
            module = ast.parse("")
            module.body = stmts[:-1]
            exec(
                compile(module, filename="<code>", mode="exec"),
                globals,
                locals,
            )
        # then we eval the last one
        # what if object doesn't have a __repr__?

        return repr(eval(compile(
            ast.Expression(body=stmts[-1].value),
            filename="<code>",
            mode="eval",
        ), globals, locals))
    else:
        # otherwise we just execute the entire code
        exec(compile(script, "<code>", "exec"), globals, locals)
        return None
_EOF_

function! s:convert()
  let l:snippet = s:get_visual_selection()
  python3 << _EOF_
import vim
# don't use local (function) scope
__run_python3__out = __run_python3__repl_exec(
    vim.eval('l:snippet'), globals(), globals()
)
_EOF_
  let l:result = py3eval("__run_python3__out")
  " reset the global variable
  python3 __run_python3__out = None
  return l:result
endfunction


function! s:get_visual_selection()
  " http://stackoverflow.com/a/6271254/371334
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\n")
endfunction

" run selection and echo representation of evaluation
function! s:py3_run_visual()
  let l:out = s:convert()
  if l:out != "None" && l:out != v:null
    echo l:out
  endif
endfunction

xnoremap <Plug>run_python3_echo :<c-u>call <SID>py3_run_visual()<CR>
nnoremap <Plug>run_python3_echo V:<c-u>call <SID>py3_run_visual()<CR>

" run selection and write representation of evaluation on next line
function! s:py3_append_visual()
  let l:out = s:convert()
  if l:out != "None" && l:out != v:null
    let l:lines = split(l:out, "\n")
    call append(getpos("'>")[1], l:lines)
    call cursor(getpos("'>")[1] + 1, 0)
    "call cursor(getpos("'>")[1] + len(l:lines), 0)
  endif
endfunction

xnoremap <Plug>run_python3_append :<c-u>call <SID>py3_append_visual()<CR>
nnoremap <Plug>run_python3_append V:<c-u>call <SID>py3_append_visual()<CR>

