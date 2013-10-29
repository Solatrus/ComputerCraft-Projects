-- Version 1.5 - February 25, 2013

local largs = { ... }
local monitor = peripheral.wrap("right")
monitor.setTextScale(0.5)
local side = "top"
--local modem = perpipheral.wrap("left")
--modem.open()

local data = {}
local lines = {}

rednet.open("back")

lines["lpa"] =        {title="Laser-Powered Assembly         ", status=redstone.testBundledInput(side, colors.black), color=colors.black}
lines["tfarm"] =      {title="Tree Farm (Inactive)           ", status=redstone.testBundledInput(side, colors.green), color=colors.green}
lines["afarm"] =      {title="Agricultural Farm              ", status=redstone.testBundledInput(side, colors.lightGray), color=colors.lightGray}
lines["minium"] =     {title="Minium Stone Sequence          ", status=redstone.testBundledInput(side, colors.cyan), color=colors.cyan}
lines["cobblegen"] =  {title="Stone Generators               ", status=redstone.testBundledInput(side, colors.magenta), color=colors.magenta}
lines["pumplava"] =   {title="Lava Tank Pump                 ", status=redstone.testBundledInput(side, colors.red), color=colors.red}

data["lines"] = lines

table.sort(data.lines)
  
function printLineStatus(line)
  term.setTextColor(line.color)
  if line.color == colors.black then term.setTextColor(colors.gray) end
  write(line.title)
  term.setTextColor(colors.lightGray)
  write(" - ")
  if line.title == "Storage Room - Sand Direction  " then
    if not line.status then 
      term.setTextColor(colors.green)
      write("To Tree Farm\n")
    else
      term.setTextColor(colors.orange)
      write("To Crafting Station\n")
    end
  else
    if line.status then 
      term.setTextColor(colors.lime)
      write("ON\n")
    else
      term.setTextColor(colors.gray)
      write("OFF\n")
    end
  end
  
end

function displayStatus(pretext)
  term.redirect(monitor)
  term.clear()
  term.setCursorPos(1,1)
  term.setTextColor(colors.white)
  data["pretext"] = pretext
  print(data.pretext)
  for key,line in pairs(data.lines) do printLineStatus(line) end
  term.restore()
end

function main(args)
  local helpText = "Uses:\n" ..
    "base-main status - gets status\n" ..
    "base-main listen - remote mode\n" ..
    "base-main <item> - toggles line\n" ..
    "Items are: "

    if coroutine.running() ~= nil then helpText = string.gsub(helpText, "base-main ", "base-remote ") end
    
    data.help = helpText
    for k,v in pairs(data.lines) do data.help = data.help .. k .. ", " end
    data.help = string.sub(data.help, 0, -3)
    data.help = data.help .. "\n"

  if #args == 0 or args[1] == "help" then
    if coroutine.running() ~= nil then write(data.help) end
  else
    --data["help"] = nil
    if args[1] == "status" then
      displayStatus("Status:")
    else
      local colorInt = 0

      if data.lines[args[1]] == nil then
          data.help = "Invalid argument: " .. args[1] .. "\n" .. data.help

          if not coroutine.running() ~= nil then write(data.help) end
          return
      else
        data.help = nil
        data.lines[args[1]].status = not data.lines[args[1]].status
      end
    
      for k,v in pairs(lines) do if v.status then colorInt = colorInt + v.color end end

      redstone.setBundledOutput(side, colorInt)
      displayStatus("Toggled " ..  data.lines[args[1]].title .. "\nStatus:")
      --sleep(2)
      --rednet.broadcast("Toggled " .. lineName(args[1]) .. "\n")
    end
  end
end

local remoteThread = function()
  while true do
    --sleep(3)
    local senderID, message, distance = rednet.receive()
   
    local match = string.match(message, "%w+%s+(%w+)")
   
    args = { match }

    write("\n")
 
    --if #args == 0 then print("Remote command - help") else print("Remote command - " .. args[1]) end

    main(args)

    --write("base> ")

    --print(textutils.serialize(broadcastData))

    rednet.send(senderID, textutils.serialize(data))
  end
end

local localThread = function()
  while true do
    sleep(0.1)
    term.restore()
    write("base:/" .. shell.dir() .."> ")
    local input = read()

    if input == "exit" then return end

    local command, arguments = string.match(input, "(%w+)%s*(.*)")

    if command == nil then command = input end
    if arguments == nil then arguments = "" end

    if command == "toggle" then
      args = { arguments }
      main(args)
    elseif command == "status" then
      args = { command }
      main(args)
    elseif command == "update" then
      shell.run("upscrp","base main")
      os.reboot()
    elseif command ~= "base-main" then
      shell.run(command,arguments)
    end
  end
end 

if ((#largs == 0) or (largs[1] ~= "listen")) then
  main(largs)
else
  --print("Listening for remote...")
  
  parallel.waitForAny(remoteThread,localThread)
end