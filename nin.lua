-- Original: Motenten / Modified: Arislan / Modified Again: Cambion
-- Haste/DW Detection Requires Gearinfo Addon
-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2

    -- Load and initialize the include file.
    include('Mote-Include.lua')
end

-- Setup variables that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    state.Buff['Climactic Flourish'] = buffactive['climactic flourish'] or false
    state.Buff['Sneak Attack'] = buffactive['sneak attack'] or false

    state.MainStep = M {
        ['description'] = 'Main Step',
        'Box Step',
        'Quickstep',
        'Feather Step',
        'Stutter Step'
    }
    state.AltStep = M {
        ['description'] = 'Alt Step',
        'Quickstep',
        'Feather Step',
        'Stutter Step',
        'Box Step'
    }
    state.UseAltStep = M(false, 'Use Alt Step')
    state.SelectStepTarget = M(false, 'Select Step Target')
    state.IgnoreTargetting = M(true, 'Ignore Targetting')

    state.ClosedPosition = M(false, 'Closed Position')

    state.CurrentStep = M {
        ['description'] = 'Current Step',
        'Main',
        'Alt'
    }
    --  state.SkillchainPending = M(false, 'Skillchain Pending')

    state.CP = M(false, "Capacity Points Mode")

    lockstyleset = 1
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.
-------------------------------------------------------------------------------------------------------------------

-- Gear Modes
function user_setup()
    state.OffenseMode:options('Normal', 'LowAcc', 'MidAcc', 'HighAcc')
    state.HybridMode:options('Normal', 'HIGH', 'MID', 'LOW')
    state.WeaponskillMode:options('Normal', 'Acc')

    -- Allows the use of Ctrl + ~ and Alt + ~ for 2 more macros of your choice.
    send_command('bind ^` input /ja "Chocobo Jig II" <me>') -- Ctrl'~'
    send_command('bind !` input /ja "Spectral Jig" <me>') -- Alt'~'
    send_command('bind f9 gs c cycle OffenseMode') -- F9
    send_command('bind ^f9 gs c cycle WeaponSkillMode') -- Ctrl'F9'
    send_command('bind f10 gs c cycle HybridMode') -- F10
    send_command('bind f11 gs c cycle mainstep') -- F11
    send_command('bind @c gs c toggle CP')

    select_default_macro_book()
    set_lockstyle()

    Haste = 0
    DW_needed = 0
    DW = true
    moving = false
    update_combat_form()
    determine_haste_group()
end

