local settings = {
	signalSide = "bottom",
	chopColor = colors.red,
	chargeColor = colors.green,
	cyclePause = 1
}

local inFront = {
	nothing = 0,
	sapling = 1,
	wood = 2,
	unknown = 3
}

function mainLoop()
	print("Planter started.")
	init()
	while true do
		i = whatIsInFront()
		if i == inFront.nothing then
			print("Nothing in front, charging then planting...")
			charge()
			plant()
		elseif i == inFront.sapling then
			print("Sapling in front, waiting...")
		elseif i == inFront.wood then
			print("Log in front, chopping...")
			chop()
		else
			print("Something unexpected in front of the turtle. Waiting...")
		end
		
		print("Waiting 3 seconds...")
		os.sleep(3)
	end
end

function init()
	redstone.setOutput(settings.signalSide, false)
	redstone.setBundledOutput(settings.signalSide, 0)
end

function whatIsInFront()
	local foundSomething, data = turtle.inspect()
	if foundSomething then
		if data.name == "minecraft:log" then
			return inFront.wood
		elseif data.name == "minecraft:sapling" then
			return inFront.sapling
		else
			return inFront.unknown
		end
	else
		return inFront.nothing
	end
end

function plant()
	turtle.place()
end

function charge()
	print("Charging axe.")
	init()
	redstone.setBundledOutput(settings.signalSide, settings.chargeColor)
	os.sleep(1)
	init()
end

function chop()
	print("Chopping...")
	init()
	redstone.setBundledOutput(settings.signalSide, settings.chopColor)
	os.sleep(1)
	init()
end

mainLoop()
