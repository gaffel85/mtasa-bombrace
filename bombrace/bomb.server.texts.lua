local PRESENTING_BOMB_HOLDER_TEXT_ID = 987771
local PRESENTING_BOMB_HOLDER_PERSONAL_TEXT_ID = 987772
local LATE_JOIN_TEXT_ID = 987774
local BOMB_TIMER_TEXT_ID = 987773
local WINNER_TEXT_ID = 987775
local PLAYER_READY_TEXT_ID = 987776
local LEAVING_LOBBY_TEXT_ID = 987777
local PREPARING_ROUND_TEXT_ID = 987778
local CLOADK_ADDED_TEXT_ID = 987779
local NITRO_ADDED_TEXT_ID = 987780

function showCloakAdded(player)
	displayMessageForAll(CLOADK_ADDED_TEXT_ID, "Cloak ready", nil, nil, 2000, 0.5, 0.5, 0, 0, 255 )
end

function showBooserAdded(player)
	displayMessageForAll(NITRO_ADDED_TEXT_ID, "Nitro ready", nil, nil, 2000, 0.5, 0.5, 0, 0, 255 )
end

function showPresentBombHolder(bombHolder)
	displayMessageForAll(PRESENTING_BOMB_HOLDER_TEXT_ID, getPlayerName(bombHolder).." now has the bomb. Hide!", nil, nil, 5000, 0.5, 0.3, 255, 0, 0 )

	displayMessageForPlayer(bombHolder, PRESENTING_BOMB_HOLDER_PERSONAL_TEXT_ID, "You have the bomb. GET IT OFF!", nil, nil, 5000, 0.5, 0.3, 255, 0, 0 )
end

function showLateJoinMessage(player)
	local message = getPlayerName(source).." joined a started game. He gets the bomb!"
	displayMessageForAll(LATE_JOIN_TEXT_ID, message, nil, nil, 2000, 0.5, 0.5, 0, 255, 0 )
end

function showPrepareRoundTimer(timeLeft)
	hideBombTimer()
	if ( timeLeft ~= nil ) then
		displayMessageForAll(PREPARING_ROUND_TEXT_ID, "Starting in "..timeLeft.."s", nil, nil, 2000, 0.5, 0.1, 0, 255, 0 )
	end
end

function showBombTimer(timeLeft)
	clearMessageForAll(PREPARING_ROUND_TEXT_ID)
	displayMessageForAll(BOMB_TIMER_TEXT_ID, timeLeft.."s", nil, nil, 2000, 0.5, 0.1, 255, 0, 0 )
end

function hideBombTimer()
	clearMessageForAll(BOMB_TIMER_TEXT_ID)
end

function showWinner(player)
	local message = getPlayerName ( player ).." won this round"
	displayMessageForAll(WINNER_TEXT_ID, message, nil, nil, 5000, 0.5, 0.5, 0, 0, 255 )
end

function showPlayerReady(player)
	clearMessageForAll(PLAYER_READY_TEXT_ID)
	displayMessageForAll(PLAYER_READY_TEXT_ID, getPlayerName(player).." is ready", nil, nil, 5000, 0.5, 0.9)
end

function showLeavingLobbyMessage(bombHolder)
	displayMessageForAll(LEAVING_LOBBY_TEXT_ID, "The bomb holder will be selected soon", nil, nil, 5000, 0.5, 0.5, 88, 255, 120)
end

function displayMessageForAll(textId, text, specialPlayer, specialText, displayTime, posX, posY, r, g, b, alpha, scale)
	local players = getElementsByType ( "player" )
	for k,v in ipairs(players) do
		clearMessageForPlayer ( v, textId )
		if(v ~= specialPlayer) then
			displayMessageForPlayer ( v, textId, text, displayTime, posX, posY, r, g, b, alpha, scale )
		end
	end
	if specialPlayer ~= nil and  specialText ~= nil then
		displayMessageForPlayer ( specialPlayer, textId, specialText, displayTime, posX, posY, r, g, b, alpha, scale )
	end
end

function clearMessageForAll ( textID , exceptPlayer)
	local players = getElementsByType ( "player" )
	for k,v in ipairs(players) do
		if(v ~= exceptPlayer) then
			clearMessageForPlayer( v, textID)
		end
	end
end

function displayMessageForPlayer ( player, ID, message, displayTime, posX, posY, r, g, b, alpha, scale )
	assert ( player and ID and message )
	local easyTextResource = getResourceFromName ( "easytext" )
	displayTime = displayTime or 5000
	posX = posX or 0.5
	posY = posY or 0.5
	r = r or 255
	g = g or 127
	b = b or 0
	-- display message for everyone
	outputConsole ( message, player )
	call ( easyTextResource, "displayMessageForPlayer", player, ID, message, displayTime, posX, posY, r, g, b, alpha, scale )
end

function clearMessageForPlayer ( player, ID )
	assert ( player and ID )
	call ( getResourceFromName ( "easytext" ), "clearMessageForPlayer", player, ID )
end