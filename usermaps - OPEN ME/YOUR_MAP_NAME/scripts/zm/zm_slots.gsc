// Slot Machine Script for Zombies Map
#using scripts\shared\util_shared;
#using scripts\shared\array_shared;
#using scripts\shared\system_shared;
#using scripts\shared\weapons_shared;
#using scripts\shared\player_shared;
#using scripts\zm\_zm_weapons;
#using scripts\shared\aat_shared;
#using scripts\zm\_zm_powerups;

#precache("material","cherry");
#precache("material","lemon");
#precache("material","bar");
#precache("material","seven");
#precache("material","bell");
#precache("material","diamond");
#precache("material","clover");
#precache("material","coin");
#precache("material","banana");

//Price + Reward
#define PRICE 500 // Change this to whatever price you want the machine to be!
#define PAIR_REWARD 250 // Change this to whatever you want the pair reward to be!
// change these to whatever you want 1 = 10% 2 =20% 
#define ODDS_CHERRY 1
#define ODDS_LEMON  1
#define ODDS_BAR    1
#define ODDS_SEVEN  1
#define ODDS_BELL   1
#define ODDS_CLOVER 1
#define ODDS_DIAMOND 1
#define ODDS_COIN   1
#define ODDS_BANANA 1
// #define ODDS_MYICON 1

// Sound defines change these to the name of the sounds you want to use/call
#define SLOTREELSTOP "slot_reel_stop"
#define SLOTSPINNING "slot_spinning"
#define SLOTLOST "slot_lose_buzz"
#define SLOTWIN "slot_win_jingle"


// SLOT MACHINE HUD POSITION - Change these values to move the slot machine HUD on the screen
#define SLOT_HUD_X 0    // Horizontal offset (pixels)
//   Negative = move left, Positive = move right
#define SLOT_HUD_Y 0    // Vertical offset (pixels)
//   Negative = move up, Positive = move down
/*
This moves it to the top right
#define SLOT_HUD_X 400
#define SLOT_HUD_Y -300
*/
/@
    Author: Coolyer

    ========================
    SLOT MACHINE SCRIPT INFO
    ========================

    This script adds a slot machine to your Zombies map. Players can spend points to spin for random rewards!

    ========================
    INTEGRATION:
    ========================
    1. In Radiant:
       - Place one or more trigger_use entities where you want slot machines.
       - Set their targetname to: slot_machine

    2. In your map's GSC script:
       - Add this line near the top with your other #using lines:
            #using scripts\zm\zm_slots;

       - In your main setup function (e.g., main() or startround()), add:
            thread zm_slots::init_slot_machines();

    3. In your zone file (.zone):
       - Add the following lines:
            scriptparsetree,scripts/zm/zm_slots.gsc
            material,cherry
            material,lemon
            material,bar
            material,seven
            material,bell
            material,diamond
            material,clover
            material,coin
            material,banana

    4. Customizing Odds:
       - At the top of this script, change the ODDS_* defines to adjust how likely each icon is to appear.
         (Higher number = more likely. All 1 = equal chance.)

    5. Customizing Price:
       - Change the PRICE define at the top to set how many points a spin costs.

    ========================
    NOTES:
    ========================
    - You can have as many slot machines as you want; just give each trigger the targetname "slot_machine".
    - Each machine can be spun independently.
    - Rewards and odds can be customized in this script.

    ========================
    ADDING NEW REWARDS:
    ========================
    To add a new effect for a specific icon combo, copy this template and place it
    with the other reward checks in the reward logic section:

    else if(spin_result[0] == "icon" && spin_result[1] == "icon" && spin_result[2] == "icon")
    {
        for(i = 0; i < 3; i++) reel[i] SetText("");
        // Add your custom effect here, for example:
        // player PlayLocalSound(SLOTWIN);
        // player.score += 1234;
        // IPrintLnBold("3 Icons! Custom reward!");
        wait(1.5);
    }

    Replace "icon" with your icon's name and add your effect code
    ========================
    ADDING NEW ICON:
    ========================
    To add a new icon to the slot machine reels:

    1. At the top of this script, add a new odds define for your icon, for example:
         #define ODDS_MYICON 1

    2. Around line 165 (where the icons array is built), add this line:
         for(i = 0; i < ODDS_MYICON; i++) icons[icons.size] = "myicon";

       Replace "MYICON" with your icon's name in all caps, and "myicon" with the actual icon/material name.

    3. Make sure you precache your material at the top:
         #precache("material","myicon");

    4. Add your material to your .zone file:
         material,myicon

    Now your new icon will appear on the slot machine reels!
@/

function init_slot_machines()
{
    slot_machines = GetEntArray("slot_machine", "targetname");
    for(i = 0; i < slot_machines.size; i++)
    {
        slot_machines[i] SetHintString("Press &&1 to spin the Slot Machine [" + PRICE + " points]");
        slot_machines[i] UseTriggerRequireLookAt();
        slot_machines[i] SetCursorHint("HINT_NOICON");
        slot_machines[i] SetVisibleToAll();
        slot_machines[i] thread slot_machine_trigger_think();
    }
}


