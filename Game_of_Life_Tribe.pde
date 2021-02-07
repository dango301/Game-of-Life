// User Variables
float res = 20; //dimensions of each cell in px //rename to resolution in the end
float margin = 8;  // margin on each side of the screen
float maxHz = 50;
float gridWeight = 0.1; // min of .01 to prevent strange behaviour
int maxTribeSize = 350;
float warriorStrengthMuliplicator = 2;
float warriorSpawnHealth = 8;
float warriorWinnerRandomMultiplier = 5;


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

// Specific to the Tribe-Variation of the game:
ArrayList<Tribe> allTribes = new ArrayList<Tribe>();
ArrayList<Tribe> deletedTribes = new ArrayList<Tribe>();
PShape crown;
PShape helmet;
PShape swords;
// Icons designed by Freepik from www.flaticon.com


void setup() {
    // size(800, 600);
    fullScreen(1);
    
    surface.setTitle("\"The Game of Life\" by Dennis Paust  © 2021");
    surface.setLocation(0, 0);
    frameRate(120);
    
    float minHeight = 40 + 2 * margin + 3 * res;
    if (width < 800) {
        println("Please increase the window's width to the minimum of 800px.");
        exit();
    }
    if (height < minHeight) {
        println("The minimum height for the window is " + minHeight + "px for your resolution of " + res + "px.");
        println("Please try increasing the window's height or reducing the resolution variable.");
        exit();
    }
    if (width < 800 || height < minHeight) return;
    
    println("============================================================================");
    println("Keyboard / Mouse inputs for the User:");
    println("Click on a cell with the left mouse button make it live.");
    println("Click on a cell with the right mouse button make it dead.");
    println("Click on a cell with the mouse wheel to have its coordinates printed out.");
    println();
    println("Press space to pause / unpause the game");
    println("Press f for current frame rate");
    println("Press g to get current generation");
    println("Press n (for next) to only evolve one generation at a time");
    println("Press q to quit the game.");
    println("============================================================================");
    println();
    println();
    
    crown = loadShape("crown.svg");
    helmet = loadShape("helmet.svg");
    swords = loadShape("swords.svg");
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
        
        allTribes = new ArrayList<Tribe>();
        deletedTribes = new ArrayList<Tribe>();
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
    } else if (key == 'q') {
        println("User ended Game after " + gen + " Generations.");
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
        Cell c = grid[i][j];
        
        println();
        println("Clicked on Cell:", i, j, c.className(), "| #Neighbours:", grid[i][j].dfs().size());
        
        if (c.className().equals("Warrior"))
            println("Health:",((Warrior)c).health);
        
        
        if (c.className().equals("Battlefield")) {
            
            Battlefield b = (Battlefield)c;
            Cell[] nbs = b.getNeighbours();
            println("\tBattlefield includes:");
            
            for (Cell cc : nbs) {
                String n = cc.className();
                if (n.equals("Warrior"))
                    println("\t\tWarrior at", cc.x, cc.y, "from Tribe",((Warrior)cc).tribe, "| Health:",((Warrior)cc).health);
                
            }
        }
        

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