repeat wait() until game:IsLoaded()

local _,Msg = (function()
    return game:HttpGet('')
end)()
if not _ then return warn(Msg) end