-- Erases the Key Binds above when you switch to another job.
function user_unload()
    send_command('unbind ^`')
    send_command('unbind !`')
    send_command('unbind !-')
    send_command('unbind ^=')
    send_command('unbind f11')
    send_command('unbind @c')
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Precast Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.Enmity = {
        head = "Highwing Helm",
        neck = "Unmoving Collar +1",
        hands = "Kurys Gloves",
        ear2 = "Friomisi Earring",
        ring1 = "Petrov Ring",
        body = "Emet Harness +1",
        legs = "Samnuha Tights",
        feet = "Ahosi Leggings"
    }

    sets.precast.JA['Provoke'] = sets.Enmity
    sets.precast.JA['No Foot Rise'] = {
        body = "Horos Casaque +2"
    }
    sets.precast.JA['Trance'] = {
        head = "Horos Tiara +3"
    }

    sets.precast.Waltz = {}

    sets.precast.WaltzSelf = set_combine(sets.precast.Waltz, {
        ring1 = "Asklepian Ring"
    })
    sets.precast.Waltz['Healing Waltz'] = {}
    sets.precast.Samba = {}
    sets.precast.Jig = {}

    sets.precast.Step = {}
    sets.precast.Step['Feather Step'] = set_combine(sets.precast.Step, {})

    sets.precast.Flourish1 = {}
    sets.precast.Flourish1['Animated Flourish'] = sets.Enmity
    sets.precast.Flourish1['Violent Flourish'] = {}
    sets.precast.Flourish1['Desperate Flourish'] = {}

    sets.precast.Flourish2 = {}
    sets.precast.Flourish2['Reverse Flourish'] = {
        hands = "Macu. Bangles +1",
        back = "Toetapper Mantle"
    }

    sets.precast.Flourish3 = {}
    sets.precast.Flourish3['Striking Flourish'] = {}
    sets.precast.Flourish3['Climactic Flourish'] = {
        head = "Maculele Tiara +1"
    }

    sets.precast.FC = {}

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {
        neck = "Magoraga Beads"
    })

    ------------------------------------------------------------------------------------------------
    ------------------------------------- Weapon Skill Sets ----------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.precast.WS = {
        head = "Ken. Jinpachi",
        body = "Mummu Jacket +2",
        hands = "Mummu Wrists +2",
        legs = "Hizamaru Sune-Ate +2",
        feet = "Ken. Sune-Ate",
        neck = "Fotia Gorget",
        waist = "Fotia Belt",
        left_ear = "Moonshade Earring",
        right_ear = "Brutal Earring",
        left_ring = "Epona's Ring",
        right_ring = "Chirich Ring",
        back = {
            name = "Andartia's Mantle",
            augments = {'DEX+20', 'Accuracy+20 Attack+20', '"Dbl.Atk."+10'}
        }
    }

    sets.precast.WS.Acc = set_combine(sets.precast.WS, {})

    sets.precast.WS.Critical = {
        body = "Meg. Cuirie +2"
    }

    sets.precast.WS['Blade: Ten'] = {
        head = "Ken. Jinpachi",
        body = "Mummu Jacket +2",
        hands = "Mummu Wrists +2",
        legs = "Hizamaru Sune-Ate +2",
        feet = "Ken. Sune-Ate",
        neck = "Fotia Gorget",
        waist = "Fotia Belt",
        left_ear = "Moonshade Earring",
        right_ear = "Brutal Earring",
        left_ring = "Epona's Ring",
        right_ring = "Chirich Ring",
        back = {
            name = "Andartia's Mantle",
            augments = {'DEX+20', 'Accuracy+20 Attack+20', '"Dbl.Atk."+10'}
        }
    }

    sets.precast.WS['Blade: Yu'] = {
        main = "Kaja Katana",
        sub = "Ternion Dagger +1",
        ammo = "Date Shuriken",
        head = {
            name = "Mochi. Hatsuburi +2",
            augments = {'Enhances "Yonin" and "Innin" effect'}
        },
        body = "Mummu Jacket +2",
        hands = "Mummu Wrists +2",
        legs = {
            name = "Mochi. Hakama +2",
            augments = {'Enhances "Mijin Gakure" effect'}
        },
        feet = "Mummu Gamash. +2",
        neck = "Moonbeam Nodowa",
        waist = "Windbuffet Belt",
        left_ear = "Moonshade Earring",
        right_ear = "Friomisi Earring",
        left_ring = "Acumen Ring",
        right_ring = "Shiva Ring",
        back = {
            name = "Andartia's Mantle",
            augments = {'INT+11', '"Mag.Atk.Bns."+10'}
        }
    }

    -- sets.precast.WS['Exenterator'].Acc = set_combine(sets.precast.WS['Exenterator'], {})

    sets.precast.WS['Pyrrhic Kleos'] = {}

    sets.precast.WS['Pyrrhic Kleos'].Acc = set_combine(sets.precast.WS['Pyrrhic Kleos'], {})

    sets.precast.WS['Evisceration'] = {}

    sets.precast.WS['Evisceration'].Acc = set_combine(sets.precast.WS['Evisceration'], {})

    sets.precast.WS['Rudra\'s Storm'] = {}

    sets.precast.WS['Rudra\'s Storm'].Acc = set_combine(sets.precast.WS['Rudra\'s Storm'], {})

    sets.precast.WS['Aeolian Edge'] = {}

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Midcast Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.midcast.FastRecast = sets.precast.FC
    sets.midcast.SpellInterrupt = {}
    sets.midcast.Utsusemi = sets.midcast.SpellInterrupt
    sets.midcast.EleJutsu = {
        main = "Kaja Katana",
        sub = "Ternion Dagger +1",
        ammo = "Date Shuriken",
        head = {
            name = "Mochi. Hatsuburi +2",
            augments = {'Enhances "Yonin" and "Innin" effect'}
        },
        body = "Mummu Jacket +2",
        hands = "Mummu Wrists +2",
        legs = "Mummu Kecks +2",
        feet = "Mummu Gamash. +2",
        neck = "Twilight Torque",
        waist = "Windbuffet Belt",
        left_ear = "Hecate's Earring",
        right_ear = "Friomisi Earring",
        left_ring = "Acumen Ring",
        right_ring = "Shiva Ring",
        back = {
            name = "Andartia's Mantle",
            augments = {'INT+11', '"Mag.Atk.Bns."+10'}
        }
    }

    ------------------------------------------------------------------------------------------------
    ----------------------------------------- Idle Sets --------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.idle = {}

    sets.idle.Town = {}

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Engaged Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------
    -- This is a Set that would only be used when you are NOT Dual Wielding.  Most likely Airy Buckler Builds with Fencer as War Sub.
    -- There are no haste parameters set for this build, because you wouldn't be juggling DW gear, you would always use the same gear, other than Damage Taken and Accuracy sets which ARE included below.
    sets.engaged = {
        main = "Kaja Katana",
        sub = "Ternion Dagger +1",
        ammo = "Date Shuriken",
        head = {
            name = "Ryuo Somen",
            augments = {'HP+50', '"Store TP"+4', '"Subtle Blow"+7'}
        },
        body = {
            name = "Mochi. Chainmail +1",
            augments = {'Enhances "Sange" effect'}
        },
        hands = {
            name = "Adhemar Wristbands",
            augments = {'DEX+10', 'AGI+10', 'Accuracy+15'}
        },
        legs = {
            name = "Mochi. Hakama +2",
            augments = {'Enhances "Mijin Gakure" effect'}
        },
        feet = "Hiza. Sune-Ate +2",
        neck = "Moonbeam Nodowa",
        waist = "Windbuffet Belt",
        left_ear = "Brutal Earring",
        right_ear = "Suppanomimi",
        left_ring = "Epona's Ring",
        right_ring = "Rajas Ring",
        back = {
            name = "Andartia's Mantle",
            augments = {'DEX+20', 'Accuracy+20 Attack+20', '"Dbl.Atk."+10'}
        }
    }

    ------------------------------------------------------------------------------------------------
    -------------------------------------- Dual Wield Sets -----------------------------------------
    ------------------------------------------------------------------------------------------------
    -- * DNC Native DW Trait: 30% DW
    -- * DNC Job Points DW Gift: 5% DW -- If you do not have these JP Gifts, add 5% 'to cap' to each set below)

    -- No Magic Haste (39% DW to cap) -- Reminder that 39% is assuming you already have 5% from Job Points.  44% DW to cap if not.
    sets.engaged.DW = {
        main = "Kaja Katana",
        sub = "Ternion Dagger +1",
        ammo = "Date Shuriken",
        head = {
            name = "Ryuo Somen",
            augments = {'HP+50', '"Store TP"+4', '"Subtle Blow"+7'}
        },
        body = {
            name = "Mochi. Chainmail +1",
            augments = {'Enhances "Sange" effect'}
        },
        hands = "Ken. Tekko",
        legs = {
            name = "Mochi. Hakama +2",
            augments = {'Enhances "Mijin Gakure" effect'}
        },
        feet = {
            name = "Taeon Boots",
            augments = {'"Dual Wield"+2', 'STR+5 DEX+5'}
        },
        neck = "Moonbeam Nodowa",
        waist = "Windbuffet Belt",
        left_ear = "Eabani Earring",
        right_ear = "Suppanomimi",
        left_ring = "Epona's Ring",
        right_ring = "Chirich Ring",
        back = {
            name = "Andartia's Mantle",
            augments = {'DEX+20', 'Accuracy+20 Attack+20', '"Dbl.Atk."+10'}
        }
    }

    -- 15% Magic Haste (32% DW to cap)
    sets.engaged.DW.LowHaste = {
        main = "Kaja Katana",
        sub = "Ternion Dagger +1",
        ammo = "Date Shuriken",
        head = {
            name = "Ryuo Somen",
            augments = {'HP+50', '"Store TP"+4', '"Subtle Blow"+7'}
        },
        body = {
            name = "Mochi. Chainmail +1",
            augments = {'Enhances "Sange" effect'}
        },
        hands = "Ken. Tekko",
        legs = {
            name = "Mochi. Hakama +2",
            augments = {'Enhances "Mijin Gakure" effect'}
        },
        feet = "Hiza. Sune-Ate +2",
        neck = "Moonbeam Nodowa",
        waist = "Windbuffet Belt",
        left_ear = "Steelflash Earring",
        right_ear = "Brutal Earring",
        left_ring = "Epona's Ring",
        right_ring = "Chirich Ring",
        back = {
            name = "Andartia's Mantle",
            augments = {'DEX+20', 'Accuracy+20 Attack+20', '"Dbl.Atk."+10'}
        }
    }

    -- 30% Magic Haste (21% DW to cap)
    sets.engaged.DW.MidHaste = {
        main = "Kaja Katana",
        sub = "Ternion Dagger +1",
        ammo = "Date Shuriken",
        head = {
            name = "Ryuo Somen",
            augments = {'HP+50', '"Store TP"+4', '"Subtle Blow"+7'}
        },
        body = "Ken. Samue",
        hands = "Ken. Tekko",
        legs = {
            name = "Mochi. Hakama +2",
            augments = {'Enhances "Mijin Gakure" effect'}
        },
        feet = "Ken. Sune-Ate",
        neck = "Moonbeam Nodowa",
        waist = "Windbuffet Belt",
        left_ear = "Eabani Earring",
        right_ear = "Brutal Earring",
        left_ring = "Epona's Ring",
        right_ring = "Chirich Ring",
        back = {
            name = "Andartia's Mantle",
            augments = {'DEX+20', 'Accuracy+20 Attack+20', '"Dbl.Atk."+10'}
        }
    }

    -- 35% Magic Haste (16% DW to cap)
    sets.engaged.DW.HighHaste = {
        main = "Kaja Katana",
        sub = "Ternion Dagger +1",
        ammo = "Date Shuriken",
        head = "Ken. Jinpachi",
        body = {
            name = "Mochi. Chainmail +1",
            augments = {'Enhances "Sange" effect'}
        },
        hands = "Ken. Tekko",
        legs = {
            name = "Mochi. Hakama +2",
            augments = {'Enhances "Mijin Gakure" effect'}
        },
        feet = "Ken. Sune-Ate",
        neck = "Moonbeam Nodowa",
        waist = "Windbuffet Belt",
        left_ear = "Steelflash Earring",
        right_ear = "Brutal Earring",
        left_ring = "Epona's Ring",
        right_ring = "Chirich Ring",
        back = {
            name = "Andartia's Mantle",
            augments = {'DEX+20', 'Accuracy+20 Attack+20', '"Dbl.Atk."+10'}
        }
    } -- 16% Gear

    -- 45% Magic Haste (1% DW to cap)
    sets.engaged.DW.MaxHaste = {
        main = "Kaja Katana",
        sub = "Ternion Dagger +1",
        ammo = "Date Shuriken",
        head = "Ken. Jinpachi",
        body = "Ken. Samue",
        hands = "Ken. Tekko",
        legs = "Ken. Hakama",
        feet = "Ken. Sune-Ate",
        neck = "Moonbeam Nodowa",
        waist = "Windbuffet Belt",
        left_ear = "Steelflash Earring",
        right_ear = "Brutal Earring",
        left_ring = "Epona's Ring",
        right_ring = "Chirich Ring",
        back = {
            name = "Andartia's Mantle",
            augments = {'DEX+20', 'Accuracy+20 Attack+20', '"Dbl.Atk."+10'}
        }
    }

    ------------------------------------------------------------------------------------------------
    --------------------------------------- Accuracy Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------
    -- Define three tiers of Accuracy.  These sets are cycled with the F9 Button to increase accuracy in stages as desired.
    sets.engaged.Acc1 = {}
    sets.engaged.Acc2 = {}
    sets.engaged.Acc3 = {}
    -- Base Shield
    sets.engaged.LowAcc = set_combine(sets.engaged, sets.engaged.Acc1)
    sets.engaged.MidAcc = set_combine(sets.engaged, sets.engaged.Acc2)
    sets.engaged.HighAcc = set_combine(sets.engaged, sets.engaged.Acc3)
    -- Base DW
    sets.engaged.DW.LowAcc = set_combine(sets.engaged.DW, sets.engaged.Acc1)
    sets.engaged.DW.MidAcc = set_combine(sets.engaged.DW, sets.engaged.Acc2)
    sets.engaged.DW.HighAcc = set_combine(sets.engaged.DW, sets.engaged.Acc3)
    -- LowHaste DW
    sets.engaged.DW.LowAcc.LowHaste = set_combine(sets.engaged.DW.LowHaste, sets.engaged.Acc1)
    sets.engaged.DW.MidAcc.LowHaste = set_combine(sets.engaged.DW.LowHaste, sets.engaged.Acc2)
    sets.engaged.DW.HighAcc.LowHaste = set_combine(sets.engaged.DW.LowHaste, sets.engaged.Acc3)
    -- MidHaste DW
    sets.engaged.DW.LowAcc.MidHaste = set_combine(sets.engaged.DW.MidHaste, sets.engaged.Acc1)
    sets.engaged.DW.MidAcc.MidHaste = set_combine(sets.engaged.DW.MidHaste, sets.engaged.Acc2)
    sets.engaged.DW.HighAcc.MidHaste = set_combine(sets.engaged.DW.MidHaste, sets.engaged.Acc3)
    -- HighHaste DW
    sets.engaged.DW.LowAcc.HighHaste = set_combine(sets.engaged.DW.HighHaste, sets.engaged.Acc1)
    sets.engaged.DW.MidAcc.HighHaste = set_combine(sets.engaged.DW.HighHaste, sets.engaged.Acc2)
    sets.engaged.DW.HighAcc.HighHaste = set_combine(sets.engaged.DW.HighHaste, sets.engaged.Acc3)
    -- HighHaste DW
    sets.engaged.DW.LowAcc.MaxHaste = set_combine(sets.engaged.DW.MaxHaste, sets.engaged.LowAcc)
    sets.engaged.DW.MidAcc.MaxHaste = set_combine(sets.engaged.DW.MaxHaste, sets.engaged.MidAcc)
    sets.engaged.DW.HighAcc.MaxHaste = set_combine(sets.engaged.DW.MaxHaste, sets.engaged.HighAcc)

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Hybrid Sets -------------------------------------------
    ------------------------------------------------------------------------------------------------
    -- Define three tiers of Defense Taken.  These sets are cycled with the F10 Button. DT1-X%, DT2-X%, DT3-X%
    sets.engaged.DT1 = {}
    sets.engaged.DT2 = {}
    sets.engaged.DT3 = {}

    -- Shield Base
    sets.engaged.LOW = set_combine(sets.engaged, sets.engaged.DT1)
    sets.engaged.LowAcc.LOW = set_combine(sets.engaged.LowAcc, sets.engaged.DT1)
    sets.engaged.MidAcc.LOW = set_combine(sets.engaged.MidAcc, sets.engaged.DT1)
    sets.engaged.HighAcc.LOW = set_combine(sets.engaged.HighAcc, sets.engaged.DT1)

    sets.engaged.MID = set_combine(sets.engaged, sets.engaged.DT2)
    sets.engaged.LowAcc.MID = set_combine(sets.engaged.LowAcc, sets.engaged.DT2)
    sets.engaged.MidAcc.MID = set_combine(sets.engaged.MidAcc, sets.engaged.DT2)
    sets.engaged.HighAcc.MID = set_combine(sets.engaged.HighAcc, sets.engaged.DT2)

    sets.engaged.HIGH = set_combine(sets.engaged, sets.engaged.DT3)
    sets.engaged.LowAcc.HIGH = set_combine(sets.engaged.LowAcc, sets.engaged.DT3)
    sets.engaged.MidAcc.HIGH = set_combine(sets.engaged.MidAcc, sets.engaged.DT3)
    sets.engaged.HighAcc.HIGH = set_combine(sets.engaged.HighAcc, sets.engaged.DT3)
    -- No Haste DW
    sets.engaged.DW.LOW = set_combine(sets.engaged.DW, sets.engaged.DT1)
    sets.engaged.DW.LowAcc.LOW = set_combine(sets.engaged.DW.LowAcc, sets.engaged.DT1)
    sets.engaged.DW.MidAcc.LOW = set_combine(sets.engaged.DW.MidAcc, sets.engaged.DT1)
    sets.engaged.DW.HighAcc.LOW = set_combine(sets.engaged.DW.HighAcc, sets.engaged.DT1)

    sets.engaged.DW.MID = set_combine(sets.engaged.DW, sets.engaged.DT2)
    sets.engaged.DW.LowAcc.MID = set_combine(sets.engaged.DW.LowAcc, sets.engaged.DT2)
    sets.engaged.DW.MidAcc.MID = set_combine(sets.engaged.DW.MidAcc, sets.engaged.DT2)
    sets.engaged.DW.HighAcc.MID = set_combine(sets.engaged.DW.HighAcc, sets.engaged.DT2)

    sets.engaged.DW.HIGH = set_combine(sets.engaged.DW, sets.engaged.DT3)
    sets.engaged.DW.LowAcc.HIGH = set_combine(sets.engaged.DW.LowAcc, sets.engaged.DT3)
    sets.engaged.DW.MidAcc.HIGH = set_combine(sets.engaged.DW.MidAcc, sets.engaged.DT3)
    sets.engaged.DW.HighAcc.HIGH = set_combine(sets.engaged.DW.HighAcc, sets.engaged.DT3)
    -- Low Haste DW
    sets.engaged.DW.LOW.LowHaste = set_combine(sets.engaged.DW.LowHaste, sets.engaged.DT1)
    sets.engaged.DW.LowAcc.LOW.LowHaste = set_combine(sets.engaged.DW.LowAcc.LowHaste, sets.engaged.DT1)
    sets.engaged.DW.MidAcc.LOW.LowHaste = set_combine(sets.engaged.DW.MidAcc.LowHaste, sets.engaged.DT1)
    sets.engaged.DW.HighAcc.LOW.LowHaste = set_combine(sets.engaged.DW.HighAcc.LowHaste, sets.engaged.DT1)

    sets.engaged.DW.MID.LowHaste = set_combine(sets.engaged.DW.LowHaste, sets.engaged.DT2)
    sets.engaged.DW.LowAcc.MID.LowHaste = set_combine(sets.engaged.DW.LowAcc.LowHaste, sets.engaged.DT2)
    sets.engaged.DW.MidAcc.MID.LowHaste = set_combine(sets.engaged.DW.MidAcc.LowHaste, sets.engaged.DT2)
    sets.engaged.DW.HighAcc.MID.LowHaste = set_combine(sets.engaged.DW.HighAcc.LowHaste, sets.engaged.DT2)

    sets.engaged.DW.HIGH.LowHaste = set_combine(sets.engaged.DW.LowHaste, sets.engaged.DT3)
    sets.engaged.DW.LowAcc.HIGH.LowHaste = set_combine(sets.engaged.DW.LowAcc.LowHaste, sets.engaged.DT3)
    sets.engaged.DW.MidAcc.HIGH.LowHaste = set_combine(sets.engaged.DW.MidAcc.LowHaste, sets.engaged.DT3)
    sets.engaged.DW.HighAcc.HIGH.LowHaste = set_combine(sets.engaged.DW.HighAcc.LowHaste, sets.engaged.DT3)
    -- Mid Haste
    sets.engaged.DW.LOW.MidHaste = set_combine(sets.engaged.DW.MidHaste, sets.engaged.DT1)
    sets.engaged.DW.LowAcc.LOW.MidHaste = set_combine(sets.engaged.DW.LowAcc.MidHaste, sets.engaged.DT1)
    sets.engaged.DW.MidAcc.LOW.MidHaste = set_combine(sets.engaged.DW.MidAcc.MidHaste, sets.engaged.DT1)
    sets.engaged.DW.HighAcc.LOW.MidHaste = set_combine(sets.engaged.DW.HighAcc.MidHaste, sets.engaged.DT1)

    sets.engaged.DW.MID.MidHaste = set_combine(sets.engaged.DW.MidHaste, sets.engaged.DT2)
    sets.engaged.DW.LowAcc.MID.MidHaste = set_combine(sets.engaged.DW.LowAcc.MidHaste, sets.engaged.DT2)
    sets.engaged.DW.MidAcc.MID.MidHaste = set_combine(sets.engaged.DW.MidAcc.MidHaste, sets.engaged.DT2)
    sets.engaged.DW.HighAcc.MID.MidHaste = set_combine(sets.engaged.DW.HighAcc.MidHaste, sets.engaged.DT2)

    sets.engaged.DW.HIGH.MidHaste = set_combine(sets.engaged.DW.MidHaste, sets.engaged.DT3)
    sets.engaged.DW.LowAcc.HIGH.MidHaste = set_combine(sets.engaged.DW.LowAcc.MidHaste, sets.engaged.DT3)
    sets.engaged.DW.MidAcc.HIGH.MidHaste = set_combine(sets.engaged.DW.MidAcc.MidHaste, sets.engaged.DT3)
    sets.engaged.DW.HighAcc.HIGH.MidHaste = set_combine(sets.engaged.DW.HighAcc.MidHaste, sets.engaged.DT3)
    -- High Haste
    sets.engaged.DW.LOW.HighHaste = set_combine(sets.engaged.DW.HighHaste, sets.engaged.DT1)
    sets.engaged.DW.LowAcc.LOW.HighHaste = set_combine(sets.engaged.DW.LowAcc.HighHaste, sets.engaged.DT1)
    sets.engaged.DW.MidAcc.LOW.HighHaste = set_combine(sets.engaged.DW.MidAcc.HighHaste, sets.engaged.DT1)
    sets.engaged.DW.HighAcc.LOW.HighHaste = set_combine(sets.engaged.DW.HighAcc.HighHaste, sets.engaged.DT1)

    sets.engaged.DW.MID.HighHaste = set_combine(sets.engaged.DW.HighHaste, sets.engaged.DT2)
    sets.engaged.DW.LowAcc.MID.HighHaste = set_combine(sets.engaged.DW.LowAcc.HighHaste, sets.engaged.DT2)
    sets.engaged.DW.MidAcc.MID.HighHaste = set_combine(sets.engaged.DW.MidAcc.HighHaste, sets.engaged.DT2)
    sets.engaged.DW.HighAcc.MID.HighHaste = set_combine(sets.engaged.DW.HighAcc.HighHaste, sets.engaged.DT2)

    sets.engaged.DW.HIGH.HighHaste = set_combine(sets.engaged.DW.HighHaste, sets.engaged.DT3)
    sets.engaged.DW.LowAcc.HIGH.HighHaste = set_combine(sets.engaged.DW.LowAcc.HighHaste, sets.engaged.DT3)
    sets.engaged.DW.MidAcc.HIGH.HighHaste = set_combine(sets.engaged.DW.MidAcc.HighHaste, sets.engaged.DT3)
    sets.engaged.DW.HighAcc.HIGH.HighHaste = set_combine(sets.engaged.DW.HighAcc.HighHaste, sets.engaged.DT3)
    -- Max Haste
    sets.engaged.DW.LOW.MaxHaste = set_combine(sets.engaged.DW.MaxHaste, sets.engaged.DT1)
    sets.engaged.DW.LowAcc.LOW.MaxHaste = set_combine(sets.engaged.DW.LowAcc.MaxHaste, sets.engaged.DT1)
    sets.engaged.DW.MidAcc.LOW.MaxHaste = set_combine(sets.engaged.DW.MidAcc.MaxHaste, sets.engaged.DT1)
    sets.engaged.DW.HighAcc.LOW.MaxHaste = set_combine(sets.engaged.DW.HighAcc.MaxHaste, sets.engaged.DT1)

    sets.engaged.DW.MID.MaxHaste = set_combine(sets.engaged.DW.MaxHaste, sets.engaged.DT2)
    sets.engaged.DW.LowAcc.MID.MaxHaste = set_combine(sets.engaged.DW.LowAcc.MaxHaste, sets.engaged.DT2)
    sets.engaged.DW.MidAcc.MID.MaxHaste = set_combine(sets.engaged.DW.MidAcc.MaxHaste, sets.engaged.DT2)
    sets.engaged.DW.HighAcc.MID.MaxHaste = set_combine(sets.engaged.DW.HighAcc.MaxHaste, sets.engaged.DT2)

    sets.engaged.DW.HIGH.MaxHaste = set_combine(sets.engaged.DW.MaxHaste, sets.engaged.DT3)
    sets.engaged.DW.LowAcc.HIGH.MaxHaste = set_combine(sets.engaged.DW.LowAcc.MaxHaste, sets.engaged.DT3)
    sets.engaged.DW.MidAcc.HIGH.MaxHaste = set_combine(sets.engaged.DW.MidAcc.MaxHaste, sets.engaged.DT3)
    sets.engaged.DW.HighAcc.HIGH.MaxHaste = set_combine(sets.engaged.DW.HighAcc.MaxHaste, sets.engaged.DT3)

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Special Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    --  sets.buff['Saber Dance'] = {legs="Horos Tights +3"}
    --  sets.buff['Fan Dance'] = {hands="Horos Bangles +3"}
    sets.buff['Climactic Flourish'] = {
        head = "Maculele Tiara +1",
        body = "Meg. Cuirie +2"
    }
    --  sets.buff['Closed Position'] = {feet="Horos T. Shoes +3"}

    sets.buff.Doom = {}

    sets.CP = {
        back = "Mecisto. Mantle"
    }

