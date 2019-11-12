
local activeSound = nil
local huntedSound = nil
local previousRadioChannel = nil

-- Since we listen for events on the root element we can use the bombHolder as the source. Events
-- triggered on any element will be catched if we listening to the root element.
function bombHolderChanged ( oldBombHolder )
	if ( activeSound ~= nil ) then
		destroyElement(activeSound)
		setRadioChannel ( previousRadioChannel )  
	end

	if ( source == getLocalPlayer() ) then
		resetHuntedSound ()
	end
end
addEventHandler("onBombHolderChanged", getRootElement(), bombHolderChanged)

function onTimesAlmostUp()
	if ( localPlayer == getBombHolder() ) then
		previousRadioChannel = getRadioChannel ( ) 
		setRadioChannel ( 0 )  
		activeSound = playSound("sounds/stress.mp3")    
	end
end
addEvent("timesAlmostUp", true)
addEventHandler("timesAlmostUp", getRootElement(), onTimesAlmostUp)

function getDistance( element, other )
    local x, y, z = getElementPosition( element )
    if isElement( element ) and isElement( other ) then
        return getDistanceBetweenPoints3D( x, y, z, getElementPosition( other ))
    end
end

function resetHuntedSound ()
	if ( huntedSound ~= nil ) then
		destroyElement(huntedSound)
		setRadioChannel ( previousRadioChannel )  
	end
end

function checkCloseToBombHolder()
	local bombHolder = getBombHolder()
	if ( bombHolder ~= nil ) then
		local distance = getDistance ( bombHolder, getLocalPlayer ())
		outputChatBox(inspect(distance))
		if (distance < DISTANCE_FOR_MUSIC) then
			if ( huntedSound == nil ) then
				previousRadioChannel = getRadioChannel ( ) 
				setRadioChannel ( 0 )  
				huntedSound = playSound("sounds/hunted.mp3") 
			end
		else
			resetHuntedSound ()
		end
	end
end
setTimer(checkCloseToBombHolder, 1000, 0)



