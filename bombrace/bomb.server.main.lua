local spawnPoints
local currentSpawn = 1
local mapLobbyMarker

local GAME_STATE_LOBBY = 1
local GAME_STATE_PREPARING_ROUND = 2
local GAME_STATE_ACTIVE_GAME = 3
local gameState = GAME_STATE_LOBBY

local bombHolder
local previousBombHolder
local previousBombHolderResetter
local bombMarker
local bombEndTime
local lobbyMarker
local participants = {}

local BOMB_START_SECONDS = 120
local SCORE_KEY = "Score"
local PRESENTING_BOMB_HOLDER_TEXT_ID = 987771
local PRESENTING_BOMB_HOLDER_PERSONAL_TEXT_ID = 987772
local LATE_JOIN_TEXT_ID = 987774
local BOMB_TIMER_TEXT_ID = 987773
local WINNER_TEXT_ID = 987775
local PLAYER_READY_TEXT_ID = 987776
local LEAVING_LOBBY_TEXT_ID = 987777

local cars = {411, 596}

scoreboardRes = getResourceFromName( "scoreboard" )

function selectRandomBombHolder()
	local players = getAlivePlayers ()
	outputChatBox("Alive players: "..#players)
	if ( #players > 1 ) then
		local newBombHolder = players[math.random ( #players ) ]
		resetBomb()
		setBombHolder ( newBombHolder )
	end
end

function setBombHolder ( player )
	resetPrevBombHolder()

	-- Make old bomb holder invisible
	local oldBombHolder = bombHolder
	--[[if ( oldBombHolder ~= nil ) then
		local result = setElementAlpha( oldBombHolder, 140 )
		setTimer(function()
			setElementAlpha( oldBombHolder, 255 )
		end, 10000, 1)
	end ]]

	bombHolder = player
	triggerClientEvent("onBombHolderChanged", player, oldBombHolder)

	--displayMessageForAll(PRESENTING_BOMB_HOLDER_TEXT_ID, getPlayerName(bombHolder).." now has the bomb. Hide!", nil, nil, 5000, 0.5, 0.3, 255, 0, 0 )

	if(bombMarker == nil ) then
		bombMarker = createMarker ( 0, 0, 1, "arrow", 2.0, 255, 0, 0)
	end
	attachElements ( bombMarker, bombHolder, 0, 0, 4 )
	
	fixVehicle (getPedOccupiedVehicle ( player ) )
end

-- Stop player from exiting vehicle
function exitVehicle ( thePlayer, seat, jacked )
    cancelEvent()
end
addEventHandler ( "onVehicleStartExit", getRootElement(), exitVehicle)

function spawn(thePlayer)
	local spawnPoint = spawnPoints[currentSpawn]
	currentSpawn = currentSpawn % #spawnPoints + 1
  	local posX, posY, posZ = coordsFromEdl ( spawnPoint )
  	local vehicle = createVehicle(cars[1], posX, posY, posZ, 0, 0, 0, "BOMBER")
	spawnPlayer(thePlayer, 0, 0, 0, 0, 253)
	setTimer(function()
		warpPedIntoVehicle(thePlayer, vehicle)
		fadeCamera(thePlayer, true)
		setCameraTarget(thePlayer, thePlayer)
	end, 50, 1)
end

function respawnAllPlayers()
	local players = getElementsByType ( "player" )
	for k,v in ipairs(players) do
		spawn ( v )
	end
end

function repairAllCars()
	local players = getAlivePlayers ()
	for k,v in ipairs(players) do
		local veh = getPedOccupiedVehicle ( v )
		if ( veh ~= nil ) then
			fixVehicle ( veh )
		end
	end
end

function bombTimeLeft() 
	local currentTime = getRealTime()
	return bombEndTime - currentTime.timestamp
end

function tickBombTimer()
	if (gameState == GAME_STATE_LOBBY) then
		return
	end

	if (gameState == GAME_STATE_PREPARE_ROUND) then
		timeLeft = bombTimeLeft()
		if ( timeLeft < 0 ) then
			startActiveRound()
		else
			displayMessageForAll(BOMB_TIMER_TEXT_ID, "Starting in "..timeLeft.."s", nil, nil, 2000, 0.5, 0.1, 0, 255, 0 )
		end
	end

	local players = getElementsByType ( "player" )
	if(bombHolder ~= nil and #players > 0) then
		timeLeft = bombTimeLeft()
		if ( timeLeft < 0 ) then
			blowBombHolder()
		else
			displayMessageForAll(BOMB_TIMER_TEXT_ID, timeLeft.."s", nil, nil, 2000, 0.5, 0.1, 255, 0, 0 )
		end
	end
end
setTimer(tickBombTimer, 1000, 0)

function blowBombHolder()
	local lastBomdBolder = bombHolder
	local vehicle = getPedOccupiedVehicle ( bombHolder )
	blowVehicle(vehicle)
	bombHolder = nil
	clearMessageForAll(BOMB_TIMER_TEXT_ID)
	setTimer(givePointsToAllAlive, 1000, 1)
	setTimer(checkIfAnyAliveAndSelectNewBombHolder, 2000, 1, lastBomdBolder)
end

function checkIfAnyAliveAndSelectNewBombHolder(lastAlive)
	local alivePlayers = getAlivePlayers ()
	if ( #alivePlayers > 1 ) then
		selectRandomBombHolder()
	else
		local message = getPlayerName ( lastAlive ).." won this round"
		displayMessageForAll(WINNER_TEXT_ID, message, nil, nil, 5000, 0.5, 0.5, 0, 0, 255 )
		setTimer(activeRoundFinished, 2000, 1)
	end
end

function givePointsToAllAlive()
	local players = getAlivePlayers ()
	for k,player in ipairs(players) do
		givePointsToPlayer ( player, 1 )
	end
end

function givePointsToPlayer(player, points)
	local score = getElementData( player, SCORE_KEY )
	if ( score == false ) then
		score = 0
	end
	score = score + points
	setElementData( player, SCORE_KEY , score)
end

function resetBomb()
	local time = getRealTime()
	bombEndTime = time.timestamp + BOMB_START_SECONDS
end

function arrayExists (tab, val)
    for index, value in ipairs (tab) do
        if value == val then
            return true
        end
    end

    return false
end

function destroyElementsByType(elementType)
	local elements = getElementsByType(elementType)
	for i,v in ipairs(elements) do
		destroyElement(v)
	end
end

function removeLobbyMarker()
	if (lobbyMarker ~= nil) then
		destroyElement(lobbyMarker)
	end
	lobbyMarker = nil
end

function showLobbyMarker()
	if (lobbyMarker == nil) then
		local posX, posY, posZ = getElementPosition ( mapLobbyMarker )
		local checkType = getElementData ( mapLobbyMarker, "type" )
		local color = getElementData ( mapLobbyMarker, "color" )
		local size = getElementData ( mapLobbyMarker, "size" )
		lobbyMarker = createMarker(posX, posY, posZ, checkType, size, r, g, b)
	end
end

function startGameMap( startedMap )
	outputDebugString("startGameMap")
	local mapRoot = getResourceRootElement( startedMap )
	spawnPoints = getElementsByType ( "playerSpawnPoint" , mapRoot )
	mapLobbyMarker = getElementsByType ( "lobbyStart" , mapRoot )[1]
	
  	resetGame()
end
addEventHandler("onGamemodeMapStart", getRootElement(), startGameMap)

function joinHandler()
	spawn(source)
	handleLateJoin()
	outputChatBox("Welcome to My Server", source)
end
addEventHandler("onPlayerJoin", getRootElement(), joinHandler)

function handleLateJoin()
	if (gameState == GAME_STATE_ACTIVE_GAME) then
		local message = getPlayerName(source).." joined a started game. He gets the bomb!"
		displayMessageForAll(LATE_JOIN_TEXT_ID, message, nil, nil, 2000, 0.5, 0.5, 0, 255, 0 )
		setTimer(setBombHolder, 2000, 1, source)
	end
end

function leaveLobby()
	local time = getRealTime()
	bombEndTime = time.timestamp + 30
	gameState = GAME_STATE_PREPARE_ROUND
	removeLobbyMarker()
	repairAllCars()
end

function enterLobby()
	participants = {}
	gameState = GAME_STATE_LOBBY
	resetRoundVars()
	showLobbyMarker()
end

function startActiveRound() 
	gameState = GAME_STATE_ACTIVE_GAME
	repairAllCars()
	resetBomb()
	resetRoundVars()
	selectRandomBombHolder()
end

function activeRoundFinished()
	enterLobby()
	respawnAllPlayers()
end

function resetGame()
	resetScore()
	enterLobby()
  	respawnAllPlayers()
end

function resetScore()
	local players = getElementsByType ( "player" )
	for k,v in ipairs(players) do
		setElementData( v, SCORE_KEY , 0)
	end
end

function resetRoundVars()
	bombHolder = nil
	resetPrevBombHolder()
	if (bombMarker ~= nil) then
		destroyElement(bombMarker)
		bombMarker = nil
	end 
end

function resetPrevBombHolder()
	previousBombHolder = nil
	if (previousBombHolderResetter ~= nil ) then
		killTimer ( previousBombHolderResetter )
	end
	previousBombHolderResetter = nil
end

function playerReady(player)
	local players = getElementsByType ( "player" )
	if arrayExists(participants, player) == false then

		table.insert(participants, player)
		clearMessageForAll(PLAYER_READY_TEXT_ID)
		displayMessageForAll(PLAYER_READY_TEXT_ID, getPlayerName(player).." is ready", nil, nil, 5000, 0.5, 0.9)

		if #participants == #players then
			displayMessageForAll(LEAVING_LOBBY_TEXT_ID, "Game will start in 5 sec", nil, nil, 5000, 0.5, 0.5, 88, 255, 120)
			setTimer( leaveLobby, 5000, 1)
		end
	end
end

function markerHit( markerHit, matchingDimension )
	if gameState == GAME_STATE_LOBBY and markerHit == lobbyMarker then
		playerReady(source)
		return
	end
end
addEventHandler( "onPlayerMarkerHit", getRootElement(), markerHit )

function playerDied( ammo, attacker, weapon, bodypart )
	
end
addEventHandler( "onPlayerWasted", getRootElement( ), playerDied)

function addPlayerBlips()
	local players = getElementsByType ( "player" )
	for k1,v1 in ipairs(players) do
		local blip = nil
		blip = createBlipAttachedTo ( v1, 5 )
		setElementVisibleTo ( blip, root, true )
		setElementVisibleTo ( blip, v1, false )
	end
end

function coordsFromEdl(element)
	local posX = getElementData ( element, "posX" )
	local posY = getElementData ( element, "posY" )
	local posZ = getElementData ( element, "posZ" )
	return posX, posY, posZ
end

function quitPlayer ( quitType )
end
addEventHandler ( "onPlayerQuit", getRootElement(), quitPlayer )

function commitSuicide ( sourcePlayer )
	-- kill the player and make him responsible for it
	killPed ( sourcePlayer, sourcePlayer )
end
addCommandHandler ( "kill", commitSuicide )

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

addEvent("onDisplayClientText", true)
addEventHandler ( "onDisplayClientText", resourceRoot, displayMessageForPlayer)

addEvent("onClearClientText", true)
addEventHandler ( "onClearClientText", getRootElement(), clearMessageForPlayer)

addEventHandler("onResourceStop",getResourceRootElement(getThisResource()),
function()
	call(scoreboardRes,"removeScoreboardColumn",SCORE_KEY)
end )

addEventHandler("onResourceStart",getResourceRootElement(getThisResource()),
function()
	call(scoreboardRes,"addScoreboardColumn",SCORE_KEY)
end )

function collisisionWithPlayer ( otherPlayer )
	val notTillbakaKaka = previousBombHolder == nil or otherPlayer ~= previousBombHolder
	if ( client == bombHolder and otherPlayer ~= nil and notTillbakaKaka) then
		resetPrevBombHolder()
		previousBombHolder = otherPlayer
		previousBombHolderResetter = setTimer(resetPrevBombHolder, 5000, 1)
		setBombHolder( otherPlayer )
	end
end
addEvent( "onCollisionWithPlayer", true )
addEventHandler( "onCollisionWithPlayer", getRootElement(), collisisionWithPlayer )

function veryLowHealth ( )
	if ( client ~= bombHolder) then
		setBombHolder( client )
	end
end
addEvent( "lowOnHealth", true )
addEventHandler( "lowOnHealth", getRootElement(), veryLowHealth )
