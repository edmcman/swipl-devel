/*  Part of SWI-Prolog

    Author:        Jan Wielemaker
    E-mail:        J.Wielemaker@vu.nl
    WWW:           http://www.swi-prolog.org
    Copyright (c)  2017, VU University Amsterdam
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in
       the documentation and/or other materials provided with the
       distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/

:- module(test_gc_thread_startup,
	  [ test_gc_thread_startup/0
	  ]).
:- use_module(library(apply)).

%!  test_gc_thread_startup
%
%   Thread race conditions and deadlocks  that   may  appear when lazily
%   starting the `gc` thread.

test_gc_thread_startup :-
    forall(between(1, 10, _),
           (run(4), put_char(user_error, .))).

run(N) :-
    kill_gc,
    length(Threads, N),
    maplist(thread_create(agc), Threads),
    maplist(thread_join, Threads).

agc :-
    thread_self(Me),
    thread_property(Me, id(ID)),
    atom_concat(a, ID, Prefix),
    forall(between(1, 10000, I),
           atom_concat(Prefix, I, _)).

kill_gc :-
    (   '$gc_stop'
    ->  thread_join(gc, _)
    ;   true
    ).

:- multifile
    prolog:message//1.

prolog:message(test_gc_thread_startup(not_created)) -->
    [ 'GC thread was not created'-[] ].
