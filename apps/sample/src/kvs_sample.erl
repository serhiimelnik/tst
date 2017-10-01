-module(kvs_sample).
-include_lib("kvs/include/metainfo.hrl").
-include_lib("kvs/include/kvs.hrl").
-include("sample.hrl").
-compile(export_all).

metainfo() ->
  #schema{name=sample,tables=[
                              #table{name='Auth',fields=record_info(fields,'Auth')}
                             ]}.
