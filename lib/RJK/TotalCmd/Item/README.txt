
Classes

Item (ItemInterface) (abstract)
    number              # number (totalcmd.inc) (required)
    menu                # description/tooltip/title
InternalCmd (Item, CommandInterface)
    name                # name (cm_*) (required)
MenuItem (Item, MenuItemInterface) (abstract)
DirMenuItem (MenuItem) (required inherited fields: menu)
    cmd                 # command
    path                # target path
Command (Item, CommandInterface) (abstract)
    cmd                 # command
    param               # parameters
    path                # start path
    iconic              # 1 = minimize (or "show as menu" if cmd ends with .bar, making the item a subbar), -1 = maximize
    key                 # shortcut key (command config)
    shortcuts           # shortcut keys (Options > Misc) only internal and user commands can have shortcuts (start menu items can be accessed as internal commands)
StartMenuItem (MenuItem, Command) (required inherited fields: cmd, menu)
Button (Command, ButtonInterface)
    button              # icon resource string
UserCmd (Button) (required inherited fields: cmd)
    name                # name (em_*) (required)

Required fields

Item:           number
InternalCmd:    number, name
DirMenuItem:    number, menu
StartMenuItem:  number, cmd, menu
Button:         number
UserCmd:        number, cmd, name

Interfaces

ItemInterface
    isCommand()         # cmd is not empty
    isButton()          # cmd and button are not empty
    isMenuItem()        # menu is not empty
CommandInterface
    isInternal()        # cmd contains an internal command name (cm_*)
    isUser()            # cmd contains a user command name (em_*)
    getCommandName()    # internal or user command name or undefined
MenuItemInterface
    isSeparator()       # menu = '-'
    isSubmenuBegin()    # menu = '-' + submenu title
    isSubmenuEnd()      # menu = '--'
ButtonInterface
    isSeparator()       # cmd or button is empty

Inheritance

Item (number, menu) abstract class -- required: number
    InternalCmd(name) -- required: name
    MenuItem () abstract class
        DirMenuItem (cmd, path) -- required: menu
    Command (cmd, param, path, iconic, key, shortcuts) abstract class
        Button (button)
            UserCmd (name) -- required: cmd, name
    MenuItem, Command
        StartMenuItem () -- required: cmd, menu
