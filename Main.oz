functor
import
   Referee_rbmaerte
   Player_rbmaerte
define
   P1
   P2
   PR1
   PR2
in
   % Fight!
   P1 = {Player_rbmaerte.createPlayer PR1}
   P2 = {Player_rbmaerte.createPlayer PR2}
   {Referee_rbmaerte.createReferee P1 P2 PR1 PR2}
end
