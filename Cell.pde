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
                t.addMember(newCell);
                // println("New Tribe Member spawned at", x, y);
                return newCell;
            } else {
                alive = false;
                if (alive) println("Tribe killed this cell at", x, y);
                return this;
            }
            
            default : // if there are multiple Tribes surrounding this cell, it becomes a Battlefield
            for (Tribe nbsTribe : tribeNbs)
                nbsTribe.inBattle = true;
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
                    grid[c.x][c.y].nextTribe = newTribe; // change property in original grid (this method is not recommended at all, though!) so following cells can join that tribe instead of creating a new one
                
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
    
    Cell get() {
        return grid[x][y];
    }
}


class Tribe {
    int maxSize = 200;
    ArrayList<MemberID> members = new ArrayList<MemberID>();
    MemberID king;
    color col;
    float minColorValue = 75;
    boolean inBattle = false;
    
    Tribe(color...col) {
        this.col = col.length > 0 ? col[0] : color(random(minColorValue, 255), random(minColorValue, 255), random(minColorValue, 255));
        allTribes.add(this);
    }
    
    ArrayList<MemberID> addMember(TribeMember member) {
        members.add(new MemberID(member.x, member.y));
        return members;
    }
    ArrayList<MemberID> removeMember(TribeMember member) {
        
        for (int i = 0; i < members.size(); i++) {
            MemberID m = members.get(i);
            if (m.x == member.x && m.y == member.y) {
                members.remove(m);
                break;
            }
        }
        return members;
    }
    
    int size() {
        return members.size();
    }
    
    float expansionProbability() {
        return 1 - this.size() / float(maxSize);
    }
    
    MemberID king() { // determine which cell is king of tribe and display it
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
            distances.append(sqrt(sq(m.x - xAvg) + sq(m.y - yAvg))); // using Pythagoras theorem to find closest cell to center of mass of entire tribe
        int index = distances.index(distances.min());
        
        
        king = members.get(index);
        shape(crown,  king.x * res + offsetX, king.y * res + offsetY + 40, res - gridWeight, res - gridWeight);
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
        ArrayList<Battlefield> battlesInProximity = new ArrayList<Battlefield>();
        ArrayList<TribeMember> enemiesInProximity = new ArrayList<TribeMember>();
        
        for (Cell c : nbs) {
            String n = c.className();
            
            if (n.equals("Battlefield"))
                battlesInProximity.add((Battlefield)c);
            else if (n.equals("TribeMember")) {
                if (((TribeMember)c).tribe != this.tribe)
                    enemiesInProximity.add((TribeMember)c);
            }
            
            if (battlesInProximity.size() > 0) {
                
                Warrior newCell = new Warrior(x, y, tribe, tribe.size() / float(tribe.maxSize) * 3, 3);
                for (Battlefield b : battlesInProximity)
                    b.addWarrior(newCell);
                return newCell;
            }
            
            if (enemiesInProximity.size() > 0)
                return new Warrior(x, y, tribe, tribe.size() / float(tribe.maxSize) * 3, 3);
            
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

//TODO: when king cell is killed destroy entire tribe and delelte it from allTribes[]; only a half of enemy tribe's cells will be added to winning tribe, others die as if destroyed by the war; restore health of all warriors

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
        float damage = 0;
        ArrayList<Warrior> previousAttackers = new ArrayList<Warrior>();
        
        for (Cell c : nbs) {
            String n = c.className();
            
            if (n.equals("Battlefield")) {
                Battlefield b = (Battlefield)c;
                
                // each Warrior from every other party attacks this Warrior
                for (Party p : b.parties) {
                    if (p.tribe == this.tribe) continue;
                    
                    for (MemberID m : p.warriors) {
                        Cell cc = m.get();
                        
                        // if a member isn't of class Warrior yet that means that warriors of that generation are still spawning 
                        if (!cc.className().equals("Warrior")) { //FIXME:
                            println("Warrior at", x, y, "could not be attacked by cell at", cc.x, cc.y, "because it was registered to battlefield at", b.x, b.y, "without being off class Warrior");
                            continue;
                        }
                        
                        Warrior w = (Warrior)cc;
                        if (previousAttackers.contains(w)) {
                            // println("prevented double attack by", w.x, w.y, "at", x, y);
                            continue;
                        }
                        
                        previousAttackers.add(w);
                        damage += w.strength;
                    }
                }
            } else if (n.equals("Warrior")) {
                Warrior w = (Warrior)c;
                
                if (w.tribe != this.tribe) {
                    //TODO: write code for when shit goes down in direct combat
                }
            }
        }
        
        // println(x, y, health);
        // it is important the health condition be checked BEFORE subtracting damage because cell must be killed in NEXT generation, as not to modify the ongoing battle of the current generation
        if (health <= 0) { //Warrior dies in battle
            println("Warrior has fallen at:", x, y);
            return new Cell(false, x, y); // Warrior becomes a normal, dead Cell
        }
        
        health -= damage;
        return this;
    }
    
    
    void display() {
        
        stroke(0);
        strokeWeight(gridWeight);
        fill(0);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight); // draw black box under rect for darker cell from alpha effect
        fill(tribe.col, 150 + 105 * health / maxHealth);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        
        shape(helmet, x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}



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
    
    ArrayList<MemberID> removeWarrior(Warrior w) {
        
        for (int i = 0; i < warriors.size(); i++) {
            MemberID m = warriors.get(i);
            if (m.x == w.x && m.y == w.y) {
                warriors.remove(m);
                break;
            }
        }
        return warriors;
    }
}

class Battlefield extends Cell {
    ArrayList<Party> parties = new ArrayList<Party>();
    long iGen; // generation in which batlefield was initialized; needed so that Battlefield cell does not begin transitioning before all the other Cells around it have also transitioned
    
