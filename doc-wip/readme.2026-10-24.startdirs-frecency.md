# Start dirs ranked by frecency

`require('genja-startdirs').ranked()` (the mydirs picker, `<leader>s…`) used plain
use counts. Now: count x recency weight, the weights genja-recent uses:
x4 last use within an hour, x2 within a day, x0.5 within a week, x0.25 older.
The function is copied into the plugin, so genja-startdirs needs nothing else.

## File

`stdpath('data')/startdirs.usage`, one line per dir: `count<Tab>unix time<Tab>path`.
Old `count<Tab>path` lines still read (time 0, weight x0.25) and get rewritten on the next use.

## Test

1. `:e` the usage file: old lines have two fields.
2. Pick a dir you rarely use from the ranked picker (or `<M-1>`…`<M-4>`) two or three times.
2. Pick a dir you rarely use from `:Mydirs` two or three times (`<M-1>`…`<M-4>` jumps are not counted since 1132d6b).
4. The usage file now has three fields per touched line.

Headless-tested: an old 50-use line ranks below a dir used 15 times just now.
