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
    local Main = Instance.new("TextButton")
    Main.Parent = menu
    Main.Size = UDim2.new(1, 0, 0, 50)
    Main.Position = UDim2.new(0, 0, 0, 0)
    Main.Text = "Main"  -- Onglet 1 -> Main
    Main.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Main.TextColor3 = Color3.fromRGB(255, 255, 255)

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
