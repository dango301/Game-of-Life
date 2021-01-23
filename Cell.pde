float tankP = .125;


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
        
        // NEW RULES
        if (!alive && sum == 3) {
            if (random(1) > tankP) alive = true;
            else return new Tank(true, x, y, 3);
        }
        else if (alive && (sum < 2 || sum > 3)) alive = false;
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


class Tank extends Cell {
    int maxHP;
    int hp;
    
    Tank(boolean alive, int x, int y, int maxHP, int...hp) { // health refers to number of generations the tank can survive despite having no neighbours
        super(alive, x, y);
        this.maxHP = maxHP;
        this.hp = hp.length > 0 ? hp[0] : maxHP;
    }
    
    Tank clone() {
        return new Tank(alive, x, y, maxHP, hp);
    }
    
    Cell transition() {
        
        Cell[] nbs = getNeighbours(x, y);
        int sum = 0;
        
        for (int i = 0; i < nbs.length; i++) {
            sum +=nbs[i].alive ? 1 : 0;
        }
        
        // NEW RULES
        if (!alive && sum == 3) {
            if (random(1) > tankP)
                return new Cell(true, x, y);
            else {
                alive = true;
                hp = 5;
            }
        }
        else if (alive) { // && (sum < 2 || sum > 3)
            
            if (sum > 2 || sum == 0) {
                hp = max(0, --hp);
                if (hp == 0) return new Cell(false, x, y);
            }
            if (sum > 2) {
                int s = floor(random(0, nbs.length));
                int l = nbs.length;
                int m = floor(random(4, 7));
                for (int i = s; i < m + s; i++) {
                    Cell dead = nbs[(i + l) % l];
                    nextGrid[dead.x][dead.y] = new Cell(false, dead.x, dead.y);
                }
            }
        }
        
        return this;
    }
    
    
    
    void display() {
        fill(alive ? color(0, float(hp) / maxHP * 255, 0) : 255);
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}