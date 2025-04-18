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

    -- Crée le Frame principal (panneau)
    local panel = Instance.new("Frame")
    panel.Parent = screenGui
    panel.Size = UDim2.new(0, 300, 0, 500)  -- Taille du panneau (300x500 pixels)
    panel.Position = UDim2.new(0, 0, 0.5, -250)  -- Centré verticalement à gauche de l'écran
    panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- Fond blanc
    panel.BackgroundTransparency = 0.7  -- 70% de transparence (30% opaque)
    panel.Draggable = true  -- Permet de déplacer le panneau
    panel.Active = true  -- Le panneau peut recevoir des événements comme le drag

    -- Ajouter un UICorner pour les coins arrondis (appliqué au Frame principal)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)  -- Coins arrondis de 20 pixels
    corner.Parent = panel

    -- Crée un menu vertical à gauche (les onglets)
    local menu = Instance.new("Frame")
    menu.Parent = panel
    menu.Size = UDim2.new(0, 50, 1, 0)  -- Menu vertical à gauche
    menu.BackgroundColor3 = Color3.fromRGB(50, 50, 50)  -- Fond gris foncé
    menu.BackgroundTransparency = 0.5  -- Légère transparence
    menu.BorderSizePixel = 0  -- Supprime les bordures

    -- Ajout d'onglets (boutons) dans le menu
    local onglet1 = Instance.new("TextButton")
    onglet1.Parent = menu
    onglet1.Size = UDim2.new(1, 0, 0, 50)
    onglet1.Position = UDim2.new(0, 0, 0, 0)
    onglet1.Text = "Main"  -- Onglet 1 -> Main
    onglet1.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    onglet1.TextColor3 = Color3.fromRGB(255, 255, 255)

    local onglet2 = Instance.new("TextButton")
    onglet2.Parent = menu
    onglet2.Size = UDim2.new(1, 0, 0, 50)
    onglet2.Position = UDim2.new(0, 0, 0, 50)
    onglet2.Text = "Play"  -- Onglet 2 -> Play
    onglet2.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    onglet2.TextColor3 = Color3.fromRGB(255, 255, 255)

    -- Applique un UICorner pour arrondir les coins des boutons
    local corner1 = Instance.new("UICorner")
    corner1.CornerRadius = UDim.new(0, 10)  -- Coins arrondis de 10 pixels
    corner1.Parent = onglet1

    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 10)  -- Coins arrondis de 10 pixels
    corner2.Parent = onglet2

    -- Crée un bouton pour rétracter le GUI
    local retractButton = Instance.new("TextButton")
    retractButton.Parent = panel
    retractButton.Size = UDim2.new(0, 50, 0, 50)
    retractButton.Position = UDim2.new(1, -50, 0, 0)  -- Bouton rétracter en haut à droite
    retractButton.Text = "-"
    retractButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    retractButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    retractButton.BorderSizePixel = 0

    -- Ajouter un UICorner au bouton (pour arrondir ses coins)
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = retractButton

    -- Vérification et initialisation de la variable isRetracted
    local isRetracted = false

    -- Fonction pour rétracter/agrandir le GUI
    retractButton.MouseButton1Click:Connect(function()
        if not panel then
            warn("Panel not found")
            return
        end
        if not retractButton then
            warn("RetractButton not found")
            return
        end

        if isRetracted then
            -- Restaurer la taille originale
            panel.Size = UDim2.new(0, 300, 0, 500)
            retractButton.Text = "-"
        else
            -- Rétracter le panneau à une barre (en largeur)
            panel.Size = UDim2.new(0, 50, 0, 500)  -- Réduire la largeur du panneau
            retractButton.Text = "+"
        end
        isRetracted = not isRetracted
    end)

    -- Fonction pour copier le lien Discord dans le presse-papier
    local function copyToClipboard(text)
        -- Ceci utilise une méthode pour copier un texte dans le presse-papier
        local success, err = pcall(function()
            setclipboard(text)  -- setclipboard est une méthode fournie par Roblox pour mettre dans le presse-papier
        end)

        if not success then
            warn("Erreur lors de la copie du texte dans le presse-papier : " .. err)
        end
    end

    -- Crée un "bloc de texte" pour afficher des informations sur le jeu
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
    gameLabel.Text = "Game : " .. game.PlaceId  -- Affiche l'ID du jeu
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
end
