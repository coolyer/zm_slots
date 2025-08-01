# BO3 Zombies Slot Machine Script

**Author:** Coolyer  
**Please credit if used.**

---

## What is this?

This script adds a slot machine to your Black Ops 3 Zombies map.  
Players can spend points to spin for random rewards such as points, powerups, or even a free weapon!

---

## Installation

1. Drag and drop the `_custom` folder into the main root of your BO3 directory.
2. Add the `zm_slots.gsc` script into your `usermaps/yourmapname/scripts/zm/` folder.
3. Add the required `#using` and `thread` lines to your map's GSC as shown in the script comments.
4. Add the necessary entries to your `.zone` file as shown in the script comments.
5. **Sounds are not included**; you must provide your own sound files for the slot machine effects.

---

## Customization

- **Odds:**  
  At the top of `zm_slots.gsc`, change the `#define ODDS_*` values to adjust how likely each icon is to appear.  
  (Higher number = more likely. All 1 = equal chance.)

- **Spin Price:**  
  Change the `#define PRICE` value at the top to set how many points a spin costs.

- **HUD Position:**  
  Change `#define SLOT_HUD_X` and `#define SLOT_HUD_Y` to move the slot machine HUD on the screen.

---
## ✨ Features

- **Fully functional slot machine** for Black Ops 3 Zombies maps
- **Easy integration** with Radiant and your map’s scripts
- Supports both **weighted odds** (classic slot randomness) and **non-weighted odds** (easy icon editing)
- **Customizable odds** for each icon (`#define ODDS_*` values)
- **Customizable spin price** and pair reward
- **Multiple slot machines** supported per map
- **Customizable HUD position** (`SLOT_HUD_X` and `SLOT_HUD_Y`)
- **Realistic spinning animation:** reels roll and land naturally on the result
- Only the **middle row determines the win**; top and bottom icons are randomized for realism
- **Reward logic** for:
  - 3 of a kind (unique rewards for each icon)
  - 2 of a kind (pair reward)
  - Nothing (lose message and sound)
- **Example rewards:** points, free weapon, powerups (double points, instakill, max ammo), weapon upgrade
- **Easy to add new icons** and new reward effects
- **Sound support** for spinning, reel stop, win, and lose (add your own sounds)
- **Clean, commented code** for easy modification
---
## Credits

**Slot Machine Icons from [Flaticon.com](https://www.flaticon.com/):**

- **Seven, Bell:** IconsNova  
  [Seven](https://www.flaticon.com/free-icon/seven_8616978?term=seven&page=1&position=22&origin=search&related_id=8616978)  
  [Bell](https://www.flaticon.com/free-icon/bell_8616927?term=bell+gambling&page=1&position=3&origin=search&related_id=8616927)

- **Cherry, Lemon:** Smashicons  
  [Cherry](https://www.flaticon.com/free-icon/cherries_3137038?term=cherry&related_id=3137038)  
  [Lemon](https://www.flaticon.com/free-icon/lemon_3137034?related_id=3137034&origin=pack)

- **Bar:** Laura Reen  
  [Bar](https://www.flaticon.com/free-icon/game_15423951?term=bar+gambling&page=1&position=9&origin=search&related_id=15423951)

- **Diamond, Banana, Clover:** Freepik  
  [Diamond](https://www.flaticon.com/free-icon/diamond_408421?term=diamond&related_id=408421)  
  [Banana](https://www.flaticon.com/free-icon/banana_2990510?term=banana&page=1&position=11&origin=search&related_id=2990510)  
  [Clover](https://www.flaticon.com/free-icon/clover_781410?term=clover&page=1&position=2&origin=search&related_id=781410)

- **Coin:** Ian Anandara  
  [Money Bag](https://www.flaticon.com/free-icon/money-bag_3004164?term=money&related_id=3004164)

Special thanks to all the artists above for their free icon resources!  
If you use these icons, please credit the original authors as required by Flaticon’s license.

---

Enjoy and happy mapping!
