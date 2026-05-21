_addon.name = 'dps'
_addon.author = 'aiyah4la'
_addon.version = '3.0'
_addon.commands = {'dps', 'dd'}

-- Logging module: writes to dps_log.txt in addon directory

files = require('files')

require('tables')
require('math')
packets = require('packets')

local moblist={"Apex Eft"}
local last_ja_time = {}
local ja_cooldown = 2
local aid = nil
local adist = 40
local aindex = nil
local ability_frame = 0
local ability_frame2 = 0
local ability_frame3 = 0
local ax = 0
local ay = 0
local cache_timer = 0
local json_encode
local active = false
local wscount = 0
local aftermath = false
local savage = false


local debuffs = 0
-- Cache — DLL calls happen elsewhere, prerender only reads
local cache = {
    player = nil,
    me = nil,
    bt = nil,
    party = nil,
    mob_array = nil,
    recasts = nil,
    spell_recasts = nil,
}

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

json_encode = function(obj)
    local t = type(obj)
    if t == 'string' then
        return '"' .. obj:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"'
    end
    if t == 'number' or t == 'boolean' then
        return tostring(obj)
    end
    if t == 'nil' then
        return 'null'
    end
    if t == 'table' then
        local result = '{'
        local first = true
        for k, v in pairs(obj) do
            if not first then result = result .. ',' end
            first = false
            result = result .. '"' .. tostring(k) .. '":' .. json_encode(v)
        end
        return result .. '}'
    end
    return '"' .. tostring(obj) .. '"'
end

local function checkactivebuffs(player, id)
    return player and has_value(player.buffs, id) or false
end

local function checkrecastability(ability_id)
    return cache.recasts and cache.recasts[ability_id] or 0
end

local function checkrecast(spell_id)
    return cache.spell_recasts and cache.spell_recasts[spell_id] or 0
end

local function can_use_ja(name)
    local now = os.time()
    local last = last_ja_time[name] or 0
    if now - last >= ja_cooldown then
        last_ja_time[name] = now
        return true
    end
    return false
end

local function aftermathbuffCheck(player)
    aftermath = player and has_value(player.buffs, 272) or false
end

local function run_buff_maintenance(player)
    -- translate_file:append('BUFF Checking buff maintenance for job \n\n')
    if (player.sub_job == 'SAM' or player.main_job == 'SAM') and checkrecastability(138) == 0 and not checkactivebuffs(player, 353) and can_use_ja("Hasso") then
        windower.send_command('input /ja "Hasso" <me>')
        -- translate_file:append('BUFF Used Hasso \n\n')
    end

    if player.sub_job == 'DRG' then
        if checkrecastability(159) == 0 and can_use_ja("High Jump") then
            windower.send_command('input /ja "High Jump" <t>')
            -- translate_file:append('BUFF Used High Jump \n\n')
        end
        if checkrecastability(158) == 0 and can_use_ja("Jump") then
            windower.send_command('input /ja "Jump" <t>')
            -- translate_file:append('BUFF Used Jump \n\n')
        end
    end

    if player.main_job == 'MNK' then
        local mnk_jas = { [31]="Impetus", [13]="Focus", [14]="Dodge", [22]="Perfect Counter", [21]="Footwork" }
        for id, name in pairs(mnk_jas) do
            if checkrecastability(id) == 0 and can_use_ja(name) then
                windower.send_command('input /ja "'..name..'" <me>')
                -- translate_file:append('BUFF Used MNK JA: ' .. name .. '\n\n')
                break
            end
        end
    end

    if player.sub_job == 'WAR' or player.main_job == 'WAR' then
        if checkrecastability(1) == 0 and can_use_ja("Berserk") then
            windower.send_command('input /ja "Berserk" <me>')
            -- translate_file:append('BUFF Used Berserk \n\n')
        end
        if checkrecastability(2) == 0 and can_use_ja("Warcry") then
            windower.send_command('input /ja "Warcry" <me>')
            -- translate_file:append('BUFF Used Warcry \n\n')
        end
        -- if checkrecastability(4) == 0 and can_use_ja("Aggressor") then
            -- windower.send_command('input /ja "Aggressor" <me>')
            -- -- translate_file:append('BUFF Used Aggressor \n\n')
        -- end
        if player.main_job == 'WAR' then
            if checkrecastability(11) == 0 and can_use_ja("Blood rage") then
                windower.send_command('input /ja "Blood rage" <me>')
                -- translate_file:append('BUFF Used Blood rage \n\n')
            end
            if checkrecastability(9) == 0 and can_use_ja("Restraint") then
                windower.send_command('input /ja "Restraint" <me>')
                -- translate_file:append('BUFF Used Restraint \n\n')
            end
            if checkrecastability(8) == 0 and can_use_ja("Retaliation") then
                windower.send_command('input /ja "Retaliation" <me>')
                -- translate_file:append('BUFF Used Retaliation \n\n')
            end
        end
    end

    if player.main_job == 'RDM' then
        if checkrecastability(50) == 0 and can_use_ja("Composure") then
            windower.send_command('input /ja "Composure" <me>')
            -- -- translate_file:append('BUFF Used Composure \n\n')
        end
        local rdm_boofs = { [95]="Enblizzard", [33]="Haste II", [116]="Phalanx" , [432]="Temper II", [43]="Refresh III" }
        
        for id, name in pairs(rdm_boofs) do
            if not checkactivebuffs(cache.player, id) then
                windower.send_command('input /ma "'..name..'" <me>')
                -- -- translate_file:append('BUFF Used RDM JA: ' .. name .. '\n\n')
                break
            end
        end
    end

    -- if (player.main_job == 'DNC' or player.sub_job == 'DNC') and not checkactivebuffs(player, 370) and checkrecastability(216) == 0 and can_use_ja("Haste Samba") then
    --     windower.send_command('input /ja "Haste Samba" <me>')
    --     -- translate_file:append('BUFF Used Haste Samba \n\n')
    -- end
