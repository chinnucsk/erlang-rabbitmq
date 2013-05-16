-module(test).
-compile(export_all).
-include_lib("amqp_client/include/amqp_client.hrl").

do() ->
	{ok, Connection} = amqp_connection:start(#amqp_params_direct{node='rabbit@JOHNSON-WS'}),
	{ok, Channel} = amqp_connection:open_channel(Connection),
	
	ok.