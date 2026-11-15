/**
 * FobVideoPlayer.pde
 * 
 * Reads NFC/RFID fob tag IDs and plays the corresponding video.
 * 
 * TWO INPUT MODES — uncomment the one that matches your reader:
 *   MODE A (default): HID keyboard reader — tag ID is "typed" as keystrokes
 *   MODE B:           USB serial reader   — tag ID arrives over serial port
 * 
 * RASPBERRY PI NOTES:
 *   - Install Processing 4 on Pi: https://processing.org/download
 *   - The Video library uses GStreamer; run `sudo apt install gstreamer1.0-*`
 *   - For serial: use /dev/ttyUSB0 or /dev/ttyACM0 instead of COMx
 *   - For fullscreen on Pi, P2D renderer may perform better than default
 */

import processing.video.*;   // Install via Sketch > Import Library > Video

// ── Tag → Video map ─────────────────────────────────────────────────────────
// Add your own tag IDs and video file names here.
// Videos must be in the sketch's /data/ folder.
HashMap<String, String> tagMap = new HashMap<String, String>();

// ── Video state ──────────────────────────────────────────────────────────────
Movie currentMovie;
String currentTag = "";
boolean videoLoaded = false;

// ── HID keyboard input (Mode A) ──────────────────────────────────────────────
String inputBuffer = "";       // accumulates keystrokes between Enter presses

// ── Serial input (Mode B) ────────────────────────────────────────────────────
// import processing.serial.*;
// Serial myPort;
// String serialBuffer = "";

// ── Background color shown when no video is playing ──────────────────────────
color bgColor = color(10);

void setup() {
  fullScreen();                 // change to size(1280, 720) if needed
  // fullScreen(P2D);           // use this on Raspberry Pi for better performance

  frameRate(60);
  background(bgColor);

  // ── Populate the tag map ─────────────────────────────────────────────────
  // Format: tagMap.put("TAG_ID_HERE", "filename.mp4");
  // Files go in the sketch's data/ folder.
  tagMap.put("0006789ABC", "intro.mp4");
  tagMap.put("0001234567", "chapter1.mp4");
  tagMap.put("000AABBCC", "chapter2.mp4");
  // ... add more entries as needed

  // ── Serial setup (Mode B — uncomment to use) ─────────────────────────────
  // printArray(Serial.list());         // prints available ports to console
  // String portName = Serial.list()[0]; // adjust index for your system
  // myPort = new Serial(this, portName, 9600);
  // myPort.bufferUntil('\n');          // trigger serialEvent on newline

  println("FobVideoPlayer ready. Tap a fob!");
  textSize(20);
  textAlign(CENTER, CENTER);
}

void draw() {
  if (videoLoaded && currentMovie != null) {
    // Scale video to fill screen, preserving aspect ratio
    float vw = currentMovie.width;
    float vh = currentMovie.height;
    if (vw > 0 && vh > 0) {
      float scale = max((float)width / vw, (float)height / vh);
      float dw = vw * scale;
      float dh = vh * scale;
      image(currentMovie, (width - dw) / 2, (height - dh) / 2, dw, dh);
    }
  } else {
    background(bgColor);
    fill(80);
    text("Waiting for fob...", width / 2, height / 2);
  }
}

// ── Called whenever a video frame is available ───────────────────────────────
void movieEvent(Movie m) {
  m.read();
}

// ── MODE A: HID keyboard reader ──────────────────────────────────────────────
// The reader types the tag ID as keystrokes followed by Enter.
void keyPressed() {
  if (key == ENTER || key == RETURN) {
    String tagID = inputBuffer.trim().toUpperCase();
    inputBuffer = "";
    if (tagID.length() > 0) {
      println("Tag scanned: " + tagID);
      handleTag(tagID);
    }
  } else if (key != BACKSPACE && key != DELETE) {
    inputBuffer += key;
  }
}

// ── MODE B: Serial reader (uncomment serialEvent to use) ─────────────────────
// void serialEvent(Serial port) {
//   String raw = port.readStringUntil('\n');
//   if (raw != null) {
//     String tagID = raw.trim().toUpperCase();
//     println("Tag scanned: " + tagID);
//     handleTag(tagID);
//   }
// }

// ── Core logic: look up tag, load and play video ──────────────────────────────
void handleTag(String tagID) {
  if (tagID.equals(currentTag)) {
    // Same tag tapped again — restart the video from the beginning
    if (currentMovie != null) {
      currentMovie.jump(0);
      currentMovie.play();
    }
    return;
  }

  if (!tagMap.containsKey(tagID)) {
    println("Unknown tag: " + tagID);
    return;
  }

  // Stop and release the current movie
  if (currentMovie != null) {
    currentMovie.stop();
    currentMovie = null;
    videoLoaded = false;
  }

  currentTag = tagID;
  String videoFile = tagMap.get(tagID);
  println("Playing: " + videoFile);

  currentMovie = new Movie(this, videoFile);
  currentMovie.loop();           // use .play() if you don't want looping
  videoLoaded = true;
}
