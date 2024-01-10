_addon.commands = {'skillup','sk'}

require('tables')
require('strings')
require('logger')
require('sets')

local socket = require('socket')

res = require('resources');
config = require('config')

local aid = ''
local adist = 50
local aindex = ''

local ax = 0
local ay = 0
local az = 0

local function has_value (tab, val)
    if (tab == nil) then
        -- print('we have nil')
        return true 
    end
    for index, value in pairs(tab) do
            if value == val then
                return true
            end
        end
    
    return false
end

local target = nil

local job = windower.ffxi.get_player()
casting = 0
healerCasting = 0

local moblist={"Blanched Mandragora"}

isbusy = 0

windower.register_event('prerender', function()
    s = windower.ffxi.get_mob_by_target('me')
    t = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')
    -- windower.send_command('input /target <bt>')
    -- print(casting)
    -- reset movement keys
    -- windower.send_command('setkey w up;')
    -- windower.send_command('setkey s up;')
    -- windower.send_command('setkey tab up;')
    -- windower.send_command('setkey f8 up;')

    -- we have a target and we are in attack mode
    sp = windower.ffxi.get_spell_recasts()
    ab = windower.ffxi.get_ability_recasts()
    -- print(casting, isbusy)
    if isbusy == 0 then
        
        -- print(ab[93])

        if (ab[93] == 0) then
            isbusy = 1
            windower.send_command('input /ja "Entrust" <me>')
            coroutine.sleep(1)
            windower.send_command('input /ma "Indi-Refresh" <p2>')
            isbusy = 0
            casting = 0
        end
        local buffs = windower.ffxi.get_player().buffs
        if not has_value(buffs,612) then
            local ab = windower.ffxi.get_player()
            isbusy = 1
            if ab.vitals.mp < 200 then
                windower.send_command('input /ma "Indi-Refresh" <me>')
                -- casting = 1
            else
                windower.send_command('input /ma "Indi-Haste" <me>')
                -- casting = 1
            end
            isbusy = 0
            casting = 0
        end

            --     -- local ab = windower.ffxi.get_player()
    --     -- 
        -- if (sp[799] == 0) then
        --     isbusy = 1
        --     windower.send_command('input /ma "Geo-Poison" <bt>')
        --     coroutine.sleep(5)
        --     windower.send_command('input /ja "Full Circle" <me>')
        --     isbusy = 0
        -- end

        
    end
    -- if (t and (s.status == 1)) then
        
    --     if t.distance:sqrt() > 2.3 then
    --         windower.send_command('setkey s down;')
    --         windower.send_command('setkey s up;')
    --         windower.send_command('setkey w down;')
    --     else
    --         windower.send_command('setkey w up;')
    --     end
            
    --     if t.distance:sqrt() < 1.8 then
    --         windower.send_command('setkey s down;')
    --     else
    --         windower.send_command('setkey s up;')
    --     end
        
    --     -- if windower.ffxi.get_player().main_job ==  'GEO' then
    --     --     recasts = windower.ffxi.get_spell_recasts()
    --     --     for eac, val in pairs(recasts) do
    --     --         if eac == 769 and val == 0 then
    --     --             windower.send_command('input /ma "Indi-Poison" <me>') 
    --     --         end

    --     --         -- if eac == 784 and val == 0 then
    --     --         --     if casting == 0 then
    --     --         --         windower.send_command('input /ma "Indi-Voidance" <me>')
    --     --         --         casting = 1
    --     --         --     end
    --     --         -- end

    --     --         -- if eac == 769 and val > 1 then
    --     --         --     if casting == 0 then
    --     --         --         windower.send_command('input /ma "Indi-Poison" <me>')
    --     --         --         casting = 1
    --     --         --     end
    --     --         -- end
    --     --     end

    --     -- end
        
    -- end
    
    -- -- get new target
    -- if (s.status == 0 and t==nil) then
    --     aid = ''
    --     adist = 50
    --     aindex = ''
    --     -- find closest?
    --     local list = windower.ffxi.get_mob_array()
    --     -- get closest mob id
    --     for each,val in pairs(list) do
    --         if has_value(moblist, val.name) and val.hpp == 100 then
    --             if val.distance:sqrt() < adist then
    --                 aid = val.id
    --                 aindex = val.index
    --                 adist = val.distance:sqrt()
    --                 ax = val.x
    --                 ay = val.y
    --                 az = val.z
    --             end
    --         else 
    --         end
    --     end
    --     -- target closest mob
        
    --     windower.ffxi.run(ax-s.x, ay-s.y, az-s.z)
    --     windower.send_command('input /targetbnpc')
    --     windower.send_command('setkey f8 up;')
    -- end
    -- -- refresh target
    -- if (s.status == 0 and t) then
    --     local t = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')
    --     if (has_value(moblist, t.name) and (t.id == aid)) then
    --         windower.send_command('input /follow')
    --         if t.distance:sqrt() < 30 then      
    --             windower.send_command('input /attack')
    --         end
    --     else
    --         aid = ''
    --         adist = 50
    --         aindex = ''
    --         ax = 0
    --         ay = 0
    --         az = 0
    --         -- find closest?
    --         local list = windower.ffxi.get_mob_array()
    --         local t = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')
            
            
    --         -- get closest mob id
    --         for each,val in pairs(list) do
    --             if has_value(moblist, val.name) and val.hpp == 100 then
    --                 if val.distance:sqrt() < adist then
    --                     aid = val.id
    --                     aindex = val.index
    --                     adist = val.distance:sqrt()
    --                     ax = val.x
    --                     ay = val.y
    --                     az = val.z
    --                 end
    --             else 
    --             end
    --         end
    --         -- target closest mob
    --         -- run towards closest mob
    --         windower.ffxi.run(ax-s.x, ay-s.y, az-s.z)
    --         windower.send_command('input /targetbnpc')

    --     end

    -- end
end)