// Main function to use the slot machine
function slot_machine_use(player, trig)
{
    if(isDefined(trig.is_spinning) && trig.is_spinning)
        return; // ignore new spins

    trig.is_spinning = true;

    if(player.score < PRICE)
    {
        IPrintLnBoldToPlayer(player, "You need " + PRICE + " points to spin!");
        trig.is_spinning = false;
        return;
    }

    player.score -= PRICE;
    player thread show_slot_machine_hud(player, trig);
}

function show_slot_machine_hud(player, trig)
{
    // Create 3x3 HUD elements for the 3 reels (top, middle, bottom)
    reel = [];
    for(i = 0; i < 3; i++)
    {
        reel[i] = [];
        for(j = 0; j < 3; j++)
        {
            reel[i][j] = NewClientHudElem(player);
            reel[i][j].alignX = "center";
            reel[i][j].alignY = "middle";
            reel[i][j].horzAlign = "center";
            reel[i][j].vertAlign = "middle";
            reel[i][j].x = (i - 1) * 70 + SLOT_HUD_X;
            reel[i][j].y = ((j - 1) * 70) + SLOT_HUD_Y; // -1=top, 0=middle, 1=bottom
            reel[i][j].fontScale = 2.0;
            reel[i][j].alpha = 1.0;
            reel[i][j].archived = false;
        }
    }

    icons = [];
    for(i = 0; i < ODDS_CHERRY; i++)  icons[icons.size] = "cherry";
    for(i = 0; i < ODDS_LEMON; i++)   icons[icons.size] = "lemon";
    for(i = 0; i < ODDS_BAR; i++)     icons[icons.size] = "bar";
    for(i = 0; i < ODDS_SEVEN; i++)   icons[icons.size] = "seven";
    for(i = 0; i < ODDS_BELL; i++)    icons[icons.size] = "bell";
    for(i = 0; i < ODDS_CLOVER; i++)  icons[icons.size] = "clover";
    for(i = 0; i < ODDS_DIAMOND; i++) icons[icons.size] = "diamond";
    for(i = 0; i < ODDS_COIN; i++)    icons[icons.size] = "coin";
    for(i = 0; i < ODDS_BANANA; i++)  icons[icons.size] = "banana";

    spin_result = [];

    player PlayLocalSound(SLOTSPINNING);

    // Pick a random start index for each reel
    reel_indices = [];
    for(i = 0; i < 3; i++)
        reel_indices[i] = RandomInt(icons.size);

    // Number of spins for each reel (reel 0 spins longest, reel 2 shortest)
    spins = [];
    spins[spins.size] = 14;
    spins[spins.size] = 10;
    spins[spins.size] = 7;

    for(spin = 0; spin < spins[0]; spin++)
    {
        for(i = 0; i < 3; i++)
        {
            if(spin < spins[i])
            {
                // Advance the reel's index (move the wheel down)
                reel_indices[i] = (reel_indices[i] + 1) % icons.size;

                // Show top, middle, bottom icons for this reel
                for(j = -1; j <= 1; j++)
                {
                    icon_index = (reel_indices[i] + j + icons.size) % icons.size;
                    icon = icons[icon_index];
                    reel[i][j+1] SetShader(icon, 64, 64);
                }

                if(spin == spins[i] - 1)
                {
                    // The icon in the middle row is the result
                    spin_result[i] = icons[reel_indices[i]];
                    player PlayLocalSound(SLOTREELSTOP);
                }
            }
        }
        wait(0.12 + (spin * 0.01));
    }
    // ****************
    //  Reward Logic  *
    // ****************
    if(spin_result[0] == "seven" && spin_result[1] == "seven" && spin_result[2] == "seven")
    {
        for(i = 0; i < 3; i++) reel[i] SetText("");
        player.score += 1000;
        IPrintLnBold("Jackpot! 3 Sevens! +1000 points");
        // Get all weapon objects from level.zombie_weapons
        thread effect_upgrade_weapon();
        player PlayLocalSound("slot_win_jingle");
        wait(1.5);
    }
    else if(spin_result[0] == "lemon" && spin_result[1] == "lemon" && spin_result[2] == "lemon")
    {
        for(i = 0; i < 3; i++) reel[i] SetText("");
        player.score += 750;
        IPrintLnBold("3 Lemons! +750 points");
        player PlayLocalSound(SLOTWIN);
        wait(1.5);
    }
    else if(spin_result[0] == "bar" && spin_result[1] == "bar" && spin_result[2] == "bar")
    {
        for(i = 0; i < 3; i++) reel[i] SetText("");
        player.score += 500;
        IPrintLnBold("3 Bars! +500 points");
        player PlayLocalSound(SLOTWIN);
        wait(1.5);
    }
    else if(spin_result[0] == "cherry" && spin_result[1] == "cherry" && spin_result[2] == "cherry")
    {
        for(i = 0; i < 3; i++) reel[i] SetText("");
        player.score += 2500;
        IPrintLnBold("3 Cherrys! +2500 points");
        player PlayLocalSound(SLOTWIN);
        wait(1.5);
    }
    else if(spin_result[0] == "bell" && spin_result[1] == "bell" && spin_result[2] == "bell")
    {
        for(i = 0; i < 3; i++) reel[i] SetText("");
        IPrintLnBold("3 Bells! Free Gun");
        player PlayLocalSound(SLOTWIN);
        all_weapons = GetArrayKeys(level.zombie_weapons);

        // Pick a random weapon
        rand_index = RandomInt(all_weapons.size);
        random_weapon = all_weapons[rand_index];

        // Give the weapon to the player
        player zm_weapons::weapon_give(random_weapon);
        player SwitchToWeapon(random_weapon);
        wait(1.5);
    }
    else if(spin_result[0] == "clover" && spin_result[1] == "clover" && spin_result[2] == "clover")
    {
        for(i = 0; i < 3; i++) reel[i] SetText("");
        IPrintLnBold("3 Clovers! Double Points!");
        player PlayLocalSound(SLOTWIN);
        thread zm_powerups::specific_powerup_drop("double_points");
        wait(1.5);
    }
    else if(spin_result[0] == "diamond" && spin_result[1] == "diamond" && spin_result[2] == "diamond")
    {
        for(i = 0; i < 3; i++) reel[i] SetText("");
        IPrintLnBold("3 Diamonds! Instakill!");
        player PlayLocalSound(SLOTWIN);
        thread zm_powerups::specific_powerup_drop("insta_kill");
        wait(1.5);
    }
    else if(spin_result[0] == "coin" && spin_result[1] == "coin" && spin_result[2] == "coin")
    {
        for(i = 0; i < 3; i++) reel[i] SetText("");
        player.score += 1000;
        player PlayLocalSound(SLOTWIN);
        IPrintLnBold("3 Coins! +1000 points!");
        wait(1.5);
    }
    else if(spin_result[0] == "banana" && spin_result[1] == "banana" && spin_result[2] == "banana")
    {
        for(i = 0; i < 3; i++) reel[i] SetText("");
        IPrintLnBold("3 Bananas! Max Ammo!");
        player PlayLocalSound(SLOTWIN);
        thread zm_powerups::specific_powerup_drop("full_ammo");
        wait(1.5);
    }
    // Any two matching (but not three)
    else if(
        (spin_result[0] == spin_result[1] && spin_result[0] != spin_result[2]) ||
        (spin_result[0] == spin_result[2] && spin_result[0] != spin_result[1]) ||
        (spin_result[1] == spin_result[2] && spin_result[1] != spin_result[0])
    )
    {
        for(i = 0; i < 3; i++) reel[i] SetText("");
        player.score += PAIR_REWARD;
        IPrintLnBold("Two of a kind! +" + PAIR_REWARD + " points");
        player PlayLocalSound(SLOTWIN);
        wait(1.5);
    }
    else
    {
        for(i = 0; i < 3; i++) reel[i] SetText("");
        IPrintLnBold("You lost! Try again!");
        player PlayLocalSound(SLOTLOST);
        wait(1.5);
    }

    // Destroy HUD elements
    for(i = 0; i < 3; i++)
        for(j = 0; j < 3; j++)
            reel[i][j] Destroy();

    trig.is_spinning = false;
}



