local cloakCooldown
local cloakReady = false

function useCloak()
	if ( cloakReady ) then
		makeInvisible(getBombHolder(), CLOAK_DURATION, false, CLOAK_HIDES_CAR == false)
		resetCloakerCountdown()
	end
end

function setCloakCooldown(duration)
	local time = getRealTime()
	cloakCooldown = time.timestamp + duration
end

function resetCloakerCountdown()
	cloakReady = false
	setCloakCooldown(CLOAK_COOLDOWN)
end

function cloakCooldownLeft() 
	local currentTime = getRealTime()
	return cloakCooldown - currentTime.timestamp
end

function tickCloakCooldown()
	if (getGameState() ~= GAME_STATE_ACTIVE_GAME or cloakCooldown == nil) then
		return
	end

	local bombHolder = getBombHolder()
	local timeLeft = cloakCooldownLeft()
	if (timeLeft >= 0 and cloakReady == false and bombHolder ~= nil) then
		triggerClientEvent("cloakCooldownTick", bombHolder, timeLeft, CLOAK_COOLDOWN)
	end

	if ( timeLeft <= 0 and cloakReady == false ) then
		cloakReady = true
		showCloakAdded(bombHolder)
	end
end
setTimer(tickCloakCooldown, 1000, 0)

function onBombHolderChanged(oldBombHolder)
	local bombHolder = source
	cloakReady = false
	bindKey(bombHolder, "z", "down", useCloak)
	if ( oldBombHolder ~= nil ) then
		unbindKey(oldBombHolder, "z", "down", useCloak)
	end

	setCloakCooldown(7)
end
addEventHandler("bombHolderChanged", root, onBombHolderChanged)