    Battlefield(int x, int y, ArrayList<Tribe> tribesAtWar, long...iGen) {
        super(false, x, y);
        this.iGen = iGen.length > 0 ? iGen[0] : gen;
        
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
        Battlefield b = new Battlefield(x, y, new ArrayList<Tribe>(), iGen);
        b.parties = this.parties;
        return b;
    }
    
    Cell transition() {
        if (gen <= iGen + 1) return this; // generation must be at least two greater than the generation in which Battlefield was initialized to guarantee all nbs have spawned
        
        ArrayList<Party> deadParties = new ArrayList<Party>();
        for (Party p : parties) {
            ArrayList<Warrior> deadWarriors = new ArrayList<Warrior>();
            
            for (MemberID m : p.warriors) {
                Cell c = m.get();
                
                if (c.className().equals("Warrior")) {
                    Warrior w = (Warrior)c;
                    if (w.health <= 0) {
                        deadWarriors.add(w);
                    }
                }
            }
            
            for (Warrior deadWarrior : deadWarriors)
                p.warriors.remove(deadWarrior);
            
            if (p.warriors.size() == 0) {
                deadParties.add(p);
                println("Last Warrior has fallen. Tribe has lost battle.");
            }
        }
        for (Party deadP : deadParties) 
            parties.remove(deadP);
        
        
        
        /*if (parties.size() == 0) {
        println("Battle at", x, y, "is over. No Tribes have emerged victorious.");
        return new Cell(false, x, y);
    }
        else*/ if (parties.size() == 1) {
            Tribe t = parties.get(0).tribe;
            println("Battle at", x, y, "is over. A Tribe has emerged victorious and spawned a new Warrior.");
            return new Warrior(x, y, t, t.size() / float(t.maxSize) * 3, 3); // where a Battle is won a new Warrior of full health and strength is spawned, in order to continue attacking
        }
        
        
        Cell[] nbs = getNeighbours();
        for (Cell c : nbs) {
            String n = c.className();
            
            if (n.equals("Warrior")) {
                Warrior w = (Warrior)c;
                boolean notInBattlefield = true;
                Party ownParty;
                
                for (Party p : parties) {
                    if (p.tribe == w.tribe) {
                        for (MemberID m : p.warriors) {
                            if (m.x == w.x && m.y == m.y) {
                                notInBattlefield = false;
                                break;
                            }
                        }
                        if (notInBattlefield) { // if Warrior's tribe is found but he isn't in battle, add warrior to party
                            p.addWarrior(w.x, w.y);
                            notInBattlefield = false;
                            break;
                        }
                    }
                    
                }
                if (notInBattlefield) { // if variable wans't changed in loop, that means that his party wasn't registered at all and must be added with the warrior
                    Party p = new Party(w.tribe);
                    parties.add(p);
                    p.addWarrior(w.x, w.y);
                    println("new Tribe with warrior at", w.x, w.y, "joined Battlefield at", x, y);
                }
            }
            
        }
        
        
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