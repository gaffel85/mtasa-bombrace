local bombHolder = nil

function bombHolderChanged ( bombHolder )
	outputChatBox("Client: New bomb holder")
	outputChatBox(inspect(bombHolder))
	bombHolder = bombHolder
end
addEvent("onBombHolderChanged", true)
addEventHandler("onBombHolderChanged", resourceRoot, bombHolderChanged)


--function displayMessageForPlayer ( ID, message, displayTime, posX, posY, r, g, b, alpha, scale )
--	triggerServerEvent("onDisplayClientText", resourceRoot, getLocalPlayer(), ID, message, displayTime, posX, posY, r, g, b, alpha, scale)
--end

function onCollision(collider)
	if ( collider ~= nil and localPlayer == bombHolder) then
		outputChatBox("Client: Collision detected! Type: "..getElementType ( collider ))
		if ( source == getPedOccupiedVehicle(localPlayer) or getElementType ( collider ) == "vehicle" ) then
			outputChatBox("Client: Collision with vehicle!")
			local otherPlayer = getVehicleOccupant(collider)
			if ( otherPlayer ~= false) then
				outputChatBox("Client: Collision with otehr player in vehicle!")
				triggerServerEvent("onCollisionWithPlayer", resourceRoot, otherPlayer)
			end
		end
	else 
		outputChatBox("Client: Collision with unkown type!")
	end
end
addEventHandler("onClientVehicleCollision", getRootElement(), onCollision)