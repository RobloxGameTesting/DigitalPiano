local parent = script.Parent

while true do
	parent.Rotation += 1

	if parent.Rotation == 180 then
		parent.Rotation = -180
	end

	task.wait(0.005)
end