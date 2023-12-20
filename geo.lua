require('tables')
require('strings')
require('logger')
require('sets')
res = require('resources')
config = require('config')
local aid = ''
local adist = 50
local aindex = ''
local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end
-- Triggers on player status change. This only triggers for the following statuses:
-- Idle, Engaged, Resting, Dead, Zoning
windower.register_event('tp change', function(new, old)
    if new > 1000 then
        windower.send_command('input /ws "Savage Blade" <t>')
        -- windower.send_command('input /item "Echo Drops" '..windower.ffxi.get_player()["name"])
    end
end)

windower.register_event('status change', function(new, old)
    -- if has_value(windower.ffxi.get_player().buffs, 15) then
    local s = windower.ffxi.get_mob_by_target('me')
        windower.send_command('send Tuxxy /ma \"Cursna\" '..s.name)
    -- end
    -- 1 = engaged
    -- 0 = idle
    -- 33 = resting
    -- dead
    -- zoning
    -- local name = res.buffs[id].english
    -- console.log(name)
    -- local abcd = ""
    -- for key,val in pairs(windower.ffxi.get_player()) do
    --     abcd = abcd..'||'..key
    --     -- print(key,val)
    -- end
    -- print(abcd)
    -- local file = assert(io.open('D:\\PlayOnline\\console.log','w'))
    -- print_r(abcd,file)
    -- file:close()
    -- windower.ffxi.get_player().buffs[0]
    if new == 1 then

    end
    if new == 0 then
        -- we tab around for mob!
        -- timer.Simple(0.5, function()
        --     windower.send_command('input /targetbnpc')
        -- end)
        
        -- windower.send_command('input /attack')
        aid = ''
        adist = 50
        aindex = ''
        
    end
end)

healerCasting = 0

casting = 0

windower.register_event('prerender', function()
    local t = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')
    local s = windower.ffxi.get_mob_by_target('me')
    local moblist={"Eschan Bugard","Eschan Tarichuk"}

    -- print(s.status)
    -- ||linkshell||superior_level||vitals||main_job_full
    -- ||job_points||main_job||sub_job_full||
    -- merits||sub_job_level||main_job_level
    -- ||sub_job_id||autorun||index||id||nation||sub_job||jobs||in_combat
    -- ||status||name||buffs||item_level||skills||main_job_id||linkshell_slot
   
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

        if windower.ffxi.get_player().main_job ==  'RDM' then 
            if not has_value(windower.ffxi.get_player().buffs, 419) then
                windower.send_command('input /ja \"Composure\" <me>')
            end
            -- check buffs
            
            if (casting == 0) then
                if not has_value(windower.ffxi.get_player().buffs, 33) then
                    windower.send_command('input /ma \"Haste II\" <me>')
                    casting = 1
                end
                if not has_value(windower.ffxi.get_player().buffs, 95) then
                    windower.send_command('input /ma \"Enblizzard\" <me>')
                    casting = 1
                end
                
                if not has_value(windower.ffxi.get_player().buffs, 43) then
                    windower.send_command('input /ma \"Refresh II\" <me>')
                    casting = 1
                end
            end
        end 
    else
    end
    -- get new target
    if (s.status == 0 and t==nil) then
        aid = ''
        adist = 50
        aindex = ''
        -- find closest?
        local list = windower.ffxi.get_mob_array()
        local t = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')
        
        local moblist={"Eschan Bugard","Eschan Tarichuk","Immanibugard"}
        -- get closest mob id
        for each,val in pairs(list) do
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
        windower.ffxi.run(ax-s.x, ay-s.y, az-s.z)
        windower.send_command('input /targetbnpc')
        -- windower.send_command('setkey f8 up;')
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
            adist = 50
            aindex = ''
            ax = 0
            ay = 0
            az = 0
            -- find closest?
            local list = windower.ffxi.get_mob_array()
            local t = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')
            
            local moblist={"Eschan Bugard","Eschan Tarichuk","Immanibugard"}
            -- get closest mob id
            for each,val in pairs(list) do
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
            windower.ffxi.run(ax-s.x, ay-s.y, az-s.z)
            windower.send_command('input /targetbnpc')
            -- windower.send_command('setkey tab down;')
            -- windower.send_command('setkey tab up;')
        end

    end
end)

windower.register_event('action',function(act)
    if act.category == 4 then
        casting = 0
    end
end)

debuff = {2,3,4,5,6,7,8,9,11,12,13,14,15,18,19}
windower.register_event('lose buff', function(id)
    
    if has_value(debuff,id) then
        healerCasting = 0
    end
end)
