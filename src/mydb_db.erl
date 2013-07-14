-module(mydb_db).

-export([open/1, put/3, get/2, del/2]).

open(File) ->
    dets:open_file(File, []).

put(Db, Key, Value) ->
    dets:insert(Db, {Key, Value}).

get(Db, Key) ->
    case dets:lookup(Db, Key) of
        [{_, Value}] -> {ok, Value};
        [] -> error
    end.

del(Db, Key) ->
    dets:delete(Db, Key).

