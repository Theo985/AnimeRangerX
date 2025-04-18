local expectedGameId = 72829404259339

if game.PlaceId == expectedGameId then
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local panel = Instance.new("Frame")
    panel.Parent = screenGui
    panel.Size = UDim2.new(0, 400, 0, 200)  -- Taille du panneau (400x200)
    panel.Position = UDim2.new(0.5, -200, 0.5, -100)  
    panel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  
    panel.BackgroundTransparency = 0.993  
    panel.BorderRadius = UDim.new(0, 20) 
    panel.Draggable = true 
    panel.Active = true  
end
