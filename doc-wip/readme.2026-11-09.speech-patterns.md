# Speech patterns in the prompts of 2026-11-09

Read from the transcribed text of one session (diff viewers, colors, reload commands).
Only the text is visible, not the voice: a wrong word can be a slip of the tongue or a mishearing of the dictation.
No psychology here, only patterns that cost a round trip, and what helps.

## 1. Wrong words (slips or mishearings)

| said | meant | kind |
|---|---|---|
| apt-lua file | `opt.lua` | sounds alike |
| cold diff, code commands | codediff | sounds alike |
| field charge | fillchars | sounds alike |
| Ganja Lua folder | `lua/genja` | name not in the dictation vocabulary |
| VIP doc | WIP doc (`doc-wip`) | letters V / W; caught and fixed by the user, the CLAUDE.md list has it |
| $QA, "not $QA, $QA" | `:qa` | a spoken colon command comes out as a symbol |
| div view, diffu module | diffview | clipped word |
| Zen mode (as a pane name) | the file `zenmode.lua` | not a slip, the winbar did show it |
| I won't Control E | I want | sounds alike |
| the QI should be fast | the UI / the quit | sounds alike |
| hit points | hints | sounds alike |
| unified and delta vim | unified and deltaview.nvim | clipped word |

What stands out: almost all are names of this config or of plugins. Plain English comes through well.

## 2. Same word for different things

- context menu: the F2 picker, and the right-click PopUp menu; the sentence "add a context menu" did not say which
- diff view pane: the file panel on the left (what you browse with `j`/`k`), while pane elsewhere meant the two diff windows
- unified view: diffview's one-window mode, or the plugin unified.nvim
- preview: the diff windows, or the file preview in telescope
- mode: diff mode (`:h diff`), layout mode (inline / side by side), the autopreview mode

Each cost a guess on my side; most guesses were right, "Shift J move up" was one I could not check (J goes down in Vim, K up; the layout is jolemak, so the key may sit elsewhere).

## 3. Struggling to put an idea into words

Patterns that showed in this session:

- Spec changes while speaking: the `darken` / `lighten` argument went from 0..1, to "integers and floats", to "forget the float", to 0..100 percent, in one message.
  The last sentence was right, the first three were noise.
- Trailing off: "Implement that. Or actually, like, yeah, like do" ended with no instruction.
- Describing the current state and the wish in one sentence: "make them close to black and just slightly red or green. I want them to fade in with the background"; it is not clear if the first part is what you have or what you want.
- Words without a scale: "super slightly", "barely visible", "even more the same", "a touch". Each needs a number to land.
  It took four rounds on the diff colors (0.30 -> 0.18 -> 0.30 -> 0.17 -> blend 70/80).
- A reference without its target: "This line should be at the very bottom"; the line was the Quit all item, said as if on screen.
- Messages cut in two: "...and that the desktop version" arrived, then "of GitHub doesn't have that feature at all" as a second message.

Good patterns to keep:

- Quick self-correction ("No, forget the float, make it simple") gives a clear final spec.
- Scope sentences: "put it in the Lua file for highlights, not the Vim script" saved a whole question.
- Asking "does that make sense?" or "is it possible?" before ordering a build.

## 4. Hints

1. Add the misheard names to the list in CLAUDE.md (`Working style`): apt-lua = opt.lua, cold diff = codediff, field charge = fillchars, Ganja = genja, div view = diffview, `$QA` = `:qa`.
   Today the list has "deer", "OAuth", "whip doc". (not done, a suggestion)
2. Name the two menus once and keep the names: "F2 menu" and "right-click menu".
3. For appearance, give a reference or a number: "as dark as the line number column", "half of the current value", "15% above the background".
   One of: current value, wanted value, or an anchor color.
4. Order the sentence as: what (file or feature), what changes, the default. Example: "In `opt.lua`, new fold, diffopt histogram, on by default".
5. Say keys the way they are typed: "shift j", "control e", "colon q a"; for commands say "colon" and the letters.
6. When a thought is not finished, say "stop" or "ignore that, new idea" before the next sentence, so a dropped half sentence is not read as an order.
7. Send one message per thought; a continuation of a cut-off sentence is easier to read as "continue: ..." than as a new request.
8. If unsure which of two things is meant, prefer "tell me the options first, change nothing"; this session did that well for the Git GUI question.

## 5. What this analysis cannot tell

- Whether a wrong word came from the voice or from the dictation: only the transcript is visible
- Anything about intent behind a slip: the table lists what was meant when the context made it clear, nothing deeper
