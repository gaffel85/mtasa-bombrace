local bombHolder = nil
local oldHolders = {}

-- Since we listen for events on the root element we can use the bombHolder as the source. Events
-- triggered on any element will be catched if we listening to the root element.
function bombHolderChanged ( oldBombHolder )
	if ( oldBombHolder ~= nil ) then
		
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
	end

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
	local vehicle = source
	if ( getElementHealth ( vehicle ) < 400 ) then
		
		local driver = getVehicleOccupant ( vehicle )
		if ( driver == bombHolder ) then
			flipIfNeeded ( vehicle )
			fixVehicle ( vehicle )
		else
			toggleAllControls ( false, true, false )
			--displayMessageForPlayer(929921111, "Car broken. Wait 5 sec.", 5000, 0.5, 0.5, 255, 0, 0 )

			fixVehicle (vehicle)
			flipIfNeeded ( vehicle )

			setTimer(function() 
				toggleAllControls ( true, true, true )
			end, 5000, 1)
		end
	end
end )

[[
function vehicleDamaged()
	if ( localPlayer ~= bombHolder ) then
		local health = getElementHealth ( getPedOccupiedVehicle ( localPlayer ) )
		if ( health < 300 ) then
			triggerServerEvent("lowOnHealth", resourceRoot)
		end
	end
end
addEventHandler("onClientVehicleDamage", getRootElement(), vehicleDamaged)
]]
