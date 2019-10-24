local playerVisibleState = {}

function makeInvisible(player, time) 
	local currentState = playerVisibleState[player]
	playerVisibleState[player] = getEndTime(time)
	if ( currentState == nil or currentState < 0 ) then
		triggerClientEvent("clientMakeInvisible", player)
	end
end

function makeVisible(player)
	local currentState = playerVisibleState[player]
	if ( currentState ~= nil and currentState > 0 ) then
		triggerClientEvent("clientMakeVisible", player)
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
		if ( currentState ~= nil and currentState > 0 ) then
			timeLeft = invisibleTimeLeft(currentState)
			if ( timeLeft <= 0 ) then
				playerVisibleState[player] = -1
				triggerClientEvent("clientMakeVisible", player)
			end
		end
	end
end
setTimer(periodicVisibleCheck, 1000, 0)