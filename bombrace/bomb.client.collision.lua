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
end
addEvent("onBombHolderChanged", true)
addEventHandler("onBombHolderChanged", getRootElement(), bombHolderChanged)


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