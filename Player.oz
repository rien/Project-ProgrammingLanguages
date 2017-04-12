functor
import System(showInfo:ShowInfo)
export
   createPlayer:CreatePlayer
define

   fun {CreatePlayer Player Referee}
      proc {ConsumeMsg Msg}
         case Msg
         of request(board: B moves: ValidMoves) then {DecideNext B ValidMoves}
         [] gameEnded(winner: P) then
            if P == Player
            then {ShowInfo Player#": Yay!"}
            else {ShowInfo Player#": Minimimi... :("}
            end
         end
      end
      proc {DecideNext B ValidMoves}
         NextMove|_ = ValidMoves.Player
      in
         {Send Referee NextMove}
      end
      Port
   in
      thread {ForAll Port ConsumeMsg} end
      {NewPort Port}
   end
end