end

local function doWS(tp)
    local job = cache.player.main_job
    local ws_name = nil

    -- translate_file:append('WS Evaluating WS for job=' .. job .. ' tp=' .. tp .. '\n\n')

    if job == 'BST' then
        ws_name = "Decimation"
    elseif job == 'BLU' then
        -- ws_name = "Seraph Blade"
        if savage then
            if tp >= 1750 then
                ws_name = "Savage Blade"
            end
        else
            aftermathbuffCheck(player)
            if not aftermath and tp == 3000 then
                ws_name = "Chant du Cygne"
            end
            if aftermath then
                ws_name = "Chant du Cygne"
            end
        end
    elseif job == 'RDM' then
        if tp >= 1000 then
            ws_name = "Savage Blade"
        end
    elseif job == 'WAR' or job == 'BRD' then
        if tp >= 1100 then
            ws_name = "Savage Blade"
        end
    elseif job == 'COR' then
        ws_name = "Evisceration"
    elseif job == 'THF' then
        ws_name = "Rudra's Storm"
    elseif job == 'DNC' then
        ws_name = "Shark Bite"
    elseif job == 'MNK' or job == 'PUP' then
        if checkactivebuffs(player, 406) then
            ws_name = "Tornado Kick"
        elseif job == 'PUP' then
            ws_name = "Stringing Pummel"
        else
            if wscount > 0 then
                wscount = wscount + 1
                ws_name = "Victory Smite"
                if wscount >= 3 then
                    wscount = 0
                end
            else
                ws_name = "Shijin Spiral"
                wscount = wscount + 1
            end
        end
    elseif job == 'SAM' then
        -- if poleOn then
            -- ws_name = "Penta Thrust"
        -- else
            ws_name = "Tachi: Jinpu"
        -- end
    elseif job == 'NIN' then
        -- ws_name = "Blade: Hi"
        if wscount == 0 then
            wscount = wscount + 1
            ws_name = "Blade: Rin"
        elseif wscount == 1 then
            ws_name = "Blade: Retsu"
            wscount = wscount + 1
        elseif wscount == 2 then
            ws_name = "Blade: Hi"
            wscount = wscount + 1
        elseif wscount == 3 then
            ws_name = "Blade: Hi"
            wscount = 0
        end
    end

    if ws_name then
        -- translate_file:append('WS Using WS: ' .. ws_name .. '\n\n')
        windower.send_command('input /ws "'..ws_name..'" <bt>')
    else
        -- translate_file:append('WS No WS selected for job=' .. job .. '\n\n')
    end
end

local function update_cache()
    cache.player = windower.ffxi.get_player()
    cache.me = windower.ffxi.get_mob_by_target('me')
    cache.bt = windower.ffxi.get_mob_by_target('t')
    cache.party = windower.ffxi.get_party()
    cache.mob_array = windower.ffxi.get_mob_array()
    cache.recasts = windower.ffxi.get_ability_recasts()
    cache.spell_recasts = windower.ffxi.get_spell_recasts()
end

