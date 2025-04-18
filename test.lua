-- ID du jeu attendu
local expectedGameId = 72829404259339

-- Vérifie si l'ID du jeu actuel est celui que tu veux
if game.PlaceId == expectedGameId then
    -- Attends que PlayerGui soit disponible
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Crée un ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = playerGui

    -- Crée le Frame (le panneau)
    local panel = Instance.new("Frame")
    panel.Parent = screenGui
    panel.Size = UDim2.new(0, 400, 0, 200)  -- Taille du panneau (400x200 pixels)
    panel.Position = UDim2.new(0.5, -200, 0.5, -100)  -- Centré à l'écran
    panel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- Couleur noire
    panel.BackgroundTransparency = 0.993  -- 0.7% de transparence
    panel.BorderRadius = UDim.new(0, 20)  -- Coins arrondis
    panel.Draggable = true  -- Permet de déplacer le panneau
    panel.Active = true  -- Le panneau peut recevoir des événements comme le drag

    -- Tu peux ajouter plus d'éléments à ce panneau, comme des textes ou des boutons
end
