local highlightLib = {}
highlightLib.Settings = {--default settings
	FillColor = Color3.fromRGB(200, 90, 255),
	OutlineColor = Color3.fromRGB(255, 119, 215),
	FillTransparency = 0.65,
	OutlineTransparency = 0,
	DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
}

local highlightsFolder = Instance.new("Folder")
highlightsFolder.Name = "HighlightName"
local folderLocation
if hookfunction then
	folderLocation = game:GetService("CoreGui")
else--making it compatible with shitty level 2 exploits and localscripts (you'd have to make this a modulescript or have access to loadstring & httpget)
	folderLocation = workspace
end
local alreadyLoaded = folderLocation:FindFirstChild("Rendered Highlights")
if alreadyLoaded then
    alreadyLoaded:Destroy()--just wiping the old folder in case it gets re-executed
end

highlightsFolder.Parent = folderLocation
local renderedTargets = {}

function highlightLib:addEsp(targetModel:Model)--highlightLib:addEsp(target.Character) to use this
	if table.find(renderedTargets,targetModel) then--preventing duplicates, this is a way to fix my psx script lol 
	    return
    end
	local highlightSettings = self.Settings--literally the only time I have used self
	local newHighlight = Instance.new("Highlight")--wow no shit
	newHighlight.Adornee = targetModel
	for i,v in next, highlightSettings do
		newHighlight[i] = v
	end
	newHighlight.Parent = highlightsFolder
	table.insert(renderedTargets,targetModel)
	
	local currentConnections = {}
	currentConnections[#currentConnections+1] = targetModel.AncestryChanged:Connect(function() --could just do 1 or not include a table, but I might get snazzy and add new shit (I won't)
		if not targetModel or targetModel.Parent == nil then
			newHighlight:Destroy()
			for i,v in ipairs(currentConnections) do
				v:Disconnect()--when a character is removed by dropping out of the map, it is destroyed with :Remove(), which just puts it in nil instead of garbage collecting everything so it lags, nice.
			end
			currentConnections = nil
			newHighlight:Destroy()
			table.remove(renderedTargets,table.find(renderedTargets,targetModel))
		end
	end)
end
function highlightLib:loadSettings(Settings)--could add sliders for the settings and just call this function but it's not good so you'd have to update the settings with a complete table of settings even if they're unchanged lol!
	self.Settings = Settings
	for i,Highlight in ipairs(highlightsFolder:GetChildren()) do
		for Name,Value in next, self.Settings do-- ;-;
			Highlight[Name] = Value
		end
	end
end

return highlightLib
