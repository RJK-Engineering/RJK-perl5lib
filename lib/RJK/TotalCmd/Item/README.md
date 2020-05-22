Item
    number              # number (totalcmd.inc)
    menu                # description/tooltip/title
InternalCmd (Item)
    name                # name (cm_*)
Command (Item)
    cmd                 # command
    param               # parameters
    path                # start path
    iconic              # 1 = minimize, -1 = maximize
    key                 # shortcut key (command config)
    shortcuts           # shortcut keys (Options > Misc) only internal and user commands can have shortcuts (start menu items can be accessed as internal commands)
    getCommandName()    # internal or user command from cmd (cm_*, em_*)
    isCommand()         # cmd is not empty
    isInternal()        # cmd contains an internal command name (cm_*)
    isUser()            # cmd contains a user command name (em_*)
MenuItem (Command)
    isSeparator()       # menu = '-'
    isSubmenuBegin()    # menu = '-' + submenu title
    isSubmenuEnd()      # menu = '--'
Button (Command)
    button              # icon resource string
    isButton()          # cmd and button are not empty
    isSeparator()       # cmd or button is empty
UserCmd (Button)
    name                # name (em_*)

-----------
required

Item:           number
InternalCmd:    number, name
MenuItem:       number, cmd, menu
Button:         number
UserCmd:        number, cmd, name