end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    if spellMap == 'Utsusemi' then
        if buffactive['Copy Image (3)'] or buffactive['Copy Image (4+)'] then
            cancel_spell()
            add_to_chat(123, '**!! ' .. spell.english .. ' Canceled: [3+ IMAGES] !!**')
            eventArgs.handled = true
            return
        elseif buffactive['Copy Image'] or buffactive['Copy Image (2)'] then
            send_command('cancel 66; cancel 444; cancel Copy Image; cancel Copy Image (2)')
        end
    end

    -- Used to overwrite Moonshade Earring if TP is more than 2750.
    if spell.type == 'WeaponSkill' then
        if player.tp > 2750 then
            equip({
                right_ear = "Sherida Earring"
            })
        end
    end

    -- Used to optimize Rudra's Storm when Climactic Flourish is active.
    if spell.type == 'WeaponSkill' then
        if spell.english == "Rudra's Storm" and buffactive['Climactic Flourish'] then
            equip({
                head = "Maculele Tiara +1",
                left_ear = "Ishvara Earring"
            })
        end
    end

    -- Forces Maculele Tiara +1 to override your WS Head slot if Climactic Flourish is active.	Corresponds with sets.buff['Climactic Flourish'].
    if spell.type == "WeaponSkill" then
        if state.Buff['Climactic Flourish'] then
            equip(sets.buff['Climactic Flourish'])
        end
    end
