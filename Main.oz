functor
import
   Board
   Referee
   Player
   Helper
   Browser
   System(showInfo:ShowInfo)
define
   P1
   P2
   PR1
   PR2
in
   P1 = {Player.createPlayer p1 PR1}
   P2 = {Player.createPlayer p2 PR2}
   ports(PR1 PR2) = {Referee.refereeFor P1 P2 5 5}
end
