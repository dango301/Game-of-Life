

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
    
    
    ArrayList<Cell> dfs() { // depth-first search that returns amount of directly connected cells
        this.discovered = true;
        
        println();
        if (!alive) return new ArrayList<Cell>();
        ArrayList<Cell> sum = new ArrayList<Cell>();
        
        Cell[] nbs = getNeighbours();
        for (Cell c : nbs) {    
            if (c.alive && (c.x == x || c.y == y)) {
                ArrayList<Cell> summand = c._dfs();
                for (Cell s : summand)
                    sum.add(s);
            }
        }
        
        for (int i = 0; i < cols; i++) {
            for (int j = 0; j < rows; j++) {
                grid[i][j].discovered = false;
            }
        }
        println("==>", x, y, sum);
        return sum;
    }
    
    ArrayList<Cell> _dfs() {
        ArrayList<Cell> sum = new ArrayList<Cell>();
        
        if (this.discovered) return sum;
        else this.discovered = true;
        
        Cell[] nbs = getNeighbours();
        for (Cell c : nbs) {    
            if (c.alive && (c.x == x || c.y == y)) {
                ArrayList<Cell> summand = c._dfs();
                for (Cell s : summand)
                    sum.add(s);
            }
        }
        
        sum.add(this);
        println(x, y, sum);
        return sum;
    }
    
    
    
    
    //called from nextGeneration() and includes ruleset for each cell type 
    Cell transition() {
        
        if (nextTribe != null) {
            TribeMember newC = new TribeMember(x, y, nextTribe);
            nextTribe.addMember(newC);
            return newC;
        }
        
        
        Cell[] nbs = getNeighbours();
        int sum = 0;
        
        // if (alive) println("\n==>", x, y);
        for (int i = 0; i < nbs.length; i++) {
            Cell c = nbs[i];
            String n = c.className();
            sum += c.alive ? 1 : 0;
            
            
            if (n.equals("TribeMember")) {
                TribeMember cc = (TribeMember)c;
                
                if (cc.tribe.size() > 4) {
                    alive = false;
                    println("Tribe killed", x, y);
                    return this;
                }
            }
        }
        
        
        if (!alive && sum == 3) alive = true;
        else if (alive && (sum < 2 || sum > 3)) alive = false;
        
        
        if (alive) {
            ArrayList<Cell> directNbs = dfs();
            
            println("\n==>", x, y);
            for (Cell c : directNbs)
                println(c.x, c.y);
            
            if (directNbs.size() < 2) alive = false;
            else if (directNbs.size() > 2) { // sum must be at least 3, which, together with this live cell, makes a total of at least 4 cells ready to form a tribe
                
                Tribe newTribe = new Tribe();
                TribeMember newCell = new TribeMember(x, y, newTribe);
                newTribe.addMember(newCell);
                
                for (Cell c : directNbs)
                    grid[c.x][c.y].nextTribe = newTribe; // change property in original grid so following cells can join that tribe instead of creating a new one
                
                println("Created new Tribe at", x, y);
                return newCell;
            }
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


class MemberID {
    int x;
    int y;
    
    MemberID(int x, int y) {
        this.x = x;
        this.y = y;
    }
    
    TribeMember get() {
        return(TribeMember)grid[x][y];
    }
}


class Tribe {
    int maxSize = 50;
    ArrayList<MemberID> members = new ArrayList<MemberID>();
    color col;
    
    Tribe(color...col) {
        float minC = 75;
        this.col = col.length > 0 ? col[0] : color(random(minC, 255), random(minC, 255), random(minC, 255));
    }
    
    ArrayList<MemberID> addMember(TribeMember member) {
        members.add(new MemberID(member.x, member.y));
        return members;
    }
    int size() {
        return members.size();
    }
    
    MemberID centerOfMass() {
        int xSum = 0; 
        int ySum = 0; 
        
        for (MemberID member : members) {
            xSum += member.x;
            xSum += member.y;
        }
        
        float xAvg = float(xSum) / this.size();
        float yAvg = float(ySum) / this.size();
        //TODO: return nearest (x, y) pair that belongs to an existing member
        return members.get(0);
    }
}


class TribeMember extends Cell{
    Tribe tribe;
    
    TribeMember(int x, int y, Tribe tribe) {
        super(true, x, y);
        this.tribe = tribe;
    }
    
    TribeMember clone() {
        return new TribeMember(x, y, tribe);
    }
    
    Cell transition() {
        Cell[] nbs = getNeighbours();
        
        for (Cell c : nbs) {
            String n = c.className();
            
            
        }
        
        
        return this;
    }
    
    void display() {
        
        fill(tribe.col);
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}