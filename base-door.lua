local dir = "back"
local status = true

local gateThread = function()
	while true do
		sleep(0.1)
		redstone.setOutput(dir,status)
	end
end

local wirelessThread = function()
	while true do
		sleep(0.1)
		redstoneIn = redstone.getInput("top") or redstone.getInput("right")
		if redstoneIn then
			status = false
			sleep(3)
			status = true
		end
	end
end
	
print("Door control ready...")
parallel.waitForAny(gateThread,wirelessThread)