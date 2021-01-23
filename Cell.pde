class Cell {
  boolean alive;
  int x;
  int y;

  Cell(boolean alive, int x, int y) {
    this.alive = alive;
    this.x = x;
    this.y = y;
  }


  Cell[] getNeighbours(int x, int y) {
    Cell[] res = new Cell[8];
    int index = 0;

    for (int i = -1; i < 2; i++) {
      for (int j = -1; j < 2; j++) {

        int col = (x + i + cols) % cols;
        int row = (y + j + rows) % rows;
        if (!(col == x && row == y))
          res[index++] = grid[col][row];
      }
    }
    return res;
  }


  // called from nextGeneration() and includes ruleset for each cell type 
  void transition() {
    Cell[] nbs = getNeighbours(x, y);
    int sum = 0;

    for (int i = 0; i < nbs.length; i++) {
      sum += nbs[i].alive ? 1 : 0;
      //String c = this.getClass().getSimpleName();
    }

    // RULES of the Game of Life (standard rules for a cell)
    if (!alive && sum == 3) alive = true;
    else if (alive && (sum < 2 || sum > 3)) alive = false;
  }


  //called from nextGeneration() to transfer properties of Cell-Object from nextGrid to grid 
  void adopt(Cell newCell) {
    //take on new properties:

    alive = newCell.alive;
  }

  void display() {
    fill(alive ? 0: 255);
    stroke(0);
    strokeWeight(gridWeight);
    rect(x * res + offsetX, y * res + offsetY + 40, res - gridWeight, res - gridWeight);
  }
}
// for now a Cell Object only holds information about it being alive or dead, later it might have sub classes like predetor, prey, etc.
