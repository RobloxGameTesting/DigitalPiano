local parent = script.Parent.Parent
local v = { Notices = true }

for _, child in pairs(parent:GetChildren()) do
	if child:IsA("Frame") then
		if v[child.Name] then
			child.Visible = true
		else
			child.Visible = false
		end
	elseif child:IsA("Folder") then
		for _, frame in pairs(child:GetChildren()) do
			if frame:IsA("Frame") then
				frame.Visible = false
			end
		end
	end
end