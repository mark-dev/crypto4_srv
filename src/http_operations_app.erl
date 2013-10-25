%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(http_operations_app).
-behaviour(application).

%% API.
-export([start/2]).
-export([stop/1]).

%% API.

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/", http_operations_toppage_handler, []}
		]}
	]),
    Priv = code:priv_dir(http_operations),
	{ok, _} = cowboy:start_https(http, 100, [{port, 8080},
						 {fail_if_no_peer_cert, false},
						 {keyfile,Priv ++ "/key.pem"},
						 {certfile,Priv ++ "/cert.pem"}], [
		{env, [{dispatch, Dispatch}]}
	]),
	http_operations_sup:start_link().

stop(_State) ->
	ok.
