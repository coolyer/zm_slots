// Slot Machine Script for Zombies Map
#using scripts\shared\util_shared;
#using scripts\shared\array_shared;
#using scripts\shared\system_shared;
#using scripts\shared\weapons_shared;
#using scripts\shared\player_shared;
#using scripts\zm\_zm_weapons;
#using scripts\shared\aat_shared;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;

#using scripts\codescripts\struct;

#insert scripts\shared\shared.gsh;

#precache("material","cherry");
#precache("material","lemon");
#precache("material","bar");
#precache("material","seven");
#precache("material","bell");
#precache("material","diamond");
#precache("material","clover");
#precache("material","coin");
#precache("material","banana");
// #precache ("material", "myicon");

//-----------------------------
// Slot Machine Configuration
//-----------------------------

// Price & Rewards
#define PRICE         500   // Cost to spin the machine
#define PAIR_REWARD   250   // Reward for a pair
#define SINGLESLOT    false  // true = single row, false = 3x3 grid

// HUD Hint Text
#define SLOT_MACHINE_HINT "Press &&1 to spin the Slot Machine [^3" + PRICE + "^7 points]"
#define LINES_COLOR "black" // Chnage the lines color can use "white"
// Odds (only used if USE_WEIGHTED_ODDS is false)
#define CHANCE_THREE_IN_A_ROW  0.05 // 5% chance for 3 in a row (jackpot)
#define CHANCE_PAIR            0.15 // 15% chance for a pair
// The rest will be "no win"

// Icon List for Non-Weighted Odds
// To add another icon, just add it to the list below (e.g., "banana", "myicon")
#define ICONS_NO_WEIGHT "cherry", "lemon", "bar", "seven", "bell", "clover", "diamond", "coin", "banana"

// Weighted Odds (classic slot machine style)
// Set to true to use Weighted odds false for none weighted
#define USE_WEIGHTED_ODDS false

// Set the weight for each icon (higher = more common)
#define ODDS_CHERRY   1
#define ODDS_LEMON    1
#define ODDS_BAR      1
#define ODDS_SEVEN    1
#define ODDS_BELL     1
#define ODDS_CLOVER   1
#define ODDS_DIAMOND  1
#define ODDS_COIN     1
#define ODDS_BANANA   1
// #define ODDS_MYICON 1   // Example for adding a new icon

// Sound Definitions
#define SLOTREELSTOP  "slot_reel_stop"
#define SLOTSPINNING  "slot_spinning"
#define SLOTLOST      "slot_lose_buzz"
#define SLOTWIN       "slot_win_jingle"

