_addon.commands = {'george', 'gg'}

require('tables')
require('strings')
require('logger')
require('sets')
local socket = require('socket')

res = require('resources')
config = require('config')
local aid = ''
local adist = 40
local aindex = ''

local ax = 0
local ay = 0
local az = 0

local function has_value(tab, val)
    if (tab == nil) then
        -- print('we have nil')
        return true
    end
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

casting = 0
debuff = {2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 18, 19, 20, 21, 30, 31, 128, 129, 130, 131, 132, 133, 134, 135,
          136, 137, 138, 139, 140, 141, 142, 144, 145, 146, 147, 148, 149, 167, 174, 175, 189, 193, 194}
erase = {11, 12, 134, 135, 21, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 144, 145, 146,
         147, 148, 149, 167, 174, 175}

cursed = {9, 15, 20, 30}
-- Triggers on player status change. This only triggers for the following statuses:
-- Idle, Engaged, Resting, Dead, Zoning
local scNum = 0
local job = windower.ffxi.get_player()
windower.register_event('tp change', function(new, old)
    if new > 1000 then
        if job.main_job == 'RDM' then
            casting = 0
            windower.send_command('input /ws "Chant du Cygne" <t>')
            -- windower.send_command('input /ws "Savage Blade" <t>')
            -- if scNum == 0 then  
            --     windower.send_command('input /ws "Red Lotus Blade" <t>')
            --     scNum = 1
            -- else
            --     windower.send_command('input /ws "Seraph Blade" <t>')
            --     scNum = 0
            -- end

        end
        if job.main_job == 'PLD' then
            windower.send_command('input /ws "Chant du Cygne" <t>')
            casting = 0
        end
        if job.main_job == 'BLU' then
            casting = 0
            windower.send_command('input /ws "Chant du Cygne" <t>')
        end
        if job.main_job == 'THF' then
            windower.send_command('input /ws "Evisceration" <t>')
        end
        if job.main_job == 'MNK' then
            if scNum == 0 then
                windower.send_command('input /ws "Ascetic\'s Fury" <t>')
                scNum = 1
            elseif scNum == 1 then
                windower.send_command('input /ws "Victory Smite" <t>')
                scNum = 2
            elseif scNum == 2 then
                windower.send_command('input /ws "Victory Smite" <t>')
                scNum = 0
            end
        end
        if job.main_job == 'SAM' then
            if scNum == 0 then
                windower.send_command('input /ws "Tachi: Yukikaze" <t>')
                scNum = 1
            elseif scNum == 1 then
                windower.send_command('input /ws "Tachi: Gekko" <t>')
                scNum = 0
            elseif scNum == 2 then
                windower.send_command('input /ws "Tachi: Ageha" <t>')
                scNum = 0
            end
        end
        if job.main_job == 'NIN' then
            windower.send_command('input /ws "Blade: Ku" <t>')
        end
    end
end)

healerCasting = 0

-- local moblist={"Eschan Bugard","Eschan Tarichuk","Immanibugard","Apex Eft","Bight Uragnite",}
local moblist = {"Apex Eft"}
local skip = 0

