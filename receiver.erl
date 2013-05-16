-module(receiver).
-include_lib("amqp_client/include/amqp_client.hrl").
-compile([export_all]).

test() ->
    %% Start a network connection
    {ok, Connection} = amqp_connection:start(#amqp_params_network{}),
    %{ok, Connection} = amqp_connection:start(#amqp_params_direct{node='rabbit@JOHNSON-WS'}),
    %% Open a channel on the connection
    {ok, Channel} = amqp_connection:open_channel(Connection),

    %% Declare a queue
    Queue = <<"messages">>,
    #'queue.declare_ok'{queue = Queue} = amqp_channel:call(Channel, #'queue.declare'{queue = Queue}),

    Sub = #'basic.consume'{queue = Queue},
    #'basic.consume_ok'{} = amqp_channel:call(Channel, Sub), %% the caller is the subscriber
    
    loop(Channel).


loop(Channel) ->
      receive
          %% This is the first message received
          #'basic.consume_ok'{} ->
              loop(Channel);

          %% This is received when the subscription is cancelled
          #'basic.cancel_ok'{} ->
              ok;

          %% A delivery
          {#'basic.deliver'{delivery_tag = Tag}, Content} ->
                %% Do something with the message payload
                %% (some work here)
                #amqp_msg{payload = Msg} = Content,
                [Pid2, Content1_2, Content2_2] = erlang:binary_to_term(Msg),
                io:format("Receive, pid - ~p, name - ~p, age - ~p~n", [Pid2, Content1_2, Content2_2]),


                %% Ack the message
                amqp_channel:cast(Channel, #'basic.ack'{delivery_tag = Tag}),

                %% Loop
                loop(Channel)
      end.