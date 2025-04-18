-- Fonction pour afficher une notification dans le jeu
local function safeNotify(title, text, duration)
    while not pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
        })
    end) do wait() end
end

-- Fonction pour copier dans le presse-papier
local function copyToClipboard(text)
    setclipboard(text)  -- Copie le texte dans le presse-papier
end

-- Attends que le jeu soit complètement chargé
while not game:IsLoaded() do
    wait(1)  -- Attendre un peu avant de vérifier à nouveau
end

-- ID du jeu attendu
local expectedGameId = 72829404259339

-- Vérifie si tu es dans le bon jeu
if game.PlaceId == expectedGameId then
    -- Crée un ScreenGui pour afficher l'interface
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = playerGui

    -- Crée un panneau (Frame) principal
    local panel = Instance.new("Frame")
    panel.Parent = screenGui
    panel.Size = UDim2.new(0, 400, 0, 300)  -- Taille du panneau (400x300 pixels)
    panel.Position = UDim2.new(0.5, -200, 0.5, -150)  -- Centré à l'écran
    panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- Fond blanc
    panel.BackgroundTransparency = 0.7  -- 70% de transparence
    panel.BorderSizePixel = 0  -- Pas de bordure
    panel.Active = true  -- Permet de déplacer le panneau
    panel.Draggable = true  -- Le panneau peut être déplacé

    -- Bouton de rétraction
    local toggleButton = Instance.new("TextButton")
    toggleButton.Parent = panel
    toggleButton.Size = UDim2.new(0, 30, 0, 30)
    toggleButton.Position = UDim2.new(1, -30, 0, 0)
    toggleButton.Text = "-"
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- Couleur du bouton
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)

    -- Crée un bloc de texte pour afficher des informations
    local infoBlock = Instance.new("Frame")
    infoBlock.Parent = panel
    infoBlock.Size = UDim2.new(0, 240, 0, 150)  -- Taille du bloc d'information
    infoBlock.Position = UDim2.new(0, 50, 0, 60)  -- Positionnement à l'intérieur du panneau
    infoBlock.BackgroundTransparency = 0.8  -- 80% transparent
    infoBlock.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- Fond noir
    infoBlock.BorderSizePixel = 0  -- Pas de bordure

    -- Texte "Owner : Kondax"
    local ownerLabel = Instance.new("TextLabel")
    ownerLabel.Parent = infoBlock
    ownerLabel.Size = UDim2.new(1, 0, 0, 30)
    ownerLabel.Text = "Owner : Kondax"
    ownerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ownerLabel.BackgroundTransparency = 1

    -- Texte "Game : <Nom du jeu ou ID>"
    local gameLabel = Instance.new("TextLabel")
    gameLabel.Parent = infoBlock
    gameLabel.Size = UDim2.new(1, 0, 0, 30)
    gameLabel.Position = UDim2.new(0, 0, 0, 30)
    local gameId = game.PlaceId or "ID non disponible"  -- Si PlaceId est nil, utilise un message par défaut
    gameLabel.Text = "Game : " .. tostring(gameId)  -- Utilise tostring pour éviter l'erreur de concaténation
    gameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    gameLabel.BackgroundTransparency = 1

    -- Texte "FPS : <FPS actuel>"
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Parent = infoBlock
    fpsLabel.Size = UDim2.new(1, 0, 0, 30)
    fpsLabel.Position = UDim2.new(0, 0, 0, 60)
    fpsLabel.Text = "FPS : " .. math.floor(game:GetService("Stats").PerformanceStats.Fps)  -- Affiche le FPS actuel
    fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    fpsLabel.BackgroundTransparency = 1

    -- Bouton Discord
    local discordButton = Instance.new("TextButton")
    discordButton.Parent = infoBlock
    discordButton.Size = UDim2.new(0, 240, 0, 30)
    discordButton.Position = UDim2.new(0, 0, 0, 120)
    discordButton.Text = "Discord Link"
    discordButton.BackgroundColor3 = Color3.fromRGB(0, 122, 255)  -- Bleu de Discord
    discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)

    discordButton.MouseButton1Click:Connect(function()
        local discordLink = "https://discord.gg/tonliendiscord"  -- Remplace par ton lien Discord
        copyToClipboard(discordLink)  -- Copie le lien Discord dans le presse-papier
        safeNotify("✅ Copié", "Le lien Discord a été copié dans ton presse-papier.", 5)
    end)

    -- Fonction pour rétracter/agrandir le panneau
    local isCollapsed = false
    toggleButton.MouseButton1Click:Connect(function()
        if isCollapsed then
            panel.Size = UDim2.new(0, 400, 0, 300)  -- Taille d'origine
            toggleButton.Text = "-"
            isCollapsed = false
        else
            panel.Size = UDim2.new(0, 30, 0, 30)  -- Taille réduite à une barre
            toggleButton.Text = "+"
            isCollapsed = true
        end
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
    -- Si ce n'est pas le bon jeu, on kick le joueur
    game.Players.LocalPlayer:Kick("Ce script n'est autorisé que dans le jeu avec l'ID : " .. expectedGameId)
end
