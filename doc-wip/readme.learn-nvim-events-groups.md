# nvim autocmd events by group

```
Source: :help autocmd-events (nvim 0.11+). Names are case-insensitive.
Pre = before, Post = after, Cmd = replaces the action (|Cmd-event|).

STARTUP / EXIT
  VimEnter          after startup (vimrc, -c, windows, buffers loaded)
  VimLeavePre       before exit, before writing shada
  VimLeave          before exit, after writing shada
  ExitPre           :quit/:qall that makes nvim exit, after QuitPre
  QuitPre           :quit/:wq/:qall, before deciding to close window or exit
  UIEnter / UILeave a UI attached / detached (builtin TUI too)
  VimSuspend        before suspend (CTRL-Z)
  VimResume         after resume from suspend
  VimResized        'lines'/'columns' changed
  FocusGained       nvim got focus
  FocusLost         nvim lost focus (also GUI dialogs)
  Signal            signal received (SIGUSR1, SIGWINCH only)
  RemoteReply       reply from a server2client() peer
  SafeState         nothing pending, about to wait for a key
  StdinReadPre      startup, before reading stdin into the buffer
  StdinReadPost     startup, after reading stdin

BUFFER LIFECYCLE
  BufNew            buffer created or renamed
  BufAdd            buffer added to the list
  BufDelete         before removing from the buffer list
  BufUnload         before unloading (freeing text)
  BufWipeout        before completely deleting
  BufHidden         last window left, buffer hidden (not unloaded)
  BufFilePre        before :file / :saveas renames the buffer
  BufFilePost       after the rename

BUFFER ENTER / LEAVE
  BufEnter          after entering a buffer
  BufLeave          before leaving to another buffer
  BufWinEnter       buffer displayed in a window (also hidden buffer shown again)
  BufWinLeave       buffer removed from a window

READING A BUFFER
  BufNewFile        editing a file that does not exist (skeletons)
  BufReadPre        before reading the file into the buffer
  BufRead           after reading, before modelines (= BufReadPost)
  BufReadCmd        replaces reading the file

WRITING A BUFFER
  BufWritePre       before writing the whole buffer (= BufWrite)
  BufWritePost      after writing
  BufWriteCmd       replaces writing the file

PARTIAL FILE READ / WRITE / APPEND (:read, :write range, :write >>)
  FileReadPre / FileReadPost / FileReadCmd
  FileWritePre / FileWritePost / FileWriteCmd
  FileAppendPre / FileAppendPost / FileAppendCmd

FILTERS (:{range}!cmd, external diff)
  FilterReadPre / FilterReadPost     around reading filter output
  FilterWritePre / FilterWritePost   around writing to a filter or external diff
  ShellCmdPost                       after :!cmd, :make, :grep
  ShellFilterPost                    after :{range}!cmd, :w !cmd, :r !cmd

FILE CHANGED OUTSIDE / READ-ONLY / SWAP
  FileChangedShell      mtime or attributes changed since editing started
  FileChangedShellPost  after handling that change
  FileChangedRO         first change to a read-only file (checkout hook)
  SwapExists            existing swap file found when opening

FILETYPE / SYNTAX / SPELL
  FileType          'filetype' was set
  Syntax            'syntax' was set
  SpellFileMissing  spell file for a language not found

OPTIONS / COLORS / MARKS
  OptionSet         after setting an option (not during startup)
  ColorSchemePre    before :colorscheme loads
  ColorScheme       after :colorscheme loaded
  MarkSet           mark set or deleted (m, :mark, :delmarks)
  DirChangedPre     cwd about to change
  DirChanged        cwd changed (pattern: global, window, tabpage, auto)

MODES
  ModeChanged       mode changed; pattern matches 'old:new'
  InsertEnter       just before Insert/Replace mode
  InsertLeavePre    just before leaving Insert (also CTRL-O)
  InsertLeave       just after leaving Insert (not CTRL-C)
  InsertChange      <Insert> pressed in Insert/Replace
  InsertCharPre     char typed in Insert, before inserting (v:char)
  RecordingEnter    macro recording starts
  RecordingLeave    macro recording stops
  SearchWrapped     n/N search wrapped around

CURSOR / IDLE
  CursorMoved       cursor moved in Normal/Visual
  CursorMovedI      cursor moved in Insert (not with popup menu)
  CursorMovedC      cursor moved in the command line
  CursorHold        no input for 'updatetime', Normal mode
  CursorHoldI       same, Insert mode

TEXT CHANGES
  TextChanged       text changed in Normal mode
  TextChangedI      text changed in Insert mode (no popup menu)
  TextChangedP      text changed in Insert mode, popup menu visible
  TextChangedT      text changed in Terminal mode
  TextYankPost      after yank or delete (not black hole)
  TextPutPre        before text is put
  TextPutPost       after text is put
  DiffUpdated       diffs updated
  CmdAtom           after one user action ("atom" of input)

COMPLETION
  CompleteChanged   Insert completion menu changed
  CompleteDonePre   completion done, before v:completed_item is cleared
  CompleteDone      completion done, after

COMMAND LINE
  CmdlineEnter      entered the command line
  CmdlineChanged    every change in the command line
  CmdlineLeavePre   just before leaving, before CmdlineLeave
  CmdlineLeave      before leaving the command line
  CmdwinEnter       entered the command-line window
  CmdwinLeave       before leaving it
  CmdUndefined      user command used but not defined
  FuncUndefined     user function used but not defined
  MenuPopup         before the right-click popup menu

WINDOWS
  WinNewPre         before a window is created
  WinNew            window created (before WinEnter)
  WinEnter          entered a window (not the first at startup)
  WinLeave          before leaving a window
  WinClosed         window closing, still in the layout (pattern: window-ID)
  WinResized        a window in the tabpage changed size
  WinScrolled       a window in the tabpage scrolled or changed size

TABPAGES
  TabNew            tabpage created (after WinEnter, before TabEnter)
  TabNewEntered     after entering a new tabpage (after BufEnter)
  TabEnter          just after entering a tabpage
  TabLeave          just before leaving a tabpage
  TabClosedPre      before closing a tabpage
  TabClosed         after closing a tabpage
  TabMoved          tabpage moved

TERMINAL
  TermOpen          terminal job starting
  TermEnter         entered Terminal mode
  TermLeave         left Terminal mode
  TermClose         terminal job ended
  TermRequest       terminal child emitted OSC/DCS/APC
  TermResponse      host terminal replied (OSC/DCS/APC/CSI)

CHANNELS
  ChanOpen          channel opened
  ChanInfo          channel state changed
  ChanClose         channel closed

QUICKFIX / SESSIONS / SOURCING
  QuickFixCmdPre    before :make, :grep, :vimgrep and friends
  QuickFixCmdPost   after, before jumping to the first location
  SessionLoadPre / SessionLoadPost     around loading a :mksession file
  SessionWritePre / SessionWritePost   around writing one
  SourcePre         before :source
  SourcePost        after :source
  SourceCmd         replaces :source

LSP (see :help lsp-events)
  LspAttach         client attached to a buffer
  LspDetach         client detached from a buffer
  LspNotify         notification sent or received
  LspRequest        request state changed
  LspProgress       $/progress message received
  LspTokenUpdate    semantic token becomes visible or changes

PLUGINS / MISC
  PackChangedPre    before vim.pack changes a plugin
  PackChanged       after vim.pack changed a plugin
  Progress          progress message created or updated (nvim_echo)
  User              never automatic; :doautocmd User {pattern}
  UserGettingBored  joke event, nothing triggers it
```
