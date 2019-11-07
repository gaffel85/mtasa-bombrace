local timerBar = nil
local timerLabel = nil

function tickBombTimer(timeLeft, totalTime)
	if ( timerBar ~= nil ) then
		if ( source ~= localPlayer) then
			guiSetVisible(timerBar, false)
		else
			guiSetVisible(timerBar, true)
		end
	end

	if (timerBar == nil) then
		timerBar = guiCreateProgressBar( 0.5, 0.85, 0.2, 0.1, true, nil )
		timerLabel = guiCreateLabel( 0, 0,1,1,"",true, timerBar)
		guiLabelSetColor ( timerLabel, 0, 128, 0 )
		guiLabelSetHorizontalAlign ( timerLabel, "center" )
		guiLabelSetVerticalAlign ( timerLabel, "center" )
		guiSetFont(timerLabel, "sa-header")
	end

	guiSetText(timerLabel, timeLeft.."s"
	local cropppedTime = math.min(totalTime, timeLeft)
	local progress = 100 * (totalTime - cropppedTime)/totalTime
	guiProgressBarSetProgress(timerBar, progress)
end
addEvent("bombTimerTick", true)
addEventHandler("bombTimerTick", getRootElement(), tickBombTimer)
