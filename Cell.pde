

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
        
        return sum;
    }
    
    
    
    
    //called from nextGeneration() and includes ruleset for each cell type 
    Cell transition() {
        
        Tribe _nextTribe = grid[x][y].nextTribe;
        if (_nextTribe != null) { // join tribe that was formed by first member in grid
            TribeMember newC = new TribeMember(x, y, _nextTribe);
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
                // println("New Tribe Member spawned at", x, y);
                return newCell;
            } else {
                alive = false;
                // if (alive) println("Tribe killed this cell at", x, y);
                return this;
            }
            
            default : // if there are multiple Tribes surrounding this cell, it becomes a Battlefield
            for (Tribe nbsTribe : tribeNbs)
                nbsTribe.inBattle = true;
            // println("Tribes going to war at", x, y);
            return new Battlefield(x, y);
        }
        
        
        if (!alive && sum == 3) alive = true;
        else if (alive && (sum < 2 || sum > 3)) alive = false;
        else if (alive) {
            ArrayList<Cell> directNbs = dfs();
            
            if (directNbs.size() < 2) alive = false;
            else if (directNbs.size() > 2) { // sum must be at least 3, which, together with this live cell, makes a total of at least 4 cells ready to form a tribe
                
                Tribe newTribe = new Tribe();
                TribeMember newCell = new TribeMember(x, y, newTribe);
                
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
    
    Cell getCell() {
        return grid[x][y];
    }
}


class Tribe {
    int maxSize = maxTribeSize;
    ArrayList<MemberID> members = new ArrayList<MemberID>();
    MemberID king;
    color col;
    float minColorValue = 75;
    boolean inBattle = false;
    Tribe hasFallenTo = null;
    
    Tribe(color...col) {
        this.col = col.length > 0 ? col[0] : color(random(minColorValue, 255), random(minColorValue, 255), random(minColorValue, 255));
        allTribes.add(this);
    }
    
    void addMember(TribeMember member) {
        
        for (MemberID m : members) {
            if (m.x == member.x && m.y == member.y) {
                // println("MemberID was not added to Tribe because it is already registered for TribeMember at", member.x, member.y);
                return;
            }
        }
        members.add(new MemberID(member.x, member.y));
    }
    
    void removeMember(int x, int y) {
        
        for (int i = 0; i < members.size(); i++) {
            MemberID m = members.get(i);
            if (m.x == x && m.y == y) {
                members.remove(m);
                return;
            }
        }
        println("MemberID could not be removed because it was never registered to tribe at " + x + " " + y);
    }
    
    int size() {
        return members.size();
    }
    
    float expansionProbability() {
        return 1 - this.size() / float(maxSize);
    }
    
    void update() { // remove all TribeMembers that were killed / removed in the previous generation

        if (hasFallenTo == null && king != null) {
            Cell k = king.getCell();
            String n = k.className();

            if (n.equals("TribeMember") || n.equals("Warrior")) {
                TribeMember c = (TribeMember)k;
                if (c.tribe != this) {
                    this.hasFallenTo = c.tribe;
                    println("King was captured at", king.x, king.y, "and His TribeMembers have fallen to the winning Tribe.");
                }
            }
        }
        
        ArrayList<MemberID> deletedMembers = new ArrayList<MemberID>();
        boolean warriorsInTribe = false;
        
        for (MemberID m : members) {
            Cell c = m.getCell();
            String n = c.className();
            
            if (n.equals("Cell") || n.equals("Battlefield")) {
                deletedMembers.add(m);
            } else if (n.equals("TribeMember") || n.equals("Warrior")) {
                TribeMember cc = (TribeMember)c;
                if (cc.tribe != this)
                    deletedMembers.add(m);
                else if (n.equals("Warrior"))
                    warriorsInTribe = true;
            }
        }
        inBattle = warriorsInTribe;
        
        for (MemberID m : deletedMembers)
            removeMember(m.x, m.y);
        
        king();
    }
    
    void king() { // determine which cell is king of tribe and display it
        if (this.size() == 0) return;
        
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
    }
}


class TribeMember extends Cell{
    Tribe tribe;
    
    TribeMember(int x, int y, Tribe tribe) {
        super(true, x, y);
        this.tribe = tribe;
        tribe.addMember(this);
    }
    
    TribeMember clone() {
        return new TribeMember(x, y, tribe);
    }
    
    Cell transition() {
        
        if (tribe.hasFallenTo != null) {
            return new TribeMember(x, y, tribe.hasFallenTo);
        }
        
        
        int directMemberNbs = dfs().size();
        if (directMemberNbs != tribe.size() && directMemberNbs < 3) // TribeMembers that are disconnected from Tribe are killed if less than four in cluster
            return new Cell(false, x, y);
        
        Cell[] nbs = getNeighbours();
        for (Cell c : nbs) {
            String n = c.className();
            
            boolean battleConditions = // Warrior is spawned, if there is a Battlefield or TribeMember / Warrior of a different Tribe
            n.equals("Battlefield")
                || ((n.equals("TribeMember") || n.equals("Warrior")) && ((TribeMember)c).tribe != this.tribe);
            
            if (battleConditions)
                return new Warrior(x, y, tribe, tribe.size() / float(tribe.maxSize) * warriorStrengthMuliplicator, warriorSpawnHealth);
        }
        
        
        return this;
    }
    
    void display() {
        
        fill(tribe.col);
        stroke(0);
        strokeWeight(gridWeight);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        
        MemberID k = tribe.king;
        if (k != null && k.x == x && k.y == y)
            shape(crown,  k.x * res + offsetX, k.y * res + offsetY + 40, res - gridWeight, res - gridWeight);
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
        
        if (tribe.hasFallenTo != null) {
            return new TribeMember(x, y, tribe.hasFallenTo);
        }
        
        
        Cell[] nbs = getNeighbours();
        ArrayList<Warrior> previousAttackers = new ArrayList<Warrior>();
        ArrayList<Tribe> enemyTribes = new ArrayList<Tribe>();
        FloatList tribeDamage = new FloatList();
        boolean noThreat = true;
        
        for (Cell c : nbs) {
            String n = c.className();
            
            if (n.equals("Battlefield")) {
                
                noThreat = false;
                Cell[] participants = ((Battlefield)c).getNeighbours();
                
                for (Cell p : participants) {
                    if (!p.className().equals("Warrior")) continue;
                    
                    // each Warrior from every other party attacks this Warrior
                    Warrior w = (Warrior)p;
                    if (w.tribe == this.tribe) continue; // don't be attacked by Warriors from same Tribe
                    
                    if (previousAttackers.contains(w)) {
                        // println("prevented double attack by", w.x, w.y, "at", x, y);
                        continue;
                    }
                    
                    previousAttackers.add(w);
                    if (!enemyTribes.contains(w.tribe)) {
                        enemyTribes.add(w.tribe);
                        tribeDamage.append(0.0);
                    }
                    
                    int i = enemyTribes.indexOf(w.tribe);
                    tribeDamage.add(i, w.strength);
                }
                
                
            } else if (n.equals("Warrior")) {
                
                Warrior w = (Warrior)c;
                if (w.tribe == this.tribe) continue; // don't be attacked by Warriors from same Tribe
                
                noThreat = false;
                if (previousAttackers.contains(w)) {
                    // println("prevented double attack by", w.x, w.y, "at", x, y);
                    continue;
                }
                
                previousAttackers.add(w);
                if (!enemyTribes.contains(w.tribe)) {
                    enemyTribes.add(w.tribe);
                    tribeDamage.append(0.0);
                }
                
                int i = enemyTribes.indexOf(w.tribe);
                tribeDamage.add(i, w.strength);
            }
        }
        
        
        if (noThreat) // Warrior becomes normal cell when there are no enemies around
            return new TribeMember(x, y, tribe);
        
        
        for (Float damage : tribeDamage)
            health -= damage;
        
        if (health <= 0) { //Warrior dies in battle
            
            int index = tribeDamage.index(tribeDamage.max()); // whoever dealt the most damage in the final generation of this Warrior is pronounced its killer
            Tribe t = enemyTribes.get(index);
            
            // println("Warrior has fallen and a new Warrior of the winning Tribe has taken his place to continue into battle at", x, y);
            return new Warrior(x, y, t, t.size() / float(t.maxSize) * warriorStrengthMuliplicator * random(2, warriorWinnerRandomMultiplier), warriorSpawnHealth); // killer spawns new Warrior in his place because he is the winner of the battle
        }
        
        
        return this;
    }
    
    
    void display() {
        
        stroke(0);
        strokeWeight(gridWeight);
        fill(0);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight); // draw blacked out box under rect for darker cell from alpha effect
        
        fill(tribe.col, 150 + 105 * health / maxHealth);
        rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        shape(helmet, x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
        
        
        MemberID k = tribe.king;
        if (k != null && k.x == x && k.y == y)
            shape(crown,  k.x * res + offsetX, k.y * res + offsetY + 40, res - gridWeight, res - gridWeight);
    }
}



class Battlefield extends Cell {
    boolean waitForWarriorsToSpawn;
    
    Battlefield(int x, int y, boolean...wait) {
        super(false, x, y);
        waitForWarriorsToSpawn = wait.length > 0 ? wait[0] : true;
    }
    
    Battlefield clone() {
        return new Battlefield(x, y, waitForWarriorsToSpawn);
    }
    
    Cell transition() {
        
        if (waitForWarriorsToSpawn) { // wait for one generation so that Battlefield dosn't disappear before Warriors are spawend around it
            waitForWarriorsToSpawn = false;
            return this;
        }
        
        Cell[] nbs = getNeighbours();
        ArrayList<Tribe> parties = new ArrayList<Tribe>();
        
        for (Cell c : nbs) {
            if (!c.className().equals("Warrior")) continue;
            
            Warrior w = (Warrior)c;
            if (!parties.contains(w.tribe))
                parties.add(w.tribe);
        }
        
        if (parties.size() == 0) {
            
            // println("Battle at", x, y, "is over. No Tribe has emerged victorious.");
            return new Cell(false, x, y);
            
        } else if (parties.size() == 1) {
            
            Tribe t = parties.get(0);
            // println("Battle at", x, y, "is over. A Tribe has emerged victorious and spawned a new Warrior.");
            return new Warrior(x, y, t, t.size() / float(t.maxSize) * warriorStrengthMuliplicator * random(2, warriorWinnerRandomMultiplier), warriorSpawnHealth); // killer spawns new Warrior in his place because he is the winner of the battle
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