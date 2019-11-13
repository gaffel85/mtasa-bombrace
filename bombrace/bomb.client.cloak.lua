local cloakBar = nil
local cloakLabel = nil

function tickCloakCooldown(timeLeft, totalTime)
	if ( cloakBar ~= nil ) then
		if ( source ~= localPlayer) then
			guiSetVisible(cloakBar, false)
		else
			guiSetVisible(cloakBar, true)
		end
	end

	if (cloakBar == nil) then
		cloakBar = guiCreateProgressBar( 0.8, 0.40, 0.1, 0.03, true, nil )
		cloakLabel = guiCreateLabel( 0, 0,1,1,"Cloak (Z)",true, cloakBar)
		guiLabelSetColor ( cloakLabel, 0, 128, 0 )
		guiLabelSetHorizontalAlign ( cloakLabel, "center" )
		guiLabelSetVerticalAlign ( cloakLabel, "center" )
		guiSetFont(cloakLabel, "default-bold-small")
	end

	local progress = 100 * (totalTime - timeLeft)/totalTime
	if ( progress < 99.5 ) then
		guiLabelSetColor ( cloakLabel, 77, 77, 77 )
	else 
		guiLabelSetColor ( cloakLabel, 80, 255, 100 )
	end
	guiProgressBarSetProgress(cloakBar, progress)
end
addEvent("cloakCooldownTick", true)
addEventHandler("cloakCooldownTick", getRootElement(), tickCloakCooldown)