local function get_nearest_mob()
    windower.add_to_chat(207, 'Getting nearest mob...')
    local internallist = cache.mob_array
    local interalplayer = cache.me
    -- if not internalplayer then windower.add_to_chat(207, 'Player not loaded, skipping.'); return end
    for _, val in pairs(cache.mob_array) do
        if has_value(moblist, val.name) and val.hpp == 100 then
            -- -- translate_file2:append('Mob ID : ' .. val.id .. '\n')
            -- -- translate_file2:append('Mob Dist : ' .. val.distance:sqrt() .. '\n\n')
            if val.distance and val.distance:sqrt() < adist  then
                aid = val.id
                aindex = val.index
                adist = val.distance:sqrt()
                ax = val.x
                ay = val.y
                wscount = 0
            end
        end
    end

    windower.ffxi.follow(aindex)
    -- coroutine.sleep(0.5)
    -- windower.send_command('input /targetbnpc;wait 0.1;input /lockon;wait 0.1;input /attack')
        --- IGNORE ---
    -- -- translate_file2:append('===== Final Mob ID : ' .. aid .. ' :: Dist : ' .. adist .. '\n\n')
end

-- translate_file:append('INIT Core functions defined, registering event handlers \n\n')

-- WS only — TP only changes while fighting
windower.register_event('tp change', function(new, old)
    if new > 999 then
        doWS(new)
        previous_target = cache.bt
    end
    if debuffs == 0 then
        windower.send_command('input /party db')
        debuffs = 1
    end
    -- update_cache()
end)

windower.register_event('lose buff', function(buff_id)
    -- translate_file:append('BUFF_LOSS Lost buff id=' .. buff_id .. '\n\n')
    -- windower.add_to_chat(167, '[buff] : ' .. buff_id )
    if buff_id == 432 then
        windower.send_command('input /ma "Temper" <me>')
        -- -- translate_file:append('BUFF_LOSS Detected loss of Haste buff (buff 33) \n\n')
    end
    if buff_id == 95 then
        windower.send_command('input /ma "Enblizzard" <me>')
    end
    if buff_id == 116 then
        windower.send_command('input /ma "Phalanx" <me>')
    end
    if buff_id == 33 and active then
        if cache.player.main_job == 'RDM' then
            windower.send_command('input /ma "Haste II" <me>')
            -- -- translate_file:append('BUFF_LOSS Sent haste request (buff 33) \n\n')
        else
            -- windower.send_command('input /ma Haste <me>')
            -- translate_file:append('BUFF_LOSS Sent haste request (buff 33) \n\n')
        end
        windower.send_command('input /p haste')
        -- translate_file:append('BUFF_LOSS Sent haste request (buff 33) \n\n')
    end
    if buff_id == 214 and active then
        windower.send_command('input /p march')
        -- translate_file:append('BUFF_LOSS Sent march request (buff 214) \n\n')
    end
    if buff_id == 198 and active then
        windower.send_command('input /p minuet')
        -- translate_file:append('BUFF_LOSS Sent minuet request (buff 198) \n\n')
    end
end)



