functor
import
   Board
   System(showInfo:ShowInfo)
   Helper(otherPlayer:OtherPlayer)
export
   createPlayer:CreatePlayer
define

   /*
    * Returns a port to a simple player.
    * Simple player (without a changing state).
    *
    */
   fun {CreatePlayer Player Referee}
      Rows = 5
      Cols = 5
      Eliminations = 2

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
      fun {DecideNext OldBoard}
         NextMove|_ = {Board.validMovesFor Player OldBoard}
      in
         {Send Referee NextMove}
         {Board.doMoveFor Player NextMove OldBoard}
      end

      fun {NextElimination B}
         Cols = {Width B.1}
         OwnRow = case Player
         of p1 then 1
         [] p2 then {Width B}
         end
         fun {FirstFromSide I}
            if B.OwnRow.I == Player
            then I
            else if I > Cols div 2
               then {FirstFromSide Cols - I + 2}
               else {FirstFromSide Cols - I + 1}
               end
            end
         end
      in
         e(OwnRow {FirstFromSide 1})
      end

      fun {RespondTo Request OldBoard}
         case Request
         of size then
            {Send Referee size(Rows Cols)}
            {Board.init Rows Cols}

         [] firstElimination then
            if Eliminations > 0
            then
               local
                  e(R C) = {NextElimination OldBoard}
               in
                  {Send Referee firstElimination(k:Eliminations row:R col:C)}
                  {Board.set empty R C OldBoard}
               end
            else
               {Send Referee firstElimination(k:0 row:nil col:nil)}
               OldBoard
            end

         [] elimination(L) then
            local
               e(R C) = {NextElimination OldBoard}
            in
               {Send Referee eliminate(R C)}
               {Board.set empty R C OldBoard}
            end

         [] move(_) then {DecideNext OldBoard}

         else raise unknownRequestError(request:Request) end
         end
      end

      fun {ProcessOther OtherMove OldBoard}
         case OtherMove
         of nil then nil
         [] size(N M) then {Board.init N M}
         [] firstElimination(k:K row:R col:C) then
            if K > 0
            then {Board.set empty R C OldBoard}
            else OldBoard
            end
         [] eliminate(R C) then {Board.set empty R C OldBoard}
         [] move(_ _) then {Board.doMoveFor {OtherPlayer Player} OtherMove OldBoard}
         else raise unknownOtherMove(other:OtherMove) end
         end
      end

      % Process each incoming message
      % This procedure ends if the last message
      % was a gameEnded()
      proc {ProcessRequests B Port}
         NextBoard
         TmpBoard
      in
         case Port
         of r(other:O request:R)|T then
            TmpBoard = {ProcessOther O B}
            NextBoard = {RespondTo R TmpBoard}
            %{DecideNext B {Board.validMovesFor Player B}}
            {ProcessRequests NextBoard T}
         [] gameEnded(winner: P)|_ then
            if P == Player
            then {ShowInfo Player#": Yay! :)"}
            else {ShowInfo Player#": I am defeated. :("}
            end
         end
      end

      Port
   in
      thread
         {ProcessRequests nil Port}
      end
      {NewPort Port}
   end
end
