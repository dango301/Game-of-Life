# Conway's Game of Life
##### written in Processing (Version 3.5.4)

Changing [Conway's original rules](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life#Rules "Wikipedia: Conway's Game of Life - Rules") and creating new cell types is possible and encouraged. The code is written as to make modifications to the standard rule sets as well as the creation of new classes for new cell types as easy as possible.
At the moment, the Cell class only keeps track of the states alive / dead. To add further sub-classes, they must extend the super, _Cell_.

**In each sub-class one can override three methods: clone, transition and display**
* clone method: return an identical object as a copy by simply instantiating one of the SAME type with all of the object's same properties
* transition method: this is where you may implement customized rulesets; use _getNeighbours_ to base rules on surrounding cells; use the _className_-method to create different rules based on a cell's neighbours and their different classes, respectively
* display method: make changes to how the objects should be drawn; appearance may be based on custom class properties to make the cells more expressive visually


_The standard game can be downloaded from the main branch (this one). Various examples of games with modified rules and additional cell types can be found in the other branches._

```diff
! Remember to change the folder's name to "Game_of_Life", the main sketch's name, when downloading the project !
```