windower.register_event('incoming chunk', function(id, data)
    -- if id == 0x028 then
    --     local packet = packets.parse('incoming', data)
    --     local category = packet['Category']
    --     local actor_id = packet['Actor']

    --     -- Category 3 = Weaponskill Finished
    --     -- Category 4 = Magic Spell Finished
    --     if category == 3 or category == 4 then
    --     -- Action packets loop through targets because a single action can hit multiple mobs (AOE)
    --     -- packet.Count tells us how many targets are bundled in this packet
    --     local target_count = packet['Target Count'] or 0
        
    --     for i = 1, target_count do
    --         -- Target-specific fields dynamically generated by the parser
    --         local target_id = packet['Target '..i..' ID']
    --         local action_count = packet['Target '..i..' Action Count'] or 0
            
    --         for j = 1, action_count do
    --             -- Check for Skillchain Sub-effects/Messages
    --             -- 431 is a common add_effect message for Skillchains
    --             local effect_msg = packet['Target '..i..' Action '..j..' Add Effect Message']
    --             local effect_param = packet['Target '..i..' Action '..j..' Add Effect Param']
                
    --             if effect_msg == 431 then
    --                 -- Trigger your magic burst processing loop safely
    --                 evaluate_magic_burst(target_id, effect_param)
    --             end
    --         end
    --     end
    -- end

    -- check for incoming message says "You can't see that target." or "Unable to see the ___" then we know we're out of range and can move forward
    if id == 0x029 and active then
        local raw_parsed = packets.parse('incoming', data)
        if raw_parsed and raw_parsed['Message'] then
            -- log every message id we see so we can identify the right ones
            -- translate_file:append(string.format('MSG 0x029 Message id=%d %s\n', raw_parsed['Message'], json_encode(raw_parsed)))
            if raw_parsed['Message'] == 4 or raw_parsed['Message'] == 78 then
                windower.ffxi.follow(aindex)
                -- translate_file:append('RANGE Detected out of range message, moving forward \n\n')
            end
        end
    end
    
    
    -- cache_timer = cache_timer + 1
    -- if cache_timer >= 10 then
    --     cache_timer = 0
    --     update_cache()
    -- end
    -- if not active then 
    --     -- translate_file:append('INCOMING Dropping - addon not active \n\n')
    --     return 
    -- end
    
    -- 
    
    -- Buff distance maintenance (every 20 packets)
    ability_frame = ability_frame + 1
    if ability_frame >= 20 and player and player.status == 1 then
        ability_frame = 0
        -- translate_file:append('DIST Distance check cycle (frame=' .. ability_frame .. ') \n\n')
        local target = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('bt')
        -- if target and not (windower.ffxi.get_player() and windower.ffxi.get_player().target_locked) then
        --     windower.send_command('input /lockon')
            
        -- end
        if target and target.distance and target.distance:sqrt() > 2.3 then
            windower.ffxi.follow(target.index)
            -- -- translate_file:append('DIST', 'Moving forward - target too far')
        end
        if target and target.distance and target.distance:sqrt() < 1.8 then
            windower.ffxi.run(false)
            -- windower.send_command('setkey s down;wait .1;setkey s up;')

            -- -- translate_file:append('DIST', 'Moving backward - target too close')
        end
    end

    ability_frame2 = ability_frame2 + 1
    if ability_frame2 >= 60 then
        ability_frame2 = 0
        -- windower.add_to_chat(8, 'Running buff maintenance 1... : ' .. player.status)
        local me = cache.me
        if me and (me.status == 1 or me.status == 2) and cache.player then
            -- translate_file:append('MAINT Running periodic buff maintenance \n\n')
            run_buff_maintenance(cache.player)
        end
    end

    -- only check for kill message packet
    if id == 0x2D then
        -- translate_file:append('KILL Kill message received for target id= \n\n')
        if data and #data >=20 then
            -- translate_file:append('KILL parsing \n\n')
            local raw_parsed = packets.parse('incoming', data)
            -- translate_file:append('KILL checking parsedvalues \n\n')
            if raw_parsed and raw_parsed['Param 1'] and raw_parsed['Param 1'] >= 4500 and previous_target and raw_parsed['Target'] == previous_target.id then
                -- translate_file:append('KILL reset vars \n\n')
                aid = nil
                adist = 30
                aindex = nil
                debuffs = 0
                wscount = 0
            end
        end
    end

end)

windower.register_event('addon command', function(cmd, ...)
    cmd = cmd and cmd:lower() or nil

    if cmd == 'start' then
        active = not active
        windower.add_to_chat(8, 'DD Mode: ' .. (active and 'ON' or 'OFF'))
    -- elseif cmd == 'assist' then
    --     assist = not assist
    --     windower.add_to_chat(8, 'Assist Mode: ' .. (assist and 'ON' or 'OFF'))
    elseif cmd == 'savage' then
        savage = not savage
        windower.add_to_chat(8, 'Savage Mode: ' .. (savage and 'ON' or 'OFF'))
    end
end)

local function next_mob_loop()
    -- Only update memory cache if the player is actually logged in
    if not windower.ffxi.get_info().logged_in then
        -- print('Updating cache...')
        coroutine.schedule(next_mob_loop, 1)
        return
    end

    if cache.player and cache.player.vitals.tp == 3000 then
        doWS(3000)
    end

    if active and cache.me and cache.me.status == 0 and aid == nil then    
        get_nearest_mob()
    elseif active and cache.me and cache.me.status == 0 and aid ~= nil  then
        -- translate_file:append('grabbing next target \n\n')

        windower.send_command('input /targetbnpc;')
        if cache.bt and (aid == cache.bt.id) then
            -- translate_file:append('TARGET Engaging target id=' .. aid .. '\n\n')
            windower.send_command('input /follow;wait 0.2;input /attack')
            -- cache.me.status = 1
            -- else
            -- windower.ffxi.follow(aindex)
        end
    end
    coroutine.schedule(next_mob_loop, 1.5)
      
end

local function start_cache_loop()

    -- Only update memory cache if the player is actually logged in
    if not windower.ffxi.get_info().logged_in then
        -- print('Updating cache...')
        coroutine.schedule(start_cache_loop, 1)
        return
    end

    update_cache()
    coroutine.schedule(start_cache_loop, 0.5)
            
end
-- translate_file:append('INIT Addon fully initialized \n\n')

update_cache()
start_cache_loop()
next_mob_loop()
