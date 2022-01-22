function onBeatHit()
	if game then
			triggerEvent('Camera Follow Pos','1700','1103')
			setProperty('defaultCamZoom',0.5);
			doTweenAlpha('alpha2','battlebg',1,0.1,'quartIn')
			doTweenAlpha('alpha4','birdbg',0,0.1,'quartIn')
	else
		setProperty('defaultCamZoom',0.75);
		doTweenAlpha('alpha3','battlebg',0,0.1,'quartIn')
		doTweenAlpha('alpha5','birdbg',1,0.1,'quartIn')
		if mustHitSection then
		
			triggerEvent('Camera Follow Pos','950','1226')

		else
			triggerEvent('Camera Follow Pos','2529','1103')

		end
	end
end

function onEvent(n,v1,v2)

	if n == "game" then
	
		game = v1 == "true"
	
	end
end