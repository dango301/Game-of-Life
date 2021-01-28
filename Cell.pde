float infectionProb = 0.05;
float transferProb = 1;
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
        int severitySum = 0;
        
        for (int i = 0; i < nbs.length; i++) {
            Cell c = nbs[i];
            sum += c.alive ? 1 : 0;
            String n = c.className();
            
            if (random(1) < transferProb) {
                if (n.equals("Infected") && (c.x == x || c.y == y)) severitySum += ((Infected)c).severity; // only infected by directly adjacent neighbours
                else if (n.equals("Carcass")) severitySum += ((Carcass)c).severity;
            }
            
        }
        
        // RULES
        if (!alive && sum == 3) alive = true;
        else if (alive && (sum < 2 || sum > 3)) alive = false;
        
        if (alive && severitySum > 0)
            return new Infected(x, y, severitySum, 4); //TODO: consider using average of all infected neighbour's durs
        if (alive && random(1) < infectionProb)
            return new Infected(x, y, 0.5, 4);
        
        
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

float textS = res * 1 / 3;

class Infected extends Cell {
    float maxSeverity = 3;
    float severity;
    int dur;
    float maxHealth = 5;
    float health;
    
    Infected(int x, int y, float severity, int dur, float...health) {
        super(true, x, y); // Infected cells are alive by default; once they die, they are replaced by normal dead cells or carcasses
        this.dur = dur;
        this.health = health.length > 0 ? health[0] : maxHealth;
    }
    
    Infected clone() {
        return new Infected(x, y, severity, dur, health);
    }
    
    Cell transition() {
        
        health -= severity;    
        Cell[] nbs = getNeighbours(x, y);
        int sum = 0;
        
        for (int i = 0; i < nbs.length; i++) {
            Cell c = nbs[i];
            sum += c.alive ? 1 : 0;
            String n = c.className();
            
            // infection is exacerbated by other infected cells or carcasses
            if (random(1) < transferProb) {
                if (n.equals("Infected") && (c.x == x || c.y == y)) severity += ((Infected)c).severity;
                else if (n.equals("Carcass")) severity += ((Carcass)c).severity;
            }
        }        
        
        if (health <= 0) { // leave carcass with same severity of disease if not healed before duration of infection runs out
            return new Carcass(x, y, 1, severity);
        }
        
        if (--dur <= 0) { //at end of infection period cell either dies and leaves carcass or lives as normal cell
            if (random(1) < deathProb) return new Carcass(x, y, 1, severity / 3); // perhaps base propabilty to severity of infection (maxDur)
            else return new Cell(true, x, y);
        }
        
        // standard rule: dies if not exactly three live neighbours
        if (alive && (sum < 2 || sum > 3)) return new Carcass(x, y, 1, severity); // leaves infectious carcass  with same severity of disease if not healed before death
        
        
        return this;
    }
    
    void display() {
        
        fill(severity / maxSeverity * 255 + 50, 0, 0); //TODO: consider using exponential scale for color
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        
        fill(255);
        textSize(textS);
        text(str(health), x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}


class Carcass extends Cell {
    float maxSeverity = 3;
    float severity;
    int dur; // for how many generations a carcass remains "alive", meaning for hol wlong it will stay on the grid before turning into a normal dead cell
    
    Carcass(int x, int y, int dur, float severity) {
        super(false, x, y); // carcass is dead by definition
        this.dur = dur;
        this.severity = severity;
    }
    
    Carcass clone() {
        return new Carcass(x, y, dur, severity);
    }
    
    Cell transition() {
        
        if (--dur <= 0)
            return new Cell(false, x, y);
        
        return this;
    }
    
    void display() {
        
        float val = severity / maxSeverity * 255 + 100;
        fill(val, val, 0);
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        
        fill(255);
        textSize(textS);
        text(str(dur), x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}