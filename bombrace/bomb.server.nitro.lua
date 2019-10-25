local bombHolderBostCooldown
local boosterAdded = false

function setBoostCooldown(duration)
	local time = getRealTime()
	bombHolderBostCooldown = time.timestamp + duration
end

function resetBoosterCountdown()
	if (boosterAdded) then
		boosterAdded = false
		setBoostCooldown(BOOST_COOLDOWN)
	end
end

function boostCooldownLeft() 
	local currentTime = getRealTime()
	return bombHolderBostCooldown - currentTime.timestamp
end

function tickCooldown()
	if (gameState ~= GAME_STATE_ACTIVE_GAME) then
		return
	end

	local bombHolder = getBombHolder()
	local timeLeft = boostCooldownLeft()
	if (timeLeft >= 0 and boosterAdded == false and bombHolder ~= nil) then
		triggerClientEvent("boosterCooldownTick", bombHolder, timeLeft, BOOST_COOLDOWN)
	end

	if ( timeLeft <= 0 and boosterAdded == false ) then
		local vehicle = getPedOccupiedVehicle (bombHolder)
		if (vehicle ~= nil) then
			addVehicleUpgrade(vehicle, 1009)
			boosterAdded = true
			displayMessageForAll(3243243, "Booster added", nil, nil, 2000, 0.5, 0.5, 0, 0, 255 )
		end
	end
end
setTimer(tickCooldown, 1000, 0)

function onBombHolderChanged(oldBombHolder)
	local bombHolder = source
	boosterAdded = false
	bindKey(bombHolder, "lctrl", "down", resetBoosterCountdown)
	if ( oldBombHolder ~= nil ) then
		unbindKey(oldBombHolder, "lctrl", "down", resetBoosterCountdown)
	end

	setBoostCooldown(5)
end
addEventHandler(EVENT_BOMB_HOLDER_CHANGED, getResourceRootElement(), onBombHolderChanged)