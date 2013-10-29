-- Code copied and modified from http://pastebin.com/6jjXTe4m

local rsSide = "back"
local monitorSide = "right"

function testForMonitor(_side)
  if peripheral.getType(_side) then
    if peripheral.getType(_side) == "monitor" then
      return true
    else return false end
  else return false end
end

Args = { ... }
if #Args < 1 then
  print("Usage: "..fs.getName(shell.getRunningProgram()).." <monitor side> [cable side]")
  return
elseif #Args > 1 then
  monitorSide = Args[1]
  rsSide = Args[2]
  if not testForMonitor(monitorSide) then
    print("There is no valid monitor on that side.")
    return
  end
elseif #Args == 1 then
  monitorSide = Args[1]
  if not testForMonitor(monitorSide) then
    print("There is no valid monitor on that side.")
    return
  end
else
  print("Error!!!")
  return
end

function toggle(n)
  if not n then
    return
  end
  local state = button[n].state
  if state then
    state = false
  else
    state = true
  end
  button[n].state = state
  return state
end
 
function sayState(n)
  if not n then
    return
  end
  x = button[n].x - 1
  y = button[n].y
  term.setCursorPos(x,y)
  if button[n].state then
    term.setTextColor(colors.lime)
    write("on ")
    term.setTextColor(colors.white)
  else
    term.setTextColor(colors.red)
    write("off")
    term.setTextColor(colors.white)
  end
end
 
function getButton(xPos,yPos)
  for i=1,12 do
    bxPos = button[i].x
    byPos = button[i].y
    xMax = bxPos + 2
    xMin = bxPos - 2
    yMax = byPos + 1
    yMin = byPos - 1
    if xPos >= xMin and xPos <= xMax and yPos >= yMin and yPos <= yMax then
      return i
    end
  end
end
 
function mPrint(w)
  write(w)
  x,y=term.getCursorPos()
  term.setCursorPos(1, y+1)
end
 
function allTheSame()
  local state = button[1].state
  for i = 2,10 do
    if state == button[i].state then
    else return false
    end
  end
  return true
end
 
function stateWriter()
  mPrint("  _____     _____     _____     _____")
  write("  ")
  for i = 1,4 do
    write("|")
    term.setTextColor(colors.red)
    write("off")
    term.setTextColor(colors.white)
    if i<4 then
      write("|     ")
    else
      mPrint("|")
    end
  end
  mPrint("  ~~~~~     ~~~~~     ~~~~~     ~~~~~")
end

function mobTypeWrite(_line,_time)
  term.setCursorPos(1,_line)
  write("  ")
  local additive = (_time - 1) * 4
  local currentx = 3
  for i = 1,4 do
    local buttonNumber = additive + i
    term.setTextColor(button[buttonNumber].color)
    write(button[buttonNumber].mob)
    term.setTextColor(colors.white)
    if i == 4 then
      
    else
      currentx = currentx + 10
      term.setCursorPos(currentx,_line)
    end
  end
  term.setCursorPos(1, _line + 1)
end
    
 
function startText()
  term.setCursorPos(1,1)
  mPrint("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
  mPrint(" Welcome to Base Control! Right click")
  mPrint(" to toggle a line.")
  mPrint(" ")
  mobTypeWrite(5,1)
  stateWriter()
  mPrint(" ")
  mobTypeWrite(10,2)
  stateWriter()
  mPrint(" ")
  mobTypeWrite(15,3)
  stateWriter()
  mPrint("_______________________________________")
end
 
function bundleState()
  running = 0
  for light = 1, 10 do
    if button[light].state == true then
      running = running + button[light].color
    end
  end
  return running
end

function refresh()
  redstone.setBundledOutput(rsSide, bundleState())
end

--This is the table that controls everything. Don't touch unless you know what you are doing.

button = {
  [1] = {x = 5; y = 7; state = false; color = colors.orange; mob = "LavaPump"},
  [2] = {x = 15; y = 7; state = false; color = colors.red; mob = "Engines"},
  [3] = {x = 25; y = 7; state = false; color = colors.lime; mob = "MainBatt"},
  [4] = {x = 35; y = 7; state = false; color = colors.magenta; mob = "Tesser"},
  
  [5] = {x = 5; y = 12; state = false; color = colors.yellow; mob = "LaserBatt"},
  [6] = {x = 15; y = 12; state = false; color = colors.green; mob = "N/A"},
  [7] = {x = 25; y = 12; state = false; color = colors.pink; mob = "N/A"},
  [8] = {x = 35; y = 12; state = false; color = colors.gray; mob = "N/A"},
  
  [9] = {x = 5; y = 17; state = false; color = colors.lightGray; mob = "N/A"},
  [10] = {x = 15; y = 17; state = false; color = colors.cyan; mob = "N/A"},
  [11] = {x = 25; y = 17; state = false; color = colors.white; mob = "All"},
  [12] = {x = 35; y = 17; state = false; color = colors.white; mob = "All"}
}
 
display = peripheral.wrap(monitorSide)
term.redirect(display)
term.clear()
term.setCursorPos(1,1)
 
local resume = true
startText()
for i = 1,10 do
  sayState(i)
end
term.setCursorPos(button[12].x-1,button[12].y)
term.setTextColor(colors.red)
write("off")
term.setTextColor(colors.white)
term.setCursorPos(button[11].x-1,button[11].y)
term.setTextColor(colors.cyan)
write("TGL")
term.setTextColor(colors.white)
refresh()
while resume == true do
  local event, side, xPos, yPos = os.pullEvent("monitor_touch")
  local selectedButton = getButton(xPos,yPos)
  if selectedButton == 11 then
    for i = 1,10 do
      toggle(i)
    end
  elseif selectedButton == 12 then
    toggle(12)
    for i=1,10 do
      button[i].state = button[12].state
    end
    sayState(12)
    allSame=true
  else
    term.setCursorPos(button[12].x - 1, button[12].y)
    term.setTextColor(colors.lightGray)
    write("---")
    term.setTextColor(colors.white)
    toggle(selectedButton)
  end
  for i=1,10 do
    sayState(i)
  end
  if allTheSame() then
    button[12].state = button[1].state
    sayState(12)
  else
    term.setCursorPos(button[12].x - 1, button[12].y)
    term.setTextColor(colors.lightGray)
    write("---")
    term.setTextColor(colors.white)
  end
  refresh()
end

-- optional, more color appropriate colors
--[==[ button = {
  [1] = {x = 5; y = 7; state = false; color = colors.lightGray; mob = "Skele"},
  [2] = {x = 15; y = 7; state = false; color = colors.gray; mob = "Wither"},
  [3] = {x = 25; y = 7; state = false; color = colors.purple; mob = "Ender"},
  [4] = {x = 35; y = 7; state = false; color = colors.cyan; mob = "Zombie"},
  
  [5] = {x = 5; y = 12; state = false; color = colors.green; mob = "Creep"},
  [6] = {x = 15; y = 12; state = false; color = colors.magenta; mob = "Witch"},
  [7] = {x = 25; y = 12; state = false; color = colors.pink; mob = "Pigman"},
  [8] = {x = 35; y = 12; state = false; color = colors.brown; mob = "Cow"},
  
  [9] = {x = 5; y = 17; state = false; color = colors.yellow; mob = "Blaze"},
  [10] = {x = 15; y = 17; state = false; color = colors.lime; mob = "Slime"},
  [11] = {x = 25; y = 17; state = false; color = colors.purple; mob = "Toggle"},
  [12] = {x = 35; y = 17; state = false; color = colors.blue; mob = "Master"}

} ]==]