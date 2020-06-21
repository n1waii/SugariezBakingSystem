local Sound = {}

local Debris = game:GetService("Debris")

function Sound:Add(id, volume, t)
	local SoundInstance = Instance.new("Sound")
	SoundInstance.SoundId = type(id) == "string" and id or "rbxassetid://"..id
	SoundInstance.MaxDistance = math.huge
	SoundInstance.Volume = volume
	SoundInstance.Parent = workspace
	SoundInstance.PlaybackSpeed = 1.2
	SoundInstance:Play()
	
	Debris:AddItem(SoundInstance, t)
	
	return SoundInstance
end

return Sound