-- this scripts holds all the globally persistent variables and helper functions
-- see the documentation in the wiki
-- NOTE:
-- THERE CAN BE ONLY ONE global_data SCRIPT in your Domoticz install.

return {
   
	-- global helper functions
	helpers = {
	    OFFICE_TEMP_TARGET = 61,
	    OFFICE_SENSOR = 46,
	    
	
	    -- Amount of minutes until sunset from midnight. After sunset the 
		-- function will return 0. offset (in minutes) to defer forward or backward.
		timeUntilSunset = function(domoticz, offset)
			local untilSunset = domoticz.time.sunsetInMinutes - domoticz.time.minutesSinceMidnight
			
			if (offset ~= nil) then
			    untilSunset = untilSunset + offset
		    end
		    
			if (untilSunset < 0) then
			    untilSunset = 0
		    end
		    
			return untilSunset
		end,
		
		-- Amount of minutes until sunrise from midnight. After sunrise the 
		-- function will return 0. offset (in minutes) to defer forward or backward.
		timeUntilSunrise = function(domoticz, offset)
			local untilSunrise = domoticz.time.sunriseInMinutes - domoticz.time.minutesSinceMidnight
			
			if (offset ~= nil) then
			    untilSunrise = untilSunrise + offset
		    end
		    
			if (untilSunrise < 0) then
			    untilSunrise = 0
		    end
		    
			return untilSunrise
		end,
		
		-- Returns the Temperatur interval for the office by taking
		-- the threshold into account.
		officeTemperatureSwitchZone = function(domoticz)
		    local threshold = domoticz.variables('OFFICE_DELTA').value
		    local tempTarget = domoticz.devices(domoticz.helpers.OFFICE_TEMP_TARGET)
            local t = {}
            
            t.target = tempTarget.setPoint
            t.max = tempTarget.setPoint + threshold		        
            t.min = tempTarget.setPoint - threshold
            
            return t
		end,
		
		-- Defines the timerange where heating should reduce or increase temperatur by
		-- a certain amount (offset). "zone" is table with entries for "min"
		-- temperatur and "max" temperatur.
		nightTemperatureSwitchZone = function(domoticz, zone, offset)
		    local currentTime = domoticz.time
		    
		    if (currentTime.matchesRule('at 00:00-05:30')) then
                domoticz.log('Enable Night mode.')
                zone.min = zone.min - offset
                zone.max = zone.max - offset
            end
            
            return zone
	    end
	}
}

