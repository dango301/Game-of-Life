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
        ArrayList<Tribe> tribeNbs = new ArrayList<Tribe>(); // all different tribes that are neighbours to this cell
        
        for (Cell c : nbs) {
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
                // println("New Tribe Member spawned at", x, y);
                return newCell;
            } else {
                alive = false;
                if (alive) println("Tribe killed this cell at", x, y);
                return this;
            }
            
            default : // if there are multiple Tribes surrounding this cell, it becomes a Battlefield-Object
            println("Tribes going to war at", x, y);
            return new Battlefield(x, y, tribeNbs);
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
    int maxSize = 200;
    ArrayList<MemberID> members = new ArrayList<MemberID>();
    MemberID king;
    color col;
    
    Tribe(color...col) {
        float minC = 75;
        this.col = col.length > 0 ? col[0] : color(random(minC, 255), random(minC, 255), random(minC, 255));
        allTribes.add(this);
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
    
    MemberID king() {
        int xSum = 0; 
        int ySum = 0; 
        
        for (MemberID member : members) {
            xSum += member.x;
            ySum += member.y;
        }
        
        float xAvg = float(xSum) / this.size();
        float yAvg = float(ySum) / this.size();
        
        FloatList distances = new FloatList();
        for (MemberID m : members)
            distances.append(sqrt(sq(m.x - xAvg) + sq(m.y - yAvg)));
        int index = distances.index(distances.min());
        // println(xAvg, yAvg, index, distances.min());
        
        
        
        king = members.get(index);
        int x = king.x;
        int y = king.y;
        shape(crown, x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        
        return king;
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
            
            if (n.equals("TribeMember")) {
                TribeMember cc = (TribeMember)c;
                if (cc.tribe != this.tribe) {
                    return new Warrior(x, y, tribe, tribe.size() / float(tribe.maxSize) * 3, 3);
                }
            } else if (n.equals("Battlefield")) {
                Battlefield cc = (Battlefield)c;
                Warrior newCell = new Warrior(x, y, tribe, tribe.size() / float(tribe.maxSize) * 3, 3);
                cc.addWarrior(newCell);
                return newCell;
            }
        }
        
        
        return this;
    }
    
    void display() {
        
        fill(tribe.col);
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        
        // MemberID k = tribe.getKing();
        // if (k.x == x && k.y == y)
        //     shape(crown, x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
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
    
    Warrior clone() {
        return new Warrior(x, y, tribe, strength, maxHealth, health);
    }
    
    Cell transition() {
        Cell[] nbs = getNeighbours();
        
        for (Cell c : nbs) {
            String n = c.className();
            
            if (n.equals("Battlefield")) {
                //TODO: now what?
                
            } else if (n.equals("Warrior")) {
                Warrior w = (Warrior)c;
                
                if (w.tribe != this.tribe) {
                    //TODO: write code for when shit goes down in direct combat
                }
            }
        }
        
        return this;
    }
    
    void display() {
        
        fill(tribe.col);
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        
        shape(helmet, x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}

//FIXME: add removeWarrior methods to Party and Battlefield classes
class Battlefield extends Cell {
    ArrayList<Party> parties = new ArrayList<Party>();
    
    class Party {
        Tribe tribe;
        ArrayList<MemberID> warriors = new ArrayList<MemberID>();
        
        Party(Tribe tribe) {
            this.tribe = tribe;
            this.warriors = warriors;
        }
        
        ArrayList<MemberID> addWarrior(int x, int y) {
            warriors.add(new MemberID(x, y));
            return warriors;
        }
        
    }
    
    Battlefield(int x, int y, ArrayList<Tribe> tribesAtWar) {
        super(false, x, y);
        
        for (Tribe t : tribesAtWar) {
            parties.add(new Party(t));
        }
    }
    
    void addWarrior(Warrior w) {
        for (Party p : parties) {
            if (p.tribe == w.tribe)
                p.addWarrior(w.x, w.y);
        }
    }
    
    Battlefield clone() {
        Battlefield b = new Battlefield(x, y, new ArrayList<Tribe>());
        b.parties = this.parties;
        return b;
    }
    
    Cell transition() {
        
        return this;
    }
    
    void display() {
        
        fill(255);
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        
        shape(swords, x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}