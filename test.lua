-- ID du jeu que tu veux détecter
local expectedGameId = 72829404259339

-- Vérifie si l'ID du jeu actuel correspond à l'ID attendu
if game.PlaceId ~= expectedGameId then
    -- Si l'ID ne correspond pas, on kick le joueur
    game.Players.LocalPlayer:Kick("Vous n'êtes pas dans le bon jeu !")
end
