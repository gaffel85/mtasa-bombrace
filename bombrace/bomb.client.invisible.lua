-- Since we listen for events on the root element we can use the bombHolder as the source. Events
-- triggered on any element will be catched if we listening to the root element.
function onClientMakeInvisible ()
	local player = source
		
		local vehicle = getPedOccupiedVehicle( player )
		if ( getLocalPlayer() == player ) then
			setElementAlpha( vehicle, 100 )
			setElementAlpha( player, 0 )
		else
			setElementAlpha( vehicle, 0 )
			setElementAlpha( player, 0 )
			setElementAlpha( vehicle, 0 )
			setVehicleOverrideLights ( vehicle, 1 ) 
			setElementCollidableWith( vehicle, getPedOccupiedVehicle ( getLocalPlayer() ) , false)
			setPlayerNametagShowing ( player, false )
		end
	
end
addEvent("clientMakeInvisible", true)
addEventHandler("clientMakeInvisible", getRootElement(), onClientMakeInvisible)

function onClientMakeVisible ()
	local player = source
	local vehicle = getPedOccupiedVehicle( player )
	setElementAlpha( vehicle, 255 )
	setElementAlpha( player, 255 )
	setVehicleOverrideLights ( vehicle, 0 ) 
	setPlayerNametagShowing ( player, true )
	setElementCollidableWith( vehicle, getPedOccupiedVehicle ( getLocalPlayer() ) , true)
end
addEvent("clientMakeVisible", true)
addEventHandler("clientMakeVisible", getRootElement(), onClientMakeVisible)