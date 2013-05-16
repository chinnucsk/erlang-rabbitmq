-module(sender).
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

    %% Publish a message
    Pid1 = erlang:self(),
    Content1 = "Johnson lau",
    Content2 = 23,
    Payload = erlang:term_to_binary([Pid1, Content1, Content2]),

    Publish = #'basic.publish'{exchange = <<>>, routing_key = Queue},
    amqp_channel:cast(Channel, Publish, #amqp_msg{payload = Payload}),

    %% Close the channel
    amqp_channel:close(Channel),
    %% Close the connection
    amqp_connection:close(Connection),

    ok.