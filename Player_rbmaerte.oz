functor
import
   Board_rbmaerte
   System(showInfo:ShowInfo)
   Helper_rbmaerte( otherPlayer:OtherPlayer
                    directionFor:DirectionFor
                  )
export
   createPlayer:CreatePlayer
define

   /*
    * Returns a port to a simple player.
    * Simple player (without a changing state).
    *
    */
   fun {CreatePlayer Referee}
      PreferredRows = 8
      PreferredCols = 8
      RequestedEliminations = 100

      Player % p1 or p2, depending on the first message we get
      Rows % Actual values
      Cols
      Eliminations

      Other
      OwnRow
      Direction

      proc {SetOwnValues}
         OwnRow = case Player
            of p1 then 1
            [] p2 then Rows
         end
         Direction = {DirectionFor Player}
         Other = {OtherPlayer Player}
      end

      % Where the magic happens:
      % Decide which move to do next.
      %
      % This is done by scoring all the possible moves and taking
      % the move with the highest score.
      fun {NextMove B}

         % Checks if there are no obstacles on the path to the other side
         fun {IsClearPath Row Col}
            if Row < 1 orelse Rows < Row
               orelse Col < 1 orelse Cols < Col
            then true
            else case B.Row.Col
               of empty then {IsClearPath Row+Direction Col}
               else false
               end
            end
         end

         % Give the given move a score (higher = better move)
         fun {ScoreMove M}
            move(_ t(Row Col)) = M
            Distance = {Abs Row-OwnRow} % M.2.1 is the row-value of the destination
            AttackBonus
            TargetPenalty
            StraightLineBonus
            NextRow = Row+Direction
         in

            % If the move slays another pawn: +10
            AttackBonus = if B.Row.Col \= empty
               then 10
               else 0
            end

            % If the move renders the pawn vulnerable: -10
            % (effectively neutralizing an attack bonus)
            TargetPenalty = if 0 < NextRow andthen NextRow < Rows+1
                              andthen ((Col < Cols
                                    andthen B.NextRow.(Col+1) == Other)
                                 orelse (1 < Col
                                    andthen B.NextRow.(Col-1) == Other))
               then ~10
               else 0
            end

            % If the pawn can go to the other side without obstacles: +20
            StraightLineBonus = if {IsClearPath NextRow Col}
                                 andthen {IsClearPath NextRow Col-1}
                                 andthen {IsClearPath NextRow Col+1}
               then 20
               else 0
            end

            s(score:Distance+AttackBonus+TargetPenalty+StraightLineBonus move:M)
         end

         % Compare two moves and return the one with the highest score
         fun {PickBest S1 S2}
            s(score:Score1 move:_) = S1
            s(score:Score2 move:_) = S2
         in
            if Score1 > Score2
            then S1
            else S2
            end
         end

         Moves = {Board_rbmaerte.validMovesFor Player B}       % All possible moves
         Scored = {Map Moves ScoreMove}                        % Score all the moves
         Best = {FoldL Scored PickBest s(score:~100 move:nil)} % Pick the best one
      in
         Best.move
      end


      % Choose the next pawn to eliminate.
      % The current strategy is to interleave the own pawns.
      %
      % Returns a tuple e(Row Col) with the coordinates 
      % of the pawn that has to be eliminated.
      fun {NextElimination B}
         fun {InterleaveFromSide I D}
            if B.OwnRow.I == Player
            then I
            else {InterleaveFromSide I+D D}
            end
         end
      in
         case Player
         of p2 then e(OwnRow {InterleaveFromSide 2 2})
         [] p1 then e(OwnRow {InterleaveFromSide Cols-1 ~2})
         end
      end

      % Apply the changes of the other player to the board.
      fun {ApplyOther OtherMove OldBoard}
         case OtherMove

         % 0. The game has just started and there is no board yet
         of nil then nil

         % 1. The other player chose the game size
         [] size(N M) then
            Player = p1 % We are player 1
            Rows = N
            Cols = M
            {SetOwnValues}
            {Board_rbmaerte.init N M}

         % 2. The other player chose how many eliminations
         % If K > 0 eliminate
         [] firstElimination(k:K row:R col:C) then
            if K > 0
            then {Board_rbmaerte.set empty R C OldBoard}
            else OldBoard
            end

         % 3. The other player eliminated one of his pawns
         [] eliminate(R C) then {Board_rbmaerte.set empty R C OldBoard}

         % 4. The other player moved
         [] move(_ _) then {Board_rbmaerte.doMoveFor Other OtherMove OldBoard}

         else raise unknownOtherMove(other:OtherMove) end
         end
      end

      % Respond to each request of the referee.
      %
      % Returns a new board which represents the situation
      % created by the move we did.
      fun {RespondTo Request OldBoard}
         case Request

         % 1. Pick the size of the board
         of size then
            Player = p2 % We are player 2
            Rows = PreferredRows
            Cols = PreferredCols
            {SetOwnValues}
            {Send Referee size(Rows Cols)}
            {Board_rbmaerte.init Rows Cols}

         % 2. Choose how many eliminations and give a first elimination
         [] firstElimination then
            if RequestedEliminations > 0
            then
               local
                  e(R C) = {NextElimination OldBoard}
                  MaxEl = (Cols-1) div 2
               in
                  Eliminations = if RequestedEliminations > MaxEl
                     then MaxEl
                     else RequestedEliminations
                  end
                  {Send Referee firstElimination(k:Eliminations row:R col:C)}
                  {Board_rbmaerte.set empty R C OldBoard}
               end
            else
               {Send Referee firstElimination(k:0 row:nil col:nil)}
               OldBoard
            end

         % 3. Eliminate further
         [] elimination(_) then
            local
               e(R C) = {NextElimination OldBoard}
            in
               {Send Referee eliminate(R C)}
               {Board_rbmaerte.set empty R C OldBoard}
            end

         % 4. Decide what our next move will be
         [] move(_) then
            local
               Move = {NextMove OldBoard}
            in
               {Send Referee Move}
               {Board_rbmaerte.doMoveFor Player Move OldBoard}
            end

         else raise unknownRequestError(request:Request) end
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
            TmpBoard = {ApplyOther O B}
            NextBoard = {RespondTo R TmpBoard}
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
