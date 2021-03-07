
local activeSound = nil
local previousRadioChannel = nil

local huntedSound = nil
local minDistanceReached = false

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

function onBombHolderCleared ( )
	resetHuntedSound ()
end
addEventHandler("bombHolderCleared", getRootElement(), onBombHolderCleared)

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
		minDistanceReached = false
		destroyElement(huntedSound)
		setRadioChannel ( previousRadioChannel )  
	end
end

function checkCloseToBombHolder()
	local bombHolder = getBombHolder()
	if ( bombHolder ~= nil and bombHolder ~= getLocalPlayer () ) then
		local distance = getDistance ( bombHolder, getLocalPlayer ())
		outputChatBox(inspect(distance))

		if ( distance > DISTANCE_FOR_ACTIVATING_STRESS_CHECK ) then
			minDistanceReached = true
		end

		if ( minDistanceReached ) then 
			if ( distance < DISTANCE_FOR_STRESS_SOUND ) then
				if ( huntedSound == nil ) then
					previousRadioChannel = getRadioChannel ( ) 
					setRadioChannel ( 0 )  
					huntedSound = playSound("sounds/hunted.mp3", true) 
				end
			else
				if ( huntedSound ~= nil ) then
					resetHuntedSound ()
				end
			end
		end
	end
end
-- setTimer(checkCloseToBombHolder, 1000, 0)



