// User Variables
float res = 10; //dimensions of each cell in px //rename to resolution in the end
float margin = 8;  // margin on each side of the screen
float maxHz = 2500;
float gridWeight =.25; // min of .01 to prevent strange behaviour


// Private Variables
int cols = - 1;
int rows = - 1;
float offsetX;
float offsetY;
Cell[][] grid;
Cell[][] nextGrid;

float T;
boolean isLooping = false;
boolean isSliding = false;
boolean isPainting = false;
boolean forceDraw = false;
boolean isImporting = false;
long lastCall = 0;
long gen = 0;


void setup() {
    // size(800, 600);
    fullScreen(1);
    //throw error if min. width: 800px for buttons or min height for one row isnt enough (dont forget margins)
    surface.setTitle("\"The Game of Life\" by Dennis Paust  © 2021");
    //surface.setResizable(true);
    surface.setLocation(0, 0);
    frameRate(120);
    
    println("============================================================================");
    println("Keyboard / Mouse inputs for the User:");
    println("Click with the left mouse button on a cell make it live.");
    println("Click with the right mouse button on a cell make it dead.");
    println();
    println("Click with the mouse wheel on a cell to have its coordinates printed out.");
    println("Press space to pause / unpause the game");
    println("Press f for current frame rate");
    println("Press g to get current Generaation");
    println("Press n (for next) to only evolve one generation at a time");
    println("Press q to quit the game.");
    println("============================================================================");
    println();
    println();
    
    mySetup(true);
}

void mySetup(boolean initialSetup) { 
    toggleLoop(false);
    background(210, 20, 60);
    
    //menuBar
    noStroke();
    fill(0);
    rect(0, 0, width, 40);
    
    //all Buttons
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(20);
    text("Select File", 0, 0, 120, 40);
    text("Save File", 120, 0, 120, 40);
    text("Play", 240, 0, 120, 40);
    text("Next Step", 360, 0, 120, 40);
    
    //Speed Slider
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



void keyPressed() {
    if (key == ' ') toggleLoop();
    else if (key == 'f') println(frameRate);
    else if (key == 'g') println("Generation: " + gen);
    else if (key == 'n') {
        toggleLoop(false);
        nextGeneration();
    }
    else if (key == 'q') {
        println("User ended Game after " + g + " Generations.");
        exit();
    }
}

void mouseMoved() {
    if (mouseY <= 40 && (mouseX <= 480 || (mouseX >= 600 && mouseX <= width - 120))) {
        cursor(HAND);
    } else cursor(ARROW);
}

void mousePressed() {
    
    if (mouseButton == CENTER) {
        int i = floor((mouseX - offsetX) / res);
        int j = floor((mouseY - offsetY - 40) / res);
        println("Cell:", i, j);
        return;
    }
    
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
    
    drawInitialGrid(false);
}

void mouseDragged() {
    slider(true);
    drawInitialGrid(true);
}

void mouseReleased() {
    isSliding = false;
    isPainting = false;
}
