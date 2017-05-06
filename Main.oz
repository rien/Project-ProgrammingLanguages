functor
import
   Referee
   Player
define
   P1
   P2
   PR1
   PR2
in
   % Fight!
   P1 = {Player.createPlayer PR1}
   P2 = {Player.createPlayer PR2}
   {Referee.createReferee P1 P2 PR1 PR2}
end
