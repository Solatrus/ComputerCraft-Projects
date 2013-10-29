-- Farming turtle for BlazeMC's direwolf20 1.4.7 Feed the Beast modpack
--
-- Turtle has a mild AI pattern to navigate an unlimited size farm. Some hard
-- coded stuff was added to navigate over the center area where the machines sat
-- (originally from an old Forestry farm)
--
-- It just requires knowing its exact X, Y, and Z coordinates for various objects

args = { ... }

rednet.open('right')

local monitorID = 34

local home = {x = -318, y = 84, z = -146, d = "s"}
local sulfur = {x = -320, y = 83, z = -146, d = "n"} -- Uses sulfur torches sulfur goo
local dropoff = {x = -320, y = 86, z = -149, d = "s"}
local startTop = {x = -326, y = 85, z = -141, d = "e"}
local x,y,z = gps.locate()

local topLoopDone = false
local cycle = "odd"

local d = "s"

local current = {x=x,y=y,z=z,d="s"}

local active = false

function broadcast(message)
	local data = {active=active,x=current.x,y=current.y,z=current.z,d=current.d,fuel=turtle.getFuelLevel(),sulfur=turtle.getItemCount(13),message=message}

	rednet.send(monitorID, textutils.serialize(data))
end

function updatePosition(movement)
	if movement == "forward" then
		turtle.forward()
		if current.d == "s" then current.z = current.z + 1
		elseif current.d == "w" then current.x = current.x - 1
		elseif current.d == "n" then current.z = current.z - 1
		elseif current.d == "e" then current.x = current.x + 1
		end
	elseif movement == "backward" then
		turtle.back()
		if current.d == "s" then current.z = current.z - 1
		elseif current.d == "w" then current.x = current.x + 1
		elseif current.d == "n" then current.z = current.z + 1
		elseif current.d == "e" then current.x = current.x - 1
		end
	elseif movement == "up" then
		turtle.up()
		current.y = current.y + 1
	elseif movement == "down" then
		turtle.down()
		current.y = current.y - 1
	end
	broadcast("stay")
end

function goTo(target)
	current.x,current.y,current.z = gps.locate()
	broadcast("stay")

	if current.y < home.y + 10 then
		for i=current.y,home.y + 10 do updatePosition("up") end
	end

	if current.z < target.z then
		while current.d ~= "s" do
			if current.d == "e" then
				turnAndGetDirection("right")
			else
				turnAndGetDirection("left")
			end
		end

		for i=current.z+1,target.z do updatePosition("forward") end
	elseif current.z > target.z then
		while current.d ~= "n" do
			if current.d == "w" then
				turnAndGetDirection("right")
			else
				turnAndGetDirection("left")
			end
		end

		for i=target.z+1,current.z do updatePosition("forward") end
	end

	if current.x < target.x then
		while current.d ~= "e" do
			if current.d == "n" then
				turnAndGetDirection("right")
			else
				turnAndGetDirection("left")
			end
		end

		for i=current.x+1,target.x do updatePosition("forward") end
	elseif current.x > target.x then
		while current.d ~= "w" do
			if current.d == "s" then
				turnAndGetDirection("right")
			else
				turnAndGetDirection("left")
			end
		end

		for i=target.x+1,current.x do updatePosition("forward") end
	end

	for i=target.y+1,current.y do updatePosition("down") end

	while current.d ~= target.d do turnAndGetDirection("left") end
end

function shutDown()
	reset()
	rednet.close("right")
	topLoopDone = true
end

function reset()
	local ox,oy,oz = gps.locate()
	local nx,ny,nz
	if turtle.forward() then
		nx,ny,nz = gps.locate()
	elseif turtle.back() then
		nx,ny,nz = ox,oy,oz
		ox,oy,oz = gps.locate()
	else
		for i=1,10 do turtle.up() end
		turtle.forward()
		nx,ny,nz = gps.locate()
	end

	if ox < nx then current.d = "e"
	elseif ox > nx then current.d = "w"
	elseif oz > nz then current.d = "n"
	elseif oz < nz then current.d = "s"
	end

	goTo(home)
end

function turnAndGetDirection(turn)
	if turn == "left" then
		turtle.turnLeft()
		if current.d == "s" then current.d = "e"
		elseif current.d == "w" then current.d = "s"
		elseif current.d == "n" then current.d = "w"
		elseif current.d == "e" then current.d = "n"
		end
	else
		turtle.turnRight()
		if current.d == "s" then current.d = "w"
		elseif current.d == "w" then current.d = "n"
		elseif current.d == "n" then current.d = "e"
		elseif current.d == "e" then current.d = "s"
		end
	end
end

function farmBelow(seedNumber)
	if not turtle.detectDown() then
		updatePosition("forward")
		return
	end
	if turtle.getItemCount(12) > 0 then dropOffItems() end
	turtle.select(13)
	if turtle.getItemCount(13) == 0 then refillFertilizer() end
	turtle.placeDown()
	turtle.select(seedNumber)
	turtle.digDown()
	turtle.suckDown()
	turtle.placeDown()
	updatePosition("forward")
