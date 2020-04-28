require("libraries/timers")
require("utils")

LinkLuaModifier("mod__repel", "modifiers/mod__repel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mod__lamp", "modifiers/mod__lamp", LUA_MODIFIER_MOTION_NONE)

WotW = class({})


function Precache(ctx)
    PrecacheUnitByNameSync("npc_dota_hero_juggernaut", ctx)
    PrecacheResource("model", "models/items/courier/xianhe_stork/xianhe_stork.vmdl", ctx)
    PrecacheResource("model", "models/items/courier/xianhe_stork/xianhe_stork_flying.vmdl", ctx)

    -- Init
    PrecacheResource("particle", "particles/status_fx/status_effect_omnislash.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_legion_commander.vsndevts", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_items.vsndevts", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_stack.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/items/oracle/ti9_cache_oracle_grand_hierophant/ti9_cache_oracle_ambient_weapon_ball_rays.vpcf", ctx)

    -- Shield
    PrecacheResource("particle", "particles/econ/items/lanaya/ta_ti9_immortal_shoulders/ta_ti9_refraction.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_templar_assassin.vsndevts", ctx)

    -- Blink
    PrecacheResource("particle", "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_blink_start_v2.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_blink_end_v2.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_earthshaker.vsndevts", ctx)

    -- Smite
    PrecacheResource("particle", "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_magnataur.vsndevts", ctx)

    -- Dagger
    PrecacheResource("particle", "particles/econ/items/phantom_assassin/pa_ti8_immortal_head/pa_ti8_immortal_stifling_dagger_model.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_invoker.vsndevts", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_phantom_assassin.vsndevts", ctx)

    -- Tempo
    PrecacheResource("particle", "particles/items2_fx/refresher.vpcf", ctx)
end

-- Create the game mode when we activate
function Activate()
    GameRules.AddonTemplate = WotW()
    GameRules.AddonTemplate:InitGameMode()
end

function WotW:InitGameMode()
    print("=:: Hardcore Reflex  ::=")
    self:InitRules()
    Convars:RegisterCommand("respawn_all", Dynamic_Wrap(self, "RespawnAll"), nil, FCVAR_CHEAT)

    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(self, "OnGameRulesStateChange"), self)
    ListenToGameEvent("dota_on_hero_finish_spawn", Dynamic_Wrap(self, "OnHeroFinishSpawn"), self)
    ListenToGameEvent("npc_spawned", Dynamic_Wrap(self, "OnNPCSpawned"), self)

    self.spawns = {
        [DOTA_TEAM_GOODGUYS] = Entities:FindAllByClassname("info_player_start_goodguys"),
        [DOTA_TEAM_BADGUYS] = Entities:FindAllByClassname("info_player_start_badguys")
    }

    GameRules:GetGameModeEntity():SetThink("OnThink", self, "GlobalThink", 0.1)
end