-- get party id data
local party = windower.ffxi.get_party()
local partylist = {};
local partyname = {};
local i = 0;
for i = 0, 5 do
    local person = 'p'..i
    if(party[person]) then
        if party[person].mob then
            partylist[i] = party[person].mob.id
        end
        partyname[i] = party[person].name
    end
end

function checkrecast(spellid)
    local recasts = windower.ffxi.get_spell_recasts()
    for eac,val in pairs(recasts) do
        -- print(eac,val)
        if eac == spellid then
            return val
        end
    end
end

local tierHigh = 'IV'
local tierNext = 'III'
function castMB(scid,num)
    -- local recasts = windower.ffxi.get_spell_recasts()
    if job == 'BLM' then
        tierHigh = 'V'
        tierNext = "IV"
    end
    if scid == 288 or scid == 291 or scid == 301 or scid == 767 or scid == 769 then
        if checkrecast(167) == 0  then
            casting = 1     
            windower.send_command('input /ma "Thunder '..tierHigh..'" <bt>')
        elseif checkrecast(166) == 0 then
            casting = 1 
            windower.send_command('input /ma "Fire '..tierHigh..'" <bt>')
        elseif checkrecast(147) == 0  then
            casting = 1     
            windower.send_command('input /ma "Thunder '..tierNext..'" <bt>')
        elseif checkrecast(146) == 0 then
            casting = 1 
            windower.send_command('input /ma "Fire '..tierNext..'" <bt>')
        end
    elseif scid == 289 or scid == 292 or scid == 296 or scid == 768 or scid == 770 then
        if checkrecast(152) == 0  then
            casting = 1     
            windower.send_command('input /ma "Blizzard '..tierHigh..'" <bt>')
        elseif checkrecast(151) == 0 then
            casting = 1 
            windower.send_command('input /ma "Blizzard '..tierNext..'" <bt>')
        end
    elseif scid == 293 or scid == 295 then
        if checkrecast(147) == 0  then
            casting = 1     
            windower.send_command('input /ma "Fire '..tierHigh..'" <bt>')
        elseif checkrecast(146) == 0 then
            casting = 1 
            windower.send_command('input /ma "Fire '..tierNext..'" <bt>')
        end
    elseif scid == 297 then
        if checkrecast(172) == 0  then
            casting = 1     
            windower.send_command('input /ma "Water '..tierHigh..'" <bt>')
        elseif checkrecast(171) == 0 then
            casting = 1 
            windower.send_command('input /ma "Water '..tierNext..'" <bt>')
        end
    elseif scid == 300 then
        if checkrecast(157) == 0  then
            casting = 1     
            windower.send_command('input /ma "Aero '..tierHigh..'" <bt>')
        elseif checkrecast(156) == 0 then
            casting = 1 
            windower.send_command('input /ma "Aero '..tierNext..'" <bt>')
        end
    elseif scid == 299 then
        if checkrecast(162) == 0  then
            casting = 1     
            windower.send_command('input /ma "Stone '..tierHigh..'" <bt>')
        elseif checkrecast(161) == 0 then
            casting = 1 
            windower.send_command('input /ma "Stone '..tierNext..'" <bt>')
        end
    end
    -- coroutine.sleep(5)
    --  local ab = windower.ffxi.get_player()
    -- if ab.vitals.mp < 200 then
    --     windower.send_command('input /ma "Indi-Refresh" <me>')
    --     casting = 1
    -- end
    -- if (num == 0) then
    --     coroutine.sleep(4)
    --     castMB(scid,1)
    -- end
