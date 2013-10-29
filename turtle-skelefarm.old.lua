while true do

	local isFull = false

	while not isFull do
		for i=1,3 do turtle.forward() end
		for i=1,200 do
			turtle.attack()
			sleep(0.125)
		end
		for i=1,3 do turtle.back() end

		for i=1,16 do
			turtle.select(i)
			turtle.dropDown()
		end
		turtle.select(1)

		turtle.turnRight()
		turtle.suck()
		turtle.turnLeft()

		turtle.craft()
		for i=1,16 do
			turtle.select(i)
			turtle.dropDown()
		end
		turtle.select(1)

		for i=1,16 do turtle.suckUp() end

		if turtle.getItemCount(16) > 1 then isFull = true
		else
			for i=1,16 do
				turtle.select(i)
				turtle.dropDown()
			end
			turtle.select(1)
		end
	end

	-- Leaving to deposit

	turtle.forward()
	for i=1,29 do turtle.up() end
	for i=1,2 do turtle.turnRight() end
	for i=1,9 do turtle.forward() end
	for i=1,8 do turtle.up() end
	for i=1,2 do turtle.turnLeft() end
	for i=1,9 do turtle.forward() end
	turtle.turnLeft()
	for i=1,5 do turtle.forward() end
	for i=1,3 do turtle.down() end
	for i=1,2 do turtle.turnLeft() end

	for i=1,16 do
		turtle.select(i)
		turtle.dropDown()
	end

	turtle.select(1)

	-- Returning

	for i=1,3 do turtle.up() end
	for i=1,5 do turtle.forward() end
	turtle.turnRight()
	for i=1,9 do turtle.forward() end
	for i=1,2 do turtle.turnLeft() end
	for i=1,8 do turtle.down() end
	for i=1,9 do turtle.forward() end
	for i=1,29 do turtle.down() end
	turtle.back()

end