functor
import System(showInfo:ShowInfo)
export
   createPlayer:CreatePlayer
define

   /*
    * Returns a port to a simple plauer.
    * Simple player (without a changing state).
    *
    */
   fun {CreatePlayer Player Referee}

      % Consume an incoming request from the referee
      proc {ConsumeMsg Msg}
         case Msg
         of request(board: B moves: ValidMoves) then {DecideNext B ValidMoves}
         [] gameEnded(winner: P) then
            if P == Player
            then {ShowInfo Player#": Yay! :D"}
            else {ShowInfo Player#": Minimimi... :("}
            end
         end
      end

      % Where the magic happens:
      % Pick the next move and send it to the Referee.
      %
      % The current implementation is simple: simply send the
      % first move in the list.
      %
      % Other possible implementation ideas:
      % - Choose the next move random
      % - Score each move and select the best one
      % - Move the pawn closest to the other side
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
