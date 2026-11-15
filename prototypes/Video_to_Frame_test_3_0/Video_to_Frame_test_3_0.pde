PImage[] frameCache;
int totalFrames = 240;

float charX;
float charY;
float charScale = 1.0;

float animationFPS = 30; // Target playback speed of your original video
int animationStartTime;

boolean showDebugInfo = true;
boolean isPreloading = true;
int preloadIndex = 0;

void setup() {
  size(640, 360); 
  
  // RPi 5 can easily handle 60fps for preloaded 360p images
  frameRate(30); 
  smooth();
  imageMode(CENTER);
  
  charX = width * 0.5;
  charY = height * 0.5;
  
  // Allocate RAM array
  frameCache = new PImage[totalFrames];
}

void draw() {
  background(40);
  
  if (isPreloading) {
    drawPreloadScreen();
    preloadNextFrame();
    return;
  }
  
  // Calculate precise frame based on time elapsed since animation started
  float elapsedSeconds = (millis() - animationStartTime) / 1000.0;
  int frameToDraw = floor(elapsedSeconds * animationFPS) % totalFrames;
  
  PImage currentImage = frameCache[frameToDraw];
  
  if (currentImage != null) {
    float targetWidth = currentImage.width * charScale;
    float targetHeight = currentImage.height * charScale;
    image(currentImage, charX, charY, targetWidth, targetHeight);
  } else {
    drawMissingFrameMessage(frameToDraw);
  }
  
  if (showDebugInfo) {
    drawDebugInfo(frameToDraw);
  }
}

void preloadNextFrame() {
  // Load chunks per draw loop to prevent the OS from thinking the app crashed on boot
  for (int i = 0; i < 6; i++) {
    if (preloadIndex >= totalFrames) {
      isPreloading = false;
      animationStartTime = millis(); 
      return;
    }
    
    String filename = "Thunderbird_IDLE_L_" + nf(preloadIndex + 1, 3) + ".png";
    PImage img = loadImage(filename);
    if (img != null) {
      frameCache[preloadIndex] = img;
    }
    preloadIndex++;
  }
}

void drawPreloadScreen() {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(22);
  int percent = int((float)preloadIndex / totalFrames * 100);
  text("Preloading video frames to RAM...\n" + percent + "%", width * 0.5, height * 0.5);
}

void drawMissingFrameMessage(int frameNumber) {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(22);
  text("Missing frame: " + nf(frameNumber + 1, 3), width * 0.5, height * 0.5);
}

void drawDebugInfo(int frameNumber) {
  fill(0, 255, 0); // Bright green text for visibility
  textAlign(LEFT, TOP);
  textSize(16);
  String info = "Frame: " + nf(frameNumber + 1, 3) + " / " + totalFrames + 
                "\nActual Engine FPS: " + nf(frameRate, 1, 1);
  text(info, 20, 20);
}

void keyPressed() {
  if ((key == 'r' || key == 'R') && !isPreloading) {
    animationStartTime = millis();
  }
  if (key == 'd' || key == 'D') {
    showDebugInfo = !showDebugInfo;
  }
}
