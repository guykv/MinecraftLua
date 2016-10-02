local settings = {
	drainSide = "top",
	signalSide = "front",
	extractColor = colors.red,
	insertColor = colors.green,
	interval = 60
}

function mainLoop()
	print("IronCycler started.")
	init()
	redstone.setBundledOutput(settings.signalSide, settings.insertColor)
	while true do
		if isBottomLiquidIron() then
			print("Bottom liquid is iron, cycling...")
			cycle()
		end
		
		wait(settings.interval)
	end
end

function init()
	redstone.setOutput(settings.signalSide, false)
	redstone.setBundledOutput(settings.signalSide, 0)
end

function wait(secs)
	print("Waiting " .. secs .. " seconds.")
	os.sleep(secs)
end

function isBottomLiquidIron()
	local p = peripheral.wrap(settings.drainSide)
	local t = p.getTankInfo()
	if t == nil or t[1] == nil or t[1].contents == nil then
		return false
	end
	
	if t[1].contents.name == "iron.molten" then
		return true
	else
		return false
	end
end

function cycle()
	print("Extracting molten iron...")
	redstone.setBundledOutput(settings.signalSide, settings.extractColor)
	while isBottomLiquidIron() do
		os.sleep(1)
	end
	
	print("Re-inserting molten iron...")
	redstone.setBundledOutput(settings.signalSide, settings.insertColor)
end

mainLoop()