function slot_machine_trigger_think()
{
    trig = self;
    while (true)
    {
        trig waittill("trigger", player);
        slot_machine_use(player, trig);
    }
}

function IPrintLnBoldToPlayer(player, msg)
{
    player IPrintLnBold(msg);
}


// This is the effect to allow upgrading weapon and adding AAT.
function effect_upgrade_weapon()
{
    weapon = self getCurrentWeapon();
    upgraded_weapon = zm_weapons::get_upgrade_weapon(weapon); 
    self PlayLocalSound("upgrade");
    // Check if weapon is already PAP
    if (zm_weapons::is_weapon_upgraded(weapon))
    {
        self IPrintLn("^2Weapon is already Pack-a-Punched! Adding a random alternate ammo type...");
        self thread give_random_aat();
        return;
    }
// Only if this exists!
    if(isDefined(upgraded_weapon))
    {
        self TakeWeapon(weapon);
        self zm_weapons::weapon_give(upgraded_weapon);
        self SwitchToWeapon(upgraded_weapon);
    }
}
function give_random_aat()
{
    weapon = self getCurrentWeapon();
    if (!isDefined(weapon)) return;

    // List of AAT mods
    aat_mods = array("zm_aat_blast_furnace", "zm_aat_dead_wire", "zm_aat_fire_works", "zm_aat_thunder_wall","zm_aat_turned");

    // Pick a random AAT
    idx = randomInt(aat_mods.size);
    mod = aat_mods[idx];

   
    // Give the new AAT mod
    self aat::remove(weapon);

    self aat::acquire(weapon, mod);
    self IPrintLnBold("^2You received a random alternate ammo type");
  
}