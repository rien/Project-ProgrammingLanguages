# Project Programmeertalen 2017
This README specifies the functions to create players and a referee for the game and the protocol which is used to communicate between the different instances. When something is not clear, please send me an email on Rien.Maertens@UGent.be.

## Protocol
Each player has to create a `Port` to which the `Referee` can send its messages to.
Each player receives a `Port` to which it can send the answers to the requests.
The referee and the players communicate with each other by sending records trough these ports.

A `Board` is a tuple with the label `board` of tuples with labels `row` of `p1`, `p2` or `empty` atoms. Pawns owned by player 1 and 2 are represented  by `p1` and `p2`. Fields without pawns are `empty`. Player 1 starts on the first row and player 2 starts on the last row. The reason I chose for tuples instead of lists is the massive performance increase. Sadly, these tuples are 1-indexed (but so are lists).

A move is represented by the tuple `move(f(row col) t(row col))`. Where `f(row col)` represents the current row and column of a pawn (**f**rom) and `t(row col)` represents the desired next coordinate of that pawn (**t**o). `row` and `col` are integers and are 1-indexed.

### Messages sent by the referee
- `request(board: B)` is sent to the player who can move next. The `board: B` value represents the current game state.  
- `gameEnded(winner: P)` is sent to all the players when the game has ended. The value `winner: P` is `p1` when player 1 has won the game, and `p2` when player 2 is victorious.

### Messages sent by the players
- `move(f(row col) t(row col))` is sent to submit a move. See above for the meaning of each field in the tuple. The _from_ coordinate should have a pawn owned by the current player and the _to_ coordinate should be a valid move for that pawn. If one of these conditions is not satisfied, the referee will request another move (once).

### Message order
- The first player (`p1`) can always make the first move.
- When a player submits an illegal move, a new `request` is sent to the same player. If the players responds with another illegal move, the game is ended in favor of the opponent.
- When a player submits a move while it is not their turn, the game is ended in favor of the opponent.

## Implementation

### Player
To create a player, use `Player.createPlayer PlayerType RefereePort`. Where `PlayerType` is `p1` or `p2` (player 1 or player 2). And `RefereePort` is the port to the referee for this player (see below). This function returns the port that should be given to the `Referee`.

### Referee
The function `Referee.refereeFor P1 P2 Rows Cols` returns the tuple `ports(PR1 PR2)`. The arguments `P1` and `P2` are the ports returned by `createPlayer` for player 1 and 2. These variables should instantiated to avoid a deadlock, because there will be sent a message to `P1` immediately. `Rows` and `Cols` are integers and represent the height and width of the playing field. The returned values `PR1` and `PR2` are ports which should be given to player 1 and player 2.

### Board
For those using normal lists, the function `Board.toList B` can be used to convert a `Board` to a list of lists. Other functions in `Board` are `Board.set NewElem RowNum ColNum Board}`, `Board.init Rows Cols`, `Board.show`, `Board.validMovesFor Player` and `Board.analyse`.

### Example
To create a game between two `Player`'s on a 5 by 5 field:
```
P1 = {Player.createPlayer p1 PR1}
P2 = {Player.createPlayer p2 PR2}
ports(PR1 PR2) = {Referee.refereeFor P1 P2 5 5}
```
This assumes that the necessary variables are available and unbound.
