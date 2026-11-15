import processing.video.*;

Movie thunderbirdIdle, thunderbirdAttack, dragonIdle, dragonAttack;
boolean thunderActive = false, dragonActive = false;
boolean thunderIsAttacking = false, dragonIsAttacking = false;

// Layout variables (calculated in setup based on screen size)
float sideWidth; 
float videoHeight;

// Inventory Items
String[] allItemNames = {
  "Blood_of_Satan", "Bursting_Scepter", "Cloak_of_Midnight", "Crimson_Bloodreaver",
  "Crown_of_Ember_Sovereign", "Excalibur", "Golden_Bell_Shield_and_Iron_Cloth",
  "Grimoire_d'Archimage", "Heart_of_Verdant_Core", "Holy_Water",
  "Paladin's_Shield", "Reaper_Sickle", "Warden's_Thornplate", "Mjölnir"
};
PImage[] allImages = new PImage[14];

// Player Loadouts
int[] p1Loadout = {-1, -1, -1, -1}; 
int[] p2Loadout = {-1, -1, -1, -1};
boolean[] equipStatus = new boolean[8];
char[] equipKeys = {'y', 'u', 'i', 'o', 'h', 'j', 'k', 'l'};

// Drag and Drop State
int draggedItemIdx = -1;
int sourceSlot = -1; 
int sourcePlayer = -1; 

void setup() {
  // Use fullScreen instead of size()
  fullScreen(); 
  
  // Calculate dynamic dimensions based on actual screen width
  sideWidth = width / 2.0;
  videoHeight = sideWidth * (9.0/16.0);
  
  // Load Videos
  thunderbirdIdle = new Movie(this, "Thunderbird_Neutral_State_L.mp4");
  thunderbirdAttack = new Movie(this, "Thunderbird_Attack_1_L.mp4");
  dragonIdle = new Movie(this, "Dragon_Neutral_State_R.mp4");
  dragonAttack = new Movie(this, "Dragon_Attack_1_R.mp4");
  
  thunderbirdIdle.loop();
  dragonIdle.loop();

  // Load Images
  for (int i = 0; i < allItemNames.length; i++) {
    allImages[i] = loadImage(allItemNames[i] + ".png");
  }
}

void movieEvent(Movie m) { m.read(); }

void draw() {
  background(10);

  // 1. Characters - Scaled to fill the top half of the screen
  drawChar(thunderbirdIdle, thunderbirdAttack, thunderActive, thunderIsAttacking, 0, 0, true);
  drawChar(dragonIdle, dragonAttack, dragonActive, dragonIsAttacking, sideWidth, 0, false);

  // 2. Loadout Part - Positioned dynamically
  float loadoutY = videoHeight + (height - videoHeight) * 0.25; 
  drawLoadoutSlots(loadoutY);

  // 3. Library - Pinned to bottom
  drawLibrary(height - 130);

  // Dragging Visual
  if (draggedItemIdx != -1) {
    imageMode(CENTER);
    image(allImages[draggedItemIdx], mouseX, mouseY, 80, 80);
    imageMode(CORNER);
  }
}

void drawLoadoutSlots(float startY) {
  // Slots grow slightly larger on bigger screens
  float slotSize = height * 0.12; 
  float spacing = 25;
  float centerGap = width * 0.08;
  float groupWidth = (slotSize * 4) + (spacing * 3);
  float startX = (width - ((groupWidth * 2) + centerGap)) / 2.0;

  renderSlotGroup("PLAYER 1 LOADOUT", startX, startY, p1Loadout, 0, slotSize, spacing, color(0, 180, 255));
  renderSlotGroup("PLAYER 2 LOADOUT", startX + groupWidth + centerGap, startY, p2Loadout, 4, slotSize, spacing, color(255, 50, 50));
}

void renderSlotGroup(String label, float x, float y, int[] loadout, int keyOffset, float size, float space, color theme) {
  float groupW = (size * 4) + (space * 3);
  fill(theme);
  textSize(22); // Larger text for full screen
  textAlign(CENTER);
  text(label, x + groupW/2, y - 50);
  stroke(theme, 100);
  strokeWeight(2);
  line(x, y - 35, x + groupW, y - 35);

  for (int i = 0; i < 4; i++) {
    float dx = x + i * (size + space);
    stroke(equipStatus[i + keyOffset] ? theme : 80);
    strokeWeight(equipStatus[i + keyOffset] ? 4 : 1);
    fill(20);
    rect(dx, y, size, size, 12);

    if (loadout[i] != -1) {
      if (!equipStatus[i + keyOffset]) tint(255, 100);
      image(allImages[loadout[i]], dx + 10, y + 10, size - 20, size - 20);
      noTint();
      fill(220);
      textSize(12);
      text(allItemNames[loadout[i]].replace("_", " "), dx + size/2, y - 10);
    }
    fill(180);
    text("[" + Character.toUpperCase(equipKeys[i + keyOffset]) + "]", dx + size/2, y + size + 30);
  }
}

