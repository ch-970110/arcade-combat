import processing.video.*;

// --- GLOBAL CONSTANTS & CONFIG ---
final float BASE_HP = 2000;
Player p1, p2;
Movie tIdle, tAtk, dIdle, dAtk;
ArrayList<LogEntry> combatLog = new ArrayList<LogEntry>();

// DODGE SETTINGS
final long DODGE_WINDOW = 1500;    // INCREASED: 1.5s for player-friendly reactions
final long DODGE_COOLDOWN = 3000;  

String[] allItemNames = {
  "Mjölnir", "Cloak_of_Midnight", "Golden_Bell_Shield_and_Iron_Cloth", "Excalibur",
  "Blood_of_Satan", "Holy_Water", "Crown_of_Ember_Sovereign", "Grimoire_d'Archimage",
  "Paladin's_Shield", "Reaper_Sickle", "Bursting_Scepter", "Warden's_Thornplate",
  "Crimson_Bloodreaver", "Heart_of_Verdant_Core"
};
PImage[] allImages = new PImage[14];

int[] p1Loadout = {-1,-1,-1,-1}, p2Loadout = {-1,-1,-1,-1};
int draggedItemIdx = -1;
boolean draggingFromP1 = false, draggingFromP2 = false; 
int dragSourceSlot = -1;

float sideWidth, videoHeight, logY, loadoutY, libraryY;
boolean p1Summoned = false, p2Summoned = false; 
boolean thunderIsAttacking = false, dragonIsAttacking = false;

float p1Stamina = 100, p2Stamina = 100;
long p1LastDodge = -5000, p2LastDodge = -5000;

class LogEntry {
  String main, damage, effect;
  color col; 
  LogEntry(String m, String d, String e, color c) { main = m; damage = d; effect = e; col = c; }
}

void setup() {
  size(960, 600); 
  calculateLayout();
  p1 = new Player(1, "Thunder"); 
  p2 = new Player(2, "Fire");    
  
  try {
    tIdle = new Movie(this, "Thunderbird_IDLE_L.mp4");
    tAtk = new Movie(this, "Thunderbird_Attack_1_L.mp4");
    dIdle = new Movie(this, "Dragon_IDLE_R.mp4");
    dAtk = new Movie(this, "Dragon_Attack_1_R.mp4");
  } catch (Exception e) { println("Video/Library error."); }

  for (int i = 0; i < allItemNames.length; i++) {
    allImages[i] = loadImage(allItemNames[i] + ".png");
  }
}

class Player {
  int id; String type; float hp, maxHp, dispHp, animHp;
  float lastAtk = -5000;
  int[] items = new int[4];
  boolean isDead = false;

  Player(int id, String type) {
    this.id = id; this.type = type;
    this.maxHp = (type.equals("Earth")) ? BASE_HP * 1.3 : BASE_HP;
    this.hp = maxHp; this.dispHp = maxHp; this.animHp = maxHp;
  }

  void sync(int[] l) { this.items = l; }

  // SPEED MULTIPLIER: Used for both the Bar and the Video Speed
  float getSpeedMult() {
    float s = 1.0;
    if (type.equals("Thunder")) s += 0.3;
    for (int i : items) {
       if (i != -1) {
         String n = allItemNames[i];
         if (n.equals("Mjölnir")) s += 0.1;
         if (n.equals("Reaper_Sickle")) s += 0.15;
         if (n.equals("Cloak_of_Midnight")) s += 0.05;
       }
    }
    return s;
  }

  // ACCURATE SYNC: Bar duration matches (Movie Duration - Offset) / Speed
  float getInterval() {
    float duration = (id == 1) ? (float)tAtk.duration() : (float)dAtk.duration();
    if (duration <= 0) duration = 1.2; 
    return max(0.2, (duration - 0.15) / getSpeedMult());
  }

  void update() {
    dispHp = lerp(dispHp, hp, 0.1);
    animHp = lerp(animHp, hp, 0.05);
    if (hp <= 0 && !isDead) { isDead = true; hp = 0; if(id == 1) p1Summoned = false; else p2Summoned = false; }
  }

