skmUtils = {}

function skmUtils.createTextArea(name, parent, height, width, x, y)
	local frame = UI.CreateFrame("Frame", name, parent)
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	frame:SetHeight(height)
	frame:SetWidth(width)
	frame.text = UI.CreateFrame("RiftTextfield", name .. "TextArea", frame)
	frame.text:SetPoint("TOPLEFT", frame, "TOPLEFT")
	frame.text:SetHeight(height)
	frame.text:SetWidth(width)
	frame.text:SetBackgroundColor(0, 0, 0, .5)
	frame.text:SetLayer(1)
	frame.text:SetText("")
	return frame
end