end

function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == "WeaponSkill" then
        if state.Buff['Sneak Attack'] == true then
            equip(sets.precast.WS.Critical)
        end
        if state.Buff['Climactic Flourish'] then
            equip(sets.buff['Climactic Flourish'])
        end
    end
    if spell.type == 'Waltz' and spell.target.type == 'SELF' then
        equip(sets.precast.WaltzSelf)
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Weaponskills wipe SATA.  Turn those state vars off before default gearing is attempted.
    if spell.type == 'WeaponSkill' and not spell.interrupted then
        state.Buff['Sneak Attack'] = false
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------
function job_buff_change(buff, gain)
    if buff == 'Saber Dance' or buff == 'Climactic Flourish' or buff == 'Fan Dance' then
        handle_equipping_gear(player.status)
    end

    if buff == "doom" then
        if gain then
            equip(sets.buff.Doom)
            send_command('@input /p Doomed.')
            disable()
        else
            enable()
            handle_equipping_gear(player.status)
        end
    end

end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------
function job_handle_equipping_gear(playerStatus, eventArgs)
    update_combat_form()
    determine_haste_group()
end

function job_update(cmdParams, eventArgs)
    handle_equipping_gear(player.status)
end

function update_combat_form()
    if DW == true then
        state.CombatForm:set('DW')
    elseif DW == false then
        state.CombatForm:reset()
    end
