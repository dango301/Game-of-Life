# Conway's Game of Life
## Tribe Variation
##### written in Processing (Version 3.5.4)

This is an example of the Game of Life with altered rules and additional cell types: _Tribe_, _TribeMember_, _Warrior_ and _Battlefield_, which simulate Cells forming Tribes and going into battle when they clash.


### Rules
##### _Cell_ Class
Normal rules apply for the _Cell_-super. However, using a depth-first search algoritm, a normal _Cell_'s directly connected neighbors are counted (i. e. how many cells are joined together, as opposed to surrounding a cell). The sum must be at least four to form a _Tribe_. _Cell_-Objects, which are directly adjacent to _TribeMembers_ have a chance that is anti-proportinal to the tribe's size to _maxSize_ ratio to become newly born members. Notwithstanding that, it cannot become a new _TribeMember_, if there is a Battlefield in its proximity or its tribe is alreay in battle. That means a tribe's growth is halted completely while it is battling.
If a normal _Cell_ detects two or more members, each of different tribes, it will be turned into a _Battlefield_-Object, which serves as a field that connects members from different tribes, even if they are not neighbouring cells.
##### _Tribe_ Class
A _Tribe_-Object is no cell in the grid and therefore does not extend the _Cell_ class. Instead, it is a structural object holding all _TribeMember_s together in an ArrayList and  holds information about their entity as a whole. For example it calculates the position of the king in the center of mass of a tribe. Whilst _Tribe_ is not a cell, it too has a transition function called _update_, where it examines whether Members were killed / removed by the user painting and, most importantly, checks whether another cell has taken the King's place, meaning the King was captured by an outside _Warrior_. In that case, the entire tribe's members fall to the winning tribe of the battle.
##### _TribeMember_ Class
As the brevity of the _TribeMember_ class' _transition_ method suggests members are mostly static. Should one or multiple members be disconnected from the rest of the tribe, it must have at least three neighbours of its kind to sustain itself. Only once a _TribeMember_ encounters a _Battlefield_-Object or a _TribeMember_ of another tribe will the boolean _battleConditions_ be satisfied and spawn a new _Warrior_ in its place.
##### _Warrior_ Class
This class further extends _TribeMember_. Due to its specialization it is a _TribeMember_ by definition but also includes properties for its _strength_ and _health_. When a regular member transitions to a _Warrior_, it is initialized with the global user-variable _warriorSpawnHealth_, while its strength is proportinal once again to the tribe's size to _maxSize_ ratio. Moreover, the strength is multiplied by another user-variable called _warriorStrengthMuliplicator_.
With a length of almost 100 lines, this _transition_ method is the most intricte of all: 

_The standard game can be downloaded from the main branch. Various examples of games with modified rules and additional cell types can be found in the other branches._

```diff
! Remember to change the folder's name to "Game_of_Life_Tribe", the main sketch's name, when downloading the project !
```