windower.register_event('prerender', function()
    ab = windower.ffxi.get_ability_recasts()
    -- print(casting)
    party = windower.ffxi.get_party()
    if party.p3.mpp < 10 then
        skip = 1
    end
    if party.p3.mpp > 90 then
        skip = 0
    end
    s = windower.ffxi.get_mob_by_target('me')
    t = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')
    -- for each,value in pairs(windower.ffxi.get_player().buffs) do
    --     -- windower.send_command('input /echo debuff# '..value)
    --     -- windower.send_command('input /echo debuff# '..each..' '..value)
    --     if has_value(debuff, value) then
    --         if has_value(cursed,value) then
    --             windower.send_command('send Tuxxy /ma Cursna '..job.name)
    --             socket.sleep(1.5)
    --         end
    --         if has_value(erase,value) then
    --             windower.send_command('send Tuxxy /ma Erase '..job.name)
    --             socket.sleep(1.5)
    --         end
    --         if value == 2 or value == 19 then
    --             windower.send_command('send Tuxxy /ma Cure '..job.name)
    --             socket.sleep(1.5)
    --         end
    --         if value == 3 then
    --             windower.send_command('send Tuxxy /ma Poisona '..job.name)
    --             socket.sleep(1.5)
    --         end
    --         if value == 4 then
    --             windower.send_command('send Tuxxy /ma Paralyna '..job.name)
    --             socket.sleep(1.5)
    --         end
    --         if value == 5 then
    --             windower.send_command('send Tuxxy /ma Blindna '..job.name)
    --             socket.sleep(1.5)
    --         end
    --         if value == 6 then
    --             windower.send_command('send Tuxxy /ma Silena '..job.name)
    --             socket.sleep(1.5)
    --         end
    --         if value == 7 then
    --             windower.send_command('send Tuxxy /ma Stona '..job.name)
    --             socket.sleep(1.5)
    --         end
    --         if value == 8 then
    --             windower.send_command('send Tuxxy /ma Viruna '..job.name)
    --             socket.sleep(1.5)
    --         end
    --     end
    -- end

    -- reset movement keys
    windower.send_command('setkey w up;')
    windower.send_command('setkey s up;')
    windower.send_command('setkey tab up;')
    windower.send_command('setkey f8 up;')
    -- we have a target and we are in attack mode
    
        if (t and (s.status == 1)) then
            if t.distance:sqrt() > 2.3 then
                windower.send_command('setkey s down;')
                windower.send_command('setkey s up;')
                windower.send_command('setkey w down;')
            else
                windower.send_command('setkey w up;')
            end

            if t.distance:sqrt() < 1.8 then
                windower.send_command('setkey s down;')
            else
                windower.send_command('setkey s up;')
            end

            if job.main_job == 'RDM' then
                ab = windower.ffxi.get_ability_recasts()
                if not has_value(windower.ffxi.get_player().buffs, 419) and (ab[50] == 0) then
                    windower.send_command('input /ja \"Composure\" <me>')
                end
                -- check buffs

                if (casting == 0) then
                    coroutine.sleep(2)
                    if not has_value(windower.ffxi.get_player().buffs, 33) then
                        casting = 1
                        windower.send_command('input /ma \"Haste II\" <me>')
                    end
                    if not has_value(windower.ffxi.get_player().buffs, 95) then
                        casting = 2
                        windower.send_command('input /ma \"Enblizzard\" <me>')
                    end

                    if not has_value(windower.ffxi.get_player().buffs, 43) then
                        casting = 3
                        windower.send_command('input /ma \"Refresh II\" <me>')
                    end

                    if not has_value(windower.ffxi.get_player().buffs, 432) then
                        casting = 4
                        windower.send_command('input /ma \"Temper\" <me>')
                    end

                end
            end

            if job.main_job == 'PLD' then
                -- ab = windower.ffxi.get_ability_recasts()
                -- if not has_value(windower.ffxi.get_player().buffs, 419) and (ab[50] == 0) then
                --     windower.send_command('input /ja \"Composure\" <me>')
                -- end
                -- check buffs

                if (casting == 0) then
                    -- coroutine.sleep(2)
                    -- if not has_value(windower.ffxi.get_player().buffs, 33) then
                    --     casting = 1
                    --     windower.send_command('input /ma \"Haste II\" <me>')
                    -- end
                    if not has_value(windower.ffxi.get_player().buffs, 274) then
                        windower.send_command('input /ma \"Enlight II\" <me>')
                        casting = 1
                    end

                    -- if not has_value(windower.ffxi.get_player().buffs, 43) then
                    --     casting = 3
                    --     windower.send_command('input /ma \"Refresh II\" <me>')
                    -- end

                    -- if not has_value(windower.ffxi.get_player().buffs, 432) then
                    --     casting = 4
                    --     windower.send_command('input /ma \"Temper\" <me>')
                    -- end

                end
            end

            if job.main_job == 'BLU' then
                --     -- if not has_value(windower.ffxi.get_player().buffs, 419) then
                --     --     windower.send_command('input /ja \"Composure\" <me>')
                --     -- end
                --     -- check buffs

                if (casting == 0) then
                    if not has_value(windower.ffxi.get_player().buffs, 33) then
                        casting = 1
                        windower.send_command('input /ma \"Erratic Flutter\" <me>')
                    end
                    if not has_value(windower.ffxi.get_player().buffs, 604) then
                        if (ab[81] == 0) then
                            casting = 1
                            -- windower.send_command('setkey  down;')
                            windower.send_command(
                                'input /ja \"Unbridled Learning\" <me> <wait1>;input /ma \"Mighty Guard\" <me>')
                            -- windower.send_command('input /ma \"Mighty Guard\" <me>')
                        end
                    end

                    -- if not has_value(windower.ffxi.get_player().buffs, 43) then
                    --     windower.send_command('input /ma \"Refresh II\" <me>')
                    --     casting = 1
                    -- end
                else
                    casting = 0
                end
            end

            if job.main_job == 'SAM' then
                if checkrecastability(138) == 0 then
                    casting = 0
                    if ((not has_value(windower.ffxi.get_player().buffs, 353)) and (checkrecastability(138) == 0)) then
                        if casting == 0 then
                            windower.send_command('input /ja \"Hasso\" <me>')
                            casting = 1
                        end
                    end
                end

            end

            if job.main_job == 'MNK' then
                --     if not has_value(windower.ffxi.get_player().buffs, 56) then
                --         windower.send_command('input /ja \"Berserk\" <me>')
                --     end
                -- if not has_value(windower.ffxi.get_player().buffs, 59) then
                --     windower.send_command('input /ja \"Focus\" <me>')
                -- end
                -- if not has_value(windower.ffxi.get_player().buffs, 60) then
                --     windower.send_command('input /ja \"Dodge\" <me>')
                -- end
                --     if not has_value(windower.ffxi.get_player().buffs, 68) then
                --         windower.send_command('input /ja \"Warcry\" <me>')
                -- end
                -- if not has_value(windower.ffxi.get_player().buffs, 461) then
                --     windower.send_command('input /ja \"Impetus\" <me>')
                -- end
            end

            if job.main_job == 'THF' then
                -- if checkrecastability(4) == 0 then
                --     windower.send_command('input /ja "Aggressor" <me>')
                -- end
                -- if checkrecastability(2) == 0 then
                --     windower.send_command('input /ja "Warcry" <me>')
                -- end
                -- if checkrecastability(1) == 0 then
                --     windower.send_command('input /ja "Berserk" <me>')
                -- end
                -- if checkrecastability(68) == 0 then
                --     windower.send_command('input /ja "Feint" <me>')
                -- end
            end

        else
        end

        -- get new target
        if skip == 0 then
        if (s.status == 0 and t == nil) then
            casting = 0
            aid = ''
            adist = 40
            aindex = ''
            -- find closest?
            local list = windower.ffxi.get_mob_array()
            -- get closest mob id
            for each, val in pairs(list) do
                if has_value(moblist, val.name) and val.hpp == 100 then
                    if val.distance:sqrt() < adist then
                        aid = val.id
                        aindex = val.index
                        adist = val.distance:sqrt()
                        ax = val.x
                        ay = val.y
                        az = val.z
                    end
                else
                end
            end
            -- target closest mob

            windower.ffxi.run(ax - s.x, ay - s.y, az - s.z)
            windower.send_command('input /targetbnpc')
            windower.send_command('setkey f8 up;')
        end

        -- refresh target
        if (s.status == 0 and t) then
            local t = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')
            if (has_value(moblist, t.name) and (t.id == aid)) then
                windower.send_command('input /follow')
                if t.distance:sqrt() < 30 then
                    windower.send_command('input /attack')
                end
            else
                aid = ''
                adist = 40
                aindex = ''
                ax = 0
                ay = 0
                az = 0
                -- find closest?
                local list = windower.ffxi.get_mob_array()
                local t = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')

                -- get closest mob id
                for each, val in pairs(list) do
                    if has_value(moblist, val.name) and val.hpp == 100 then
                        if val.distance:sqrt() < adist then
                            aid = val.id
                            aindex = val.index
                            adist = val.distance:sqrt()
                            ax = val.x
                            ay = val.y
                            az = val.z
                        end
                    else
                    end
                end
                -- target closest mob
                -- run towards closest mob
                -- print(ax,ay,az)
                windower.ffxi.run(ax - s.x, ay - s.y, az - s.z)
                windower.send_command('input /targetbnpc')
                -- windower.send_command('setkey tab down;')
                -- windower.send_command('setkey tab up;')
            end

        end
    end
end)

