float tankP = 0.1;
float killerP = 0.7;


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
    
    Cell[] getNeighbours() {
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
    
    
    
    void display() {
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
    
    Tank clone() {
        return new Tank(x, y, maxHP, hp); // Tanks are always alive; if they die, a normal, dead cell is returned
    }
    
    Cell transition() {
        
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
    
    
    
    void display() {
        fill(0, float(hp) / maxHP * 220, 0);
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);

        
        fill(255);
        textSize(res * 2 / 3);
        text(str(hp), x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}