functor
import
   Board
   System(showInfo:ShowInfo)
export
   createPlayer:CreatePlayer
define

   /*
    * Returns a port to a simple plauer.
    * Simple player (without a changing state).
    *
    */
   fun {CreatePlayer Player Referee}

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
         NextMove|_ = ValidMoves
      in
         {Send Referee NextMove}
      end

      % Process each incoming message
      % This procedure ends if the last message
      % was a gameEnded()
      proc {ProcessRequests Port}
         case Port
         of request(board: B)|T then
            {DecideNext B {Board.validMovesFor Player B}}
            {ProcessRequests T}
         [] gameEnded(winner: P)|_ then
            if P == Player
            then {ShowInfo Player#": Yay! :D"}
            else {ShowInfo Player#": Minimimi... :("}
            end
         end
      end

      Port
   in
      thread
         {ProcessRequests Port}
         {ShowInfo "Player "#Player#" thread ended."}
      end
      {NewPort Port}
   end
end
