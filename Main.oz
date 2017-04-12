functor
import
   Board
   Referee
   Helper
   Browser
   System(showInfo:ShowInfo)
define
   P1
   P2
   S1
   S2
   PR1
   PR2
   B
   B2
   M
   fun {IsP2 P}
      P == p2
   end
in
   B = {Board.init 5 5}
   {ShowInfo "Board at 5 5:"#B.5.5}
   M = {Board.validMovesFor p1 B}
   {Board.show B}
   B2 = {Board.set p2 3 3 B}
   {Board.show B2}
   {NewPort S1 P1}
   {NewPort S2 P2}
   ports(PR1 PR2) = {Referee.refereeFor P1 P2 5 5}
   {Send PR1 mv(f(2 2) t(2 2))}
   {Send PR1 mv(f(2 2) t(2 2))}
   {Send PR2 mv(f(2 2) t(2 2))}
   {ShowInfo "END"}
end
