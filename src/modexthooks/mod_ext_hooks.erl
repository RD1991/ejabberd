-module(mod_ext_hooks).

-author("Chetan Saundankar").

-behavior(gen_mod).

% -import("httpc").

-include("ejabberd.hrl").
-include("logger.hrl").
-include("jlib.hrl").

-export([start/2, stop/1, mod_opt_type/1,on_muc_filter_message/5,on_muc_filter_presence/5]).

-export([on_offline_message/3]).


-ifndef(LAGER).
-define(LAGER, 1).
-endif.

start(_Host, _Opt) ->
	?INFO_MSG("In on_offline_message ~p~n", [_Opt]),
	% TableId = ets:new(mod_ext_hooks_opts, [set, public, named_table ,{write_concurrency, false}, {read_concurrency, true}]),
	% ets:insert(mod_ext_hooks_opts, _Opt).
	ejabberd_hooks:add(offline_message_hook, _Host, ?MODULE, on_offline_message, 50),
	ejabberd_hooks:add(muc_filter_message, _Host, ?MODULE, on_muc_filter_message, 50),
	ejabberd_hooks:add(muc_filter_presence, _Host, ?MODULE, on_muc_filter_presence, 50).

stop(_Host) ->
	ejabberd_hooks:delete(offline_message_hook, _Host, ?MODULE, on_offline_message, 50),
	ejabberd_hooks:delete(muc_filter_message, _Host, ?MODULE, on_muc_filter_message, 50),
	ejabberd_hooks:delete(muc_filter_presence, _Host, ?MODULE, on_muc_filter_presence, 50),	
	?INFO_MSG("On stop in mod_hello ", []).

% on_offline_message(_From, _To, _Packet) ->
% 	%?INFO_MSG("In on_offline_message ~p~n", [_Packet]),
% 	Method = post,
% 	%URL = "https://demo3477636.mockable.io/postdata",
% 	URL = "http://192.168.2.29:5000/api/hooks/jabber/mucfilter",
% 	Header = [],
% 	Type = "text/plain",
% 	HTTPOptions = [],
% 	Options = [],	
% 	% Tag = {<<"a">>, <<"b">>},
% 	%Tag = #xmlel{name = <<"x">>,attrs = [{<<"xmlns">>, <<"chetan">>}]},
% 	%NewPacket = fxml:append_subtags(_Packet, [Tag]),
% 	%NewPacket = {_From, _To, _Packet},
% 	% Xml = fxml:element_to_binary(Tag),	
% 	%Xml = fxml:element_to_binary(_Packet),	
% 	R = httpc:request(Method, {URL, Header, Type, "Hello"}, HTTPOptions, Options),
% 	{ok, {{"HTTP/1.1",ReturnCode, State}, Head, Body}} = R.


on_offline_message(_From, _To, _Packet) ->
	?INFO_MSG("In on_offline_message ~p~n", [_From]),
	Method = post,
	%URL = "http://demo3477636.mockable.io/postdata",
	URL = "http://grup-stg.cloudapp.net:5000/api/hooks/jabber/userfilter/offline",
	Header = [],
	Type = "text/plain",
	HTTPOptions = [],
	Options = [],	
	NewFrom = get_jid_string(_From),
	FromTag = #xmlel{name = <<"from">>,attrs = [{<<"jid">>, NewFrom}]},
	NewPacket = fxml:append_subtags(_Packet, [FromTag]),
	Xml = fxml:element_to_binary(NewPacket),	
	R = httpc:request(Method, {URL, Header, Type, Xml}, HTTPOptions, Options),
	{ok, {{"HTTP/1.1",ReturnCode, State}, Head, Body}} = R.

on_muc_filter_message(Stanza, MUCState, RoomJID, FromJID, _FromNick) ->
	?INFO_MSG("RoomJID: ~p~n", [RoomJID]),
	?INFO_MSG("FromJID: ~p~n", [FromJID]),
	?INFO_MSG("MUCState: ~p~n", [MUCState]),
	%?INFO_MSG("FromNick: ~p~n", [FromNick]),
	Method = post,
	URL = "http://grup-stg.cloudapp.net:5000/api/hooks/jabber/mucfilter/offline",
	Header = [],
	Type = "text/plain",
	HTTPOptions = [],
	Options = [],
	NewMUCState = get_jid_string(MUCState),
	NewRoomJID = get_jid_string(RoomJID),
	NewFromJID = get_jid_string(FromJID),
	%NewFromNick = get_jid_string(FromNick),	
	%Tag = {<<"a">>, <<"b">>},
	%NewPacket = {_From, _To, _Packet},
	%FromTag = #xmlel{name = <<"from">>,attrs = [{<<"jid">>, NewFromJID}, {<<"nick">>, NewFromNick}]},
	FromTag = #xmlel{name = <<"from">>,attrs = [{<<"jid">>, NewFromJID}]},
	RoomTag = #xmlel{name = <<"room">>,attrs = [{<<"jid">>, NewRoomJID}, {<<"state">>, NewMUCState}]},
	NewPacket = fxml:append_subtags(Stanza, [FromTag, RoomTag]),
	Xml = fxml:element_to_binary(NewPacket),	
	?INFO_MSG("Xml to string ~p~n", [Xml]),
	R = httpc:request(Method, {URL, Header, Type, Xml}, HTTPOptions, Options),
	{ok, {{"HTTP/1.1",ReturnCode, State}, Head, Body}} = R,
	Stanza.

on_muc_filter_presence(Stanza, MUCState, RoomJID, FromJID, _FromNick) ->
	?INFO_MSG("In on_muc_filter_presence ~p~n", [fxml:element_to_binary(Stanza)]),
	?INFO_MSG("RoomJID: ~p~n", [RoomJID]),
	?INFO_MSG("FromJID: ~p~n", [FromJID]),
	?INFO_MSG("MUCState: ~p~n", [MUCState]),
	%?INFO_MSG("FromNick: ~p~n", [FromNick]),
	Method = post,
	%URL = "https://demo3477636.mockable.io/postdata",
	URL = "http://grup-stg.cloudapp.net:5000/api/hooks/jabber/userstatus",
	Header = [],
	Type = "text/plain",
	HTTPOptions = [],
	Options = [],
	NewMUCState = get_jid_string(MUCState),
	NewRoomJID = get_jid_string(RoomJID),
	NewFromJID = get_jid_string(FromJID),
	%NewFromNick = get_jid_string(FromNick),	
	%Tag = {<<"a">>, <<"b">>},
	%NewPacket = {_From, _To, _Packet},
	FromTag = #xmlel{name = <<"from">>,attrs = [{<<"jid">>, NewFromJID}]},
	RoomTag = #xmlel{name = <<"room">>,attrs = [{<<"jid">>, NewRoomJID}, {<<"state">>, NewMUCState}]},
	NewPacket = fxml:append_subtags(Stanza, [FromTag, RoomTag]),
	Xml = fxml:element_to_binary(NewPacket),	
	?INFO_MSG("Xml to string ~p~n", [Xml]),
	R = httpc:request(Method, {URL, Header, Type, Xml}, HTTPOptions, Options),
	{ok, {{"HTTP/1.1",ReturnCode, State}, Head, Body}} = R,
	Stanza.

get_jid_string(JidElement) ->
	Jid = binary_to_list(erlang:element(2, JidElement)) ++ "@" ++ binary_to_list(erlang:element(3, JidElement)),
	Jid.

mod_opt_type(iqdisc) -> fun gen_iq_handler:check_type/1;
mod_opt_type(_) -> [iqdisc].
