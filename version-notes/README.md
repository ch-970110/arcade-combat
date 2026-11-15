# Project Log



## I. Prototypes:

* FobVideoPlayer
* Arcade\_Combat
* Arcade\_Combat2\_0
* Arcade\_Combat\_3\_0



## II. Game Version Control \& Update:

* v1.3.0:

  * release - success --released
  * base version of 3.0
* v1.4.1:

  * test - success -- applied
  * updated combat log,
  * equipment list,
  * equipment
* v1.4.2:

  * test - success -- applied
  * added dodge feature
* v1.4.3:

  * test - success -- applied
  * applied KO animation
* v1.5.0:

  * release - success -- released
  * sync dodge animation to dodge cool-bar,
  * changed colour of bars,
  * animated the HP change,
  * altered HUD position
* v1.5.1:

  * test - failed -- pending fix

    * bugs:

      * key-pressed summon
      * all animations failed/not shown
  * 'loop' the game
* v1.5.2

  * test - unsolved -- pending fix

    * bugs:

      * P1 attack animation gone -- fixed
      * combat log down -- fixed
      * HUB layout overlapping -- fixed
      * combat log info occasional colour/type error -- unsolved
      * alignment of equipment description to master design doc -- unsolved
  * test \& fix functionalities of all equipment

    * Mjolnir -- fixed
    * Reaper Sickle -- fixed
    * Cloak of Midnight -- fixed
    * Golden Bell Shield \& Iron Cloth -- fixed
    * Paladin's Shield -- special error
    * Warden's Thornplate -- fixed
    * Heart of Verdant Core -- fixed
    * Excalibur -- fixed
    * Crimson Bloodreaver -- fixed
    * Holy Water -- not tested
    * Crown of Ember Sovereign -- not tested
    * Grimoire d'Archimage -- not tested
    * Bursting Scepter -- not tested
    * Blood of Satan -- not tested
* v1.5.3

  * test -- not started -- pending fix

    * combat log 4.0

      * standardise colour of log content



## III. Equipment:

* Speed \& Cooldowns (getSpeedMult): Mjölnir (+10%), Reaper Sickle (+15%), Cloak of Midnight (+5%).
* Max HP (sync): Golden Bell Shield \& Iron Cloth (+200 HP).
* Defensive/Reactive (takeDamage): Paladin's Shield (15% reduction), Golden Bell Shield (20% reduction), Cloak of Midnight (-20 flat dmg), Warden's Thornplate (10% reflect), Heart of Verdant Core (10% heal under 50% HP).
* Offensive (handleAttack): Mjölnir (+150 atk), Excalibur (+50 atk, 30% chance for Holy proc), Crimson Bloodreaver (+40 atk, Bleed proc), Holy Water (x1.20 mult), Crown of Ember Sovereign (x1.10 mult), Grimoire d'Archimage (x1.25 mult), Bursting Scepter (25% Crit chance), Blood of Satan (15% Lifesteal).



* case "Mjölnir": return "+150 Atk, +10% Spd";
* &#x20;   case "Excalibur": return "+50 Atk, +30% Holy";
* &#x20;   case "Heart\_of\_Verdant\_Core": return "Heal 10% of all Dmg";
* &#x20;   case "Cloak\_of\_Midnight": return "-20 Dmg, +5% Spd";
* &#x20;   case "Golden\_Bell\_Shield\_and\_Iron\_Cloth": return "20% Res, +200 HP";
* &#x20;   case "Blood\_of\_Satan": return "+15% Life Steal";
* &#x20;   case "Holy\_Water": return "+20% Holy Dmg";
* &#x20;   case "Crown\_of\_Ember\_Sovereign": return "+10% Fire Dmg";
* &#x20;   case "Grimoire\_d'Archimage": return "+25% Mag Atk";
* &#x20;   case "Paladin's\_Shield": return "15% Damage Reduc";
* &#x20;   case "Reaper\_Sickle": return "+15% Atk Spd";
* &#x20;   case "Bursting\_Scepter": return "+25% Crit Chance";
* &#x20;   case "Warden's\_Thornplate": return "Reflect 10% Dmg";
* &#x20;   case "Crimson\_Bloodreaver": return "+40 Atk, Bleed";



* Mjölnir                          +150 Phys atk, +10% atk spd     God of Thunder: +(p=0.2) 20% phys dmg {(p=0.3) of dizzy spell for 5 sec for thunder type}
* Cloak of Midnight                +15% mag redu, 5% dizzy redu    Vanish: if incoming atk value > 20% current HP, triggers absolute defense {one time use per round} {inapplicable against true dmg and special effect of reaper sickle}
* Golden Bell Shield \& Iron Cloth  +20% phys redu, +400 max HP     Nine Yang Sutra: if HP < 10% max HP, triggers absolute defense {one time use per round} {inapplicable against true dmg and special effect of reaper sickle}
* Excalibur                        +200 phys atk, +50 true dmg     Rightful King: +(P=0.3) 30% true dmg
* Blood of Satan                   +50 true atk, +25% atk spd      Frenzy: if HP < 10% max HP, 100% life steal on next atk {one time use per round}
* Holy Water                       +10% dizzy redu, +15% all redu  Bless from God: all chances increase by 20 percentile
* Crown of Ember Sovereign         +30% mag dmg, 10% atk spd       Infernal Dominion: every 3rd hit +200 mag dmg
* Grimoire d'Archimage             +200 mag dmg, +50 true dmg      Life Magic: permanent 15% life steal
* Paladin's Shield                 +300 max HP, +150 phys redu     Super Armor: immune against dizzy spells
* Reaper Sickle                    +125 true dmg, 15% atk spd      Harvest of Death: 25% chance to execute if target < 15% max HP {highest priority}
* Bursting Scepter                 +100 mag atk, +10% life steal   Overload: +(P=0.3) 30% dizzy spell for 5 sec {stops status coolbar}
* Warden's Thornplate              +200 phys redu, +200 mag redu   Thorny Spikes: reflects 10% of phy dmg as true dmg
* Crimson Bloodreaver              +15% life steal, +15% atk spd   Blood Thirsty: life steal doubles if enemy is below 30% of max HP
* Heart of Verdant Core            +200 max HP, +10% dizzy redu    Eternal Spring: every 10 sec, randomly regenerate 10\~100 HP



## IV. Cycle of Dominance

* The Elemental Loop

  * Thunder > Water > Fire > Earth > Thunder

    * Dominant: +25% dmg
    * Recessive: -20% dmg
* The Axis of Chaos

  * Holy ↔ Dark

    * Mutual Destruction: both deal +50% dmg to each other



## V. Character Identities

* Earth: +100 max HP, +5% all redu
* Thunder: +30% atk spd
* Fire: +20% physical dmg
* Dark: +25% magic dmg
* Holy: +10% true dmg
* Water: +15% base life steal

