float infectionProb = 0.01;
float transferProb = 0.75;
float deathProb = 0.66;


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
        int infectionSum = 0;
        
        for (int i = 0; i < nbs.length; i++) {
            Cell c = nbs[i];
            sum += c.alive ? 1 : 0;
            String n = c.className();
            
            if (alive && random(1) < transferProb) {
                if (n.equals("Infected") && (c.x == x || c.y == y)) infectionSum += ((Infected)c).dur; // only infected by directly adjacent neighbours
                else if (n.equals("Carcass")) infectionSum += ((Carcass)c).dur;
            }
            
        }
        
        // RULES
        if (!alive && sum == 3) alive = true;
        else if (alive && (sum < 2 || sum > 4)) alive = false;
        
        if (alive && infectionSum > 0)
            return new Infected(true, x, y, infectionSum);
        if (alive && random(1) < infectionProb)
            return new Infected(true, x, y, 4);
        
        
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
            Cell c = nbs[i];
            sum += c.alive ? 1 : 0;
            String n = c.className();
            
            // infection is exacerbated by other infected cells or carcasses
            if (random(1) < transferProb) {
                if (n.equals("Infected") && (c.x == x || c.y == y)) dur -= ((Infected)c).dur;
                else if (n.equals("Carcass")) dur -= ((Carcass)c).dur;
            }
        }        
        
        dur = max(0, dur - 1);
        if (dur == 0) { //at end of infection period cell either dies and leaves carcass or lives as normal cell
            if (random(1) < deathProb) return new Carcass(false, x, y, 1); // perhaps base propabilty to severity of infection (maxDur)
            else return new Cell(true, x, y);
        }
        
        // standard rule: dies if not exactly three live neighbours
        if (alive && (sum < 2 || sum > 4)) return new Carcass(false, x, y, 1); // leaves infectious carcass if not healed before death
        
        
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