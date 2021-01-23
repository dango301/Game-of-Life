

void nextGeneration() {

  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      nextGrid[i][j].adopt(grid[i][j]);
    }
  }


  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {

      Cell newC = nextGrid[i][j];
      newC.transition();
      newC.display(); // note: for some reason all cells are only drawn at once, after the loop is done
    }
  }


  //this loop is ESSENTIAL! grid = newGrid does not work, propably because of 2D Array ==> every item has to be reassigned!
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      grid[i][j].adopt(nextGrid[i][j]);
    }
  }

  gen++;
}



void fileImported(File selection) {

  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    JSONArray values = loadJSONArray(selection.getAbsolutePath());

    if (values.size() != cols * rows) {

      cols = 0;
      rows = 0;

      for (int i = 0; i < values.size(); i++) {
        JSONObject obj = values.getJSONObject(i); 
        int x = obj.getInt("x");
        int y = obj.getInt("y");

        if (++x > cols) cols = x;
        if (++y > rows) rows = y;
        // the above if statements require the last cell (that of highest row and column) to be last in JSON object
      }
      res = min((width - 2 * margin) / cols, (height - 40 - 2 * margin) / rows);


      grid = new Cell[cols][rows];
      nextGrid = new Cell[cols][rows];
      println("Resolution was changed to " + res + "px to accomodate imported Grid-Ratio: " + cols + " x " + rows);
    }


    for (int i = 0; i < values.size(); i++) {
      JSONObject obj = values.getJSONObject(i); 

      int x = obj.getInt("x");
      int y = obj.getInt("y");
      boolean a = obj.getBoolean("alive");

      Cell c = new Cell(a, x, y);
      grid[x][y] = c;
    }
    forceDraw = true;
  }
}



void fileExported(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    String path = selection.getAbsolutePath();
    path = split(path, ".")[0] + ".json";

    JSONArray values = new JSONArray();
    int index = 0;

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {

        Cell cell = grid[i][j];
        JSONObject obj = new JSONObject();

        obj.setInt("id", index);
        obj.setInt("x", cell.x);
        obj.setInt("y", cell.y);
        obj.setBoolean("alive", cell.alive);

        values.setJSONObject(index++, obj);
      }
    }
    saveJSONArray(values, path);
    println("File saved as " + path);
  }
}




void drawInitialGrid() {

  if (!(mouseX >= offsetX && mouseX <= width - offsetX && mouseY >= offsetY + 40 && mouseY <= height - offsetY))
    return;

  if (isLooping) {
    toggleLoop(false);
    return;
  }

  int i = floor((mouseX - offsetX) / res);
  int j = floor((mouseY - offsetY - 40) / res);
  if (i >= cols || j >= rows) return;

  Cell c = grid[i][j];
  c.alive = mouseButton == LEFT;
  c.display();
}



void toggleLoop(boolean ...forcedState) {
  isLooping = forcedState.length > 0 ? forcedState[0] : !isLooping;
  //println(isLooping);
  fill(0);
  rect(240, 0, 120, 40);
  fill(255);
  text(isLooping ? "Pause" : "Play", 240, 0, 120, 40);
}
