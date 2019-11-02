
local activeSound = nil
local previousRadioChannel = nil

-- Since we listen for events on the root element we can use the bombHolder as the source. Events
-- triggered on any element will be catched if we listening to the root element.
function bombHolderChanged ( oldBombHolder )
	if ( activeSound ~= nil ) then
		destroyElement(activeSound)
		setRadioChannel ( previousRadioChannel )  
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
