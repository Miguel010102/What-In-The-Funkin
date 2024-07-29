function onCreate()
end
function setUp()
end

function modsTimeline()

	--Make it default to reverse being enabled.
	setdefault(1, "reverse")
	
	--at beat 0, sets drunk to 100% after 2 beats using the sineInOut ease function
	tween(0, 2, "sineInOut", 1, "drunk")
	
	--at beat 2, sets tipsy to 100% after 2 beats using the tap ease function. Tap will automatically make the mod go back to 0 after it's done.
	add(2, 2, "tap", 1, "tipsy")
	
	--At beat 8, reset all mods back to default. This will make everything back to 0 BUT reverse will still be set to 1 (cuz it's default value is 1 as set earlier)
	reset(8)
end
