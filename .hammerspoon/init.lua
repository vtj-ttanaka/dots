local keycode = -1

local function resetKeycode()
   keycode = -1
end

local function eventhandler(e)
   if e:getType() == hs.eventtap.event.types.flagsChanged then
      local f = e:getFlags()
      if f['alt'] or f['cmd'] then
         local c = e:getKeyCode()
         if c == keycode then
            resetKeycode()
            if c == 58 or c == 61 then
               hs.application.launchOrFocus('Hyper')
            elseif c == 55 then
               local screen = hs.mouse.getCurrentScreen()
               local rect = screen:fullFrame()
               local center = hs.geometry.rectMidPoint(rect)
               hs.mouse.absolutePosition(center)
            end
         else
            keycode = c
            hs.timer.doAfter(0.5, resetKeycode)
         end
      end
   end
end

event = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, eventhandler)
event:start()

local function handleGlobalAppEvent(name, event, app)
   if event == hs.application.watcher.activated then
      -- Set input method to en
      if name == "Hyper" then
         hs.eventtap.keyStroke({}, 0x66)
      -- Set input method to ja
      elseif name == "Slack" then
         hs.eventtap.keyStroke({}, 0x68)
      end
   end
end

local appsWatcher = hs.application.watcher.new(handleGlobalAppEvent)
appsWatcher:start()
