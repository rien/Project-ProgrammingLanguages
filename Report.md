---
title: Report Project Programming Languages
author: Rien Maertens
date: May 2017
urlcolor: blue
---

 - Hardware/software used
 - Conclusion
    - Assignment 1
        - Message Passing
        - Declarativity
    - Assignment 2
        - New rule => own code?
        - Integrating others

  - How does code work?
  - Drawbacks, advantages decla & mpc
  - Impact rule change (vs other models & statefull)
  - Impact communications
  - Another programming model better?

# Introduction

This report is made on behalf of the course Programming Languages, taught by professor Eric Laermans.
There were two assignments that had to be done.
First, a chess-like game had to implemented in the Oz programming language using only the declarative model and the message-passing concurrency model.
Second, the first implementation had to be adapted to  communicate with other students' implementations and to facilitate an extra rule added to the game.

The development was done on a laptop with an Intel i7 Haswell processor running Arch Linux.
Neovim was the main editor used to write the source code and this report.
An [oz.vim](https://github.com/Procrat/oz.vim) plugin for this editor was of great help.
The source code was built with the Mozart 2 programming system together with make to simplify conditional compilation and execution.
This report was written in markdown and converted to pdf (trough \LaTeX) with [Pandoc](http://pandoc.org/).

# Assignments

## Assignment 1

### The board
I started this assignment by implementing a module to represent and manipulate a board to play the game on.
This seemed like a good basis to start with and allowed me to learn the specifics of the Oz language while writing this module.

Initially a board was represented by a list of lists of symbols.
Because there were going to be a lot of indexed reads on the board I have searched for an alternative to the built-in linked lists, which have linear access time.
I looked at arrays (constant, but not declarative), quadtrees (logarithmic, but not built-in and a lot of work to implement) and tuples (constant and built-in).

I did a benchmark accessing a million items in both structures and where lists would take five minutes to read all the items, tuples would need less than a second.
Needless to say, it was an easy decision to convert the board from a list of lists to a tuple of tuples.


### The referee
The next step was to write a referee module.
Because the referee has to keep track of the board and the progress of the game, it has to have some kind of 'state'.
Originally this was done by using `fold` on the list of incoming messages.
But as the referee became more complex I wrote a function that recursively iterates.
In general the flow of a move is as follows:

1. A message is received
2. The referee checks whether it is the turn of the player who sent the message
3. The referee checks whether the move the player sent is valid
4. The move is executed on the board and the referee checks if the game is finished
5. If the game isn't finished, the other player is sent the new board

At the start of the game, each player is given its own port to communicate with the referee.
The threads processing the contents of these ports wrap the message of each player in a record together with the symbol of the player and send that record to the main referee port.
The messages are essentially multiplexed.
This way, the referee knows which player is currently talking and it prevents a player from pretending to be the other.
When such behaviour is detected, the player who was pretending to be the other loses.


### The player
Finally, a player module was written.
The first implementation was very simple: the first item in the list of valid moves was sent to the referee.

### Declarativity

### Message-passing Concurrency

The way ports are exchanged between the referee and the players is loosely based on the examples in sections 5.2.1 and 5.2.2 in the book (_Concepts, Techniques and Models of Computer Programming_)

## Assignment 2


# Implementation

## Helper

## Board
Because I am somewhat comfortable with Haskell, I took a functional approach to writing the functions in this module.
I preferred to use functions like `map`, `fold` and `join` instead of `for` constructs and other iterating functions.

The following functions can be found in the `Board` functor:

 - `Init`: takes two arguments `N` and `M` and generates a board with `N` rows and `M` columns with the pawns of each player on its starting row.
 - `Show`: procedure which prints the board contents to the standard output.
 - `Set`: takes a pawn symbol, a row, a column and a board as arguments and returns a new board with the new pawn placed on the given row and column.
 - `DoMoveFor`: takes a player symbol (`p1` or `p2`) a move and a board and returns a new board where this move is performed.
 - `ValidMovesFor`: takes a player and a board and returns all the valid moves for this player.
 - `Analyze`: takes a board and returns a record with for each player all his valid moves and a boolean whether that player reached the other side or not.

One could argue that the last two functions (`Analyze` and `ValidMovesFor`) should be moved to the `Referee` functor because they essentially dictate who has won and which moves are valid.
However, since a player would probably want to use these functions it seemed logic to keep these functions with the board to keep the player independent from its referee.

## Referee

Almost all of the functionality in this functor is within the `CreateReferee` function: it starts its own thread with its initial state and defines the functions who need to access its arguments: the ports from and to each player.
The most important subfunctions are:

- `ProcessMsg`: takes a list of message and an initial state, pops the first message and checks if it is message receiver's turn.
If that is the case, it the message to a judge function and recurses with a new state and the rest of the messages.

## Player

# Conclusion

## Declarativity

## Message-passing Concurrency

## Comparison with other programming models



# Appendix A: Agreed communications

```include
protocol/README.md
```

