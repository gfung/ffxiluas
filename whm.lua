_addon.commands = {'whm','wm'}

require('tables')
require('strings')
require('logger')
require('sets')
local socket = require('socket')
res = require('resources')
config = require('config')

local function has_value (tab, val)
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
ability = 0
local t = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')
local s = windower.ffxi.get_mob_by_target('me')
windower.register_event('prerender', function()
    local p = windower.ffxi.get_party()
    ab = windower.ffxi.get_ability_recasts()
    s = windower.ffxi.get_mob_by_target('me')
    t = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')
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
    elseif windower.ffxi.get_player().main_job ==  'WHM' then
        -- if (ability == 0) then 
            if not has_value(windower.ffxi.get_player().buffs, 358) then
                windower.send_command('input /ja \"Light Arts\" <me>')
                -- ability = 1
            end
            if ab[29] == 0 then
                if not has_value(windower.ffxi.get_player().buffs, 417) then
                    windower.send_command('input /ja \"Afflatus Solace\" <me>')
                    -- ability = 1
                end
            end
            if not has_value(windower.ffxi.get_player().buffs, 113) then
                windower.send_command('input /ma \"Reraise III\" <me>')
                -- ability = 1
            end
        -- end
    end 
    
    -- cure bot
    for each,value in pairs(p) do  
        if (type(value)== 'table') then
            local thischar = value.name
            for eac,val in pairs(value) do
                if eac == "hpp" then
                    -- windower.send_command('input '..thischar..' '..val)
                    if val < 30 and val > 0 then
                        windower.send_command('input /ma "Cure IV" '..thischar)
                        socket.sleep(1.5)
                    end

                    if (val <= 50) and (val >= 30) then
                        windower.send_command('input /ma "Cure IV" '..thischar)
                        socket.sleep(1.5)
                    end

                    if (val < 80) and (val > 50) then
                        windower.send_command('input /ma "Cure III" '..thischar)
                        socket.sleep(1.5)
                    end
                end
                -- windower.send_command('input '..eac..' '..val)
            end
        end
    end
    -- local recasts = windower.ffxi.get_spell_recasts()
    -- if (recasts[66] == 0) then
    --     windower.send_command('input /ma "Barfira" <me>')
    -- end
    -- status bot???
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

        
        -- if windower.ffxi.get_player().main_job ==  'GEO' then
        --     recasts = windower.ffxi.get_spell_recasts()
        --     for eac, val in pairs(recasts) do
        --         if eac == 769 and val == 0 then
        --             windower.send_command('input /ma "Indi-Poison" <me>') 
        --         end

        --         -- if eac == 784 and val == 0 then
        --         --     if casting == 0 then
        --         --         windower.send_command('input /ma "Indi-Voidance" <me>')
        --         --         casting = 1
        --         --     end
        --         -- end

        --         -- if eac == 769 and val > 1 then
        --         --     if casting == 0 then
        --         --         windower.send_command('input /ma "Indi-Poison" <me>')
        --         --         casting = 1
        --         --     end
        --         -- end
        --     end

        -- end
        
    end
end)

windower.register_event('action',function(act)
    if act.category == 4 or act.category == 8  then
        casting = 0
    end
end)

-- windower.register_event('action message',function (actor_id, target_id, actor_index, target_index, message_id, param_1, param_2, param_3)
--     windower.send_command('input /echo '..message_id)
--     if message_id == 17 then
--         casting = 0
--     end
-- end)


windower.register_event('gain buff',function(msg)
    if msg == 417 or msg == 358 then
        ability = 0
    end
end)

windower.register_event('lose buff', function(id)
    if has_value(debuff,id) then
        healerCasting = 0
    end

    if (id == 104) then
        windower.send_command('input /ma "Barthundra" <me>')
    end
end)

windower.register_event('tp change', function(new, old)
    -- if new > 1000 then
    --     if job.main_job ==  'WHM' then 
    --         windower.send_command('input /ws "Hexa Strike" <t>')
    --     end
        
    -- end
end)

windower.register_event('addon command', function(...)
    local cmd = 'none'
	if (#arg > 0) then
		cmd = arg[1]
	end

    if (cmd == 't') then
        -- local acvtiveBuffs = windower.ffxi.get
        local buffs = windower.ffxi.get_spell_recasts()
        print(buffs[66])

        -- if (#arg < 2) then
		-- 	windower.add_to_chat(207, "what did you want to test")
		-- 	return
		-- end
		-- arg[2]		
		return
    end
end)