  void takeDamage(float raw, Player attacker, String procEffect) {
    if (isDead) return;
    long lastD = (id == 1) ? p1LastDodge : p2LastDodge;
    
    if (millis() - lastD < DODGE_WINDOW) { 
      logCombat("P" + id, "EVADED", "{DODGED}", color(0, 255, 255)); 
      return; 
    }
    
    // HEART OF VERDANT CORE REWORK: Heal 10% of damage taken if HP < 50%
    float finalDmg = raw;
    if (hp < maxHp * 0.5 && hasEquipped("Heart_of_Verdant_Core")) {
       float heal = raw * 0.10;
       hp = min(maxHp, hp + heal);
       procEffect += " {CORE REGEN}";
    }

    hp -= finalDmg;
    color logColor = color(255);
    if (procEffect.contains("HOLY")) logColor = color(255, 255, 100);
    else if (raw > 300) logColor = color(255, 100, 100);
    
    logCombat("P" + attacker.id + " -> P" + id, "[-" + (int)raw + "]", procEffect, logColor);
  }

  boolean hasEquipped(String n) {
    for(int i : items) if (i!=-1 && allItemNames[i].equals(n)) return true;
    return false;
  }
}

void draw() {
  background(15);
  p1Stamina = min(100, p1Stamina + 0.5);
  p2Stamina = min(100, p2Stamina + 0.5);
  p1.sync(p1Loadout); p2.sync(p2Loadout);
  p1.update(); p2.update();

  drawChar(tIdle, tAtk, p1Summoned, thunderIsAttacking, 0, 0, true, p1.getSpeedMult());
  drawChar(dIdle, dAtk, p2Summoned, dragonIsAttacking, sideWidth, 0, false, p2.getSpeedMult());
  
  drawHUD(p1, 20, videoHeight - 60, p1Stamina, p1Summoned, p1LastDodge, thunderIsAttacking);
  drawHUD(p2, width - 320, videoHeight - 60, p2Stamina, p2Summoned, p2LastDodge, dragonIsAttacking);
  
  drawCombatLog(logY);
  drawEffectSummary(p1, 10, logY);
  drawEffectSummary(p2, width - 210, logY);
  drawLoadoutSlots(loadoutY);
  drawLibrary(libraryY);

  if (draggedItemIdx != -1) { imageMode(CENTER); image(allImages[draggedItemIdx], mouseX, mouseY, 40, 40); imageMode(CORNER); }
}

void drawHUD(Player p, float x, float y, float stam, boolean summ, long lastD, boolean currentlyAtking) {
  if (millis() - lastD < DODGE_WINDOW) { stroke(0, 255, 255); strokeWeight(3); } else { noStroke(); }
  fill(summ ? 30 : 10); rect(x, y, 300, 18, 5);
  noStroke(); 
  if(summ) { fill(200, 0, 0); rect(x, y, map(p.dispHp, 0, p.maxHp, 0, 300), 18, 5); }
  fill(255); textSize(12); text("P" + p.id + " HP: " + (int)p.animHp, x + 5, y - 5);

  float barW = 145, gap = 10;
  float atkProg = constrain((millis() - p.lastAtk) / (p.getInterval() * 1000), 0, 1);
  fill(40); rect(x, y + 22, barW, 8, 4);
  
  boolean ready = (atkProg >= 1.0 && !currentlyAtking);
  fill(ready ? color(0, 255, 150) : color(180, 150, 40));
  rect(x, y + 22, barW * atkProg, 8, 4);
  if(ready) { fill(255); textSize(9); textAlign(CENTER); text("READY", x + barW/2, y + 30); textAlign(LEFT); }

  fill(40); rect(x + barW + gap, y + 22, barW, 8, 4);
  fill(50, 150, 255);
  rect(x + barW + gap, y + 22, map(stam, 0, 100, 0, barW), 8, 4);
}

