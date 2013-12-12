--[[

     Copland Awesome WM config
     github.com/copycat-killer

--]]

-- {{{ Required libraries
local gears     = require("gears")
local awful     = require("awful")
awful.rules     = require("awful.rules")
require("awful.autofocus")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local drop      = require("scratchdrop")
local lain      = require("lain")
-- local eminent   = require("eminent")
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
                     title = "Oops, there were errors during startup!",
                     naughty.notify({ preset = naughty.config.presets.critical,
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart applications
function run_once(prg,arg_string,pname,screen)
    if not prg then
        do return nil end
    end
    if not pname then pname = prg
    end
    if not arg_string then
        awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. ")",screen)
    else
        awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. " ".. arg_string .."' || (" .. prg .. " " .. arg_string .. ")",screen)
    end
end

run_once("unclutter", "-idle 1")
run_once("compton")
run_once("mpd")
run_once("xrdb", ".Xresources")
-- run_once("~/bin/tmux-player")
run_once("redshift")

-- }}}

-- {{{ Variable definitions
-- localization
os.setlocale(os.getenv("LANG"))

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/fede/theme.lua")

-- common
modkey     = "Mod4"
altkey     = "Mod1"
terminal   = "xterm"
editor     = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- user defined
music    = "~/bin/tmux-player"
screenshot = terminal .. "-e /home/fede/bin/screenshot "

local layouts = {
    awful.layout.suit.floating,
    lain.layout.uselesstile,
    lain.layout.uselesstile.left,
    lain.layout.uselesstile.top,
    --lain.layout.termfair,
}
-- }}}

-- {{{ Tags
tags = {
    names2 = { "term", "devl", "file", "stat" },
    names = { "inet", "ethz", "docs", "misc" },-- Secondary screen
    layout = { layouts[2], layouts[1], layouts[1],  layouts[2] },
    layout2 = { layouts[3], layouts[2], layouts[2], layouts[3] }
}
tags[1] = awful.tag(tags.names2, 2, tags.layout2)
tags[2] = awful.tag(tags.names, 1, tags.layout)
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Menu
require("freedesktop/freedesktop")
-- }}}

