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
   P1 = {Player.createPlayer p1 PR1}
   P2 = {Player.createPlayer p2 PR2}
   p(PR1 PR2) = {Referee.createReferee P1 P2 5 5}
end
