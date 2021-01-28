# Conway's Game of Life
## Tank Variation
##### written in Processing (Version 3.5.4)

This is an example of the Game of Life with altered rules and an additional cell type: _Tank_, which represents a cell with genetic alterations enabling it to outlive other cells for several generations more. 


### Rules
The standard rules apply for the _Cell_-super. However, every newly born cell has a probability (_tankP_) of becoming a _Tank_-Object, in which case it is initialized with a certain health value (_hp_). If a tank has more than two live neighbors or none at all, it loses a health point, as if by over- or underpopulation, respectively. Should a tank's health be decremented to zero, it turns into a regular, dead _Cell_-Object. In case a tank has exactly three live neighbors, its health will be incremented until _maxHP_ is reached, as if the tank were supported by a community. Notwithstanding that, the tank has a "biological" disadvantage: In case it has more than two live neighbors, it will **kill** each of its neighbors with a chance of _killerP_, as if due to an egoistical need of resources leaving none for others. The probability of a cell being killed is multiplied by the amount of tanks in its vicinity lessening the chances for survival in a "competitive" region.



_The standard game can be downloaded from the main branch. Various examples of games with modified rules and additional cell types can be found in the other branches._

```diff
! Remember to change the folder's name to "Game_of_Life_Tank", the main sketch's name, when downloading the project !
```
