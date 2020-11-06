-- Controls heating in the office room.
return {

	active = true,
	
	on = {
		devices = {
		    46, --temperature change
		    50, --switch Q1
		    51, --switch Q2
		    61 --change of target temperatur
		}
	},

	-- persistent data
	-- see documentation about persistent variables
	data = {
		manualOverride = { initial = false },
		manualOverheat = { initial = 0 }
	},

	-- custom logging level for this script
	logging = {
        level = domoticz.LOG_INFO
    },

	-- Set Walli to turn on Q1 (50) when temperatur lower target temperatur (61)
	-- minus treshold ('OFFICE_DELTA') or Q1(50) or Q2(51) state is on and beneath
	-- target temperatur (61) minus and plus treshold ('OFFICE_DELTA').
	-- Manual use of Q1(50) increases target temperatur by 0.5 degree and Q2(51)
	-- increases target temperatur by 1 degree.
	-- A configurable treshold (OFFICE_DELTA) prevents switching on and off 
	-- too frequently (0.2)
	-- Night mode: is between 00:00 and 05:30 and decreases target temperature
	-- by one degree.
	execute = function(domoticz, triggeredItem)

        local zone = domoticz.helpers.officeTemperatureSwitchZone(domoticz)
		local tempCur = domoticz.devices(46).temperature

        local switch2 = domoticz.devices(50)
		local switch3 = domoticz.devices(51)
        
        local dzdt = domoticz.data

        if (triggeredItem.isDevice == true and dzdt.manualOverride == false) then
		   if ((triggeredItem.id == 50 or triggeredItem.id ==51) and triggeredItem.state == 'On') then
		       dzdt.manualOverride = true
	       end
        elseif (triggeredItem.isDevice == true and dzdt.manualOverride == true) then
           if ((triggeredItem.id == 50 or triggeredItem.id ==51) and triggeredItem.state == 'Off') then
		       dzdt.manualOverride = false
	       end
		end
        
        if (dzdt.manualOverride and switch2.state == 'On' and switch3.state == 'Off') then
            dzdt.manualOverheat = 0.5
        elseif (dzdt.manualOverride and switch3.state == 'On') then
            dzdt.manualOverheat = 1
        elseif (dzdt.manualOverride == false) then
            dzdt.manualOverheat = 0
        end
        
        if (dzdt.manualOverheat > 0) then
            zone.max = zone.target + dzdt.manualOverheat
        end
        
        if (dzdt.manualOverride == false) then
            zone = domoticz.helpers.nightTemperatureSwitchZone(domoticz, zone, 1)
        end
        
		domoticz.log('ManualOverride ' .. tostring(dzdt.manualOverride) .. ' Overheat ' .. dzdt.manualOverheat)
		domoticz.log('Temperatur Current ' .. tempCur .. 'Temperatur min/max ' .. zone.min .. '/' .. zone.max)
		
		local switchTarget = false
		
        if (tempCur <= zone.min or ((switch2.state == 'On' or switch3.state == 'On') and tempCur <= zone.max)) then
            switchTarget = true
        end
        
        -- Turn on or off section. Important: use "silent()" command option,
        -- otherwise it will cause a loop
        if (switchTarget == true) then
            switch2.switchOn().checkFirst().silent()
        elseif (switchTarget == false) then
            switch2.switchOff().checkFirst().silent()
            if (domoticz.data.manualOverride) then
                domoticz.data.manualOverride = false
                domoticz.data.manualOverheat = 0
            end
            switch3.switchOff().checkFirst().silent()
        end
    
        domoticz.log('Finished - Heizung Q1/Q2 ' .. switch2.state .. '/' .. switch3.state)		
	end
}

