-module(test).
-compile(export_all).
-include_lib("amqp_client/include/amqp_client.hrl").

do() ->
	amqp_connection:start(#amqp_params_direct{node='rabbit@JOHNSON-PC'}).