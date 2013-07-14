-module(mydb_client_handler).

-behavior(e2_task).

-export([start_link/1]).

-export([handle_task/1, terminate/2]).

start_link(Socket) ->
    e2_task:start_link(?MODULE, Socket).

handle_task(Socket) ->
    handle_command_line(read_line(Socket), Socket).

read_line(Socket) ->
    inet:setopts(Socket, [{active, false}, {packet, line}]),
    gen_tcp:recv(Socket, 0).

handle_command_line({ok, Data}, Socket) ->
    handle_command(parse_command(Data), Socket);
handle_command_line({error, closed}, _Socket) ->
    {stop, normal}.

parse_command(Data) ->
    handle_command_re_result(
      re:run(Data, "(.*?) (.*)\r\n", [{capture, all_but_first, list}])).

handle_command_re_result({match, [Command, Arg]}) -> {Command, Arg};
handle_command_re_result(nomatch) -> error.

handle_command({"GET", Key}, Socket) ->
    handle_reply(db_get(Key), Socket);
handle_command({"PUT", KeyVal}, Socket) ->
    handle_reply(db_put(split_keyval(KeyVal)), Socket);
handle_command({"DEL", Key}, Socket) ->
    handle_reply(db_del(Key), Socket);
handle_command(_, Socket) ->
    handle_reply(error, Socket).

split_keyval(KeyVal) ->
    handle_keyval_parts(re:split(KeyVal, " ", [{return, list}, {parts, 2}])).

handle_keyval_parts([Key]) -> {Key, ""};
handle_keyval_parts([Key, Val]) -> {Key, Val}.

db_get(Key) ->
    mydb_data:get(Key).

db_put({Key, Val}) ->
    mydb_data:put(Key, Val).

db_del(Key) ->
    mydb_data:del(Key).

handle_reply(Reply, Socket) ->
    send_reply(Reply, Socket),
    {repeat, Socket}.

send_reply({ok, Val}, Socket) ->
    gen_tcp:send(Socket, ["+", Val, "\r\n"]);
send_reply(ok, Socket) ->
    gen_tcp:send(Socket, "+OK\r\n");
send_reply(error, Socket) ->
    gen_tcp:send(Socket, "-ERROR\r\n").

terminate(_Reason, Socket) ->
    gen_tcp:close(Socket).
