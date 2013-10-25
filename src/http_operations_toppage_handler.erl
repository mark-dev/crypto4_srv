
-module(http_operations_toppage_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    {Method, Req2} = cowboy_req:method(Req),
    {Operation, Req3} = cowboy_req:qs_val(<<"operation">>, Req2),
    {Arg1,Req4} = cowboy_req:qs_val(<<"arg1">>,Req3),
    {Arg2,Req5} = cowboy_req:qs_val(<<"arg2">>,Req4),
    {ok, Req6} = operation(Method,{Operation,Arg1,Arg2}, Req5),
    {ok, Req6, State}.

operation(<<"GET">>,{Op,Arg1,Arg2},Req) when is_binary(Op),
					     is_binary(Arg1),
					     is_binary(Arg2) ->
    OpResult = try 
		   execute_cmd(Op,Arg1,Arg2) 
	       catch
		   Type:Error ->
		       [<<"Exception ">>,
			to_string(Type),
			<<$\n>>,
			to_string(Error)]
	       end,
    cowboy_req:reply(200, [{<<"content-type">>, <<"text/plain; charset=utf-8">>}],OpResult, Req);
operation(_M,_A,Req)->
    cowboy_req:reply(400, [], <<"seems wrong syntax">>, Req).

terminate(_Reason, _Req, _State) ->
    ok.


%%Internal functions
bin_to_num(A)->
    try
	case binary:split(A,<<".">>,[global]) of
	    [_,_] ->
		binary_to_float(A);
	    [_] ->
		binary_to_integer(A)
	end
    catch
	_:T ->
	    throw({bin_to_num,T,A})
    end.

execute_cmd(CMD,A1,A2)->
    P1 = bin_to_num(A1),
    P2 = bin_to_num(A2),
    Fun = case CMD of
	      <<"plus">> ->
		  fun erlang:'+'/2;
	      <<"minus">> ->
		  fun erlang:'-'/2;
	      <<"mpl">> ->
		  fun erlang:'*'/2;
	      <<"div">> ->
		  fun erlang:'/'/2;
	      Other ->
		  throw({unknown_operation_keyword,Other})
	  end,
    to_string(apply(Fun,[P1,P2])).

to_string(T)->
    io_lib:format("~p",[T]).


