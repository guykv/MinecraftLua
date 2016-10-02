local settings = {
    drumSide = "front",
    cableSide = "bottom",
    activatorColor = colors.white,
    lampColor = colors.orange,
    cycleDelay = 5,
    emptyDrumSlot = 1,
    fullDrumSlot = 2,
    activatorSignalDuration = 1,
    lampDuration = 1,
    drumPlacementDelay = 1
}

function mainLoop()
    print("DrumSwitcher started.")
    init(settings)
    while true do
        if isDrumFull() then
            removeFullDrum()
            os.sleep(settings.drumPlacementDelay)
            placeEmptyDrum()
        end
        
        os.sleep(settings.cycleDelay)
    end
end

function init()
    redstone.setBundledOutput(settings.cableSide, 0)
end

function placeEmptyDrum()
    if turtle.getItemCount(settings.emptyDrumSlot) == 0 then
        blinkLightUntilSlotRefill()
    end
    
    turtle.select(settings.emptyDrumSlot)
    turtle.place()
end

function removeFullDrum()
    print("Sending redstone signal to activator")
    redstone.setBundledOutput(settings.cableSide, settings.activatorColor)
    os.sleep(settings.activatorSignalDuration)
    redstone.setBundledOutput(settings.cableSide, 0)
    
    print("Sucking full drum")
    turtle.select(settings.fullDrumSlot)
    if turtle.suck() then
        turtle.dropUp()
    else
		error("Failed to suck full drum")
    end
end

function blinkLightUntilSlotRefill()
    local currentColor = redstone.getBundledOutput(settings.cableSide)
    local signal = true
    while turtle.getItemCount(settings.emptyDrumSlot) == 0 do
        if signal then
            redstone.setBundledOutput(settings.cableSide, colors.combine(currentColor, settings.lampColor))
        else
            redstone.setBundledOutput(settings.cableSide, currentColor)
        end
        
        os.sleep(settings.lampDuration)
        signal = not signal
    end
    
    redstone.setBundledOutput(settings.cableSide, currentColor)
end

function isDrumFull()
    local side = settings.drumSide
    local tank = peripheral.wrap(side)
    if tank == nil then
        print("Found no peripheral on " .. side .. ", placing drum")
        placeEmptyDrum()
        return false
    end
    
    local tankInfo = tank.getTankInfo(side)
    if tankInfo == nil then
        print("Found no tank on " .. side)
        return false
    end
    
    local capacity = 0
    local amount = 0
    for name, value in pairs(tankInfo[1]) do
        if name == "capacity" then
            capacity = value
        end
        
        if name == "amount" then
            amount = value
        end
    end
    
    print("Amount on " .. side .. " is " .. amount)
    
    if amount >= capacity then
        return true
    else
        return false
    end
end

mainLoop()
