import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Game_of_Life_Tank extends PApplet {

// User Variables
float res = 20; //dimensions of each cell in px //rename to resolution in the end
float margin = 8;  // margin on each side of the screen
float maxHz = 2500;
float gridWeight = 0.25f; // min of .01 to prevent strange behaviour


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


public void setup() {
    
    // fullScreen();
    
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
    
    mySetup(true);
}

public void mySetup(boolean initialSetup) { 
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
        println("Grid-Ratio: " + cols + " x " + rows);
    }
    offsetX = (width - (cols * res + 2 * margin)) / 2 + margin;
    offsetY = (height - (40 + rows * res + 2 * margin)) / 2 + margin;
    gen = 0;
    
    fill(255);
    stroke(0);
    strokeWeight(1);
    for (int i = 0; i < cols; i++) {
        for (int j = 0; j < rows; j++) {
            
            if (initialSetup)
                grid[i][j] = new Cell(false, i, j);
            
            grid[i][j].display();
        }
    }
    
    println("Loaded.");
    println();
    println();
}



public void draw() {
    if (forceDraw) {
        mySetup(false);
        forceDraw = false;
    }
    
    if (isLooping && lastCall + T <= millis()) {
        
        nextGeneration();
        lastCall = millis();
    }
}



public void keyPressed() {
    if (key == ' ') toggleLoop();
    else if (key == 'f') println(frameRate);
    else if (key == 'g') println("Generation: " + gen);
    else if (key == 'n') {
        toggleLoop(false);
        nextGeneration();
    } else if (key == 'q') {
        println("\nUser ended Game after " + gen + " Generations.");
        exit();
    }
}

public void mouseMoved() {
    if (mouseY <= 40 && (mouseX <= 480 || (mouseX >= 600 && mouseX <= width - 120))) {
        cursor(HAND);
    } else cursor(ARROW);
}

