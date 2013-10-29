-- Works with wget script found at http://turtlescripts.com/project/gjdh0e-wget
-- Example use:
--       "upscrp base control run" fetches http://yourscriptslocation/base-control.lua,
--       saves it to the base directory on the computer as the file base-control
--       and then runs it.

args = { ... }

-- Modify this line before using this script!
scriptloc = "http://yourscriptslocation/"

if #args == 0 then return end

local type = args[1]
local app = args[2]

shell.run("wget", scriptloc .. type .. "-" .. app .. ".lua " .. type .. "-" .. app)

if #args == 3 and args[3] == "run" then shell.run(type .. "-" .. app) end