void keyPressed() {
  if (key == 'w' && !p1.isDead && !p1Summoned) { p1Summoned = true; tIdle.loop(); }
  if (key == '5' && !p2.isDead && !p2Summoned) { p2Summoned = true; dIdle.loop(); }
  if (key == 's' && p1Summoned && p1Stamina >= 100) { p1LastDodge = millis(); p1Stamina = 0; }
  if (key == '2' && p2Summoned && p2Stamina >= 100) { p2LastDodge = millis(); p2Stamina = 0; }

  if (key == 'a' && p1Summoned && !thunderIsAttacking && !p1.isDead) {
    if (millis() - p1.lastAtk > p1.getInterval()*1000) {
      thunderIsAttacking = true; p1.lastAtk = millis();
      tIdle.stop(); tAtk.speed(p1.getSpeedMult()); tAtk.jump(0); tAtk.play();
      if(p2Summoned) handleAttack(p1, p2);
    }
  }
  if (key == '1' && p2Summoned && !dragonIsAttacking && !p2.isDead) {
    if (millis() - p2.lastAtk > p2.getInterval()*1000) {
      dragonIsAttacking = true; p2.lastAtk = millis();
      dIdle.stop(); dAtk.speed(p2.getSpeedMult()); dAtk.jump(0); dAtk.play();
      if(p1Summoned) handleAttack(p2, p1);
    }
  }
}

void handleAttack(Player atk, Player def) {
  float total = 200; String procs = "";
  for (int i : atk.items) { 
    if (i == -1) continue; 
    if (allItemNames[i].equals("Mjölnir")) total += 150; 
    if (allItemNames[i].equals("Excalibur")) total += 50;
  }
  if (atk.hasEquipped("Excalibur") && random(1) < 0.3) { total *= 1.3; procs += "{HOLY}"; }
  def.takeDamage(total, atk, procs);
}

void drawChar(Movie idl, Movie atk, boolean summ, boolean atking, float x, float y, boolean isP1, float speed) { 
  if (!summ) { fill(10); rect(x, y, sideWidth, videoHeight); return; } 
  if (atking) { 
    // Sync logic: Exit animation when reaching duration minus offset
    if (atk.time() >= atk.duration()-0.15) { 
      atk.stop(); 
      if (isP1) thunderIsAttacking=false; else dragonIsAttacking=false; 
      idl.loop(); 
    } 
    image(atk, x, y, sideWidth, videoHeight); 
  } else { 
    if (idl.time() >= idl.duration()-0.1 || idl.time()==0) { idl.jump(0); idl.play(); } 
    image(idl, x, y, sideWidth, videoHeight); 
  } 
}

void calculateLayout() { sideWidth = width/2.0; videoHeight = sideWidth*(9.0/16.0); logY = videoHeight+10; loadoutY = logY+130; libraryY = height-70; }
void movieEvent(Movie m) { m.read(); }
void logCombat(String m, String d, String e, color c) { combatLog.add(new LogEntry(m, d, e, c)); if (combatLog.size()>5) combatLog.remove(0); }

void drawCombatLog(float y) { 
  fill(0, 150); rect(width/2-140, y, 280, 120, 10); textAlign(CENTER); textSize(11); 
  for (int i=0; i<combatLog.size(); i++) { 
    LogEntry le = combatLog.get(i); 
    fill(le.col); text(le.main, width/2-50, y+25+(i*18)); 
    text(le.damage, width/2+20, y+25+(i*18)); 
    text(le.effect, width/2+80, y+25+(i*18)); 
  } 
  textAlign(LEFT); 
}

void drawEffectSummary(Player p, float x, float y) { 
  fill(0, 180); noStroke(); rect(x, y, 200, 120, 10); 
  fill(140, 200, 255); textSize(10); text("PASSIVES:", x+10, y+20); 
  for (int i=0; i<4; i++) { 
    if (p.items[i] != -1) { 
      fill(200); text("• " + getEffectDesc(allItemNames[p.items[i]]), x+10, y+40+(i*15)); 
    } 
  } 
}

String getEffectDesc(String n) { 
  switch(n) { 
    case "Mjölnir": return "+150 Atk, +10% Spd"; 
    case "Excalibur": return "+50 Atk, +30% Holy"; 
    case "Heart_of_Verdant_Core": return "Heal 10% Dmg (<50% HP)"; 
    case "Cloak_of_Midnight": return "+100 MDef, +5% Spd"; 
    case "Golden_Bell_Shield_and_Iron_Cloth": return "+20% Res, +200 HP"; 
    case "Blood_of_Satan": return "+15% Life Steal";
    case "Holy_Water": return "+20% Holy Dmg";
    case "Crown_of_Ember_Sovereign": return "+10% Fire Dmg";
    case "Grimoire_d'Archimage": return "+25% Mag Atk";
    case "Paladin's_Shield": return "15% Damage Reduc";
    case "Reaper_Sickle": return "+15% Atk Spd";
    case "Bursting_Scepter": return "+20% Crit Chance";
    case "Warden's_Thornplate": return "Reflect 10% Dmg";
    case "Crimson_Bloodreaver": return "+40 Atk, Bleed";
    default: return n.replace("_", " "); 
  } 
}

