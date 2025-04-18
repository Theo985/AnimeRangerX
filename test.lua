-- Fonction pour envoyer une notification
local function safeNotify(title, text, duration)
    while not pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
        })
    end) do wait() end
end

-- Affiche une notification indiquant que le script a démarré
safeNotify("🚀 Script Lancé", "Le script a bien démarré!", 5)

-- Attendre que le jeu soit bien chargé avant de continuer
while not game:IsLoaded() do
    wait(1)
end

-- ID du jeu attendu
local expectedGameId = 72829404259339

-- Vérifie si on est dans le bon jeu
if game.PlaceId == expectedGameId then
    -- Affiche une notification si on est dans le bon jeu
    safeNotify("🕹️ Jeu Correct", "Tu es dans le bon jeu !", 5)

    -- Attendre que PlayerGui soit disponible
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Crée un ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = playerGui

    -- Crée le Frame (panneau)
    local panel = Instance.new("Frame")
    panel.Parent = screenGui
    panel.Size = UDim2.new(0, 400, 0, 200)  -- Taille du panneau (400x200 pixels)
    panel.Position = UDim2.new(0.5, -200, 0.5, -100)  -- Centré à l'écran
    panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- Fond blanc
    panel.BackgroundTransparency = 0.8  -- 80% de transparence (20% opaque)
    panel.Draggable = true  -- Permet de déplacer le panneau
    panel.Active = true  -- Le panneau peut recevoir des événements comme le drag

    -- Ajouter un UICorner pour les coins arrondis (appliqué au Frame)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)  -- Coins arrondis de 20 pixels
    corner.Parent = panel

    -- Ajout d'un bouton pour rétracter le GUI
    local retractButton = Instance.new("TextButton")
    retractButton.Parent = panel
    retractButton.Size = UDim2.new(0, 100, 0, 30)
    retractButton.Position = UDim2.new(0.5, -50, 0, 170)  -- En bas au centre
    retractButton.Text = "Rétracter"
    retractButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    retractButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    
    -- Ajouter un UICorner au bouton (pour arrondir aussi ses coins)
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)  -- Coins arrondis de 10 pixels
    buttonCorner.Parent = retractButton

    -- Variable pour savoir si le panneau est rétracté ou non
    local isRetracted = false

    -- Fonction pour rétracter/agrandir le GUI
    retractButton.MouseButton1Click:Connect(function()
        if isRetracted then
            -- Rétablir la taille initiale
            panel.Size = UDim2.new(0, 400, 0, 200)
            retractButton.Text = "Rétracter"
        else
            -- Rétracter le panneau
            panel.Size = UDim2.new(0, 400, 0, 50)  -- Réduire la taille du panneau
            retractButton.Text = "Agrandir"
        end
        isRetracted = not isRetracted
    end)

    -- Essaie de charger le script depuis l'URL raw
    local success, errorMsg = pcall(function()
        local scriptContent = game:HttpGet("https://raw.githubusercontent.com/Theo985/AnimeRangerX/main/test.lua")
        loadstring(scriptContent)()  -- Exécute le script récupéré
    end)

    -- Si une erreur survient lors du chargement du script externe, on affiche un message d'erreur
    if not success then
        warn("Erreur lors du chargement du script externe : " .. errorMsg)
        safeNotify("❌ Erreur", "Erreur lors du chargement du script : " .. errorMsg, 5)
    else
        -- Si tout est bon, affiche une notification de succès
        safeNotify("✅ Script Chargé", "Le script a été chargé avec succès.", 5)
    end
else
    -- Si l'ID du jeu ne correspond pas, affiche une notification d'erreur
    safeNotify("❌ Jeu Incorrect", "Tu n'es pas dans le bon jeu !", 5)
end
