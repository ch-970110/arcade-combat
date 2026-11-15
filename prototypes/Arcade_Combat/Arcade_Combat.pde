import processing.video.*;

Movie leftVideo;
Movie rightVideo;

void setup() {
  size(1280, 720);
  background(0);

  // Initialize videos
  leftVideo = new Movie(this, "video1.mp4");
  rightVideo = new Movie(this, "video2.mp4");

  // Start them
  leftVideo.loop();
  rightVideo.loop();
}

void draw() {
  background(0);
  float pW = width / 3.0;

  // --- LEFT VIDEO ---
  if (leftVideo.width > 0) {
    image(leftVideo, 0, 0, pW, height);
  }

  // --- RIGHT VIDEO (Manual Loop Check) ---
  if (rightVideo.width > 0) {
    // Check if Video 2 is stuck at the end
    // If current time is within 0.1 seconds of the end, jump to start
    if (rightVideo.time() >= rightVideo.duration() - 0.1 && rightVideo.duration() > 0) {
      rightVideo.jump(0);
      rightVideo.play();
    }
    
    image(rightVideo, pW * 2, 0, pW, height);
  }
}

// This function is the most reliable way to read frames
void movieEvent(Movie m) {
  m.read();
}

void keyPressed() {
  if (key == ' ') {
    leftVideo.stop();
    rightVideo.stop();
    leftVideo.loop();
    rightVideo.loop();
  }
}
