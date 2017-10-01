-module(config).
-compile(export_all).

log_level() -> info.
log_modules() -> % any
  [
   %%    n2o_async,
   n2o_proto,
   n2o_stream,
   n2o_nitrogen,
   %%    n2o_session,
   doc,
   kvs,
   store_mnesia,
   verify,
   req,
   auth,
   routes
  ].
