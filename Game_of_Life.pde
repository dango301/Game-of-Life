// User Variables //<>//
float res = 20; //dimensions of each cell in px //rename to resolution in the end
float margin = 8;  // margin on each side of the screen
float maxHz = 2500;
float gridWeight = .1; // min of .01 to prevent strange behaviour
//TODO: print keys for user to press

int cols = -1;
int rows = -1;
float offsetX;
float offsetY;
Cell[][] grid;
Cell[][] nextGrid;

float T;
boolean isLooping = false;
boolean forceDraw = false;
long lastCall = 0;
long gen = 0;


void setup() {
  size(800, 600);
  //fullScreen(1);
  //throw error if min. width: 800px for buttons or min height for one row isnt enough (dont forget margins)
  surface.setTitle("\"The Game of Life\" by Dennis Paust  © 2021");
  //surface.setResizable(true);
  surface.setLocation(0, 0);
  frameRate(120);

  println("============================================================================");
  println("Keyboard inputs for User:");
  println("Press space to pause / unpause the game");
  println("Press n to only evolve one generation at a time");
  println("Press g to get current Generaation");
  println("Press f for current frame rate");
  println("============================================================================");
  println();
  println();

  mySetup(true);
}


void mySetup(boolean initialSetup) { 
  toggleLoop(false);
  background(210, 20, 60);

  // menuBar
  noStroke();
  fill(0);
  rect(0, 0, width, 40);

  // all Buttons
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(20);
  text("Select File", 0, 0, 120, 40);
  text("Save File", 120, 0, 120, 40);
  text("Play", 240, 0, 120, 40);
  text("Next Step", 360, 0, 120, 40);

  // Speed Slider
  text("Speed:", 480, 0, 120, 40);
  rect(600, 18, width - 720, 4, 4);
  T = 1000;
  ellipse(600, 20, 10, 10);
  text("1Hz", width - 120, 0, 120, 40);


  if (initialSetup) {

    cols = floor((width - 2 * margin) / res);
    rows = floor((height - 40 - 2 * margin) / res);
    grid = new Cell[cols][rows];
    nextGrid = new Cell[cols][rows];

    offsetX = ((width - 2 * margin) % res) / 2 + margin;
    offsetY = ((height - 40 - 2 * margin) % res) / 2 + margin;
    println("Grid-Ratio: " + cols + " x " + rows);
  } else {
    offsetX = (width - (cols * res + 2 * margin)) / 2 + margin;
    offsetY = (height - (40 + rows * res + 2 * margin)) / 2 + margin;
  }

  fill(255);
  stroke(0);
  strokeWeight(1);
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {

      if (initialSetup)
        grid[i][j] = new Cell(false, i, j);

      nextGrid[i][j] = new Cell(false, i, j);
      grid[i][j].display();
    }
  }

  println("Loaded.");
  println();
  println();
}


void draw() {
  if (forceDraw) {
    mySetup(false);
    forceDraw = false;
  }

  if (isLooping && lastCall + T <= millis()) {

    nextGeneration();
    lastCall = millis();
  }
}





void mouseMoved() {
  if (mouseY <= 40 && (mouseX <= 480 || (mouseX >= 600 && mouseX <= width - 120))) {
    cursor(HAND);
  } else cursor(ARROW);
}


void mousePressed() {

  if (mouseY <= 40) {

    if (mouseX < 480) {

      int button = floor(mouseX / 120); 
      switch(button) {
      case 0:
        toggleLoop(false);
        selectInput("Select a previous Game of Life", "fileImported");
        break;
      case 1:
        toggleLoop(false);
        selectOutput("Save Game Progress to a File", "fileExported");
        break;
      case 2:
        toggleLoop();
        break;
      case 3:
        toggleLoop(false);
        nextGeneration();
        break;
      }
    } else if (mouseX >= 600 && mouseX < width - 120) 
      slider(false);
  }

  drawInitialGrid();
}



void keyPressed() {
  if (key == ' ') toggleLoop();
  else if (key == 'f') println(frameRate);
  else if (key == 't') ;
  else if (key == 'g') println("Generation: " + gen);
  else if (key == 'n') {
    toggleLoop(false);
    nextGeneration();
  }
}



void mouseDragged() {
  slider(true);
  drawInitialGrid();
}



void slider(boolean allowOverflow) {

  if (mouseY > 40) return;
  float x = mouseX;
  if (!allowOverflow && !(x >= 600 && x <= width - 120)) return;
  if (x < 480) return;

  x = constrain(x, 600, width - 120);
  float p = map(x, 600, width - 120, 0, 1);
  float hz = pow(10, p * log(maxHz) / log(10)); // power with base 10 with maximal exponent such as to reach maxHz for p=1 
  T = 1000 / hz;
  //println(hz, T);

  noStroke();
  fill(0);
  rect(480, 0, width, 40);
  fill(255);
  text("Speed:", 480, 0, 120, 40);
  rect(600, 18, width - 720, 4, 4);
  text(nf(hz, 0, 2) + "Hz", width - 120, 0, 120, 40);
  ellipse(600 + p * (width - 720), 20, 10, 10);
}
