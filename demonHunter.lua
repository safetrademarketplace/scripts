if not game:IsLoaded() then game.Loaded:Wait() end

if game.PlaceId ~= 136364146980997 then
    task.wait(2)
end

loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/b7bd020e5240088272d16cb46b61d741.lua"))()
