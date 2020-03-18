python3 << _EOF_
import ast

__vim_py3_eval_visual__out = None

# https://stackoverflow.com/a/47130538
def repl_exec(script, globals=None, locals=None):
    __vim_py3_eval_visual__stmts = list(ast.iter_child_nodes(ast.parse(script)))
    if not __vim_py3_eval_visual__stmts:
        return None
    if isinstance(__vim_py3_eval_visual__stmts[-1], ast.Expr):
        # the last one is an expression and we will try to return the results
        # so we first execute the previous statements
        if len(__vim_py3_eval_visual__stmts) > 1:
            exec(compile(
                ast.Module(body=__vim_py3_eval_visual__stmts[:-1]),
                filename="<ast>",
                mode="exec",
            ), globals, locals)
        # then we eval the last one
        # what if object doesn't have a __repr__?

        return repr(eval(compile(
            ast.Expression(body=__vim_py3_eval_visual__stmts[-1].value),
            filename="<ast>",
            mode="eval",
        ), globals, locals))
    else:
        # otherwise we just execute the entire code
        exec(script, globals, locals)
        return None
_EOF_

function! s:convert()
  let l:snippet = s:get_visual_selection()
  python3 << _EOF_
import vim
# don't use local (function) scope
__vim_py3_eval_visual__out = repl_exec(
    vim.eval('l:snippet'), globals(), globals()
)
_EOF_
  let l:result = py3eval("__vim_py3_eval_visual__out")
  " reset the global variable
  python3 __vim_py3_eval_visual__out = None
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

xnoremap <Plug>py3_eval_visual_run_visual :<c-u>call <SID>py3_run_visual()<CR>

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

xnoremap <Plug>py3_eval_visual_append_visual :<c-u>call <SID>py3_append_visual()<CR>