-- {{{ Wibox
markup = lain.util.markup
blue   = beautiful.fg_focus

-- Textclock
mytextclock = awful.widget.textclock("<span font='Tamsyn 5'> </span>%d %b %H:%M ")

-- Calendar
lain.widgets.calendar:attach(mytextclock)

--[[ Mail IMAP check
-- commented because it needs to be set before use
mailwidget = lain.widgets.imap({
    timeout  = 180,
    server   = "server",
    mail     = "mail",
    password = "keyring get mail",
    settings = function()
        mail  = ""
        count = ""

        if mailcount > 0 then
            mail = "<span font='Tamsyn 5'> </span>Mail "
            count = mailcount .. " "
        end

        widget:set_markup(markup(blue, mail) .. count)
    end
})
]]

-- MPD
mpdicon = wibox.widget.imagebox(beautiful.play)
mpdwidget = lain.widgets.mpd({
    settings = function()
        if mpd_now.state == "play" then
            title = mpd_now.title
            artist  = " - " .. mpd_now.artist  .. markup("#333333", " |<span font='Tamsyn 3'> </span>")
            mpdicon:set_image(beautiful.play)
        elseif mpd_now.state == "pause" then
            title = "mpd "
            artist  = "paused" .. markup("#333333", " |<span font='Tamsyn 3'> </span>")
            mpdicon:set_image(beautiful.pause)
        else
            title  = ""
            artist = ""
            mpdicon:set_image()
        end

        widget:set_markup(markup(blue, title) .. artist)
    end
})

-- Battery
baticon = wibox.widget.imagebox(beautiful.bat)
batbar = awful.widget.progressbar()
batbar:set_color(beautiful.fg_normal)
batbar:set_width(55)
batbar:set_ticks(true)
batbar:set_ticks_size(6)
batbar:set_background_color(beautiful.bg_normal)
batmargin = wibox.layout.margin(batbar, 2, 7)
batmargin:set_top(6)
batmargin:set_bottom(6)
batupd = lain.widgets.bat({
    settings = function()
        if bat_now.perc == "N/A" then
            bat_perc = 100
            baticon:set_image(beautiful.ac)
        else
            bat_perc = tonumber(bat_now.perc)
            if bat_perc > 50 then
                batbar:set_color(beautiful.fg_normal)
                baticon:set_image(beautiful.bat)
            elseif bat_perc > 15 then
                baticon:set_image(beautiful.bat_low)
            else
                batbar:set_color("#EB8F8F")
                baticon:set_image(beautiful.bat_no)

            end

        end
        batbar:set_value(bat_perc / 100)
    end
})
batwidget = wibox.widget.background(batmargin)
batwidget:set_bgimage(beautiful.widget_bg)

-- /home fs
diskicon = wibox.widget.imagebox(beautiful.disk)
diskbar = awful.widget.progressbar()
diskbar:set_color(beautiful.fg_normal)
diskbar:set_width(55)
diskbar:set_ticks(true)
diskbar:set_ticks_size(6)
diskbar:set_background_color(beautiful.bg_normal)
diskmargin = wibox.layout.margin(diskbar, 2, 7)
diskmargin:set_top(6)
diskmargin:set_bottom(6)
fshomeupd = lain.widgets.fs({
    partition = "/home",
    settings  = function()
        if fs_now.used < 90 then
            diskbar:set_color(beautiful.fg_normal)
        else
            diskbar:set_color("#EB8F8F")
        end
        diskbar:set_value(fs_now.used / 100)
    end
})
diskwidget = wibox.widget.background(diskmargin)
diskwidget:set_bgimage(beautiful.widget_bg)

-- ALSA volume bar
volicon = wibox.widget.imagebox(beautiful.vol)
volume = lain.widgets.alsabar({width = 55, ticks_size = 6,
settings = function()
    if volume_now.status == "off" then
        volicon:set_image(beautiful.vol_mute)
    elseif volume_now.level == 0 then
        volicon:set_image(beautiful.vol_no)
    elseif volume_now.level <= 50 then
        volicon:set_image(beautiful.vol_low)
    else
        volicon:set_image(beautiful.vol)
    end
end,
colors =
{
    background = beautiful.bg_normal,
    mute = "#EB8F8F",
    unmute = beautiful.fg_normal
}})
volmargin = wibox.layout.margin(volume.bar, 2, 7)
volmargin:set_top(6)
volmargin:set_bottom(6)
volumewidget = wibox.widget.background(volmargin)
volumewidget:set_bgimage(beautiful.widget_bg)

-- Weather
yawn = lain.widgets.yawn(784794,
{
    timeout  = 80,
})

-- Separators
spr = wibox.widget.textbox(' ')
small_spr = wibox.widget.textbox('<span font="Tamsyn 4"> </span>')
bar_spr = wibox.widget.textbox('<span font="Tamsyn 3"> </span>' .. markup("#333333", "|") .. '<span font="Tamsyn 3"> </span>')

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 18 })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(small_spr)
    left_layout:add(mylayoutbox[s])
    left_layout:add(bar_spr)
    left_layout:add(mytaglist[s])
    left_layout:add(spr)
    left_layout:add(bar_spr)
    left_layout:add(mypromptbox[s])
    left_layout:add(spr)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then
      right_layout:add(wibox.widget.systray())
      right_layout:add(small_spr)
      right_layout:add(mpdicon)
      right_layout:add(mpdwidget)
      --right_layout:add(mailwidget)
      --right_layout:add(baticon)
      --right_layout:add(batwidget)
      -- right_layout:add(bar_spr)
      right_layout:add(diskicon)
      right_layout:add(diskwidget)
      right_layout:add(bar_spr)
      right_layout:add(volicon)
      right_layout:add(volumewidget)
      right_layout:add(bar_spr)
      right_layout:add(mytextclock)
    end

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Take a screenshot
    awful.key({ }, "Print", function() awful.util.spawn(screenshot) end),

    -- Tag browsing
    awful.key({ modkey, "Control" }, "h", awful.tag.viewprev  ),
    awful.key({ modkey, "Control" }, "l", awful.tag.viewnext  ),
    awful.key({ modkey }, "Escape", awful.tag.history.restore ),

    -- Change tag of the other screen
    awful.key({ modkey }, "Right",
        function()
            if screen.count() == 2 then
                s = mouse.screen
                if s == 1 then ss = 2 else ss = 1 end
                awful.tag.viewnext(screen[ss].index)
                awful.screen.focus(s)
            end
        end ),
    awful.key({ modkey }, "Left",
        function()
            if screen.count() == 2 then
                s = mouse.screen
                if s == 1 then ss = 2 else ss = 1 end
                awful.tag.viewprev(screen[ss].index)
                awful.screen.focus(s)
            end
        end ),

    -- Non-empty tag browsing
    awful.key({ altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end),
    awful.key({ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end),

    -- Default client focus
    awful.key({ altkey }, "k",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ altkey }, "j",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- By direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.global_bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.global_bydirection("right")
            if client.focus then client.focus:raise() end
        end),

    -- Show Menu
    awful.key({ modkey }, "w",
        function ()
            mymainmenu:show({ keygrabber = true })
        end),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
    end),

    -- On the fly useless gaps change
    awful.key({ altkey, "Control" }, "=", function () lain.util.useless_gaps_resize(1) end),
    awful.key({ altkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end),

    -- Rename tag
    -- awful.key({ altkey, "Shift"   }, "r", function () lain.util.rename_tag(mypromptbox) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ altkey, "Shift"   }, "l",      function () awful.tag.incmwfact( 0.02)     end),
    awful.key({ altkey, "Shift"   }, "h",      function () awful.tag.incmwfact(-0.02)     end),
    awful.key({ modkey, "Shift"   }, "l",      function () awful.tag.incnmaster(-1)       end),
    awful.key({ modkey, "Shift"   }, "h",      function () awful.tag.incnmaster( 1)       end),
    awful.key({ modkey,           }, "-",      function () awful.tag.incncol(-1)          end),
    awful.key({ modkey,           }, "=",      function () awful.tag.incncol( 1)          end),
    awful.key({ modkey,           }, "space",  function () awful.layout.inc(layouts,  1)  end),
    awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(layouts, -1)  end),
    awful.key({ modkey, "Control" }, "n",      awful.client.restore),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r",      awesome.restart),
    awful.key({ modkey, "Shift"   }, "q",      awesome.quit),

    -- Dropdown terminal
    awful.key({ modkey,	          }, "z",      function () drop(terminal) end),

    -- Widgets popups
    awful.key({ altkey,           }, "c",      function () lain.widgets.calendar:show(7) end),
    awful.key({ altkey,           }, "h",      function () fshomeupd.show(7) end),
    awful.key({ altkey,           }, "w",      function () yawn.show(7) end),

    -- ALSA volume control
    awful.key({ altkey }, "Up",
        function ()
            awful.util.spawn("amixer -q set " .. volume.channel .. " " .. volume.step .. "+")
            volume.notify()
        end),
    awful.key({ altkey }, "Down",
        function ()
            awful.util.spawn("amixer -q set " .. volume.channel .. " " .. volume.step .. "-")
            volume.notify()
        end),
    awful.key({ altkey }, "m",
        function ()
            awful.util.spawn("amixer -q set " .. volume.channel .. " playback toggle")
            volume.notify()
        end),
    --awful.key({ altkey, "Control" }, "m",
        --function ()
            --awful.util.spawn("amixer -q set " .. volume.channel .. " playback 100%")
            --volume.notify()
        --end),

    -- MPD control
    awful.key({ altkey, "Control" }, "Up",
        function ()
            awful.util.spawn_with_shell("mpc toggle || ncmpcpp toggle || ncmpc toggle || pms toggle")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Down",
        function ()
            awful.util.spawn_with_shell("mpc stop || ncmpcpp stop || ncmpc stop || pms stop")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Left",
        function ()
            awful.util.spawn_with_shell("mpc prev || ncmpcpp prev || ncmpc prev || pms prev")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Right",
        function ()
            awful.util.spawn_with_shell("mpc next || ncmpcpp next || ncmpc next || pms next")
            mpdwidget.update()
        end),

    -- Copy to clipboard
    -- awful.key({ modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end),

    -- User programs
    awful.key({ modkey , "Control"}, "m", function () awful.util.spawn_with_shell(music) end),

    -- Prompt
    awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ altkey, "Shift"   }, "m",      lain.util.magnify_client                         ),
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.toggletag(tag)
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     size_hints_honor = false } },
    --{ rule = { class = "st" },
          --properties = { opacity = 0.99 } },

    { rule = { instance = "xterm", name = "vimpc"},
          properties = {floating = false, tag = tags[1][3] } },

    { rule = { class = "MPlayer" },
          properties = { floating = true } },

    { rule = { name = "mutt" },
          properties = { floating = true } },

    { rule = { name = "Google Keep" },
          properties = { floating = true } },

    { rule = { name = "Eclipse SDK" },
          properties = { floating = true } },

    { rule = { class = "feh" },
          properties = { floating = true } },

    { rule = { class = "sxiv" },
          properties = { floating = true } },

    { rule = { instance = "sun-awt-X11-XFramePeer" },
          properties = { floating=true} },

    { rule = { instance = "plugin-container" },
          properties = { tag = tags[1][1] } },

	  --{ rule = { class = "Gimp" },
                --properties = { tag = tags[1][4] } },

    --{ rule = { class = "Gimp", role = "gimp-image-window" },
          --properties = { maximized_horizontal = true,
                         --maximized_vertical = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup and not c.size_hints.user_position
       and not c.size_hints.program_position then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
    end
end)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_width = 0
            c.border_color = beautiful.border_normal
        else
            c.border_width = beautiful.border_width
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
        local clients = awful.client.visible(s)
        local layout  = awful.layout.getname(awful.layout.get(s))

        if #clients > 0 then -- Fine grained borders and floaters control
            for _, c in pairs(clients) do -- Floaters always have borders
                if awful.client.floating.get(c) or layout == "floating" then
                    c.border_width = beautiful.border_width

                -- No borders with only one visible client
                elseif layout == "max" then
                    clients[1].border_width = 0
                    awful.client.moveresize(0, 0, 2, 2, clients[1])
                else
                    c.border_width = beautiful.border_width
                end
            end
        end
      end)
end
-- }}}
