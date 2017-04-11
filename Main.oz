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
in
   {ShowInfo "Test"}
   {NewPort S1 P1}
   {NewPort S2 P2}
   ports(PR1 PR2) = {Referee.refereeFor P1 P2 5}
   {Send PR1 submitMove(f(0 0) t(0 0))}
   {Send PR1 submitMove(f(0 0) t(0 0))}
   {Send PR2 submitMove(f(0 0) t(0 0))}
   {ShowInfo "END"}
end
