local bombHolder = nil

-- Since we listen for events on the root element we can use the bombHolder as the source. Events
-- triggered on any element will be catched if we listening to the root element.
function bombHolderChanged ( )
	bombHolder = source
end
addEvent("onBombHolderChanged", true)
addEventHandler("onBombHolderChanged", getRootElement(), bombHolderChanged)


--function displayMessageForPlayer ( ID, message, displayTime, posX, posY, r, g, b, alpha, scale )
--	triggerServerEvent("onDisplayClientText", resourceRoot, getLocalPlayer(), ID, message, displayTime, posX, posY, r, g, b, alpha, scale)
--end

function onCollision(collider)
	if ( collider ~= nil and localPlayer == bombHolder) then
		outputChatBox("Source: "..inspect(source))
		outputChatBox("Collider: "..inspect(collider))
		outputChatBox("Collider type: "..inspect(getElementType ( collider )))
		outputChatBox("Local player vehicle: "..inspect(getPedOccupiedVehicle(localPlayer)))
		if ( source == getPedOccupiedVehicle(localPlayer) and getElementType ( collider ) == "vehicle" ) then
			local otherPlayer = getVehicleOccupant(collider)
			outputChatBox("Other player: "..inspect(otherPlayer))
			if ( otherPlayer ~= false) then
				triggerServerEvent("onCollisionWithPlayer", resourceRoot, otherPlayer)
			end
		end
	end
end
addEventHandler("onClientVehicleCollision", getRootElement(), onCollision)