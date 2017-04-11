
functor
import
   Board
   Referee
   System(showInfo:ShowInfo)
define
   P1
   P2
   S1
   S2
   PR1
   PR2
   B
in
   B = {Board.init 5}
   {ShowInfo "Board at 4 4:"#{Board.get 4 4 B}}
   {ShowInfo "Test"}
   {NewPort S1 P1}
   {NewPort S2 P2}
   ports(PR1 PR2) = {Referee.refereeFor P1 P2 5}
   {Send PR1 submitMove(f(1 1) t(1 1))}
   {Send PR1 submitMove(f(1 1) t(1 1))}
   {Send PR2 submitMove(f(1 1) t(1 1))}
   {ShowInfo "END"}
end