function WotW:InitRules()
    GameRules.ROUND_NUMBER = 0
    GameRules.POINTS_TO_WIN = 15
    GameRules.TEAM_POINTS = {
        [DOTA_TEAM_GOODGUYS] = 0,
        [DOTA_TEAM_BADGUYS] = 0
    }
    GameRules.HEROES = {
        [DOTA_TEAM_GOODGUYS] = {},
        [DOTA_TEAM_BADGUYS] = {}
    }
    GameRules.ROUND_IN_PROGRESS = false
    GameRules.PREGAME_TIME = 15
    GameRules.ROUND_END_DELAY = 2
    GameRules.ROUND_START_DELAY = 5
    GameRules.TEAM_COLOURS = {
        [DOTA_TEAM_GOODGUYS] = Vector(75, 125, 250),
        [DOTA_TEAM_BADGUYS] = Vector(250, 75, 125)
    }

    for _, team in pairs(GetTeams()) do
        SetTeamCustomHealthbarColor(team, GameRules.TEAM_COLOURS[team].x, GameRules.TEAM_COLOURS[team].y, GameRules.TEAM_COLOURS[team].z)
        GameRules:SetCustomGameTeamMaxPlayers(team, 5)
    end

    GameRules:SetCustomGameSetupAutoLaunchDelay(15)
    GameRules:EnableCustomGameSetupAutoLaunch(true)
    --    GameRules:LockCustomGameSetupTeamAssignment(true)

    GameRules:SetPreGameTime(GameRules.PREGAME_TIME)

    GameRules:SetFirstBloodActive(false)
    GameRules:SetGoldPerTick(0)
    GameRules:SetGoldTickTime(0)
    GameRules:SetHeroRespawnEnabled(false)
    GameRules:SetStartingGold(0)
    GameRules:SetUseBaseGoldBountyOnHeroes(true)
    GameRules:SetUseCustomHeroXPValues(true)

    local gamemode = GameRules:GetGameModeEntity()
    gamemode:SetAnnouncerDisabled(true)
    gamemode:SetBuybackEnabled(false)
    gamemode:SetCustomGameForceHero("npc_dota_hero_juggernaut")
    gamemode:SetRecommendedItemsDisabled(true)
    gamemode:SetStashPurchasingDisabled(true)
    gamemode:SetCameraDistanceOverride(1300)
end

-- Evaluate the state of the game
function WotW:OnThink()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        if GameRules.ROUND_IN_PROGRESS then
            self:CheckVictoryConditions()
        end
    elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return nil
    end
    return 1
end

function WotW:OnGameRulesStateChange()
    local new_state = GameRules:State_Get()

    if new_state == DOTA_GAMERULES_STATE_PRE_GAME then
        RemoveFOW(GameRules.PREGAME_TIME)
        self.LAMP = CreateUnitByName("npc_dota_lamp", Vector(0, 0, 0), false, nil, nil, DOTA_TEAM_NEUTRALS)
        CustomNetTables:SetTableValue("game_state", "round_info", { name = "PREGAME" })
        CustomNetTables:SetTableValue("game_state", "target_points", { points_to_win = GameRules.POINTS_TO_WIN })
        CustomNetTables:SetTableValue("game_state", "team_points", { good_points = GameRules.TEAM_POINTS[DOTA_TEAM_GOODGUYS], bad_points = GameRules.TEAM_POINTS[DOTA_TEAM_BADGUYS] })
    elseif new_state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        self:StartNewRound()
    end
end

