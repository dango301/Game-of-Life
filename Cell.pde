

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
    Cell clone() {
        return new Cell(alive, x, y);
    }
    
    
    String className() {
        return this.getClass().getSimpleName();
    }
    
    Cell[] getNeighbours(int x, int y) {
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
    Cell transition() {
        Cell[] nbs = getNeighbours(x, y);
        int sum = 0;
        
        for (int i = 0; i < nbs.length; i++) {
            sum +=nbs[i].alive ? 1 : 0;
        }
        
        // RULES
        if (!alive && sum == 3) alive = true;
        else if (alive && (sum < 2 || sum > 3)) alive = false;
        
        if (alive && random(1) < 0.1) return new Infected(true, x, y, 1);
        return this;
    }
    
    
    
    void display() {
        fill(alive ? 0 : 255);
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}


// At the moment, the Cell class only keeps track of the state alive / dead.
// To add further sub-classes they must extend the super, Cell

// In each sub-class one can override three methods: clone, transition and display
// clone method: return an identical object as a copy by simply instantiating one of the SAME type with all of the objects same properties
// transition method: this is where you may implement customized rulesets; use getNeighbours to base rules on surrounding cells; use the className-method on neighbours to create different rules for different classes
// display method: make changes to how the objects should be drawn; appearance may be based on custom class properties to make the cells more expressive visually

float textS = res * 2 / 3;

class Infected extends Cell {
    int maxDur;
    int dur;
    
    Infected(boolean alive, int x, int y, int duration, int...maxDuration) {
        super(alive, x, y);
        dur = duration;
        maxDur = maxDuration.length > 0 ? maxDuration[0] : duration;
    }
    
    Infected clone() {
        return new Infected(alive, x, y, dur, maxDur);
    }
    
    Cell transition() {
        Cell[] nbs = getNeighbours(x, y);
        int sum = 0;
        
        for (int i = 0; i < nbs.length; i++) {
            sum +=nbs[i].alive ? 1 : 0;
        }
        
        if (alive && (sum < 2 || sum > 3)) return new Carcass(false, x, y, 2);
        
        println();
        println(x, y);
        for (int i = 0; i < nbs.length; i++) {
            Cell c = nbs[i];
            String n = c.className();
            
            if (c.alive && (c.x == x || c.y == y)) {
                println(c.x, c.y);
                if (n == "Infected") {
                    Infected cc = (Infected)c.clone();
                    cc.dur = cc.dur + 2;
                    cc.maxDur = max(cc.maxDur, cc.dur);
                    if (i < 4) // assuming you get 8 surrounding neighbours
                        nextGrid[c.x][c.y] = cc;
                    else 
                        grid[c.x][c.y] = cc;
                }
                else if (n == "Cell") {
                    Infected cc = new Infected(true, c.x, c.y, dur);
                    if (i < 4) // assuming you get 8 surrounding neighbours
                        nextGrid[c.x][c.y] = cc;
                    else 
                        grid[c.x][c.y] = cc;
                }
            }
        }
        
        dur = max(0, dur - 1);
        if (dur == 0) { //at end of inction period cell either dies and leaves carcass or lives as normal cell
            if (alive && random(1) < 0.1) return new Carcass(false, x, y, 2);
            else return new Cell(true, x, y);
        }
        
        return this;
    }
    
    void display() {
        
        fill(float(dur) / maxDur * 255, 0, 0);
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        
        fill(255);
        textSize(textS);
        text(str(dur), x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}


class Carcass extends Cell {
    int dur; // for how many generations a carcass remains "alive", meaning for hol wlong it will stay on the grid before turning into a normal dead cell
    
    Carcass(boolean alive, int x, int y, int duration) {
        super(alive, x, y);
        dur = duration;
    }
    
    Carcass clone() {
        return new Carcass(alive, x, y, dur);
    }
    
    Cell transition() {
        Cell[] nbs = getNeighbours(x, y);
        
        for (int i = 0; i < nbs.length; i++) {
            Cell c = nbs[i];
            String n = c.className();
            
            if (c.alive) {
                if (n == "Infected") {
                    Infected cc = (Infected)c.clone();
                    cc.dur = cc.dur + 2;
                    cc.maxDur = max(cc.maxDur, cc.dur);
                    if (i < 4) // assuming you get 8 surrounding neighbours
                        nextGrid[c.x][c.y] = cc;
                    else 
                        grid[c.x][c.y] = cc;
                    
                }  else if (n == "Cell") {
                    Infected cc = new Infected(true, c.x, c.y, 1);
                    if (i < 4) // assuming you get 8 surrounding neighbours
                        nextGrid[c.x][c.y] = cc;
                    else 
                        grid[c.x][c.y] = cc;
                }
            }
        }
        
        dur = max(0, dur - 1);
        if (dur == 0) return new Cell(false, x, y);
        
        return this;
    }
    
    void display() {
        
        fill(218, 222, 0);
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        
        fill(255);
        textSize(res);
        text(str(dur), x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}