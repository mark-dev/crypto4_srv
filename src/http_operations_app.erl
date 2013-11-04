
%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(http_operations_app).
-behaviour(application).

%% API.
-export([start/2]).
-export([stop/1]).

%% API.

start(_Type, _Args) ->
    Dispatch = cowboy_router:compile([{'_', [
					     {"/", http_operations_toppage_handler, []}
					    ]}
				     ]),
    Priv = code:priv_dir(http_operations),
    SSLOpts = [{verify,verify_peer},
	       {fail_if_no_peer_cert,true},
	       {cacertfile,filename:join([Priv,"server","ca.pem"])},
	       {keyfile,filename:join([Priv,"server2","key.pem"])},
	       {certfile,filename:join([Priv,"server2","cert.pem"])}],
    {ok, _} = cowboy:start_https(http, 100, [{port, 8080} | SSLOpts],
				 [{env, [{dispatch, Dispatch}]}]),
    http_operations_sup:start_link().

stop(_State) ->
	ok.