end

function get_custom_wsmode(spell, spellMap, defaut_wsmode)
    local wsmode

    if state.Buff['Sneak Attack'] then
        wsmode = 'SA'
    end

    return wsmode
end

function customize_idle_set(idleSet)
    if state.CP.current == 'on' then
        equip(sets.CP)
        disable('back')
    else
        enable('back')
    end

    return idleSet
end

function customize_melee_set(meleeSet)
    if state.Buff['Climactic Flourish'] then
        meleeSet = set_combine(meleeSet, sets.buff['Climactic Flourish'])
    end
    if state.ClosedPosition.value == true then
        meleeSet = set_combine(meleeSet, sets.buff['Closed Position'])
    end

    return meleeSet
end

-- Handle auto-targetting based on local setup.
function job_auto_change_target(spell, action, spellMap, eventArgs)
    if spell.type == 'Step' then
        if state.IgnoreTargetting.value == true then
            state.IgnoreTargetting:reset()
            eventArgs.handled = true
        end

        eventArgs.SelectNPCTargets = state.SelectStepTarget.value
    end
end

-- Function to display the current relevant user state when doing an update.
-- Set eventArgs.handled to true if display was handled, and you don't want the default info shown.
function display_current_job_state(eventArgs)
    local msg = '[ Melee'

    if state.CombatForm.has_value then
        msg = msg .. ' (' .. state.CombatForm.value .. ')'
    end

    msg = msg .. ': '

    msg = msg .. state.OffenseMode.value
    if state.HybridMode.value ~= 'Normal' then
        msg = msg .. '/' .. state.HybridMode.value
    end
    msg = msg .. ' ][ WS: ' .. state.WeaponskillMode.value .. ' ]'

    if state.DefenseMode.value ~= 'None' then
        msg =
            msg .. '[ Defense: ' .. state.DefenseMode.value .. state[state.DefenseMode.value .. 'DefenseMode'].value ..
                ' ]'
    end

    if state.ClosedPosition.value then
        msg = msg .. '[ Closed Position: ON ]'
    end

    if state.Kiting.value then
        msg = msg .. '[ Kiting Mode: ON ]'
    end

    msg = msg .. '[ ' .. state.MainStep.current

    if state.UseAltStep.value == true then
        msg = msg .. '/' .. state.AltStep.current
    end

    msg = msg .. ' ]'

    add_to_chat(060, msg)

    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- User self-commands.
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