end

windower.register_event('action',function(act)
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
            -- casting = 1
        end
    end

    if act.category == 34 and act.actor_id == partylist[0] then
        casting = 0
    end

    if act.category == 11 then
        if has_value(partylist,act.actor_id) then
            bt = windower.ffxi.get_mob_by_target('bt')
            for each,value in pairs(act.targets) do
                if value.id == bt.id then
                    for eachh,valuu in pairs(value.actions) do
                        -- check sc element and do burst here
                        if (casting == 0) then
                            coroutine.sleep(3)
                            castMB(valuu.add_effect_message,0)
                        end
                    end
                    -- print('we do action on target: '..value.action.add_effect_message)
                end
            end
        end
    end

    if act.category == 3 then
        if has_value(partylist,act.actor_id) then
            bt = windower.ffxi.get_mob_by_target('bt')
            for each,value in pairs(act.targets) do
                if value.id == bt.id then
                    for eachh,valuu in pairs(value.actions) do
                        -- check sc element and do burst here
                        if (casting == 0) then
                            coroutine.sleep(3)
                            castMB(valuu.add_effect_message,0)
                        end
                    end
                    -- print('we do action on target: '..value.action.add_effect_message)
                end
            end
        end
    end
end)

windower.register_event('lose buff', function(id)
    if has_value(debuff,id) then
        healerCasting = 0
    end
    if id == 10 then
        casting =0
    end

    -- if (id == 612) then
    --     -- local ab = windower.ffxi.get_player()
    --     -- if ab.vitals.mp < 200 then
    --         windower.send_command('input /ma "Indi-Refresh" <me>')
    --         casting = 1
    --     -- else
    --     --     windower.send_command('input /ma "Indi-Haste" <me>')
    --     --     casting = 1
    --     -- end
    -- end
end)

windower.register_event('addon command', function(...)
    local cmd = 'none'
	if (#arg > 0) then
		cmd = arg[1]
	end

    if (cmd == 't') then
        local buffs = windower.ffxi.get_player().buffs
        for each, value in pairs(buffs) do
            
            print(res.buffs[value].english,value)
        end
        -- if (#arg < 2) then
		-- 	windower.add_to_chat(207, "what did you want to test")
		-- 	return
		-- end
		-- arg[2]		
		return
    end

    if (cmd == 'a') then
        local ab = windower.ffxi.get_player()
        print(ab.vitals.mp)
        -- local ab = windower.ffxi.get_ability_recasts()
        -- local recasts = res.ability_recasts
        -- for each, value in pairs(recasts) do
        --     if (value.english == 'Entrust') then
        --     print(each, value.english)
        --     end
        --     -- -- end
            
        --     -- print(res.ability_recasts[value].english,value)
        -- end
        -- -- if (#arg < 2) then
		-- -- 	windower.add_to_chat(207, "what did you want to test")
		-- -- 	return
		-- -- end
		-- -- arg[2]		
		return
    end
    

end)

windower.register_event('tp change', function(new, old)
    -- if new > 1000 then
    --     if job.main_job ==  'GEO' then 
    --         windower.send_command('input /ws "Black Halo" <t>')
    --     end

    -- end
end)