void drawLibrary(float startY) {
  float itemSize = 75;
  float spacing = 15;
  float totalW = (itemSize * 14) + (spacing * 13);
  float startX = (width - totalW) / 2.0;

  fill(120);
  textAlign(CENTER);
  textSize(16);
  text("INVENTORY (DRAG TO EQUIP / DRAG OUT TO UNLOAD)", width/2, startY - 30);

  for (int i = 0; i < 14; i++) {
    float x = startX + i * (itemSize + spacing);
    fill(25);
    stroke(80);
    rect(x, startY, itemSize, itemSize, 8);
    if (allImages[i] != null) image(allImages[i], x + 5, startY + 5, itemSize - 10, itemSize - 10);
  }
}

// Logic for Mouse and Keys remains the same, but uses dynamic Y variables
void mousePressed() {
  float libItemSize = 75;
  float libSpacing = 15;
  float libStartX = (width - ((libItemSize * 14) + (libSpacing * 13))) / 2.0;
  float libStartY = height - 130;

  for (int i = 0; i < 14; i++) {
    float x = libStartX + i * (libItemSize + libSpacing);
    if (mouseX > x && mouseX < x + libItemSize && mouseY > libStartY && mouseY < libStartY + libItemSize) {
      draggedItemIdx = i;
      sourceSlot = -1;
      return;
    }
  }

  float slotSize = height * 0.12;
  float spacing = 25;
  float centerGap = width * 0.08;
  float groupWidth = (slotSize * 4) + (spacing * 3);
  float p1StartX = (width - ((groupWidth * 2) + centerGap)) / 2.0;
  float loadoutY = videoHeight + (height - videoHeight) * 0.25;

  for (int i = 0; i < 4; i++) {
    float x = p1StartX + i * (slotSize + spacing);
    if (mouseX > x && mouseX < x + slotSize && mouseY > loadoutY && mouseY < loadoutY + slotSize && p1Loadout[i] != -1) {
      draggedItemIdx = p1Loadout[i];
      sourceSlot = i;
      sourcePlayer = 1;
      return;
    }
    float x2 = p1StartX + groupWidth + centerGap + i * (slotSize + spacing);
    if (mouseX > x2 && mouseX < x2 + slotSize && mouseY > loadoutY && mouseY < loadoutY + slotSize && p2Loadout[i] != -1) {
      draggedItemIdx = p2Loadout[i];
      sourceSlot = i;
      sourcePlayer = 2;
      return;
    }
  }
}

void mouseReleased() {
  if (draggedItemIdx == -1) return;

  float slotSize = height * 0.12;
  float spacing = 25;
  float centerGap = width * 0.08;
  float groupWidth = (slotSize * 4) + (spacing * 3);
  float startX = (width - ((groupWidth * 2) + centerGap)) / 2.0;
  float loadoutY = videoHeight + (height - videoHeight) * 0.25;

  boolean droppedInSlot = false;

  for (int i = 0; i < 4; i++) {
    float dx = startX + i * (slotSize + spacing);
    if (mouseX > dx && mouseX < dx + slotSize && mouseY > loadoutY && mouseY < loadoutY + slotSize) {
      p1Loadout[i] = draggedItemIdx;
      droppedInSlot = true;
    }
    float dx2 = startX + groupWidth + centerGap + i * (slotSize + spacing);
    if (mouseX > dx2 && mouseX < dx2 + slotSize && mouseY > loadoutY && mouseY < loadoutY + slotSize) {
      p2Loadout[i] = draggedItemIdx;
      droppedInSlot = true;
    }
  }

  if (!droppedInSlot && sourceSlot != -1) {
    if (sourcePlayer == 1) p1Loadout[sourceSlot] = -1;
    else if (sourcePlayer == 2) p2Loadout[sourceSlot] = -1;
  }
  draggedItemIdx = -1;
  sourceSlot = -1;
}

void drawChar(Movie idle, Movie attack, boolean active, boolean attacking, float x, float y, boolean isP1) {
  if (!active) return;
  Movie display = attacking ? attack : idle;
  if (!attacking && display.time() >= display.duration() - 0.1) display.jump(0);
  if (attacking && attack.time() >= attack.duration() - 0.1) {
    if (isP1) thunderIsAttacking = false; else dragonIsAttacking = false;
    attack.stop();
    idle.loop();
  }
  image(display, x, y, sideWidth, videoHeight);
}

void keyPressed() {
  // Press ESC to exit full screen
  if (key == 'w' || key == 'W') thunderActive = !thunderActive;
  if ((key == 'a' || key == 'A') && thunderActive) { 
    thunderIsAttacking = true; thunderbirdAttack.jump(0); thunderbirdAttack.play(); 
  }
  if (key == '5') dragonActive = !dragonActive;
  if (key == '1' && dragonActive) { 
    dragonIsAttacking = true; dragonAttack.jump(0); dragonAttack.play(); 
  }
  for (int i = 0; i < equipKeys.length; i++) {
    if (key == equipKeys[i]) equipStatus[i] = !equipStatus[i];
  }
}
