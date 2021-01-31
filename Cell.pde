// Icons designed by Freepik from www.flaticon.com
//TODO: put icon attirbution in readme

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
    
    
    ArrayList<Cell> dfs() { // depth-first search that returns amount of directly connected cells of the same class as cell that dfs() was called on
        grid[x][y].discovered = true; // target grid cell not this.discovered because that property would belong to the clone, not what the neighbourse would be searching for
        
        // println();
        // println();
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
        // println("==>", x, y, sum.size());
        // for (Cell c : sum)
        //     println(c.x, c.y);
        
        return sum;
    }
    
    ArrayList<Cell> _dfs(String n) {
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
        // println("->", x, y, sum.size());
        // for (Cell c : sum)
        //     println(c.x, c.y);
        
        return sum;
    }
    
    
    
    
    //called from nextGeneration() and includes ruleset for each cell type 
    Cell transition() {
        
        Tribe _nextTribe = grid[x][y].nextTribe;
        if (_nextTribe != null) { // join tribe that was formed by first member in grid
            TribeMember newC = new TribeMember(x, y, _nextTribe);
            _nextTribe.addMember(newC);
            return newC;
        }
        
        
        Cell[] nbs = getNeighbours();
        int sum = 0;
        ArrayList<Tribe> tribeNbs = new ArrayList<Tribe>();
        
        for (int i = 0; i < nbs.length; i++) {
            Cell c = nbs[i];
            sum += c.alive ? 1 : 0;
            
            if (c.className().equals("TribeMember") && (c.x == x || c.y == y)) {
                Tribe t = ((TribeMember)c).tribe;
                if (!tribeNbs.contains(t))
                    tribeNbs.add(t);
            }
        }
        
        switch(tribeNbs.size())  {
            case 0 : // act like normal cell if no tribeNbs
            break;
            
            case 1 : // if there is one Tribe, there is a chnce of spawing this cell as a new member; otherwise it becomes / remains dead
            Tribe t = tribeNbs.get(0);
            
            if (random(1) < t.expansionProbability()) {
                TribeMember newCell = new TribeMember(x, y, t);
                t.addMember(newCell);
                println("New Tribe Member spawned at", x, y);
                return newCell;
            } else {
                alive = false;
                if (alive) println("Tribe killed this cell at", x, y);
                return this;
            }
            
            default : // if there are more than one tribeNbs, this cell must die / remain dead, as if the tribes were at war and unable to expand
            alive = false;
            if (alive) println("Tribe killed this cell at", x, y);
            return this;
        }
        
        
        if (!alive && sum == 3) alive = true;
        else if (alive && (sum < 2 || sum > 3)) alive = false;
        else if (alive) {
            ArrayList<Cell> directNbs = dfs();
            
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
    int maxSize = 100;
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
    
    float expansionProbability() {
        return 1 - this.size() / float(maxSize);
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