function determine_haste_group()
    classes.CustomMeleeGroups:clear()
    if DW == true then
        if DW_needed <= 1 then
            classes.CustomMeleeGroups:append('MaxHaste')
        elseif DW_needed > 1 and DW_needed <= 9 then
            classes.CustomMeleeGroups:append('HighHaste')
        elseif DW_needed > 9 and DW_needed <= 21 then
            classes.CustomMeleeGroups:append('MidHaste')
        elseif DW_needed > 21 and DW_needed <= 39 then
            classes.CustomMeleeGroups:append('LowHaste')
        elseif DW_needed > 39 then
            classes.CustomMeleeGroups:append('')
        end
    end
end

function job_self_command(cmdParams, eventArgs)
    if cmdParams[1] == 'step' then
        if cmdParams[2] == 't' then
            state.IgnoreTargetting:set()
        end

        local doStep = ''
        if state.UseAltStep.value == true then
            doStep = state[state.CurrentStep.current .. 'Step'].current
            state.CurrentStep:cycle()
        else
            doStep = state.MainStep.current
        end

        send_command('@input /ja "' .. doStep .. '" <t>')
    end
    gearinfo(cmdParams, eventArgs)
end

function gearinfo(cmdParams, eventArgs)
    if cmdParams[1] == 'gearinfo' then
        if type(tonumber(cmdParams[2])) == 'number' then
            if tonumber(cmdParams[2]) ~= DW_needed then
                DW_needed = tonumber(cmdParams[2])
                DW = true
            end
        elseif type(cmdParams[2]) == 'string' then
            if cmdParams[2] == 'false' then
                DW_needed = 0
                DW = false
            end
        end
        if type(tonumber(cmdParams[3])) == 'number' then
            if tonumber(cmdParams[3]) ~= Haste then
                Haste = tonumber(cmdParams[3])
            end
        end
        if type(cmdParams[4]) == 'string' then
            if cmdParams[4] == 'true' then
                moving = true
            elseif cmdParams[4] == 'false' then
                moving = false
            end
        end
        if not midaction() then
            job_update()
        end
    end
