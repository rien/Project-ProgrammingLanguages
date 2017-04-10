# Project-ProgTalen
Project Programmeertalen 2017

## Protocol
Each player has to create a `Port` to which the `Referee` can send its messages to.
Each player receives a `Port` to which it can send the answers to the requests.
The referee and the players communicate with each other by sending records trough these ports.

### Messages sent by the referee
- `moveRequest(board: B)` is sent to the player who can move next. The `board: B` value represents the current game state.
- `gameEnded(winner: P)` is sent to all the players when the game has ended. The value `winner: P` is `p1` when player 1 has won the game, and `p2` when player 2 is victorious.

### Messages sent by the players
- `submitMove(from:(row col) to:(row col))` is sent to submit a move. The `from:(row col)` value is a tuple with the coordinates of a pawn owned by the current player. The `to:(row col)` value  is a tuple with the coordinates to which this pawn has to be moved to. (`row` and `col` are normal integers)

### Message order
- The first player (`p1`) can always make the first move.
- When a player submits an illegal move, a new `moveRequest` is sent to the same player. If the players responds with another illegal move, the game is ended in favor of the opponent.
- When a player submits a move while it is not their turn, the game is ended in favor of the opponent.
