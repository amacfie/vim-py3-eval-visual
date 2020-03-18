Defines two mappings:

* `<Plug>run_python3_echo`: Evaluate selection (visual mode) or
  line (normal mode) with the Python 3 interpreter and echo the result (if any)
* `<Plug>run_python3_append`: Evaluate selection (visual mode) or
  line (normal mode) with the Python 3 interpreter and put the result (if any)
  on the next line in the buffer

To use, define custom mappings e.g.
```vim
xmap <leader>m <Plug>run_python3_echo
nmap <leader>m <Plug>run_python3_echo
xmap <leader><cr> <Plug>run_python3_append
nmap <leader><cr> <Plug>run_python3_append
```

Multiline visual selections are supported.

State is preserved as in `:python3` commands.

If you want certain modules to always be available, just put
`python3 import module_name` etc. in your `$MYVIMRC` file.

