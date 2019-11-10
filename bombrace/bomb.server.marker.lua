local bombMarker
local bombObj

local DEFAULT_OFFSET = { x = 0, y = 0, z = 0}
local DEFAULT_ROTATION = { x = 90, y = 0, z = 0}
local DEFAULT_SCALE = 3

local vehicleParams = { 
	[551] = { 
		name = "", 
		bomb = {
			offset = { x = 0, y = 0, z = 0},
			rotation = { x = 0, y = 0, z = 0},
			scale = 2
		 } 
	}, 
	[415] = {  
		name = "", 
		bomb = {
			offset = { x = 0, y = 0, z = 0},
			rotation = { x = 0, y = 0, z = 0},
			scale = 2
		 } 
	}, 
	[531] = { 
		name = "", 
		bomb = {
			offset = { x = 0, y = 0, z = 0},
			rotation = { x = 0, y = 0, z = 0},
			scale = 2
		 } 
	 }, 
	[475] = {  
		name = "", 
		bomb = {
			offset = { x = 0, y = 0, z = 0},
			rotation = { x = 0, y = 0, z = 0},
			scale = 2
		 } 
	}, 
	[437] = {  
		name = "", 
		bomb = {
			offset = { x = 0, y = 0, z = 0},
			rotation = { x = 0, y = 0, z = 0},
			scale = 2
		 } 
	}, 
	[557] = {  
		name = "", 
		bomb = {
			offset = { x = 0, y = 0, z = 0},
			rotation = { x = 0, y = 0, z = 0},
			scale = 2
		 } 
	}
}

function getBombParams ( vehicle )
	local model = getElementModel ( vechicle )
	local params = vehicleParams[model]
	if ( params ~= nil ) then
		return params.offset.x, params.offset.y, params.offset.z, params.rotation.x, params.rotation.y, params.rotation.z, params.scale
	else 
		return DEFAULT_OFFSET.x, DEFAULT_OFFSET.y, DEFAULT_OFFSET.z,DEFAULT_ROTATION.x, DEFAULT_ROTATION.y, DEFAULT_ROTATION.z, DEFAULT_SCALE
	end
end

function attachBombMarker ( player )
	if(bombMarker == nil ) then
		bombMarker = createMarker ( 0, 0, 1, "arrow", 2.0, 255, 0, 0)
	end
	attachElements ( bombMarker, player, 0, 0, 4 )

	local vehicle = getPedOccupiedVehicle ( player )
	local x,y,z,ry,rz,scale = getBombParams ( vehicle )
	if ( bombObj == nil ) then
		bombObj = createObject( 1654, 0, 0, 0, rx, ry, rz, true )
		setObjectScale ( bombObj, scale )
		setElementCollisionsEnabled ( bombObj, false )
	end
	attachElements ( bombObj, vehicle, x, y, z )
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