# Project-ProgTalen
Project Programmeertalen 2017

## Protocol
Each player has to create a `Port` to which the `Referee` can send its messages to.
Each player receives a `Port` to which it can send the answers to the requests.
The referee and the players communicate with each other by sending records trough these ports.

A `Board` is a `List` of `List`s of `p1`, `p2` or `empty` atoms. Pawns owned by player 1 and 2 are represented  by `p1` and `p2`. Fields without pawns are `empty`.

### Messages sent by the referee
- `moveRequest(board: B)` is sent to the player who can move next. The `board: B` value represents the current game state.
- `gameEnded(winner: P)` is sent to all the players when the game has ended. The value `winner: P` is `p1` when player 1 has won the game, and `p2` when player 2 is victorious.

### Messages sent by the players
- `submitMove(f(row col) t(row col))` is sent to submit a move. The `f(row col)` value is a tuple with the coordinates of a pawn owned by the current player. The `t(row col)` value  is a tuple with the coordinates to which this pawn has to be moved. (`row` and `col` are normal integers)

### Message order
- The first player (`p1`) can always make the first move.
- When a player submits an illegal move, a new `moveRequest` is sent to the same player. If the players responds with another illegal move, the game is ended in favor of the opponent.
- When a player submits a move while it is not their turn, the game is ended in favor of the opponent.