windower.register_event('action message',
    function(actor_id, target_id, actor_index, target_index, message_id, param_1, param_2, param_3)
        if message_id == 17 then
            casting = 1
        end
        if message_id == 18 then
            casting = 1
        end

    end)

function checkrecast(spellid)
    local recasts = windower.ffxi.get_spell_recasts()
    for eac, val in pairs(recasts) do
        -- print(eac,val)
        if eac == spellid then
            return val
        end
    end
end

function checkrecastability(spellid)
    local recasts = windower.ffxi.get_ability_recasts()
    for eac, val in pairs(recasts) do
        if eac == spellid then
            -- if checkrecastability(spellid) == 0 then
            return val
            -- end
        end
    end
end

local tierHigh = 'V'
local tierNext = 'IV'
function castMB(scid)
    local recasts = windower.ffxi.get_spell_recasts()
    if job == 'RDM' or job == 'BLM' then
        tierHigh = 'V'
        tierNext = "IV"
    end
    if scid == 288 or scid == 291 or scid == 301 or scid == 767 or scid == 769 then
        if checkrecast(167) == 0 then
            casting = 5
            windower.send_command('input /ma "Thunder ' .. tierHigh .. '" <bt>')
        elseif checkrecast(166) == 0 then
            casting = 6
            windower.send_command('input /ma "Fire ' .. tierHigh .. '" <bt>')
        elseif checkrecast(147) == 0 then
            casting = 7
            windower.send_command('input /ma "Thunder ' .. tierNext .. '" <bt>')
        elseif checkrecast(146) == 0 then
            casting = 8
            windower.send_command('input /ma "Fire ' .. tierNext .. '" <bt>')
        end
    elseif scid == 289 or scid == 292 or scid == 296 or scid == 768 or scid == 770 then
        if checkrecast(152) == 0 then
            casting = 9
            windower.send_command('input /ma "Blizzard ' .. tierHigh .. '" <bt>')
        elseif checkrecast(151) == 0 then
            casting = 1
            windower.send_command('input /ma "Blizzard ' .. tierNext .. '" <bt>')
        end
    elseif scid == 293 or scid == 295 then
        if checkrecast(147) == 0 then
            casting = 11
            windower.send_command('input /ma "Fire ' .. tierHigh .. '" <bt>')
        elseif checkrecast(146) == 0 then
            casting = 12
            windower.send_command('input /ma "Fire ' .. tierNext .. '" <bt>')
        end
    elseif scid == 297 then
        if checkrecast(172) == 0 then
            casting = 13
            windower.send_command('input /ma "Water ' .. tierHigh .. '" <bt>')
        elseif checkrecast(171) == 0 then
            casting = 14
            windower.send_command('input /ma "Water ' .. tierNext .. '" <bt>')
        end
    elseif scid == 300 then
        if checkrecast(157) == 0 then
            casting = 15
            windower.send_command('input /ma "Aero ' .. tierHigh .. '" <bt>')
        elseif checkrecast(156) == 0 then
            casting = 16
            windower.send_command('input /ma "Aero ' .. tierNext .. '" <bt>')
        end
    elseif scid == 299 then
        if checkrecast(162) == 0 then
            casting = 17
            windower.send_command('input /ma "Stone ' .. tierHigh .. '" <bt>')
        elseif checkrecast(161) == 0 then
            casting = 18
            windower.send_command('input /ma "Stone ' .. tierNext .. '" <bt>')
        end
    end
