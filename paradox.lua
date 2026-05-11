if not game:IsLoaded() then game.Loaded:Wait() end
local url = (game.PlaceId == 9870517705) 
    and "https://raw.githubusercontent.com/whodunitwww/cerberus-helpers/refs/heads/main/paradox/lobby_script.lua" 
    or "https://raw.githubusercontent.com/safetrademarketplace/scripts/refs/heads/main/paradox_script.lua"
loadstring(game:HttpGet(url))()