public void mousePressed() {
    
    if (mouseButton == CENTER) {
        int i = floor((mouseX - offsetX) / res);
        int j = floor((mouseY - offsetY - 40) / res);
        println("Clicked on Cell:", i, j, grid[i][j].className());
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

public void mouseDragged() {
    slider(true);
    drawInitialGrid(true);
}

public void mouseReleased() {
    isSliding = false;
    isPainting = false;
}
float tankP = 0.1f;
float killerP = 0.7f;


class Cell {
    boolean alive;
    int x;
    int y;
    
    Cell(boolean alive, int x, int y) {
        this.alive = alive;
        this.x = x;
        this.y = y;
    }
    
    //called from nextGeneration() to transfer properties of original Cell-Object to a new one as not to modify any Cells in the original grid while its values are still needed 
    public Cell clone() {
        return new Cell(alive, x, y);
    }
    
    
    public String className() {
        return this.getClass().getSimpleName();
    }
    
    public Cell[] getNeighbours() {
        Cell[] res = new Cell[8];
        int index = 0;
        
        for (int i = - 1; i < 2; i++) {
            for (int j = - 1; j < 2; j++) {
                
                int col = (x + i + cols) % cols;
                int row = (y + j + rows) % rows;
                if (!(col == x && row == y))
                    res[index++] = grid[col][row];
            }
        }
        return res;
    }
    
    
    //called from nextGeneration() and includes ruleset for each cell type 
    public Cell transition() {
        Cell[] nbs = getNeighbours();
        int sum = 0;
        int tankNeighbours = 0;
        
        for (int i = 0; i < nbs.length; i++) {
            Cell c = nbs[i];
            sum += c.alive ? 1 : 0;
            
            if (c.className().equals("Tank")) {
                Tank t = (Tank)c;
                Cell[] n = t.getNeighbours();
                int s = 0;
                
                for (int j = 0; j < n.length; j++)
                    s += n[j].alive ? 1 : 0;
                
                if (s > 2) tankNeighbours++;
            }
        }
        
        // NEW RULES
        if (!alive && sum == 3) {
            if (random(1) > tankP) alive = true;
            else return new Tank(x, y, 3);
        }
        else if (alive && (sum < 2 || sum > 3)) alive = false;
        else if (alive && sum == 3 && tankNeighbours > 0) {
            if (random(1) * tankNeighbours < killerP)
                alive = false;
        }
        
        
        return this;
    }
    
    
    
    public void display() {
        fill(alive ? 0 : 255);
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}


// In each sub-class one can override three methods: clone, transition and display
// clone method: return an identical object as a copy by simply instantiating one of the SAME type with all of the objects same properties
// transition method: this is where you may implement customized rulesets; use getNeighbours to base rules on surrounding cells; use the className-method on neighbours to create different rules for different classes
// display method: make changes to how the objects should be drawn; appearance may be based on custom class properties to make the cells more expressive visually 


class Tank extends Cell {
    int maxHP;
    int hp;
    
    Tank(int x, int y, int maxHP, int...hp) { // health refers to number of generations the tank can survive despite having no neighbours
        super(true, x, y);
        this.maxHP = maxHP;
        this.hp = hp.length > 0 ? hp[0] : maxHP;
    }
    
    public Tank clone() {
        return new Tank(x, y, maxHP, hp); // Tanks are always alive; if they die, a normal, dead cell is returned
    }
    
    public Cell transition() {
        
        Cell[] nbs = getNeighbours();
        int sum = 0;
        int tankNeighbours = 0;
        
        for (int i = 0; i < nbs.length; i++) {
            Cell c = nbs[i];
            sum += c.alive ? 1 : 0;
            
            if (c.className().equals("Tank")) {
                Tank t = (Tank)c;
                Cell[] n = t.getNeighbours();
                int s = 0;
                
                for (int j = 0; j < n.length; j++)
                    s += n[j].alive ? 1 : 0;
                
                if (s > 2) tankNeighbours++;
            }
        }
        
        // NEW RULES
        if (!alive && sum == 3) {
            if (random(1) > tankP)
                return new Cell(true, x, y);
            else {
                alive = true;
                hp = constrain(++hp, 0, maxHP); // regenerate health if surrounded by exactly three live neighbours
            }
        }
        else if (alive && sum > 2 || sum == 0) {
            if (--hp <= 0)
                return new Cell(false, x, y);
        }
        else if (alive && sum == 3 && tankNeighbours > 0) {
            if (random(1) * tankNeighbours < killerP)
                return new Cell(false, x, y);
        }
        
        return this;
    }
    
    
    
    public void display() {
        fill(0, PApplet.parseFloat(hp) / maxHP * 220, 0);
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);

        
        fill(255);
        textSize(res * 2 / 3);
        text(str(hp), x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}


public void nextGeneration() {
    nextGrid = new Cell[cols][rows];
    
    
    for (int i = 0; i < cols; i++) {
        for (int j = 0; j < rows; j++) {
            // clone to transfer properties of original Cell-Object to a new one as not to modify any Cells in the original grid while its values are still needed
            // transition function has a return type of Cell (since a given cell it may be transitioned into another cell type, if sub-classes are created)
            Cell clone = grid[i][j].clone().transition();
            nextGrid[i][j] = clone;
            clone.display(); // note: all cells are drawn at once after the loop is done
        }
    }
    
    
    grid = nextGrid;
    gen++;
}



public void fileImported(File selection) {
    
    if (selection == null) {
        println("Window was closed or the user hit cancel.");
        return;
    }

    String path = selection.getAbsolutePath();
    println("User selected " + path);
    if (!split(path, ".")[1].equals("json")) {
        println("File could not be imported. Please select a file of type '.json'");
        return;
    }

    isImporting = true;
    JSONArray values = loadJSONArray(path);
    
    if (values.size() != cols * rows) {
        
        cols = 0;
        rows = 0;
        
        for (int i = 0; i < values.size(); i++) {
            JSONObject obj = values.getJSONObject(i); 
            int x = obj.getInt("x");
            int y = obj.getInt("y");
            
            if (++x > cols) cols = x;
            if (++y > rows) rows = y;
            // the above if statements require the last cell (that of highest row and column) to be last in JSON object
        }
        res = min((width - 2 * margin) / cols,(height - 40 - 2 * margin) / rows);
        
        
        grid = new Cell[cols][rows];
        nextGrid = new Cell[cols][rows];
        println("Resolution was changed to " + res + "px to accomodate imported Grid-Ratio: " + cols + " x " + rows);
    }
    
    
    for (int i = 0; i < values.size(); i++) {
        JSONObject obj = values.getJSONObject(i); 
        
        int x = obj.getInt("x");
        int y = obj.getInt("y");
        boolean a = obj.getBoolean("alive");
        
        Cell c = new Cell(a, x, y);
        grid[x][y] = c;
    }
    forceDraw = true;
    
}

public void fileExported(File selection) {
    if (selection == null) {
        println("Window was closed or the user hit cancel.");
    } else {
        String path = selection.getAbsolutePath();
        path = split(path, ".")[0] + ".json";
        
        JSONArray values = new JSONArray();
        int index = 0;
        
        for (int i = 0; i < cols; i++) {
            for (int j = 0; j < rows; j++) {
                
                Cell cell = grid[i][j];
                JSONObject obj = new JSONObject();
                
                obj.setInt("x", cell.x);
                obj.setInt("y", cell.y);
                obj.setBoolean("alive", cell.alive);
                
                values.setJSONObject(index++, obj);
            }
        }
        saveJSONArray(values, path);
        println("File saved as " + path);
    }
}



public void slider(boolean allowOverflow) {
    
    if (isPainting) return;
    if (!allowOverflow) isSliding = true;
    
    float x = mouseX;
    if (!allowOverflow && !(x >= 600 && x <= width - 120)) return;
    if (x < 480) return;
    
    x = constrain(x, 600, width - 120);
    float p = map(x, 600, width - 120, 0, 1);
    float hz = pow(10, p * log(maxHz) / log(10)); // power with base 10 and a maximal exponent such as to reach maxHz for p=1 
    T = 1000 / hz;
    //println(hz, T);
    
    noStroke();
    fill(0);
    rect(480, 0, width, 40);
    fill(255);
    textSize(20);
    text("Speed:", 480, 0, 120, 40);
    rect(600, 18, width - 720, 4, 4);
    text(nf(hz, 0, 2) + "Hz", width - 120, 0, 120, 40);
    ellipse(600 + p * (width - 720), 20, 10, 10);
}

public void drawInitialGrid(boolean dragged) {
    
    if (isImporting) {
        isImporting = false;
        return;
    }
    if (isSliding) return;
    if (!dragged) isPainting = true;
    if (!(mouseX >= offsetX && mouseX <= width - offsetX && mouseY >= offsetY + 40 && mouseY <= height - offsetY)) return;
    
    if (isLooping) {
        toggleLoop(false);
        return;
    }
    
    int i = floor((mouseX - offsetX) / res);
    int j = floor((mouseY - offsetY - 40) / res);
    if (i >= cols || j >= rows) return;
    
    Cell c = new Cell(mouseButton == LEFT, i, j);
    grid[i][j] = c;
    c.display();
}

public void toggleLoop(boolean...forcedState) {
    isLooping = forcedState.length > 0 ? forcedState[0] : !isLooping;
    
    fill(0);
    rect(240, 0, 120, 40);
    
    fill(255);
    textSize(20);
    text(isLooping ? "Pause" : "Play", 240, 0, 120, 40);
}
  public void settings() {  size(800, 600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Game_of_Life_Tank" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
