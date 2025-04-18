-- Attends que le jeu soit complètement chargé
wait()  -- Si tu veux attendre que toutes les ressources soient bien chargées avant de continuer
while not game:IsLoaded() do
    wait(1)  -- Attendre un peu avant de vérifier à nouveau
end

-- ID du jeu attendu
local expectedGameId = 72829404259339

-- Vérifie si tu es dans le bon jeu
if game.PlaceId == expectedGameId then
    -- Attends que PlayerGui soit disponible
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Crée un ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = playerGui

    -- Crée le Frame (panneau)
    local panel = Instance.new("Frame")
    panel.Parent = screenGui
    panel.Size = UDim2.new(0, 400, 0, 200)  -- Taille du panneau (400x200 pixels)
    panel.Position = UDim2.new(0.5, -200, 0.5, -100)  -- Centré à l'écran
    panel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- Couleur noire
    panel.BackgroundTransparency = 0.993  -- 0.7% de transparence
    panel.BorderRadius = UDim.new(0, 20)  -- Coins arrondis
    panel.Draggable = true  -- Permet de déplacer le panneau
    panel.Active = true  -- Le panneau peut recevoir des événements comme le drag

    -- Essayons de charger le script depuis l'URL raw
    local success, errorMsg = pcall(function()
        local scriptContent = game:HttpGet("https://raw.githubusercontent.com/Theo985/AnimeRangerX/main/test.lua")
        loadstring(scriptContent)()
    end)

    -- Si une erreur survient lors du chargement du script externe, on affiche un message d'erreur
    if not success then
        warn("Erreur lors du chargement du script externe : " .. errorMsg)
    end
end
