local cloakBar = nil
local cloakLabel = nil

function tickCloakCooldown(timeLeft, totalTime)
	if (cloakBar == nil) then
		cloakBar = guiCreateProgressBar( 0.8, 0.40, 0.1, 0.03, true, nil )
		cloakLabel = guiCreateLabel( 0, 0,1,1,"Cloak",true, cloakBar)
		guiLabelSetColor ( cloakLabel, 0, 128, 0 )
		guiLabelSetHorizontalAlign ( cloakLabel, "center" )
		guiLabelSetVerticalAlign ( cloakLabel, "center" )
		guiSetFont(cloakLabel, "default-bold-small")
	end

	local progress = 100 * (totalTime - timeLeft)/totalTime
	guiProgressBarSetProgress(cloakBar, progress)
end
addEvent("cloakCooldownTick", true)
addEventHandler("cloakCooldownTick", getRootElement(), tickCloakCooldown)
