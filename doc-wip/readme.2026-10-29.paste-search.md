# Paste search: one provider for all lookups

`plug-wip/genja-paste-ai.nvim` replaces `lua/genja/ext/perplexity.lua` and
`plugin/perplexity-search.lua`. Every lookup (keys, commands, `<F2>`, right-click)
goes to the current provider.

Providers:

- perplexity, chatgpt, grok: the query goes in the URL.
- gemini, manus: the query is copied to the clipboard and the site opens; paste with Ctrl+V.

## Keys and commands

    <leader>pl / pw / py    line / word / last yank
    <leader>ps              (visual) the selection; right-click on a selection does the same
    :PasteSearch [-provider name] [-save] [query]   aliases :Xty, :Pplx
        no query: the current line; :'<,'>PasteSearch: the selection
        -provider name: switch first; -save: keep it (alone: only saves)
    <F2>  lookup  paste search provider (<current>)
        <CR> switch for this session, <M-s> switch and save

The saved provider is `lua/genja/local/paste-ai.lua` (gitignored), one line:
`return 'grok'`. Delete the file to go back to perplexity.

## Test

1. `:PasteSearch hello`: perplexity opens with "hello".
2. `:PasteSearch -provider grok what is lua`: grok opens; `<leader>pw` on a word now goes to grok too.
3. `:Xty -provider gemini neovim`: gemini opens, a notify says the query was copied; Ctrl+V in the page.
4. `<F2>`: the `lookup` entry shows the current provider; pick chatgpt with `<M-s>`.
   `lua/genja/local/paste-ai.lua` now says `return 'chatgpt'`; restart nvim, `<F2>` still shows chatgpt.
5. Select two lines, `:'<,'>Pplx`: both lines are the query.
6. Select text, right-click, "Lookup: paste search selection".
