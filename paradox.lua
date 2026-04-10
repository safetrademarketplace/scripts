if not game:IsLoaded() then game.Loaded:Wait() end
local url = (game.PlaceId == 9870517705) 
    and "https://raw.githubusercontent.com/whodunitwww/cerberus-helpers/refs/heads/main/paradox/lobby_script.lua" 
    or "https://api.luarmor.net/files/v4/loaders/eb151426cc40bf2ea1713bc4df3c50c9.lua"
loadstring(game:HttpGet(url))()