end

function refillFertilizer()
	broadcast("Sulfur goo empty. Refilling...")
	local cD = current.d

	local previous = {x=current.x,y=current.y,z=current.z,d=current.d}
	goTo(sulfur)
	updatePosition("forward")
	turtle.select(13)
	while not turtle.suckUp() do
		broadcast("No sulfur goo in supply, waiting 5 minutes for more...") 
		os.sleep(300)
	end
	updatePosition("backward")
	goTo(previous)
end

function dropOffItems()
	broadcast("Dropping off excess items...")
	local previous = {x=current.x,y=current.y,z=current.z,d=current.d}
	goTo(dropoff)
	for i=4,12 do
		turtle.select(i)
		if turtle.compareTo(1) then turtle.transferTo(1,64) end
		while not turtle.dropDown() and turtle.getItemCount(i) > 0 do
			broadcast("Storage is full, pausing...")
			sleep(60)
		end
	end
	broadcast("Resuming task...")
	goTo(previous)
end

function checkForTorch()
	turtle.select(14)
	if turtle.compareDown() then
		for i=1,5 do updatePosition("up") end
		for i=1,9 do updatePosition("forward") end
		for i=1,5 do updatePosition("down") end
	end
end

function checkForWall()
	local wallFound = false
	turtle.select(15)
	if turtle.compareDown() then wallFound = true end
	turtle.select(16)
	if turtle.compareDown() then wallFound = true end

	if wallFound then
		if cycle == "odd" then
			updatePosition("backward")
			turnAndGetDirection("left")
			updatePosition("forward")
			turnAndGetDirection("left")
			cycle = "even"
		else
			updatePosition("backward")
			turnAndGetDirection("right")
			updatePosition("forward")
			turnAndGetDirection("right")
			cycle = "odd"
		end
	end

	return wallFound
end

function getActiveStatus(request)
	if request then rednet.send(monitorID,"farmcontrol.getstatus") end
	local id, msg, distance = rednet.receive()

	if id ~= monitorID then return end;

	if msg == "ON" then
		broadcast("Detected ON signal. Starting.")
		active = true
	elseif msg == "OFF" then
		broadcast("Detected OFF signal. Standing by.")
		active = false
	elseif msg == "STATUS" then
		broadcast("clear");
	elseif msg == nil then
		broadcast("Rednet receive timed out. Standing by.")
		active = false
		--broadcast("Unknown message from ID ".. id .. ": '" .. msg .. "' Ignoring.")
	end
end

function loop()
	broadcast("Starting session...")
	sleep(2)

	--if redstone.getInput("left") then broadcast("Redstone signal received. Going into standby.") end
	--while redstone.getInput("left") do sleep(5) end
	while true do
		while not active do sleep(1) end
		--broadcast("Hello.")
		getActiveStatus(true)
		sleep(0.1)
		math.randomseed(os.time())
		broadcast("Cycle started")
		if turtle.getFuelLevel() < 500 then
			broadcast("Low fuel: Returning home to recahrge before resuming...")
			local previous = current

			goTo(home)
			--if redstone.getInput("left") then broadcast("Redstone signal received. Going into standby.") end
			--while redstone.getInput("left") do sleep(30) end
			while turtle.getFuelLevel() < 10000 do
				broadcast("stay")
				sleep(1)
			end
			while not active do sleep(1) end
			goTo(previous)
		end

		-- South axis pass 1
		while true do
			sleep(0.1)
			--broadcast("Hello.")
			while not active do sleep(1) end
			checkForTorch()
			if checkForWall() then break end
			local seed = math.random(3)

			if seed == 1 then
				for i=4,12 do
					if turtle.getItemCount(1) < 10 then
						turtle.select(i)
						if turtle.compareTo(1) then turtle.transferTo(1, 54) end
					else break
					end
				end
			end

			farmBelow(seed)

			if (current.x - 30 > home.x) or (current.x + 30 < home.x) or (current.z - 30 > home.z) or (current.z + 30 < home.z) then
				broadcast("Started to wonder off. Returning to farm...")
				goTo(startTop)
				break
			end
		end

		turtle.select(16)
		if turtle.compareDown() then
			cycle = "odd"

			goTo(startTop)
		end
	end
end


local mainThread = function()
	getActiveStatus(true)

	while not active do sleep(1) end

	while turtle.getFuelLevel() < 500 do
		broadcast("Not enough power.. waiting")
		sleep(60)
	end
	reset()
	--if redstone.getInput("left") then broadcast("Redstone signal received. Going into standby.") end
	--while redstone.getInput("left") do sleep(5) end
	goTo(startTop)

	loop()
end

local watchThread =	function()
	while true do
		getActiveStatus(false)
	end
end

local pingStatusThread = function()
	while true do
		sleep(30)
		getActiveStatus(true)
	end
end

if #args == 0 then
	parallel.waitForAny(mainThread,watchThread)
elseif args[1] == "reset" then
	reset()
end