--[[
	Author: einsteinK, Alphexus
	Purpose: A way of adding a timeout to Event:Wait(). You can also pass a callback function.
--]] 

local EventTimeout = {}

function EventTimeout.new(ev, t, callback)
	local res, con;
	con = ev:Connect(function(...)
		res = ...
		con:Disconnect()
	end)
	
   	t = tick() + (t or 30)
	repeat wait() until res or tick() > t
	
	if not res then 
		if con ~= nil then
			con:Disconnect()
		end
		return false, callback ~= nil and callback(false, res) or nil
	end
	
	if con ~= nil then
		con:Disconnect()
	end
	
	return true, res, callback ~= nil and callback(false, res) or nil
end


return EventTimeout