void drawLoadoutSlots(float y) { 
  float s=50, sp=10; 
  for(int i=0; i<4; i++) { 
    fill(30); stroke(80); rect(60+i*(s+sp), y, s, s, 8); 
    if(p1Loadout[i]!=-1) image(allImages[p1Loadout[i]], 65+i*(s+sp), y+5, s-10, s-10); 
    fill(30); rect(width-300+i*(s+sp), y, s, s, 8); 
    if(p2Loadout[i]!=-1) image(allImages[p2Loadout[i]], width-295+i*(s+sp), y+5, s-10, s-10); 
  } 
}

void drawLibrary(float y) { 
  float s=40, sp=5; 
  for(int i=0; i<14; i++) { 
    fill(30); noStroke(); rect(width/2-320+i*(s+sp), y, s, s, 5); 
    if(allImages[i]!=null) image(allImages[i], width/2-315+i*(s+sp), y+5, s-10, s-10); 
  } 
}

void mousePressed() { 
  float s_lib=40, sp_lib=5; 
  for(int i=0; i<14; i++) { 
    float x=width/2-320+i*(s_lib+sp_lib); 
    if(mouseX >= x && mouseX <= x+s_lib && mouseY >= libraryY && mouseY <= libraryY+s_lib) { draggedItemIdx = i; return; } 
  } 
  float s_ld=50, sp_ld=10; 
  for(int i=0; i<4; i++) { 
    float p1x = 60+i*(s_ld+sp_ld); 
    if(mouseX >= p1x && mouseX <= p1x+s_ld && mouseY >= loadoutY && mouseY <= loadoutY+s_ld) { 
      if (p1Loadout[i] != -1) { draggedItemIdx = p1Loadout[i]; draggingFromP1 = true; dragSourceSlot = i; return; } 
    } 
    float p2x = width-300+i*(s_ld+sp_ld); 
    if(mouseX >= p2x && mouseX <= p2x+s_ld && mouseY >= loadoutY && mouseY <= loadoutY+s_ld) { 
      if (p2Loadout[i] != -1) { draggedItemIdx = p2Loadout[i]; draggingFromP2 = true; dragSourceSlot = i; return; } 
    } 
  } 
}

void mouseReleased() { 
  if(draggedItemIdx == -1) return; 
  float s_ld=50, sp_ld=10; boolean droppedInSlot = false; 
  for(int i=0; i<4; i++) { 
    float p1x = 60+i*(s_ld+sp_ld); 
    if(mouseX >= p1x && mouseX <= p1x+s_ld && mouseY >= loadoutY && mouseY <= loadoutY+s_ld) { 
      p1Loadout[i]=draggedItemIdx; droppedInSlot=true; 
      if (draggingFromP1 && dragSourceSlot != i) p1Loadout[dragSourceSlot] = -1; else if (draggingFromP2) p2Loadout[dragSourceSlot] = -1; 
    } 
    float p2x = width-300+i*(s_ld+sp_ld); 
    if(mouseX >= p2x && mouseX <= p2x+s_ld && mouseY >= loadoutY && mouseY <= loadoutY+s_ld) { 
      p2Loadout[i]=draggedItemIdx; droppedInSlot=true; 
      if (draggingFromP2 && dragSourceSlot != i) p2Loadout[dragSourceSlot] = -1; else if (draggingFromP1) p1Loadout[dragSourceSlot] = -1; 
    } 
  } 
  if(!droppedInSlot && (draggingFromP1 || draggingFromP2)) { 
    if(draggingFromP1) p1Loadout[dragSourceSlot] = -1; if(draggingFromP2) p2Loadout[dragSourceSlot] = -1; 
  } 
  draggedItemIdx = -1; draggingFromP1 = false; draggingFromP2 = false; dragSourceSlot = -1; 
}
