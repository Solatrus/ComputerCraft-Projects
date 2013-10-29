args = { ... }

local baseID = 55

--local modem = peripheral.wrap("top")

--modem.open()
rednet.open("top")

if #args == 0 then
  rednet.broadcast(baseID, "base")
else
  local broadcast = "base " .. args[1]
  rednet.send(baseID, broadcast)
end


local senderID, message, distance = rednet.receive(5)

if senderID == nil then
  print("No response.")
  return
end

data = textutils.unserialize(message)

term.setTextColor(colors.white)

function printLineStatus(line)
  term.setTextColor(line.color)
  if line.color == colors.black then term.setTextColor(colors.gray) end
  write(line.title)
  term.setTextColor(colors.lightGray)
  write(" - ")
  if line.title == "Storage Room - Sand Direction  " then
    if line.status then 
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

function displayStatus()
  --term.redirect(monitor)
  --term.clear()
  term.setTextColor(colors.white)
  print(data.pretext)
  for key, line in pairs(data.lines) do
    printLineStatus(line)
  end
end

if data.help ~= nil then write(data.help) else displayStatus() end