end

local party = windower.ffxi.get_party()
local partylist = {};
local partyname = {};
local i = 0;
for i = 0, 5 do
    local person = 'p' .. i
    if (party[person]) then
        if party[person].mob then
            partylist[i] = party[person].mob.id
        end
        partyname[i] = party[person].name
    end
end

windower.register_event('action', function(act)

    if act.category == 4 and act.actor_id == partylist[0] then
        -- print('done casting')
        casting = 0
    end

    if act.category == 8 and act.actor_id == partylist[0] then
        -- print(act.param)
        if act.param == 28787 then
            -- print('cancel casting ')
            casting = 0
        else
            -- print('casting ')
            casting = 19
        end
    end

    if job.main_job == 'RDM' then
        if act.category == 11 then
            -- if has_value(partylist,act.actor_id) then
            bt = windower.ffxi.get_mob_by_target('bt')
            for each, value in pairs(act.targets) do
                if value.id == bt.id then
                    for eachh, valuu in pairs(value.actions) do
                        -- check sc element and do burst here
                        if (casting == 0) then

                            coroutine.sleep(3)
                            castMB(valuu.add_effect_message)
                        end
                    end
                    -- print('we do action on target: '..value.action.add_effect_message)
                end
            end
            -- end
        end

        if act.category == 3 then
            -- print("cast mb7")
            -- if has_value(partylist,act.actor_id) then
            -- bt = windower.ffxi.get_mob_by_target('bt')
            for each, value in pairs(act.targets) do
                -- if value.id == bt.id then
                for eachh, valuu in pairs(value.actions) do
                    -- check sc element and do burst here
                    -- if (casting == 0) then
                    coroutine.sleep(3)
                    -- print("cast mb")
                    castMB(valuu.add_effect_message)
                    -- end
                end
                -- print('we do action on target: '..value.action.add_effect_message)
                -- end
            end
            -- end
        end
    end
end)

windower.register_event('lose buff', function(id)
    if has_value(debuff, id) then
        healerCasting = 0
    end
    if id == 10 then
        casting = 0
    end
    -- casting = 1
end)

windower.register_event('addon command', function(...)
    local cmd = 'none'
    if (#arg > 0) then
        cmd = arg[1]
    end

    if (cmd == 't') then
        local buffs = windower.ffxi.get_player().buffs
        for each, value in pairs(buffs) do
            if res.buffs[value].english == 'Haste' then
                print(value)
            end
            -- print(res.buffs[value].english,value)
        end

        -- if (#arg < 2) then
        -- 	windower.add_to_chat(207, "what did you want to test")
        -- 	return
        -- end
        -- arg[2]		
        return
    end
end)
