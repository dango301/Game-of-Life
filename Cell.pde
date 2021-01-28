float infectionProb = 0.05;
float transferProb = 0.5;
float deathProb = 0.125;
float spawnSev = 0.5;
float spawnDur = 4;
float maxSev = 3;
float healingRate = 1 / 3;


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
        float severitySum = 0;
        
        for (int i = 0; i < nbs.length; i++) {
            Cell c = nbs[i];
            sum += c.alive ? 1 : 0;
            String n = c.className();
            
            if (alive && random(1) < transferProb) {
                if (n.equals("Infected") && (c.x == x || c.y == y)) // only infected by directly adjacent neighbours
                    severitySum += ((Infected)c).severity;
                else if (n.equals("Carcass"))
                    severitySum += ((Carcass)c).severity;
            }
        }
        
        // RULES
        if (!alive && sum == 3) alive = true;
        else if (alive && (sum < 2 || sum > 3)) alive = false;
        
        if (alive) {
            if (severitySum > 0)
                return new Infected(x, y, severitySum, spawnDur);
            else if (random(1) < infectionProb)
                return new Infected(x, y, spawnSev, spawnDur);
        }
        
        return this;
    }
    
    
    
    void display() {
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

float textS = res * 2 / 3;

class Infected extends Cell {
    float maxSeverity = maxSev;
    float severity;
    int dur;
    float maxHealth = 5;
    float health;
    
    Infected(int x, int y, float severity, int dur, float...health) {
        super(true, x, y); // Infected cells are alive by default; once they die, they are replaced by normal dead cells or carcasses
        this.severity = severity;
        this.dur = dur;
        this.health = health.length > 0 ? health[0] : maxHealth;
    }
    
    Infected clone() {
        return new Infected(x, y, severity, dur, health);
    }
    
    Cell transition() {
        
        health -= severity;
        if (health <= 0)
            return new Carcass(x, y, 1, severity); // leave carcass with same severity of disease if not healthy before duration of infection runs out
        
        
        Cell[] nbs = getNeighbours(x, y);
        int sum = 0;
        
        for (int i = 0; i < nbs.length; i++) {
            Cell c = nbs[i];
            sum +=c.alive ? 1 : 0;
            String n = c.className();
            
            if (c.alive)
                health += healingRate;
            
            
            // infection is exacerbated by other infected cells or carcasses
            if (random(1) < transferProb) {
                if (n.equals("Infected") && (c.x == x || c.y == y)) severity += ((Infected)c).severity;
                else if (n.equals("Carcass")) severity += ((Carcass)c).severity;
            }
        }
        health = constrain(health, 0, maxHealth);
        
        if (--dur <= 0) { //at end of infection period cell either dies and leaves carcass or lives as normal cell
            if (random(1) < deathProb) return new Carcass(x, y, 1, severity / 3); // perhaps base propabilty to severity of infection (maxDur)
            else return new Cell(true, x, y);
        }
        
        // standard rule: dies if not exactly three live neighbours
        if (alive && (sum < 2 || sum > 3)) return new Carcass(x, y, 1, severity); // leaves infectious carcass  with same severity of disease if not healed before death
        
        
        return this;
    }
    
    void display() {
        
        float p = severity / maxSeverity;
        float r = pow(10, p * log(maxSeverity * 255) / log(10)) + 50;
        fill(r, 0, 0);
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        
        fill(255);
        textSize(textS);
        text(str(health), x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}


class Carcass extends Cell {
    float maxSeverity = maxSev;
    float severity;
    int dur; // for how many generations a carcass will stay on the grid before turning into a normal dead cell
    
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
        
        float p = severity / maxSeverity;
        float rg = pow(10, p * log(maxSeverity * 220) / log(10));
        fill(rg, rg, 0);
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        
        fill(255);
        textSize(textS);
        text(str(dur), x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}