// Slot Machine HUD Position
#define SLOT_HUD_X    0    // Horizontal offset (pixels): negative = left, positive = right
#define SLOT_HUD_Y    0    // Vertical offset (pixels): negative = up, positive = down
/*
    Example: Move HUD to top right
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
       - Add any new icon materials you use (see below).

    ========================
    CUSTOMIZING ODDS & ICONS:
    ========================
    - At the top of this script, set USE_WEIGHTED_ODDS to true or false:
        #define USE_WEIGHTED_ODDS false

    - **Non-weighted odds (recommended for easy editing):**
        - Edit the ICONS_NO_WEIGHT define:
            #define ICONS_NO_WEIGHT "cherry", "lemon", "bar", "seven", "bell", "clover", "diamond", "coin", "banana"
        - To add a new icon, just add it to the list (e.g., "banana", "myicon").
        - The script will automatically use all icons in this list with equal chance.

    - **Weighted odds:**
        - Set USE_WEIGHTED_ODDS to true.
        - Add or edit the ODDS_* defines for each icon at the top of the script:
            #define ODDS_CHERRY 1
            #define ODDS_MYICON 2
        - In the icons array setup (find the "// Weighted odds" comment), add:
            for(i = 0; i < ODDS_MYICON; i++) icons[icons.size] = "myicon";
        - Higher numbers mean the icon appears more often on the reels.

    ========================
    ADDING NEW ICONS:
    ========================
    1. Add your icon to the ICONS_NO_WEIGHT define (for non-weighted odds), or add a new ODDS_* define and for() loop (for weighted odds).
    2. Precache your material at the top of the script:
         #precache("material","myicon");
    3. Add your material to your .zone file:
         material,myicon
    4. Open APE (Asset Property Editor) and, in the GDT browser, search for "gambling" to find all the slot machine icon images.
       - Duplicate an existing icon material.
       - Assign your own custom image/texture to the duplicated material.
       - Be sure to update the material’s image property to use your new icon.
       - Save and build your assets.
    ========================
    ADDING NEW REWARDS:
    ========================
    To add a new effect for a specific icon combo, copy this template and place it
    I have left a commented function just uncomment it if you want to use it.
    with the other reward checks in the reward logic section:

    else if(is_triple(spin_result, "myicon"))
    { 
        player.score += 500;
        IPrintLnBold("3 myicon! +500 points");  
    }
    Replace "myicon" with your icon's name and add your effect code.

    ========================
    NOTES:
    ========================
    - You can have as many slot machines as you want; just give each trigger the targetname "slot_machine".
    - Each machine can be spun independently.
    - Rewards and odds can be customized in this script.
    - Weighted odds = realistic slot odds. Non-weighted odds = easiest for adding/removing icons.

@/

function init_slot_machines()
{
    slot_machines = GetEntArray("slot_machine", "targetname");
    for(i = 0; i < slot_machines.size; i++)
    {
        slot_machines[i] SetHintString(SLOT_MACHINE_HINT);
        slot_machines[i] UseTriggerRequireLookAt();
        slot_machines[i] SetCursorHint("HINT_NOICON");
        slot_machines[i] SetVisibleToAll();
        slot_machines[i] thread slot_machine_trigger_think();
    }
   
}
function get_slot_spin_result(icons)
{
    rand = RandomFloat(1.0);
    spin_result = [];

    if(rand < CHANCE_THREE_IN_A_ROW)
    {
        // Force 3 in a row
        icon = icons[RandomInt(icons.size)];
        spin_result = [];
        spin_result[0] = icon;
        spin_result[1] = icon;
        spin_result[2] = icon;
    }
    else if(rand < CHANCE_THREE_IN_A_ROW + CHANCE_PAIR)
    {
        // Force a pair (two same, one different)
        icon_pair = icons[RandomInt(icons.size)];
        icon_other = icon_pair;
        while(icon_other == icon_pair)
            icon_other = icons[RandomInt(icons.size)];
        // Randomize which position is the odd one
        odd = RandomInt(3);
        for(i = 0; i < 3; i++)
        {
            if(i == odd)
                spin_result[i] = icon_other;
            else
                spin_result[i] = icon_pair;
        } 
    }
    else
    {
        // All different
        pool = [];
        while(pool.size < 3)
        {
            icon = icons[RandomInt(icons.size)];
            is_duplicate = false;
            for(k = 0; k < pool.size; k++)
            {
                if(pool[k] == icon)
                {
                    is_duplicate = true;
                    break;
                }
            }
            if(!is_duplicate)
                pool[pool.size] = icon;
        }
        spin_result = pool;
    }
    return spin_result;
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
    lines = []; // New: store line HUD elements
    if (!IS_TRUE(SINGLESLOT))
    {
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
            // --- Add horizontal lines above and below the middle row ---
            // Top line (between top and middle)
            line_top = NewClientHudElem(player);
            line_top.alignX = "center";
            line_top.alignY = "middle";
            line_top.horzAlign = "center";
            line_top.vertAlign = "middle";
            line_top.x = (i - 1) * 70 + SLOT_HUD_X;
            line_top.y = SLOT_HUD_Y - 35; // halfway between top and middle
            line_top SetShader(LINES_COLOR, 64, 2); // 64px wide, 2px tall line
            line_top.alpha = 0.5;
            lines[lines.size] = line_top;

            // Bottom line (between middle and bottom)
            line_bot = NewClientHudElem(player);
            line_bot.alignX = "center";
            line_bot.alignY = "middle";
            line_bot.horzAlign = "center";
            line_bot.vertAlign = "middle";
            line_bot.x = (i - 1) * 70 + SLOT_HUD_X;
            line_bot.y = SLOT_HUD_Y + 35; // halfway between middle and bottom
            line_bot SetShader(LINES_COLOR, 64, 2);
            line_bot.alpha = 0.5;
            lines[lines.size] = line_bot;
        }
    }
    else
    {
        for(i = 0; i < 3; i++)
        {
            reel[i] = NewClientHudElem(player);
            reel[i].alignX = "center";
            reel[i].alignY = "middle";
            reel[i].horzAlign = "center";
            reel[i].vertAlign = "middle";
            reel[i].x = (i - 1) * 70 + SLOT_HUD_X; // <-- use define for X offset
            reel[i].y = SLOT_HUD_Y;                // <-- use define for Y offset
            reel[i].fontScale = 2.0;
            reel[i].alpha = 1.0;
            reel[i].archived = false;
        }
    }
    //************************
    // Weighted odds         
    // Add new icons here if using weighted odds 
    //************************ 
    icons = [];
    if(IS_TRUE(USE_WEIGHTED_ODDS))
    {
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
        for(i = 0; i < 3; i++)
            spin_result[i] = icons[RandomInt(icons.size)];
    }
    else 
    {
        icons = array(ICONS_NO_WEIGHT);
        spin_result = get_slot_spin_result(icons);
    }

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



    for(i = 0; i < 3; i++)
    {
        // Find the index of the result icon in the icons array
        result_index = 0;
        for(k = 0; k < icons.size; k++)
        {
            if(icons[k] == spin_result[i])
            {
                result_index = k;
                break;
            }
        }
       
        start_index = (result_index - (spins[i] - 1) + icons.size) % icons.size;
        reel_indices[i] = start_index;
    }

    // SPINNING ANIMATION
    for(spin = 0; spin < spins[0]; spin++)
    {
        for(i = 0; i < 3; i++)
        {
            if(spin < spins[i])
            {
                current_index = (reel_indices[i] + spin) % icons.size;
                if (!IS_TRUE(SINGLESLOT))
                {
                    for(j = -1; j <= 1; j++)
                    {
                        icon_index = (current_index + j + icons.size) % icons.size;
                        icon = icons[icon_index];
                        reel[i][j+1] SetShader(icon, 64, 64);
                    }
                }
                else
                {
                    icon = icons[current_index];
                    reel[i] SetShader(icon, 64, 64);
                }
                if(spin == spins[i] - 1)
                {
                    // LAST SPIN: Center is the result, top/bottom are random (not the result)
                    for(j = -1; j <= 1; j++)
                    {
                        if(j == 0)
                            icon = spin_result[i];
                        else
                        {
                            // Pick a random icon that is NOT the result for realism
                            do {
                                icon = icons[RandomInt(icons.size)];
                            } while(icon == spin_result[i]);
                        }
                        reel[i][j+1] SetShader(icon, 64, 64);
                    }
                    player PlayLocalSound(SLOTREELSTOP);
                }
                else
                {
                    // Normal spinning code
                    for(j = -1; j <= 1; j++)
                    {
                        icon_index = (current_index + j + icons.size) % icons.size;
                        icon = icons[icon_index];
                        reel[i][j+1] SetShader(icon, 64, 64);
                    }
                }
            }
        }
        wait(0.12 + (spin * 0.01));
    }

    // ****************
    //  Reward Logic  *
    // ****************
    clear_slot_hud(reel, lines);
    sound_to_play = SLOTWIN;
    
    if(is_triple(spin_result, "seven"))
    {
        player.score += 1000;
        IPrintLnBold("Jackpot! 3 Sevens! +1000 points");
 
        weapon = self getCurrentWeapon();
        upgraded_weapon = zm_weapons::get_upgrade_weapon(weapon);
        if (isDefined(upgraded_weapon))
        {
            self TakeWeapon(weapon);
            self zm_weapons::weapon_give(upgraded_weapon);
            self SwitchToWeapon(upgraded_weapon);
        }
        else
        {
            self IPrintLnBold("No upgraded version found for this weapon!");
        }
        
        //thread effect_upgrade_weapon();
        // can use threads for other functions as well like open door or anything. 

    }
    else if(is_triple(spin_result, "lemon"))
    {
        player.score += 750;
        IPrintLnBold("3 Lemons! +750 points");

    }
    else if(is_triple(spin_result, "bar"))
    { 
        player.score += 500;
        IPrintLnBold("3 Bars! +500 points");
        
    }
    else if(is_triple(spin_result, "cherry"))
    { 
        player.score += 2500;
        IPrintLnBold("3 Cherrys! +2500 points");
    }
    else if(is_triple(spin_result, "bell"))
    {
        IPrintLnBold("3 Bells! Free Gun");
        
        all_weapons = GetArrayKeys(level.zombie_weapons);

        // Pick a random weapon
        rand_index = RandomInt(all_weapons.size);
        random_weapon = all_weapons[rand_index];

        
        
    }
    else if(is_triple(spin_result,"clover"))
    {
        
        IPrintLnBold("3 Clovers! Double Points!");
        thread zm_powerups::specific_powerup_drop("double_points",player.origin);
        
    }
    else if(is_triple(spin_result,"diamond"))
    {
        IPrintLnBold("3 Diamonds! Instakill!");
        thread zm_powerups::specific_powerup_drop("insta_kill",player.origin);
        
    }
    else if(is_triple(spin_result,"coin"))
    {
        
        player.score += 1000;
        IPrintLnBold("3 Coins! +1000 points!");
        
    }
    else if(is_triple(spin_result,"banana"))
    {
        
        IPrintLnBold("3 Bananas! Max Ammo!");
        thread zm_powerups::specific_powerup_drop("full_ammo", player.origin);
        
    }
    /*else if(is_triple(spin_result, "myicon"))
    { 
        player.score += 500;
        IPrintLnBold("3 myicons! +500 points");
        
    }
    */
    // Any two matching (but not three)
    else if(is_pair(spin_result))
    {
    player.score += PAIR_REWARD;
    IPrintLnBold("Two of a kind! +" + PAIR_REWARD + " points");
    }
    // This is the lost part of the reward section
    else
    {
        IPrintLnBold("You lost! Try again!");
        sound_to_play = SLOTLOST;  
    }
    player PlayLocalSound(sound_to_play);

    // Destroy HUD elements
    if (!IS_TRUE(SINGLESLOT))
    {
        for(i = 0; i < 3; i++)
            for(j = 0; j < 3; j++)
                if (isDefined(reel[i][j]) && !isArray(reel[i][j]))
                    reel[i][j] Destroy();
    }
    else
    {
        for(i = 0; i < 3; i++)
            if (isDefined(reel[i]) && !isArray(reel[i]))
                reel[i] Destroy();
    }
    // Destroy horizontal lines
    if (isDefined(lines))
    {
        for(i = 0; i < lines.size; i++)
            if (isDefined(lines[i]) && !isArray(lines[i]))
                lines[i] Destroy();
    }

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

function clear_slot_hud(reel, lines)
{
    // Clear reels
    if (!IS_TRUE(SINGLESLOT))
    {
        for(i = 0; i < 3; i++)
            for(j = 0; j < 3; j++)
                if (isDefined(reel[i][j]) && !isArray(reel[i][j]))
                    reel[i][j] SetText("");
    }
    else
    {
        for(i = 0; i < 3; i++)
            if (isDefined(reel[i]) && !isArray(reel[i]))
                reel[i] SetText("");
    }
    // Destroy lines
    if (isDefined(lines))
    {
        for(i = 0; i < lines.size; i++)
            if (isDefined(lines[i]) && !isArray(lines[i]))
                lines[i] Destroy();
    }
}
function is_triple(spin_result, icon)
{
        return spin_result[0] == icon && spin_result[1] == icon && spin_result[2] == icon;
}
function is_pair(spin_result)
{
    return (
        (spin_result[0] == spin_result[1] && spin_result[0] != spin_result[2]) ||
        (spin_result[0] == spin_result[2] && spin_result[0] != spin_result[1]) ||
        (spin_result[1] == spin_result[2] && spin_result[1] != spin_result[0])
    );
}