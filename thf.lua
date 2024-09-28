include('organizer-lib')

function get_sets()
    sets.weapons = {main="Suwaiyas"}
    sets.precast = {}
    --sets.precast.Boost = {hands="Anchorite's Gloves +1"}
    sets.precast.Chakra = {ammo="Iron Gobbet",body="Anchorite's Cyclas +1",hands="Hes. Gloves +1"}
    sets.precast.Counterstance = {feet="Hes. Gaiters +1"}
    sets.precast.Focus = {head="Anchorite's Crown +1"}
    sets.precast.Dodge = {feet="Anchorite's Gaiters +1"}
    sets.precast.Mantra = {feet="Hes. Gaiters +1"}
    sets.precast.Footwork = {feet="Shukuyu Sune-Ate"}
    sets.precast.Steal = {
        feet="Skulk. Poulaines +1",
        hands="Plun. Armlets +1"
    }
    sets.precast['Hundred Fists'] = {legs="Hes. Hose +1"}
    sets.Waltz = {head="Anwig Salade",neck="Unmoving Collar +1",ring1="Valseur's Ring",ring2="Carbuncle Ring +1",
        waist="Aristo Belt",legs="Desultor Tassets",feet="Dance Shoes"}
        
    -- sets.precast['Victory Smite'] = {
    --     ammo="Ginsen",
    --     head="Hizamaru Somen +1",
    --     body="Hiza. Haramaki +1",
    --     hands="Hizamaru Kote +1",
    --     legs="Hiza. Hizayoroi +1",
    --     feet="Hiza. Sune-Ate +2",
    --     neck="Fotia Gorget",
    --     waist="Fotia Belt",
    --     left_ear="Moonshade Earring",
    --     right_ear="Brutal Earring",
    --     left_ring="Rufescent Ring",
    --     left_ring="Epona's Ring",
    --     back={ name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}},
    -- }

        
    sets.WS = {
        -- main="Naegling",
        -- sub={ name="Shijo", augments={'DMG:+15','Accuracy+15','Attack+15',}},
        -- ammo="Shadow Sachet",
        head="Meghanada Visor +1",
        body="Mummu Jacket +2",
        hands="Meg. Gloves +1",
        legs="Meg. Chausses +1",
        feet="Meg. Jam. +1",
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear="Brutal Earring",
        right_ear="Moonshade Earring",
        -- left_ring="Epona's Ring",
        -- right_ring="Vocane Ring",
        back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20',}},
    }
    
    sets.TP = {}
    
    sets.TP.DD = {
        -- main="Naegling",
        -- sub="Ternion Dagger +1",
        ammo="Ginsen",
        head="Adhemar Bonnet",
        body="Mummu Jacket +2",
        hands="Adhemar Wristbands",
        legs="Meg. Chausses +1",
        feet="Plun. Poulaines +1",
        neck="Lissome Necklace",
        waist="Windbuffet Belt",
        left_ear="Suppanomimi",
        right_ear="Dedition earring",
        left_ring="Epona's Ring",
        right_ring="Chirich Ring",
        back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20',}},
    }
    
    sets.status = {}
    sets.status.Engaged = sets.TP.DD
    
    sets.status.Idle = {
        -- ammo="Iron Gobbet",
        -- head="Lithelimb Cap",
        -- body="Emet Harness +1",
        -- hands={ name="Herculean Gloves", augments={'Accuracy+30','Damage taken-4%','STR+9','Attack+4',}},
        -- legs="Mummu Kecks +1",
        feet="Jute Boots",
        -- neck="Wiglen Gorget",
        -- waist="Moonbow Belt",
        -- left_ear="Novia Earring",
        -- right_ear="Genmei Earring",
        -- left_ring="Defending Ring",
        -- right_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',}},
        -- back={ name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','"Dbl.Atk."+10',}},
    }
    send_command('input /macro book 15;wait .1;input /macro set 1')
end

function precast(spell) 
    if spell.english == 'Tornado Kick' and buffactive.Footwork then
        equip(sets.precast[spell.english])
        equip({feet="Shukuyu Sune-Ate"})
    elseif sets.precast[spell.english] then

        equip(sets.precast[spell.english])
    elseif spell.type=="WeaponSkill" then
        equip(sets.WS)
    elseif string.find(spell.english,'Waltz') then
        equip(sets.Waltz)
    end
end

function aftercast(spell)
    if sets.status[player.status] then
        equip(sets.status[player.status])
    end
end

function status_change(new,old)
    if sets.status[new] then
        equip(sets.status[new])
    end
end