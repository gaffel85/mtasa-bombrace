local bombHolder = nil
local boosterBar = nil
local boosterLabel = nil

-- Since we listen for events on the root element we can use the bombHolder as the source. Events
-- triggered on any element will be catched if we listening to the root element.
function bombHolderChanged ( oldBombHolder )
	bombHolder = source
	outputDebugString("New bombHolder: "..inspect(bombHolder))
end
addEvent("onBombHolderChanged", true)
addEventHandler("onBombHolderChanged", getRootElement(), bombHolderChanged)

function tickBoosterCooldown(timeLeft, totalTime)
	if (boosterBar == nil) then
		boosterBar = guiCreateProgressBar( 0.8, 0.35, 0.1, 0.03, true, nil ) --create the gui-progressbar
		boosterLabel = guiCreateLabel( 0, 0,1,1,"Booster",true, boosterBar)
		guiLabelSetColor ( boosterLabel, 0, 128, 0 )
		guiLabelSetHorizontalAlign ( boosterLabel, "center" )
		guiLabelSetVerticalAlign ( boosterLabel, "center" )
		guiSetFont(boosterLabel, "default-bold-small")
	end

	local progress = 100 * (totalTime - timeLeft)/totalTime
	guiProgressBarSetProgress(boosterBar, progress)
end
addEvent("boosterCooldownTick", true)
addEventHandler("boosterCooldownTick", getRootElement(), tickBoosterCooldown)
