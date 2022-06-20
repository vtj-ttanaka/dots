flagsChanged = hs.eventtap.event.types.flagsChanged
flag = false

local function launchTerm (event)
   if event:getType() == flagsChanged then
      local f = event:getFlags()
      if f['alt'] then
         local c = event:getKeyCode()
         if c == 58 or c == 61 then
            if not flag then
               flag = true
               hs.timer.doAfter(0.5, function() flag = false end)
            else
               flag = false
               hs.application.launchOrFocus('Hyper')
            end
         else
            flag = false
         end
      end
   end
end

event = hs.eventtap.new({flagsChanged}, launchTerm)
event:start()
