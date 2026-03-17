## The Desire

I want to open buffers and have them by defualt scoped to a tab.
In another tab by default doing :ls would not show other tabs buffers.
If i want to open another tabs buffer in my curretn tab u would still be able to do that.

jump to buffer by defualt will jump to a windown in the current tab that shows that buffer,
if that does not exist but the buffer is scoped to the current tab then it will open the buffer on the curretn window.
if the buffer is not scoped to the tab at all then the jump would jump to the tab where it resieds to the open window on it where it is open.
if in all tabs there is no window that has the buffer open then just go to one of the tabs it is scoped to and open it on its current window...

close a buffer without closing the window
close a buffer with closing the window
close a window without closing a buffer
close a tab with closign the buffers 
all smart closing with validation in case of unsaved edits...

when closing a buffer by deault it closes the window -> that is bad
when closigna window with :q it keeps the buffer alive

## NVIM native

### switchbuf

switchbuf config -> supports openwindow and opentab concepts
also supports split window and new tab -> but those ddnt fit my desire and they are optional
it operates on a priority design...
missing the open on window prior to opentab becuase native nvim doesnt have the concept of scoped tabs

switchbuf is only a configuration that other commands opearte via...
other command:
- sb (split buffer) 
- drop (equivalnt of edit command but witht he switchbuf logic)

important:
- edit command opens the buffer on the current window no questions asked...
- buf command opens the buffer on the current window no questions asked...

notable missing a command that just opens a buf accordign to switchbuf with buf id -- maybe drop but i think it does require a pth and not an id...

### hidden buffers + ls

buffers have types and they are either listed or unlisted (hidden) thus ls shiows them or not and they all are availble on ls!

some specicial plugin buffers even witht the type exisitjng have the naming convention of <plugin>://<name> i guess its helpful
but still the buf type should be enough and having the type be empty i think can help omit them...

### autocmd events

nvim nativly has events that cna trigger commands and functions etc...
some being BufEnter BufDelete TabEnter TabLeave BufWipeout

i tought to myslef i can make scoped tabs without requiring to configure switchbuf stuff and when people use even non swithcbuf commands like edit or buf it would do the scoping logic automatically... jumpt to tab and open on window etc...
this is duable...

## The Problem

the problem starts with the idea of the buf command... its sucha simple command that is usable and i dont want to restrict its use...
but even if it did work according to swithcbuf, we said swithcbuf soesnt have our full desire capabilities so problemo...

i dont want one buffer to be only on one tab but i definilty dont want all buffers to be always seen in all tabs unless opt in

even if we use the drop command for plugins like the snacks picker we in trouble becuase switchbuf doesnt support our extra logic...
buffer managers designs and oil filesystem stuff both use either the buf or edit or configurable to drop commands.

in the good case they are configurable, those who arent like the buffer manager plugin do not have a pace at all becuase its the minimum stuff needed
snakcs picker is and can also call a custom function which is good
buffer manager plugin doesnt even support ls! call and no way to ovveride and uses badd (buffer add) also terrible decision it made it a edit and buf manager which is incorrect to a plugin called buffer manager...

## Solutions

if i were to do a pr to nvim i would add the scoped buffers concept with the simplest of things
- the tab to buffers mapping
- the buffer to tabs mapping
- making a b2 command that can be enbaled but not override buffer command to not break stuff - operates accordignn to swithcbuf config + ! to open in current window no questions asked
- make another case for the switchbuf for the open in current window if no window in tab has it and is scopedd to tab...
- make drop command support new optional switchu option along with sb and any other command that nativly already supports optional swithcbuf
- to keep the logic small in the new b2 command and any other switchbuf based command and not need to modify the native edit and buf commands i might think its a fine idea to add the buffer to a tab and the tab to a buffer in the mappings still via the event autocmds
- definitly have the tab neter and leave autocmd doing the unlist and list logic on their scoped buffers...

the thing is we can do that wihtout doing a pr first via custom lua or fnl code becuase as we said here we can use autocmds to make edit and buf commnads auto add to scope without changing how they work and just havea custom B command that eitehr recevis text or buf id (any number) that will do the custom logic us...
by default we would still be using the switchug configuration just acknoleding in the implemtation of the commad that no matter the order of the swithcbuf config, directly after the useopen option it will do our custom logic...