function WotW:OnHeroFinishSpawn(keys)
    print("OnHeroFinishSpawn")
    local hero = EntIndexToHScript(keys.heroindex)
    if hero ~= nil then
        if not hero.first_spawned then
            hero.frist_spawned = true

            -- Acquire a spawn point
            local team_spawns = self.spawns[hero:GetTeam()]
            local random_index = math.random(1, #team_spawns)
            hero.spawn = team_spawns[random_index]
            table.remove(team_spawns, random_index)
            hero:SetOrigin(hero.spawn:GetOrigin())

            -- Remove TP
            local starting_tp = hero:FindItemInInventory("item_tpscroll")
            if starting_tp then
                UTIL_Remove(starting_tp)
            end

            -- Skill abilities
            for i = 0, 4 do
                local ability = hero:GetAbilityByIndex(i)
                if ability ~= nil then
                    ability:SetLevel(1)
                end
            end

            local item = CreateItem("item_quelling_blade", hero, hero)
            hero:AddItem(item)
            local item2 = CreateItem("item_refresher_datadriven", hero, hero)
            hero:AddItem(item2)
            

            local colour = GameRules.TEAM_COLOURS[hero:GetTeam()]
            PlayerResource:SetCustomPlayerColor(hero:GetPlayerID(), colour.x, colour.y, colour.z)
            table.insert(GameRules.HEROES[hero:GetTeam()], hero)

            hero:AddNewModifier(hero, nil, "mod__repel", { duration = GameRules.PREGAME_TIME + 0.5 })
        end
    end
end

function WotW:OnNPCSpawned(keys)
    print("OnNPCSpawned")
    local entity = EntIndexToHScript(keys.entindex)
    if entity ~= nil then
        if entity:IsRealHero() then
            if entity.spawn ~= nil then
                entity:SetOrigin(entity.spawn:GetOrigin())
            end

            entity:AddNewModifier(entity, nil, "mod__repel", { duration = 0.5 })
         elseif entity:GetUnitName() == "npc_dota_lamp" then
             entity:SetAngles(0, 270, 0)
             entity:AddNewModifier(entity, nil, "mod__lamp", nil)
             entity:StartGesture(ACT_DOTA_IDLE)
        end
    end
end

function WotW:RespawnAll()
    print("RespawnAll")
    local heroes = Entities:FindAllByClassname("npc_dota_hero_juggernaut")
    for _, hero in pairs(heroes) do
        hero:RespawnHero(false, false)
        RefreshAbilities(hero)
        ProjectileManager:ProjectileDodge(hero)
    end
end

function WotW:StartNewRound()
    print("StartNewRound")

    GameRules.ROUND_NUMBER = GameRules.ROUND_NUMBER + 1
    self:RespawnAll()
    EmitGlobalSound("Hero_LegionCommander.PressTheAttack")
    CustomNetTables:SetTableValue("game_state", "round_info", { name = "ROUND " .. GameRules.ROUND_NUMBER })
    GameRules.ROUND_IN_PROGRESS = true
end

function WotW:GetTeamAlive()
    local team_alive = {
        [DOTA_TEAM_GOODGUYS] = false,
        [DOTA_TEAM_BADGUYS] = false
    }
    for _, team in pairs(GetTeams()) do
        if #GameRules.HEROES[team] > 0 then
            for _, hero in pairs(GameRules.HEROES[team]) do
                team_alive[team] = team_alive[team] or hero:IsAlive()
            end
        else
            team_alive[team] = true
        end
    end
    return team_alive
end

function WotW:HasRoundEnded()
    local team_alive = self:GetTeamAlive()

    return not team_alive[DOTA_TEAM_GOODGUYS] or not team_alive[DOTA_TEAM_BADGUYS]
end

function WotW:CheckVictoryConditions()
    if self:HasRoundEnded() then
        GameRules.ROUND_IN_PROGRESS = false

        -- Wait before declaring winner in case of draw
        Timers:CreateTimer(GameRules.ROUND_END_DELAY, function()
            RemoveFOW(GameRules.ROUND_START_DELAY)

            local team_alive = self:GetTeamAlive()
            if not team_alive[DOTA_TEAM_GOODGUYS] and not team_alive[DOTA_TEAM_BADGUYS] then
                print("RoundDraw")
            else
                for _, team in pairs(GetTeams()) do
                    if team_alive[team] then
                        print("RoundWin", team)
                        GameRules.TEAM_POINTS[team] = GameRules.TEAM_POINTS[team] + 1
                        if GameRules.TEAM_POINTS[team] == GameRules.POINTS_TO_WIN then
                            GameRules:SetGameWinner(team)
                            return nil
                        end
                    end

                    for _, hero in pairs(GameRules.HEROES[team]) do
                        if hero:IsAlive() then
                            local index = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
                            ParticleManager:ReleaseParticleIndex(index)
                            EmitGlobalSound("Hero_LegionCommander.Duel.Victory")
                        end
                    end
                end
            end
            CustomNetTables:SetTableValue("game_state", "team_points", { good_points = GameRules.TEAM_POINTS[DOTA_TEAM_GOODGUYS], bad_points = GameRules.TEAM_POINTS[DOTA_TEAM_BADGUYS] })

            Timers:CreateTimer(GameRules.ROUND_START_DELAY, function()
                self:StartNewRound()
            end)
        end)
    end
end