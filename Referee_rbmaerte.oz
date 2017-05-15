functor
import
   Board_rbmaerte
   Helper_rbmaerte(isEmpty:IsEmpty otherPlayer:OtherPlayer)
   System(showInfo:ShowInfo)
   Application
export
   createReferee:CreateReferee
define

   /* RefereeFor
    *
    * Play a game on a board of the given size (Rows x Cols),
    * between two player which can be communicated with trough the ports P1 and P2.
    * The ports for the players to communicate with the referee will be bound to PR1 and PR2.
    */
   proc {CreateReferee P1 P2 PR1 PR2}

      % Which port for which player?
      fun {PortFor P}
         case P
         of p1 then P1
         [] p2 then P2
         end
      end

      /* Port which receives messages from both players and processes them while
       * keeping an internal (using FoldL).
       */
      fun {RefereePort InitialState}
         local Port
         in
            thread
               {ProcessMsg InitialState Port}
            end
            {NewPort Port}
         end
      end

      % Using the current State and an incoming message, calculate the next state
      % If the game has ended, return nil.
      proc {ProcessMsg State Messages}
         Msg|NextMessages = Messages
         state(board:_ stage:Stage player:CP) = State
         msg(player:RP move:M) = Msg
         NextState
      in
         {ShowInfo "Received a '"#{Label M}#"' response from "#RP#"."}

         % First, check if the current player
         if RP == CP
         then
            NextState = case Stage
            of pickSize then {JudgeSize State M}
            [] pickElimination then {JudgeFirstElimination State M}
            [] elimination(_) then {JudgeElimination State M}
            [] gameStarted(_) then {JudgeMove State M}
            else raise unknownStageError(stage:Stage) end
            end
         else
            {ShowInfo "Player "#RP#" did not wait his/her turn!"}
            {EndGame CP}
         end

         case NextState
         of nil then skip % This does not recurse
         else {ProcessMsg NextState NextMessages} % Recurse, next iteration
         end
      end

      fun {Eliminate OldBoard Row Col Player}
         if OldBoard.Row.Col \= Player
         then
            {ShowInfo "Position to eliminate was not a pawn of this player."}
            {EndGame {OtherPlayer Player}}
            nil % Return nil (the game will be ended anyway)
         else
            {Board_rbmaerte.set empty Row Col OldBoard}
         end
      end

      fun {JudgeSize State Response}
         state( board: _
                stage: _
                player: Player
                ) = State
         NewBoard
         NextPlayer
      in
         NextPlayer = {OtherPlayer Player}
         case Response
         of size(Rows Cols) then
            if Rows < 5 orelse Rows > 8
            orelse Cols < 5 orelse Cols > 8
            then
               {ShowInfo "Wrong board dimensions."}
               {EndGame NextPlayer}
            else
               NewBoard = {Board_rbmaerte.init Rows Cols}
            end
         else
            {ShowInfo "Unexpected response. Expected size(N M)."}
            {EndGame NextPlayer}
         end
         {NextRequest NextPlayer Response firstElimination}
         state(board:NewBoard stage:pickElimination player:NextPlayer)
      end

      % Review the requested elimination count and execute the first elimination
      fun {JudgeFirstElimination State Response}
         state( board: OldBoard
                stage: _
                player: Player
                ) = State
         NextBoard
         NextPlayer
         NextStage
      in
         case Response
         of firstElimination(k:K row:R col:C) then
            if K > 0
            then
               NextPlayer = {OtherPlayer Player}
               if K > {Width OldBoard.1} div 2
               then
                  {ShowInfo "Too many eliminations requested."}
                  {EndGame NextPlayer}
               else
                  {NextRequest NextPlayer Response elimination(K)}
                  NextBoard = {Eliminate OldBoard R C Player}
                  NextStage = elimination(K)
               end
            else
               NextPlayer = Player
               NextStage = gameStarted(false)
               NextBoard = OldBoard
               {NextRequest Player Response move(false)}
            end
         else
            {ShowInfo "Unexpected response. Expected firstElimination."}
            {EndGame {OtherPlayer NextPlayer}}
         end
         state(board:NextBoard stage:NextStage player:NextPlayer)
      end

      % Execute an elimination if it was correct
      fun {JudgeElimination State Response}
         state( board: OldBoard
                stage: elimination(L)
                player: Player
                ) = State
         NextBoard
         NextPlayer = {OtherPlayer Player}
         NextStage
         NextK
      in
         case Response
         of eliminate(R C) then
            NextBoard = {Eliminate OldBoard R C Player}

            % If we just had player2, decrease the count (p1 started eliminating)
            if Player == p2
            then
               NextK = L-1
            else
               NextK = L
            end

            % If NextK is zero, start the game. Else, continue eliminating.
            if NextK > 0
            then
               NextStage = elimination(NextK)
               {NextRequest NextPlayer Response elimination(NextK)}
            else
               NextStage = gameStarted(false)
               {NextRequest NextPlayer Response move(false)}
            end
         else
            {ShowInfo "Unexpected response. Expected firstElimination."}
            {EndGame {OtherPlayer NextPlayer}}
         end
         state(board:NextBoard stage:NextStage player:NextPlayer)
      end



      % Decide if the current move is valid and return a new state accordingly
      fun {JudgeMove State Response}
         state( board: OldBoard
                stage: gameStarted(Again)
                player: Player
                ) = State
         move(f(Fr Fc) t(Tr Tc)) = Response
      in
         {ShowInfo Player#" wants from ("#Fr#" "#Fc#") to ("#Tr#" "#Tc#")"}
         if {Member Response {Board_rbmaerte.validMovesFor Player OldBoard}}
         then
            % The move is valid, change board and player
            local
               NextBoard
               NextMoves
               NextPlayer
               NewSituation
               NoMoreMoves
            in

               NextBoard = {Board_rbmaerte.doMoveFor Player Response OldBoard}
               NextPlayer = {OtherPlayer Player}
               NewSituation = {Board_rbmaerte.analyse NextBoard}
               NextMoves = NewSituation.moves
               NoMoreMoves = {IsEmpty NextMoves.NextPlayer}

               % Show the current board
               {Board_rbmaerte.show NextBoard}

               if NewSituation.finished.Player
               then
                  {ShowInfo "Game ended because "#Player#" reached the other side."}
                  {EndGame Player}
                  nil % Return nil -> end game
               else if NoMoreMoves
                  then
                     {ShowInfo "Game ended because there are no more moves possible."}
                     {EndGame Player}
                     nil % Return nil -> end game
                  else
                     {NextRequest NextPlayer Response move(false)}
                     % Return new state
                     state(board:NextBoard stage:gameStarted(false) player:NextPlayer)
                  end
               end
            end
         else
            % The move is invalid, check if this is the player's second chance
            {ShowInfo "Player "#Player#"'s move is invalid."}
            if Again
            then
               {ShowInfo "-> Player "#Player#" loses because of two illegal moves."}
               {EndGame {OtherPlayer Player}}

               % Return nil -> end game
               nil
            else
               % Second chance: same board and player
               {ShowInfo "-> Player "#Player#"'s move is invalid and is given a second chance."}
               {NextRequest Player Response move(true)} 

               % Return the new state
               state(board:OldBoard stage:gameStarted(true) player:Player)
            end
         end
      end

      % Send a request to the (new) player and return the new sate
      proc {NextRequest TargetPlayer OtherMove Request}
         {ShowInfo "\nSending '"#{Label Request}#"' request to "#TargetPlayer}
         {Send {PortFor TargetPlayer} r(other:OtherMove request:Request)}
         % state(board:NextBoard player:TargetPlayer again:NextAgain moves:NextMoves)
      end

      % End the game and declare Player as the winner.
      % Returns an empty (nil) state.
      proc {EndGame Player}
         local Status = gameEnded(winner: Player)
         in
            {Send P1 Status}
            {Send P2 Status}
            {ShowInfo "\nPlayer "#Player#" has won!"}
            {Application.exit 0}
         end
      end

      RefPort
   in
      % Request the board size from player two
      % Arguments: Player OtherMove Request
      {NextRequest p2 nil size}

      % Start the referee thread with the initial state
      RefPort = {RefereePort state(board:nil stage:pickSize player:p2)}

      % Create the ports for the players
      PR1 = {PlayerPort p1 RefPort}
      PR2 = {PlayerPort p2 RefPort}
   end

   /* Create a port for a player (p1 or p2) to send messages to the referee
    * Messages sent to these ports are forwarded to the RefPort
    * with an identifier for the sender attached.
    */
   fun {PlayerPort Player RefPort}
      local Port
         proc {SendMsg Msg}
            {Send RefPort msg(player:Player move:Msg)}
         end
      in
         thread {ForAll Port SendMsg} end
         {NewPort Port}
      end
   end
end
