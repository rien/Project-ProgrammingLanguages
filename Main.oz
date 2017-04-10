functor
import
   Board
define
   B
   B2
in
   B = {Board.init 5}
   {Board.show B}
   B2 = {Board.replaceWith p2 3 3 B}
   {Board.show B2}
end
