functor
import
   Board
   Helper(isEmpty:IsEmpty otherPlayer:OtherPlayer)
   System(showInfo:ShowInfo)
export
   createReferee:CreateReferee
define

   /* RefereeFor
    *
    * Play a game on a board of the given size (Rows x Cols),
    * between two player which can be communicated with trough the ports P1 and P2.
    * The function returns a tuple with two Ports: one for each player.
    */
   fun {CreateReferee P1 P2 Rows Cols}

      % Which port for whic player?
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
               {ShowInfo "Referee thread ended."}
            end
            {NewPort Port}
         end
      end

      % Using the current State and an incoming message, calculate the next state
      % If the game has ended, return nil.
      proc {ProcessMsg State Messages}
         Msg|NextMessages = Messages
         state(board:_ player:CP again:_ moves:_) = State
         msg(player:RP move:M) = Msg
         NextState
      in
         {ShowInfo "Received a message from "#RP#"."}

         % First, check if the current player
         if RP == CP
         then NextState = {JudgeMove State M}
         else
            {ShowInfo "Player "#RP#" did not wait his/her turn!"}
            NextState = {EndGame CP}
         end

         case NextState
         of nil then skip % This does not recurse
         else {ProcessMsg NextState NextMessages} % Recurse, next iteration
         end
      end

      % Decide if the current move is valid and return a new state accordingly
      fun {JudgeMove State Move}
         state( board:OldBoard
                player:Player
                again:Again
                moves: ValidMoves
                ) = State

         % Helper method: Execute the move
         fun {DoMove}
            mv(f(Fr Fc) t(Tr Tc)) = Move
         in
            {ShowInfo "From ("#Fr#" "#Fc#") to ("#Tr#" "#Tc#")"}
            {Board.set Player Tr Tc {Board.set empty Fr Fc OldBoard}}
         end

      in
         if {Member Move ValidMoves.Player}
         then
            local
               NextBoard
               NextMoves
               NextPlayer
               NewSituation
               NoMoreMoves
            in
               NextBoard = {DoMove}
               NextPlayer = {OtherPlayer Player}
               NewSituation = {Board.analyse NextBoard}
               NextMoves = NewSituation.moves
               NoMoreMoves = {IsEmpty NextMoves.NextPlayer}

               % Show the current board
               {Board.show NextBoard}

               if NewSituation.finished.Player
               then
                  {ShowInfo "Game ended because "#Player#" reached the other side."}
                  {EndGame Player} % Returns nil -> end game
               else if NoMoreMoves
                  then
                     {ShowInfo "Game ended because there are no more moves possible."}
                     {EndGame Player} % Returns nil -> end game
                  else
                     {RequestNext NextBoard NextPlayer NextMoves false} % Returns new state
                  end
               end
            end
            % The move is valid, change board and player
         else
            % The move is invalid, check if this is the player's second chance
            {ShowInfo "Player "#Player#"'s move is invalid."}
            if Again
            then
               {ShowInfo "-> Player "#Player#" loses because of two illegal moves."}
               {EndGame {OtherPlayer Player}} % Returns nil -> end game
            else
               % Second chance: same board and player
               {ShowInfo "-> Player "#Player#"'s move is invalid is given a second chance."}
               {RequestNext OldBoard Player ValidMoves true} % Returns new state
            end
         end
      end

      % Send a request to the (new) player and return the new sate
      fun {RequestNext NextBoard NextPlayer NextMoves NextAgain}
         {ShowInfo "\nSending request to "#NextPlayer}
         {Send {PortFor NextPlayer} request(board: NextBoard)}
         state(board:NextBoard player:NextPlayer again:NextAgain moves:NextMoves)
      end

      % End the game and declare Player as the winner.
      % Returns an empty (nil) state.
      fun {EndGame Player}
         local Status = gameEnded(winner: Player)
         in
            {Send P1 Status}
            {Send P2 Status}
            {ShowInfo "\nPlayer "#Player#" has won!"}
            nil % Nil state to signal the end
         end
      end

      % The initial board
      InitBoard = {Board.init Rows Cols}

      InitState
      RefPort

      % The initial situation
      situation(finished:_ moves:Moves) = {Board.analyse InitBoard}
   in
      % Request a first move from player one, this
      % create the intial state to start the Referee thread with.
      % Arguments: Board Player Again ValidMoves
      InitState = {RequestNext InitBoard p1 Moves false}

      % Start the referee thread with the initial state
      RefPort = {RefereePort InitState}

      % Create the ports for the players
      p({PlayerPort p1 RefPort} {PlayerPort p2 RefPort})
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
