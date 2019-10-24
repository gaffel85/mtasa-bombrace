local playerVisibleState = {}

function getGhosts()
	local ghosts = {}
	for player,state in pairs(playerVisibleState) do
		if (state.ghost and state.time > 0) then
			table.insert(ghosts, player)
		end
	end
end

function makeInvisible(player, time, ghost)
	ghost = ghost or true
	if ( player == nil ) then
		return
	end

	local currentState = playerVisibleState[player]
	playerVisibleState[player] = { ghost = ghost, time = getEndTime(time) }
	if ( currentState == nil or currentState.time < 0 ) then
		triggerClientEvent("clientMakeInvisible", player, ghost, getGhosts())
	end
end

function makeVisible(player)
	if ( player == nil ) then
		return
	end

	local currentState = playerVisibleState[player]
	if ( currentState ~= nil and currentState.time > 0 ) then
		triggerClientEvent("clientMakeVisible", player, getGhosts())
	end
end

function getEndTime(duration)
	local time = getRealTime()
	return time.timestamp + duration
end


function invisibleTimeLeft(endTime) 
	local currentTime = getRealTime()
	return endTime - currentTime.timestamp
end

function periodicVisibleCheck()
	local players = getElementsByType ( "player" )
	for k1,player in ipairs(players) do

		local currentState = playerVisibleState[player]
		if ( currentState ~= nil and currentState.time > 0 ) then
			timeLeft = invisibleTimeLeft(currentState.time)
			if ( timeLeft <= 0 ) then
				playerVisibleState[player] =  { ghost = false, time = -1 }
				triggerClientEvent("clientMakeVisible", player, getGhosts())
			end
		end
	end
end
setTimer(periodicVisibleCheck, 1000, 0)