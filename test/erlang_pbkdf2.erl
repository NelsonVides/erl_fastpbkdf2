-module(erlang_pbkdf2).

-export([hi/4]).

-type sha_type() :: crypto:sha1() | crypto:sha2().

-spec hi(sha_type(), binary(), binary(), non_neg_integer()) -> binary().
hi(Sha, Password, Salt, 1) ->
    crypto:hmac(Sha, Password, <<Salt/binary, 0, 0, 0, 1>>);
hi(Sha, Password, Salt, IterationCount)
  when is_integer(IterationCount), IterationCount > 1 ->
    U1 = crypto:hmac(Sha, Password, <<Salt/binary, 0, 0, 0, 1>>),
    mask(U1, hi_round(Sha, Password, U1, IterationCount - 1)).

-spec hi_round(sha_type(), binary(), binary(), non_neg_integer()) -> binary().
hi_round(Sha, Password, UPrev, 1) ->
    crypto:hmac(Sha, Password, UPrev);
hi_round(Sha, Password, UPrev, IterationCount) ->
    U = crypto:hmac(Sha, Password, UPrev),
    mask(U, hi_round(Sha, Password, U, IterationCount - 1)).

-spec mask(binary(), binary()) -> binary().
mask(Key, Data) ->
    KeySize = size(Key) * 8,
    <<A:KeySize>> = Key,
    <<B:KeySize>> = Data,
    C = A bxor B,
    <<C:KeySize>>.
