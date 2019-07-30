
function onCollision(collider,force, bodyPart, x, y, z, nx, ny, nz) 
	if ( source == getPedOccupiedVehicle(localPlayer) or getElementType ( collider ) == "vehicle" ) then
		local otherPlayer = getVehicleOccupant(collider)
		if ( otherPlayer ~= false) then
			triggerServerEvent(onCollisionWithPlayer, resourceRoot, otherPlayer)
		end
	end
end

addEventHandler("onClientVehicleCollision", getRootElement(), onCollision)