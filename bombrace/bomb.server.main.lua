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
local lobbyMarker
local participants = {}
local blowingPlayer = nil

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

function getGameState()
	return gameState
end

function selectRandomBombHolder()
	local players = getAlivePlayers ()
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
	attachBombMarker ( player )

	if ( player == bombHolder ) then
		return
	end

	blowingPlayer = nil

	local oldBombHolder = bombHolder
	if (oldBombHolder ~= nil) then
		removeVehicleUpgrade( getPedOccupiedVehicle (oldBombHolder), 1009)
	end

	bombHolder = player
	makeVisible(bombHolder)
	makeInvisible(oldBombHolder, TILLBAKAKAKA_TIME)
	triggerClientEvent("onBombHolderChanged", player, oldBombHolder)

	showPresentBombHolder(bombHolder)
	fixVehicle (getPedOccupiedVehicle ( player ) )

	addBombTime( SWITCH_EXTRA_TIME )
	triggerEvent("bombHolderChanged", bombHolder, oldBombHolder)
end

function clearBombHolder ()
	bombHolder = nil
	triggerEvent("onBombHolderCleared", root)
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
  	spawnAt(thePlayer, posX, posY, posZ, rotX, rotY, rotZ)
end

function spawnAt(player, posX, posY, posZ, rotX, rotY, rotZ) 
	local vehicle = createVehicle(getCurrentVehicle(), posX, posY, posZ, rotX, rotY, rotZ, "BOMBER")
	spawnPlayer(player, 0, 0, 0, 0, 285)
	setTimer(function()
		warpPedIntoVehicle(player, vehicle)
		fadeCamera(player, true)
		setCameraTarget(player, player)
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

function blowBombHolder()
	local lastBomdBolder = bombHolder
	local vehicle = getPedOccupiedVehicle ( bombHolder )
	blowingPlayer = bombHolder
	blowVehicle(vehicle)
	resetBombMarker ()
	clearBombHolder ()
	hideBombTimer()	
	setTimer(givePointsToAllAlive, 1000, 1)
	setTimer(checkIfAnyAliveAndSelectNewBombHolder, 2000, 1, lastBomdBolder)
	setTimer(destroyElement, 8000, 1, vehicle)
end
addEventHandler("bombTimesUp", root, blowBombHolder)

function checkIfAnyAliveAndSelectNewBombHolder(lastAlive)
	local alivePlayers = getAlivePlayers ()
	if ( #alivePlayers > 1 ) then
		selectRandomBombHolder()
	else
		showWinner(alivePlayers[1])
		setTimer(activeRoundFinished, PRESENT_WINNER_TIME * 1000, 1)
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
	setBombTime(PREPARE_TIME)
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
	triggerClientEvent ( "newRound", getRootElement() )
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
	clearBombHolder ()
	resetPrevBombHolder()
	resetBombMarker()
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
	if ( blowingPlayer == source ) then
		blowingPlayer = nil
		triggerClientEvent ( "playerDied", source, getAlivePlayers() )
		setTimer(startSpectating, 3000, 1, source)
	else
		local posX, posY, posZ = getElementPosition(source)
		spawnAt( source, posX, posY, posZ, 0, 0, 0)

		if ( source == bombHolder ) then
			setBombHolder ( source ) 
		else 
			showRepairingCar ( source )
			toggleAllControls ( source, false, true, false )
			onRepairCar ( source )
			local theWasted = source
			setTimer(function() 
				toggleAllControls ( theWasted, true, true, true )
			end, 5000, 1)
		end
	end
end
addEventHandler( "onPlayerWasted", getRootElement( ), playerDied)

function startSpectating(player) 
	triggerClientEvent ( "startSpectating", player )
end

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


function onRepairCar ( player )
	makeVisible ( player )
	local blip = createBlipAttachedTo ( player, 27 )
	setElementVisibleTo ( blip, root, true )
	setElementVisibleTo ( blip, player, false )
	showPlayerParalyzied ( getBombHolder(), player)
	
	setTimer(function()
		makeVisible ( player )
	end, REPAIR_TIME * 1000, 1)
end
addEvent( "repairCar", true )
addEventHandler( "repairCar", getRootElement(), onRepairCar )

