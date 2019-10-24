local bombHolder = nil
local oldHolders = {}
local damageBar = nil
local damageLabel = nil
local boosterBar = nil
local boosterLabel = nil

-- Since we listen for events on the root element we can use the bombHolder as the source. Events
-- triggered on any element will be catched if we listening to the root element.
function bombHolderChanged ( oldBombHolder )
	--[[if ( oldBombHolder ~= nil ) then
		
		if ( localPlayer == oldBombHolder ) then
			setElementAlpha( getPedOccupiedVehicle( oldBombHolder ), 100 )
			setElementAlpha( oldBombHolder, 150 )
		else
			setElementAlpha( getPedOccupiedVehicle( oldBombHolder ), 0 )
			setElementAlpha( oldBombHolder, 0 )
			setElementAlpha( getPedOccupiedVehicle( oldBombHolder ), 0 )
			setVehicleOverrideLights ( oldBombHolder, 1 ) 
			setElementCollidableWith( getPedOccupiedVehicle( localPlayer ), getPedOccupiedVehicle( oldBombHolder ) , false)
			setPlayerNametagShowing ( oldBombHolder, false )
		end
		

		table.insert(oldHolders, oldBombHolder)
		setTimer(function()
			local oldest = table.remove(oldHolders, 1)
			setElementAlpha( getPedOccupiedVehicle( oldest ), 255 )
			setElementAlpha( oldest, 255 )
			setVehicleOverrideLights ( oldest, 0 ) 
			setPlayerNametagShowing ( oldest, true )
			setElementCollidableWith( getPedOccupiedVehicle( localPlayer ), getPedOccupiedVehicle( oldest ) , true)
		end, 10000, 1)
	end]]

	bombHolder = source
	outputDebugString("New bombHolder: "..inspect(bombHolder))
end
addEvent("onBombHolderChanged", true)
addEventHandler("onBombHolderChanged", getRootElement(), bombHolderChanged)

function timesAlmostUp2()
	playSound("sounds/stress.mp3")
end
addEvent("timesAlmostUp", true)
addEventHandler("timesAlmostUp", getRootElement(), timesAlmostUp2)

function tickBoosterCooldown(timeLeft, totalTime)
	if (boosterBar == nil) then
		boosterBar = guiCreateProgressBar( 0.8, 0.35, 0.1, 0.03, true, nil ) --create the gui-progressbar
		boosterLabel = guiCreateLabel( 0, 0,1,1,"Booster",true, boosterBar)
		guiLabelSetColor ( boosterLabel, 0, 128, 0 )
		guiLabelSetHorizontalAlign ( boosterLabel, "center" )
		guiLabelSetVerticalAlign ( boosterLabel, "center" )
		guiSetFont(boosterLabel, "default-bold-small")
	end

	local progress = 100 * (totalTime - timeLeft)/totalTime
	guiProgressBarSetProgress(boosterBar, progress)
end
addEvent("boosterCooldownTick", true)
addEventHandler("boosterCooldownTick", getRootElement(), tickBoosterCooldown)


function onCollision(collider)
	if ( collider ~= nil and localPlayer == bombHolder) then
		outputDebugString("Collider type: "..inspect(getElementType ( collider )))
		outputDebugString("Local player vehicle: "..inspect(getPedOccupiedVehicle(localPlayer)))
		if ( source == getPedOccupiedVehicle(localPlayer) and getElementType ( collider ) == "vehicle" ) then
			local otherPlayer = getVehicleOccupant(collider)
			if ( otherPlayer ~= false) then
				triggerServerEvent("onCollisionWithPlayer", resourceRoot, otherPlayer)
			end
		end
	end
end
addEventHandler("onClientVehicleCollision", getRootElement(), onCollision)

function flipIfNeeded(vehicle)
	local rx,ry,rz = getElementRotation ( vehicle )
	if rx > 90 and rx < 270 or ry > 90 and ry < 270 then
		local posX, posY, posZ = getElementPosition ( vehicle )
		setElementPosition (vehicle, posX, posY, posZ + 2)
		setElementRotation (vehicle, 0, 0, rz)
	end
end

addEventHandler ( "onClientVehicleDamage", root, function ( )
	if (damageBar == nil) then
		damageBar = guiCreateProgressBar( 0.8, 0.3, 0.1, 0.03, true, nil ) --create the gui-progressbar
		damageLabel = guiCreateLabel( 0, 0,1,1,"Damage",true, damageBar)
		guiLabelSetColor ( damageLabel, 255, 0, 0 )
		guiLabelSetHorizontalAlign ( damageLabel, "center" )
		guiLabelSetVerticalAlign ( damageLabel, "center" )
		guiSetFont(damageLabel, "default-bold-small")
	end

	local vehicle = source
	local health = getElementHealth ( vehicle )
	guiProgressBarSetProgress(damageBar, 100 * (math.max(health, 250) - 250) / 750)
	if ( health < 250 ) then
		
		local driver = getVehicleOccupant ( vehicle )
		if ( driver == bombHolder ) then
			setVehicleDamageProof ( vehicle , true )
			flipIfNeeded ( vehicle )
			fixVehicle ( vehicle )
			setTimer(function() 
				setVehicleDamageProof ( vehicle , false )
			end, 5000, 1)
		else
			toggleAllControls ( false, true, false )
			setVehicleDamageProof ( vehicle , true )
			--displayMessageForPlayer(929921111, "Car broken. Wait 5 sec.", 5000, 0.5, 0.5, 255, 0, 0 )

			fixVehicle (vehicle)
			flipIfNeeded ( vehicle )

			setTimer(function() 
				toggleAllControls ( true, true, true )
				setVehicleDamageProof ( vehicle , false )
			end, 5000, 1)
		end
	end
end )


