Defines two key sequences:

* `<Plug>py3_eval_visual_run_visual`: Evaluate selection with the Python 3
  interpreter and echo the result (if any)
* `<Plug>py3_eval_visual_append_visual`: Evaluate selection with the Python 3
  interpreter and put the result (if any) on the next line in the buffer

To use, define custom visual mode mappings e.g.
```vim
xmap <leader>m <Plug>py3_eval_visual_run_visual
xmap <leader><cr> <Plug>py3_eval_visual_append_visual
```

Multiline selections are supported.

State is preserved as in `:python3` commands.

If you want certain modules to always be available, just put
`python3 import module_name` etc. in your `$MYVIMRC` file.

