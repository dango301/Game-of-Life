# Conway's Game of Life
## Virus Variation
##### written in Processing (Version 3.5.4)

This is an example of the Game of Life with altered rules and additional cell types. It introduces two new cell types: _Infected_ and _Carcass_, which both carry a virus in this model.


### Rules
The standard rules apply. However, every living a cell has a probability (_infectionProb_) of becoming infected, in which case, it will be turned into a cell of the type _Infected_. If there are other cells carrying the virus, each neighbor of a healthy, regular cell has a chance of transferring the virus (_transferProb_).

The _Infected_-Object is initialized with a certain severity and duration characterizing the infection of a given cell. Within the transition function it is specified that its health is reduced by the value of _severity_, but also, its infection is exacerbated by surrounding cells carrying the virus by literally adding to the severity with a likelihood of _transferProb_. In each generation the duration (_dur_) of the infection is decremented. Should the cell die after _dur_ is zero, it will return a normal, live Cell-Object. Otherwise, it returns an infectious Carcass passing on its severity based on one of the three ways it can die:
1. _health = 0_: infection causes bad health until cell dies and returns Carcass with full severity.
2. _dur = 0_: at end of infection period cell either dies and leaves carcass with one third of its severity or lives on as normal cell based on _deathProb_
3. standard rule: death due to under- / overpopulation if not exactly three live neighbors; leaves Carcass with full severity.

The _Carcass_-Object only possesses properties the properties _severity_ and _dur_ (for how many generations a carcass will stay on the grid before turning into a normal dead cell). Its only purpose is to perhaps infect other _Cell_-Objects or worsen the severity of already infected cells.


_The standard game can be downloaded from the main branch (this one). Various examples of games with modified rules and additional cell types can be found in the other branches._

```diff
! Remember to change the folder's name to "Game_of_Life_Virus", the main sketch's name, when downloading the project !
```