end

-- If you attempt to use a step, this will automatically use Presto if you are under 5 Finishing moves and resend step.
function job_pretarget(spell, action, spellMap, eventArgs)
    if spell.type == 'Step' then
        local allRecasts = windower.ffxi.get_ability_recasts()
        local prestoCooldown = allRecasts[236]
        local under5FMs = not buffactive['Finishing Move 5'] and not buffactive['Finishing Move (6+)']

        if player.main_job_level >= 77 and prestoCooldown < 1 and under5FMs then
            cast_delay(1.1)
            send_command('input /ja "Presto" <me>')
        end
    end

    -- If you attempt to use Climactic Flourish with zero finishing moves, this will automatically use Box Step and then resend Climactic Flourish.	
    local under1FMs = not buffactive['Finishing Move 1'] and not buffactive['Finishing Move 2'] and
                          not buffactive['Finishing Move 3'] and not buffactive['Finishing Move 4'] and
                          not buffactive['Finishing Move 5'] and not buffactive['Finishing Move (6+)']

    if spell.english == "Climactic Flourish" and under1FMs then
        cast_delay(1.9)
        send_command('input /ja "Box Step" <t>')
    end
end

-- My Waltz Rules to Overwrite Mote's
-- My Current Waltz Amounts: I:372 II:697 III:1134
function refine_waltz(spell, action, spellMap, eventArgs)
    if missingHP ~= nil then
        if player.main_job == 'DNC' then
            if missingHP < 40 and spell.target.name == player.name then
                -- Not worth curing yourself for so little.
                -- Don't block when curing others to allow for waking them up.
                add_to_chat(122, 'Full HP!')
                eventArgs.cancel = true
                return
            elseif missingHP < 475 then
                newWaltz = 'Curing Waltz'
                waltzID = 190
            elseif missingHP < 850 then
                newWaltz = 'Curing Waltz II'
                waltzID = 191
            else
                newWaltz = 'Curing Waltz III'
                waltzID = 192
            end
        else
            -- Not dnc main or sub; ignore
            return
        end
    end
end

-- Automatically loads a Macro Set by: (Pallet,Book)
function select_default_macro_book()
    if player.sub_job == 'SAM' then
        set_macro_page(1, 5)
    elseif player.sub_job == 'WAR' then
        set_macro_page(2, 5)
    elseif player.sub_job == 'RUN' then
        set_macro_page(3, 5)
    elseif player.sub_job == 'BLU' then
        set_macro_page(4, 5)
    elseif player.sub_job == 'THF' then
        set_macro_page(9, 5)
    elseif player.sub_job == 'NIN' then
        set_macro_page(10, 5)
        -- 
    else
        set_macro_page(2, 5)
    end
end

function set_lockstyle()
    send_command('wait 2; input /lockstyleset ' .. lockstyleset)
end
