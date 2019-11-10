local bombMarker
local bombObj

function attachBombMarker ( player )
	if(bombMarker == nil ) then
		bombMarker = createMarker ( 0, 0, 1, "arrow", 2.0, 255, 0, 0)
	end
	attachElements ( bombMarker, player, 0, 0, 4 )

	if ( bombObj == nil ) then
		bombObj = createObject( 1654, 0, 0, 0, 90, 0, 0, true )
		setObjectScale ( bombObj, 3.0 )
		setElementCollisionsEnabled ( bombObj, false )
	end
	local vehicle = getPedOccupiedVehicle ( player )
	attachElements ( bombObj, vehicle, 0, 0, 2 )
end

function hideBombMarker ( exceptPlayer )
	setElementVisibleTo(bombMarker, root, false)
	if ( exceptPlayer ~= nil ) then
		setElementVisibleTo(bombMarker, exceptPlayer, true)
	end
end

function showBombMarker ( exceptPlayer )
	setElementVisibleTo(bombMarker, root, true)
	if ( exceptPlayer ~= nil ) then
		setElementVisibleTo(bombMarker, exceptPlayer, false)
	end
end

function resetBombMarker ()
	if (bombMarker ~= nil) then
		destroyElement(bombMarker)
		bombMarker = nil
	end 

	if ( bombObj ~= nil ) then
		destroyElement ( bombObj )
		bombObj = nil
	end
end