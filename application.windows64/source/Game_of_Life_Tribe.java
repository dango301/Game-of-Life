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

public class Game_of_Life_Tribe extends PApplet {

// User Variables
float res = 20; //dimensions of each cell in px //rename to resolution in the end
float margin = 8;  // margin on each side of the screen
float maxHz = 50;
float gridWeight = 0.1f; // min of .01 to prevent strange behaviour
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


public void setup() {
    // size(800, 600);
    
    
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
    
    allTribes = new ArrayList<Tribe>();
    deletedTribes = new ArrayList<Tribe>();
    
    
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

public void mouseDragged() {
    slider(true);
    drawInitialGrid(true);
}

public void mouseReleased() {
    isSliding = false;
    isPainting = false;
}


class Cell {
    boolean alive;
    int x;
    int y;
    Tribe nextTribe = null;
    boolean discovered = false; // only needed for dfs method; has no semantic value
    
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
    
    
    public ArrayList<Cell> dfs() { // depth-first search that returns amount of directly connected cells of the same class as cell that dfs() was called on
        grid[x][y].discovered = true; // target grid cell not this.discovered because that property would belong to the clone, not what the neighbourse would be searching for
        
        if (!alive) return new ArrayList<Cell>();
        ArrayList<Cell> sum = new ArrayList<Cell>();
        
        Cell[] nbs = getNeighbours(); // this only works because neighbours are taken directly from grid
        for (Cell c : nbs) {    
            if (c.alive && (c.x == x || c.y == y) && c.className().equals(this.className())) {
                ArrayList<Cell> summand = c._dfs(this.className());
                for (Cell s : summand)
                    sum.add(s);
            }
        }
        
        for (int i = 0; i < cols; i++) {
            for (int j = 0; j < rows; j++) {
                grid[i][j].discovered = false;
            }
        }
        
        return sum;
    }
    
    public ArrayList<Cell> _dfs(String n) {
        ArrayList<Cell> sum = new ArrayList<Cell>();
        
        if (this.discovered) return sum;
        else this.discovered = true;
        
        Cell[] nbs = getNeighbours();
        for (Cell c : nbs) {    
            if (c.alive && (c.x == x || c.y == y) && c.className().equals(n)) {
                ArrayList<Cell> summand = c._dfs(n);
                for (Cell s : summand)
                    sum.add(s);
            }
        }
        
        sum.add(this);
        
        return sum;
    }
    
    
    
    
    //called from nextGeneration() and includes ruleset for each cell type 
    public Cell transition() {
        
        Tribe _nextTribe = grid[x][y].nextTribe;
        if (_nextTribe != null) { // join tribe that was formed by first member in grid
            TribeMember newC = new TribeMember(x, y, _nextTribe);
            return newC;
        }
        
        
        Cell[] nbs = getNeighbours();
        int sum = 0;
        ArrayList<Tribe> tribeNbs = new ArrayList<Tribe>(); // all different tribes that are neighbours to this cell
        boolean hasMemberNb = false; // a normal cell can only become a member, if it has a DIRECT neighbour that is part of a tribe
        boolean battleInProximity = false; // a normal cell cannot become a tribe member if it is a neighbour to a battlefield
        
        for (Cell c : nbs) {
            String n = c.className();
            sum += c.alive ? 1 : 0;
            
            if (n.equals("TribeMember") || n.equals("Warrior")) {
                Tribe t = ((TribeMember)c).tribe;
                
                if (c.x == x || c.y == y)
                    hasMemberNb = true;
                
                if (!tribeNbs.contains(t))
                    tribeNbs.add(t);
                
            } else if (n.equals("Battlefield"))
                battleInProximity = true;
        }
        
        switch(tribeNbs.size())  {
            case 0 : // act like normal cell if no tribeNbs
            break;
            
            case 1 : // if there is one Tribe and this cell fulfills the criteria, there is a chance of spawing this cell as a new member; otherwise it is killed / remains dead
            Tribe t = tribeNbs.get(0);
            boolean newMemberConditions =
            hasMemberNb
            && !battleInProximity
            && !t.inBattle
            && random(1) < t.expansionProbability();
            
            if (newMemberConditions) {
                TribeMember newCell = new TribeMember(x, y, t);
                // println("New Tribe Member spawned at", x, y);
                return newCell;
            } else {
                alive = false;
                // if (alive) println("Tribe killed this cell at", x, y);
                return this;
            }
            
            default : // if there are multiple Tribes surrounding this cell, it becomes a Battlefield
            for (Tribe nbsTribe : tribeNbs)
                nbsTribe.inBattle = true;
            // println("Tribes going to war at", x, y);
            return new Battlefield(x, y);
        }
        
        
        if (!alive && sum == 3) alive = true;
        else if (alive && (sum < 2 || sum > 3)) alive = false;
        else if (alive) {
            ArrayList<Cell> directNbs = dfs();
            
            if (directNbs.size() < 2) alive = false;
            else if (directNbs.size() > 2) { // sum must be at least 3, which, together with this live cell, makes a total of at least 4 cells ready to form a tribe
                
                Tribe newTribe = new Tribe();
                TribeMember newCell = new TribeMember(x, y, newTribe);
                
                for (Cell c : directNbs)
                    grid[c.x][c.y].nextTribe = newTribe; // change property in original grid (this method is not recommended at all, though!) so following cells can join that tribe instead of creating a new one
                
                println("Created new Tribe at", x, y);
                return newCell;
            }
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
// clone method: return an identical object as a copy by simply instantiating one of the SAME type with all of the object's same properties
// transition method: this is where you may implement customized rulesets; use getNeighbours to base rules on surrounding cells; use the className-method to create different rules based on a cell's neighbours and their different classes, respectively
// display method: make changes to how the objects should be drawn; appearance may be based on custom class properties to make the cells more expressive visually


class MemberID {
    int x;
    int y;
    
    MemberID(int x, int y) {
        this.x = x;
        this.y = y;
    }
    
    public Cell getCell() {
        return grid[x][y];
    }
}


class Tribe {
    int maxSize = maxTribeSize;
    ArrayList<MemberID> members = new ArrayList<MemberID>();
    MemberID king;
    int col;
    float minColorValue = 75;
    boolean inBattle = false;
    Tribe hasFallenTo = null;
    
    Tribe(int...col) {
        this.col = col.length > 0 ? col[0] : color(random(minColorValue, 255), random(minColorValue, 255), random(minColorValue, 255));
        allTribes.add(this);
    }
    
    public void addMember(TribeMember member) {
        
        for (MemberID m : members) {
            if (m.x == member.x && m.y == member.y) {
                // println("MemberID was not added to Tribe because it is already registered for TribeMember at", member.x, member.y);
                return;
            }
        }
        members.add(new MemberID(member.x, member.y));
    }
    
    public void removeMember(int x, int y) {
        
        for (int i = 0; i < members.size(); i++) {
            MemberID m = members.get(i);
            if (m.x == x && m.y == y) {
                members.remove(m);
                return;
            }
        }
        println("MemberID could not be removed because it was never registered to tribe at " + x + " " + y);
    }
    
    public int size() {
        return members.size();
    }
    
    public float expansionProbability() {
        return 1 - this.size() / PApplet.parseFloat(maxSize);
    }
    
    public void update() { // remove all TribeMembers that were killed / removed in the previous generation

        if (hasFallenTo == null && king != null) {
            Cell k = king.getCell();
            String n = k.className();

            if (n.equals("TribeMember") || n.equals("Warrior")) {
                TribeMember c = (TribeMember)k;
                if (c.tribe != this) {
                    this.hasFallenTo = c.tribe;
                    println("King was captured at", king.x, king.y, "and His TribeMembers have fallen to the winning Tribe.");
                }
            }
        }
        
        ArrayList<MemberID> deletedMembers = new ArrayList<MemberID>();
        boolean warriorsInTribe = false;
        
        for (MemberID m : members) {
            Cell c = m.getCell();
            String n = c.className();
            
            if (n.equals("Cell") || n.equals("Battlefield")) {
                deletedMembers.add(m);
            } else if (n.equals("TribeMember") || n.equals("Warrior")) {
                TribeMember cc = (TribeMember)c;
                if (cc.tribe != this)
                    deletedMembers.add(m);
                else if (n.equals("Warrior"))
                    warriorsInTribe = true;
            }
        }
        inBattle = warriorsInTribe;
        
        for (MemberID m : deletedMembers)
            removeMember(m.x, m.y);
        
        king();
    }
    
    public void king() { // determine which cell is king of tribe and display it
        if (this.size() == 0) return;
        
        int xSum = 0; 
        int ySum = 0; 
        
        for (MemberID member : members) {
            xSum += member.x;
            ySum += member.y;
        }
        
        float xAvg = PApplet.parseFloat(xSum) / this.size();
        float yAvg = PApplet.parseFloat(ySum) / this.size();
        
        FloatList distances = new FloatList();
        for (MemberID m : members)
            distances.append(sqrt(sq(m.x - xAvg) + sq(m.y - yAvg))); // using Pythagoras theorem to find closest cell to center of mass of entire tribe
        
        int index = distances.index(distances.min());
        king = members.get(index);
    }
}


class TribeMember extends Cell{
    Tribe tribe;
    
    TribeMember(int x, int y, Tribe tribe) {
        super(true, x, y);
        this.tribe = tribe;
        tribe.addMember(this);
    }
    
    public TribeMember clone() {
        return new TribeMember(x, y, tribe);
    }
    
    public Cell transition() {
        
        if (tribe.hasFallenTo != null) {
            return new TribeMember(x, y, tribe.hasFallenTo);
        }
        
        
        int directMemberNbs = dfs().size();
        if (directMemberNbs != tribe.size() && directMemberNbs < 3) // TribeMembers that are disconnected from Tribe are killed if less than four in cluster
            return new Cell(false, x, y);
        
        Cell[] nbs = getNeighbours();
        for (Cell c : nbs) {
            String n = c.className();
            
            boolean battleConditions = // Warrior is spawned, if there is a Battlefield or TribeMember / Warrior of a different Tribe
            n.equals("Battlefield")
                || ((n.equals("TribeMember") || n.equals("Warrior")) && ((TribeMember)c).tribe != this.tribe);
            
            if (battleConditions)
                return new Warrior(x, y, tribe, tribe.size() / PApplet.parseFloat(tribe.maxSize) * warriorStrengthMuliplicator, warriorSpawnHealth);
        }
        
        
        return this;
    }
    
    public void display() {
        
        fill(tribe.col);
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        
        MemberID k = tribe.king;
        if (k != null && k.x == x && k.y == y)
            shape(crown,  k.x * res + offsetX, k.y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}


class Warrior extends TribeMember {
    float maxHealth;
    float strength;
    float health;
    
    Warrior(int x, int y, Tribe tribe, float strength, float maxHealth, float...health) {
        super(x, y, tribe);
        this.strength = strength;
        this.maxHealth = maxHealth;
        this.health = health.length > 0 ? health[0] : maxHealth;
    }
    
    public Warrior clone() {
        return new Warrior(x, y, tribe, strength, maxHealth, health);
    }
    
    public Cell transition() {
        
        if (tribe.hasFallenTo != null) {
            return new TribeMember(x, y, tribe.hasFallenTo);
        }
        
        
        Cell[] nbs = getNeighbours();
        ArrayList<Warrior> previousAttackers = new ArrayList<Warrior>();
        ArrayList<Tribe> enemyTribes = new ArrayList<Tribe>();
        FloatList tribeDamage = new FloatList();
        boolean noThreat = true;
        
        for (Cell c : nbs) {
            String n = c.className();
            
            if (n.equals("Battlefield")) {
                
                noThreat = false;
                Cell[] participants = ((Battlefield)c).getNeighbours();
                
                for (Cell p : participants) {
                    if (!p.className().equals("Warrior")) continue;
                    
                    // each Warrior from every other party attacks this Warrior
                    Warrior w = (Warrior)p;
                    if (w.tribe == this.tribe) continue; // don't be attacked by Warriors from same Tribe
                    
                    if (previousAttackers.contains(w)) {
                        // println("prevented double attack by", w.x, w.y, "at", x, y);
                        continue;
                    }
                    
                    previousAttackers.add(w);
                    if (!enemyTribes.contains(w.tribe)) {
                        enemyTribes.add(w.tribe);
                        tribeDamage.append(0.0f);
                    }
                    
                    int i = enemyTribes.indexOf(w.tribe);
                    tribeDamage.add(i, w.strength);
                }
                
                
            } else if (n.equals("Warrior")) {
                
                Warrior w = (Warrior)c;
                if (w.tribe == this.tribe) continue; // don't be attacked by Warriors from same Tribe
                
                noThreat = false;
                if (previousAttackers.contains(w)) {
                    // println("prevented double attack by", w.x, w.y, "at", x, y);
                    continue;
                }
                
                previousAttackers.add(w);
                if (!enemyTribes.contains(w.tribe)) {
                    enemyTribes.add(w.tribe);
                    tribeDamage.append(0.0f);
                }
                
                int i = enemyTribes.indexOf(w.tribe);
                tribeDamage.add(i, w.strength);
            }
        }
        
        
        if (noThreat) // Warrior becomes normal cell when there are no enemies around
            return new TribeMember(x, y, tribe);
        
        
        for (Float damage : tribeDamage)
            health -= damage;
        
        if (health <= 0) { //Warrior dies in battle
            
            int index = tribeDamage.index(tribeDamage.max()); // whoever dealt the most damage in the final generation of this Warrior is pronounced its killer
            Tribe t = enemyTribes.get(index);
            
            // println("Warrior has fallen and a new Warrior of the winning Tribe has taken his place to continue into battle at", x, y);
            return new Warrior(x, y, t, t.size() / PApplet.parseFloat(t.maxSize) * warriorStrengthMuliplicator * random(2, warriorWinnerRandomMultiplier), warriorSpawnHealth); // killer spawns new Warrior in his place because he is the winner of the battle
        }
        
        
        return this;
    }
    
    
    public void display() {
        
        stroke(0);
        strokeWeight(gridWeight);
        fill(0);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight); // draw blacked out box under rect for darker cell from alpha effect
        
        fill(tribe.col, 150 + 105 * health / maxHealth);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        shape(helmet, x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        
        
        MemberID k = tribe.king;
        if (k != null && k.x == x && k.y == y)
            shape(crown,  k.x * res + offsetX, k.y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}



class Battlefield extends Cell {
    boolean waitForWarriorsToSpawn;
    
    Battlefield(int x, int y, boolean...wait) {
        super(false, x, y);
        waitForWarriorsToSpawn = wait.length > 0 ? wait[0] : true;
    }
    
    public Battlefield clone() {
        return new Battlefield(x, y, waitForWarriorsToSpawn);
    }
    
    public Cell transition() {
        
        if (waitForWarriorsToSpawn) { // wait for one generation so that Battlefield dosn't disappear before Warriors are spawend around it
            waitForWarriorsToSpawn = false;
            return this;
        }
        
        Cell[] nbs = getNeighbours();
        ArrayList<Tribe> parties = new ArrayList<Tribe>();
        
        for (Cell c : nbs) {
            if (!c.className().equals("Warrior")) continue;
            
            Warrior w = (Warrior)c;
            if (!parties.contains(w.tribe))
                parties.add(w.tribe);
        }
        
        if (parties.size() == 0) {
            
            // println("Battle at", x, y, "is over. No Tribe has emerged victorious.");
            return new Cell(false, x, y);
            
        } else if (parties.size() == 1) {
            
            Tribe t = parties.get(0);
            // println("Battle at", x, y, "is over. A Tribe has emerged victorious and spawned a new Warrior.");
            return new Warrior(x, y, t, t.size() / PApplet.parseFloat(t.maxSize) * warriorStrengthMuliplicator * random(2, warriorWinnerRandomMultiplier), warriorSpawnHealth); // killer spawns new Warrior in his place because he is the winner of the battle
        }
        
        
        return this;
    }
    
    public void display() {
        
        fill(255);
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        
        shape(swords, x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}


public void nextGeneration() {
    nextGrid = new Cell[cols][rows];
    
    for (Tribe t : deletedTribes)
        allTribes.remove(t);
    
    
    for (Tribe t : allTribes) {
        t.update();
        if (t.size() == 0)
            deletedTribes.add(t);
    }
    
    
    
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
    
    Cell oldCell = grid[i][j];
    boolean redrawMembers = false;
    if (oldCell.className().equals("TribeMember") || oldCell.className().equals("Warrior")) {
        redrawMembers = true;
    }
    
    Cell c = new Cell(mouseButton == LEFT, i, j);
    grid[i][j] = c;
    
    if (redrawMembers) {
        for (Tribe t : allTribes) {
            t.update();
            for (MemberID m : t.members)
                ((TribeMember)m.getCell()).display();
        }
    }
    
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
  public void settings() {  fullScreen(1); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Game_of_Life_Tribe" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
