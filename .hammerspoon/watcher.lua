local function handleGlobalAppEvent(name, event, app)
   if event == hs.application.watcher.activated then
      if name == "Hyper" then
         hs.eventtap.keyStroke({}, 0x66)
      elseif name == "Slack" then
         hs.eventtap.keyStroke({}, 0x68)
      end
   end
end

local appsWatcher = hs.application.watcher.new(handleGlobalAppEvent)
appsWatcher:start()
