local playerVisibleState = {}

--==================== Helpers ========================

local function has_value (tab, val)
	if (tab == nil) then
		return false
	end

    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function getGhosts()
	local ghosts = {}
	for player,state in pairs(playerVisibleState) do
		if (state.ghost and state.time > 0) then
			table.insert(ghosts, player)
		end
	end
	return ghosts
end

function getInvisibles()
	local invisibles = {}
	for player,state in pairs(playerVisibleState) do
		if (state.time > 0) then
			table.insert(invisibles, player)
		end
	end
	return invisibles
end

function getHardPlayers(currentPlayer)
	local hardPlayers = {}
	local ghosts = getGhosts()

	local players = getElementsByType ( "player" )
	for k,otherPlayer in ipairs(players) do
		local notAGhost = has_value(ghosts, otherPlayer) == false
		if (otherPlayer ~= currentPlayer and notAGhost) then
			table.insert(hardPlayers, otherPlayer)
		end
	end

	return hardPlayers
end

function getVisiblePlayers(currentPlayer)
	local visivlePlayers = {}
	local invisibles = getInvisibles()

	local players = getElementsByType ( "player" )
	for k,otherPlayer in ipairs(players) do
		local notInvisible = has_value(invisibles, otherPlayer) == false
		if (otherPlayer ~= currentPlayer and notInvisible) then
			table.insert(visivlePlayers, otherPlayer)
		end
	end

	return visivlePlayers
end

--^^^^^^^^^^^^^^^^^^^^ Helpers ^^^^^^^^^^^^^^^^^^^^

function makeInvisible(player, time, ghost, onlyRadarHidden)
	if ( ghost == nil) then
		ghost = true
	end
	if ( player == nil ) then
		return
	end
	if ( onlyRadarHidden ) then
		onlyRadarHidden = false
	end

	local currentState = playerVisibleState[player]
	playerVisibleState[player] = { ghost = ghost, time = getEndTime(time), onlyRadarHidden = onlyRadarHidden }
	if (currentState == nil or 
		currentState.time < 0  or 
		currentState.ghost ~= ghost or 
		currentState.onlyRadarHidden ~= onlyRadarHidden
	) then
		if ( onlyRadarHidden == false ) then
			triggerClientEvent("clientMakeInvisible", player, ghost, getHardPlayers(player))
		end

		if ( currentState.onlyRadarHidden ~= onlyRadarHidden and onlyRadarHidden = true ) then
			triggerClientEvent("clientMakeVisible", player, getHardPlayers(player))
		end

		showPlayerBlips()
	end
end

function makeVisible(player)
	if ( player == nil ) then
		return
	end

	local currentState = playerVisibleState[player]
	if ( currentState ~= nil and currentState.time > 0 and currentState.onlyRadarHidden == false) then
		triggerClientEvent("clientMakeVisible", player, getHardPlayers(player))
	end
	showPlayerBlips()
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
				triggerClientEvent("clientMakeVisible", player, getHardPlayers(player))
				showPlayerBlips()
			end
		end
	end
end
setTimer(periodicVisibleCheck, 1000, 0)

function showPlayerBlips()
	destroyElementsByType ("blip")
	local bombHolder = getBombHolder()
	for _,player in ipairs(getVisiblePlayers( bombHolder )) do	
		local blip = createBlipAttachedTo ( player, 0 )
		setElementVisibleTo ( blip, root, false )
		if ( player ~= bombHolder ) then
			setElementVisibleTo ( blip, bombHolder, true )
		end
	end

	if ( bombHolder ~= nil) then
		local holderState = playerVisibleState[bombHolder]
		if ( holderState ~= nil and holderState.time > 0 ) then
			hideBombMarker ( bombHolder )
		else 
			showBombMarker ( )
		end
	end
end