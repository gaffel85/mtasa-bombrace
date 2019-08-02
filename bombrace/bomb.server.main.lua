local spawnPoints
local currentSpawn = 1

local bombHolder
local bombMarker
local bombEndTime

local BOMB_START_SECONDS = 60
local SCORE_KEY = "Score"
local PRESENTING_BOMB_HOLDER_TEXT_ID = 987771
local PRESENTING_BOMB_HOLDER_PERSONAL_TEXT_ID = 987772
local BOMB_TIMER_TEXT_ID = 987773

local cars = {411, 596}

scoreboardRes = getResourceFromName( "scoreboard" )

function selectRandomBombHolder()
	local players = getAlivePlayers ()
	if ( #players > 1 ) then
		local newBombHolder = players[math.random ( #players ) ]
		setBombHolder ( newBombHolder )
	end
end

function setBombHolder ( player )
	bombHolder = player
	triggerClientEvent(resourceRoot, "onBombHolderChanged", resourceRoot, bombHolder)

	displayMessageForAll(PRESENTING_BOMB_HOLDER_TEXT_ID, getPlayerName(bombHolder).." now has the bomb. Hide!", bombHolder, "You have the bomb. Hit someone to pass the bomb", 5000, 0.5, 0.3, 255, 0, 0 )

	if(bombMarker == nil ) then
		bombMarker = createMarker ( 0, 0, 1, "arrow", 2.0, 255, 0, 0)
	end
	attachElements ( bombMarker, bombHolder, 0, 0, 4 )
	
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

function tickBombTimer()
	local players = getElementsByType ( "player" )
	if(bombHolder ~= nil and #players > 0) then
		local currentTime = getRealTime()
		local timeLeft = bombEndTime - currentTime.timestamp
		if ( timeLeft < 0 ) then
			local vehicle = getPedOccupiedVehicle ( bombHolder )
			blowVehicle(vehicle)
			resetBomb()
			bombHolder = nil
			clearMessageForAll(BOMB_TIMER_TEXT_ID)
			setTimer(selectRandomBombHolder, 2000, 1)
		end

		displayMessageForAll(BOMB_TIMER_TEXT_ID, timeLeft.."s", nil, nil, 2000, 0.5, 0.1, 255, 0, 0 )
	end
end
setTimer(tickBombTimer, 1000, 0)

function resetBomb()
	local time = getRealTime()
	bombEndTime = time.timestamp + BOMB_START_SECONDS
end

function resetRoundVars()
  
end

function newRound()
	resetRoundVars()
	respawnAllPlayers()
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

function startGameMap( startedMap )
	outputDebugString("startGameMap")
	local mapRoot = getResourceRootElement( startedMap )
    spawnPoints = getElementsByType ( "playerSpawnPoint" , mapRoot )
  	resetGame()
end
addEventHandler("onGamemodeMapStart", getRootElement(), startGameMap)

function resetGame()
  resetBomb()
  resetRoundVars()
  respawnAllPlayers()
end

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

function joinHandler()
	spawn(source)
	if ( bombHolder == nil) then
		selectRandomBombHolder()
	end
	outputChatBox("Welcome to My Server", source)
end
addEventHandler("onPlayerJoin", getRootElement(), joinHandler)

function collisisionWithPlayer ( otherPlayer )
	outputChatBox("Server: Collision detected!")
	if ( client == bombHolder and otherPlayer ~= nil) then
		setBombHolder = otherPlayer
	end
end
addEvent( "onCollisionWithPlayer", true )
addEventHandler( "onCollisionWithPlayer", resourceRoot, collisisionWithPlayer )
