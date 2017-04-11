functor
import
   Application
   Board
   System(showInfo:ShowInfo)
export
   refereeFor:RefereeFor
define
   /* RefereeFor
    *
    * Play a game on a board of the given Size,
    * between two player which can be communicated with trough the ports P1 and P2.
    * The function returns a tuple with two Ports: one for each player.
    */
   fun {RefereeFor P1 P2 Size}

      % Port which handles all the messages to the Referee
      % The state of the 'loop' is kept within FoldL
      fun {RefereePort InitialState}
         local Port
         in
            thread {FoldL Port ConsumeMessage InitialState _} end
            {NewPort Port}
         end
      end

      % Create a port for a player (p1 or p2)
      % Messages sent to these ports are forwarded to the RefPort
      % with the sending player attached
      fun {PlayerPort Player RefPort}
         local Port
            proc {SendMsg Msg}
               {ShowInfo "Player "#Player#"'s message came trough"}
               {Send RefPort msg(player:Player move:Msg)}
            end
         in
            thread
               for M in Port do
                  {SendMsg M}
               end
            end
            {NewPort Port}
         end
      end

      % Using the current State and an incoming message, calculate the next state
      fun {ConsumeMessage OldState Msg}
         local
            state(board:B player:CP again:A) = OldState
            msg(player:RP move:M) = Msg
         in
            % First, check if the current player
            if RP == CP
            then {JudgeMove CP M B A}
            else
               {ShowInfo "Player "#RP#" did not wait his/her turn!"}
               {EndGame CP}
            end
         end
      end

      % Decide if the current move is valid and return a new state accordingly
      fun {JudgeMove Player Move Board Again}
         state(board:Board player:Player again:Again)
      end

      % End the game and declare Player as the winner
      fun {EndGame Player}
         local Status = gameEnded(winner: Player)
         in
            {Send P1 Status}
            {Send P2 Status}
            {ShowInfo "Player "#Player#" has won!"}
            {Application.exit 0}
            nil
         end
      end

      % The initial state
      InitState = state(player:p1 board:{Board.init Size} again:false)

      % Start the referee thread with the initial state
      RP = {RefereePort InitState}
   in
      {ShowInfo "Game started!"}
      %  Send a request to player 1. The game is on.
      {Send P1 moveRequest(board: InitState.board)}
      ports({PlayerPort p1 RP} {PlayerPort p2 RP})
   end
end
