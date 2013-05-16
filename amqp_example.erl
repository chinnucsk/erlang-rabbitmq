-module(amqp_example).
-include_lib("amqp_client/include/amqp_client.hrl").
-compile([export_all]).

test() ->
    %% Start a network connection
    %{ok, Connection} = amqp_connection:start(#amqp_params_network{}),
    {ok, Connection} = amqp_connection:start(#amqp_params_direct{node='rabbit@JOHNSON-WS'}),
    %% Open a channel on the connection
    {ok, Channel} = amqp_connection:open_channel(Connection),

    %% Declare a queue
    #'queue.declare_ok'{queue = Q}
        = amqp_channel:call(Channel, #'queue.declare'{}),

    %% Publish a message
    Pid1 = erlang:self(),
    Content1 = "Johnson lau",
    Content2 = 23,

    Payload = erlang:term_to_binary([Pid1, Content1, Content2]),

    Publish = #'basic.publish'{exchange = <<>>, routing_key = Q},
    amqp_channel:cast(Channel, Publish, #amqp_msg{payload = Payload}),





    %% Get the message back from the queue
    Get = #'basic.get'{queue = Q},
    {#'basic.get_ok'{delivery_tag = Tag}, #amqp_msg{payload = Msg}}
         = amqp_channel:call(Channel, Get),

    %% Do something with the message payload
    %% (some work here)
    [Pid2, Content1_2, Content2_2] = erlang:binary_to_term(Msg),
    io:format("Receive, pid - ~p, name - ~p, age - ~p~n", [Pid2, Content1_2, Content2_2]),

    Pid2 ! "Good!",

    %% Ack the message
    amqp_channel:cast(Channel, #'basic.ack'{delivery_tag = Tag}),

    receive
      Message ->
        io:format("Message: ~p~n", [Message])
    end,





    %% Close the channel
    amqp_channel:close(Channel),
    %% Close the connection
    amqp_connection:close(Connection),

    ok.