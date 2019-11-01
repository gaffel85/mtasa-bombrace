local spawnPoints
local currentSpawn = 1
local mapLobbyMarker

GAME_STATE_LOBBY = 1
GAME_STATE_PREPARING_ROUND = 2
GAME_STATE_ACTIVE_GAME = 3
local gameState = GAME_STATE_LOBBY


local bombHolder
local previousBombHolder
local previousBombHolderResetter
local bombMarker
local bombEndTime
local lobbyMarker
local participants = {}

local SCORE_KEY = "Score"

local currentVehicle = 1
local vehicles = {551, 415, 531, 475, 437, 557}

addEvent("bombHolderChanged")

scoreboardRes = getResourceFromName( "scoreboard" )

function nextVehicle()
	currentVehicle = currentVehicle % #vehicles + 1
end

function getCurrentVehicle()
	return vehicles[currentVehicle]
end

function selectRandomBombHolder()
	local players = getAlivePlayers ()
	outputChatBox("Alive players: "..#players)
	if ( #players > 1 ) then
		local newBombHolder = players[math.random ( #players ) ]
		resetBomb()
		setBombHolder ( newBombHolder )
	end
end

function getBombHolder()
	return bombHolder
end

function getGameState()
	return gameState
end

function setBombHolder ( player )

	local oldBombHolder = bombHolder
	if (oldBombHolder ~= nil) then
		removeVehicleUpgrade( getPedOccupiedVehicle (oldBombHolder), 1009)
	end

	bombHolder = player
	makeVisible(bombHolder)
	makeInvisible(oldBombHolder, TILLBAKAKAKA_TIME)
	triggerClientEvent("onBombHolderChanged", player, oldBombHolder)

	showPresentBombHolder(bombHolder)

	if(bombMarker == nil ) then
		bombMarker = createMarker ( 0, 0, 1, "arrow", 2.0, 255, 0, 0)
	end
	attachElements ( bombMarker, bombHolder, 0, 0, 4 )
	fixVehicle (getPedOccupiedVehicle ( player ) )

	setBombTime( bombTimeLeft() + SWITCH_EXTRA_TIME )
	triggerEvent("bombHolderChanged", bombHolder, oldBombHolder)
	triggerClientEvent("timesAlmostUp", bombHolder)
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
	local rotX, rotY, rotZ = rotFromEdl ( spawnPoint )
  	local vehicle = createVehicle(getCurrentVehicle(), posX, posY, posZ, rotX, rotY, rotZ, "BOMBER")
	spawnPlayer(thePlayer, 0, 0, 0, 0, 285)
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
			showPrepareRoundTimer(timeLeft)
		end
	end

	local players = getElementsByType ( "player" )
	if(bombHolder ~= nil and #players > 0) then
		timeLeft = bombTimeLeft()
		if (timeLeft < 11 and timeLeft > 9) then
			triggerClientEvent("timesAlmostUp", bombHolder)
		end

		if ( timeLeft < 0 ) then
			blowBombHolder()
		else
			showBombTimer(timeLeft)
		end
	end
end
setTimer(tickBombTimer, 1000, 0)

function blowBombHolder()
	local lastBomdBolder = bombHolder
	local vehicle = getPedOccupiedVehicle ( bombHolder )
	blowVehicle(vehicle)
	bombHolder = nil
	hideBombTimer()	
	setTimer(givePointsToAllAlive, 1000, 1)
	setTimer(checkIfAnyAliveAndSelectNewBombHolder, 2000, 1, lastBomdBolder)
end

function checkIfAnyAliveAndSelectNewBombHolder(lastAlive)
	local alivePlayers = getAlivePlayers ()
	if ( #alivePlayers > 1 ) then
		selectRandomBombHolder()
	else
		showWinner(alivePlayers[1])
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
	setBombTime(BOMB_START_SECONDS)
end

function setBombTime(duration)
	local time = getRealTime()
	bombEndTime = time.timestamp + duration
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
	outputChatBox("Welcome to Bomb Race!", source)
end
addEventHandler("onPlayerJoin", getRootElement(), joinHandler)

function handleLateJoin()
	if (gameState == GAME_STATE_ACTIVE_GAME) then
		showLateJoinMessage()
		setTimer(setBombHolder, 2000, 1, source)
	end
end

function leaveLobby()
	local time = getRealTime()
	bombEndTime = time.timestamp + PREPARE_TIME
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
	nextVehicle()
	resetRoundVars()
	leaveLobby()
	destroyElementsByType ("vehicle")
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
		showPlayerReady(player)

		if #participants == #players then
			showLeavingLobbyMessage()
			leaveLobby()
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

function coordsFromEdl(element)
	local posX = getElementData ( element, "posX" )
	local posY = getElementData ( element, "posY" )
	local posZ = getElementData ( element, "posZ" )
	return posX, posY, posZ
end

function rotFromEdl(element)
	local posX = getElementData ( element, "rotX" )
	local posY = getElementData ( element, "rotY" )
	local posZ = getElementData ( element, "rotZ" )
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

addCommandHandler ( "changetime",
    function ( thePlayer, command, time )
        local timeNumber = tonumber ( time )
		if ( timeNumber > 0 ) then
			setBombTime(timeNumber)
		end
    end
)

addCommandHandler ( "changeveh",
    function ( thePlayer, command, newModel )
        local theVehicle = getPedOccupiedVehicle ( thePlayer ) -- get the vehicle the player is in
        newModel = tonumber ( newModel )                          -- try to convert the string argument to a number
        if theVehicle and newModel then                           -- make sure the player is in a vehicle and specified a number
            setElementModel ( theVehicle, newModel )
        end
    end
)

addCommandHandler ( "fixit",
    function ( thePlayer, command, newModel )
        local theVehicle = getPedOccupiedVehicle ( thePlayer )
        if theVehicle then
            fixVehicle ( theVehicle )
        end
    end
)

function collisisionWithPlayer ( otherPlayer )
	local notTillbakaKaka = previousBombHolder == nil or otherPlayer ~= previousBombHolder
	if ( client == bombHolder and otherPlayer ~= nil and notTillbakaKaka) then
		resetPrevBombHolder()
		previousBombHolder = client
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
