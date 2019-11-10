-- Since we listen for events on the root element we can use the player as the source. Events
-- triggered on any element will be catched if we listening to the root element.
function onClientMakeInvisible (isGhost, hardPlayers)
	local player = source
		
		local vehicle = getPedOccupiedVehicle( player )
		if ( getLocalPlayer() == player ) then
			setElementAlpha( vehicle, 150 )
			setElementAlpha( player, 0 )
			setBombAlpha ( vehicle, 150 )

			if (isGhost) then
				for _, hardPlayer in ipairs(hardPlayers) do
					setElementCollidableWith( vehicle, getPedOccupiedVehicle ( hardPlayer ) , false)
				end
			end
		else
			setElementAlpha( vehicle, 0 )
			setElementAlpha( player, 0 )
			setElementAlpha( vehicle, 0 )
			setBombAlpha ( vehicle, 0 )
			setVehicleOverrideLights ( vehicle, 1 )
			setPlayerNametagShowing ( player, false )

			if (isGhost) then
				setElementCollidableWith( vehicle, getPedOccupiedVehicle ( getLocalPlayer() ) , false)
			end
		end
	
end
addEvent("clientMakeInvisible", true)
addEventHandler("clientMakeInvisible", getRootElement(), onClientMakeInvisible)

function onClientMakeVisible (hardPlayers)
	local player = source
	local vehicle = getPedOccupiedVehicle( player )
	setElementAlpha( vehicle, 255 )
	setElementAlpha( player, 255 )
	setBombAlpha ( vehicle, 255 )
	setVehicleOverrideLights ( vehicle, 0 ) 
	setPlayerNametagShowing ( player, true )
	for _, hardPlayer in ipairs(hardPlayers) do
		setElementCollidableWith( vehicle, getPedOccupiedVehicle (hardPlayer ) , true)
	end
	
end
addEvent("clientMakeVisible", true)
addEventHandler("clientMakeVisible", getRootElement(), onClientMakeVisible)

function setBombAlpha ( vehicle, alpha )
	local attachedElements = getAttachedElements ( vehicle )
	if ( attachedElements ) then
		for _, element in ipairs ( attachedElements ) do
			if ( getElementType ( element ) == "object" ) then
				setElementAlpha( element, alpha )
			end
		end
	end
end