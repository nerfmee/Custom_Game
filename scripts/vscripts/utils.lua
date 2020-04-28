function GetTeams()
    return {
        DOTA_TEAM_GOODGUYS,
        DOTA_TEAM_BADGUYS
    }
end

function GetEnemy(team)
    if team == DOTA_TEAM_GOODGUYS then
        return DOTA_TEAM_BADGUYS
    elseif team == DOTA_TEAM_BADGUYS then
        return DOTA_TEAM_GOODGUYS
    end
end

function RemoveFOW(duration)
    for _, team in pairs(GetTeams()) do
        AddFOWViewer(team, Vector(0, 0, 0), 20000, duration, false)
    end
end

function RefreshAbilities(hero)
    for i = 0, 4 do
        local ability = hero:GetAbilityByIndex(i)
        if ability ~= nil then
            ability:EndCooldown()
        end
    end
end