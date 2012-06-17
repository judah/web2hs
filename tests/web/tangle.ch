% [8] allow longer identifiers
@x
@!max_id_length=12; {long identifiers are chopped to this length, which must
@y
@!max_id_length=50; {long identifiers are chopped to this length, which must
@z

% [105] Expect "div" and "mod" instead of "DIV" and "MOD"
@x
@ @<Contribution is \.*...@>=
((t=ident)and(v=3)and@|
 (((out_contrib[1]="D")and(out_contrib[2]="I")and(out_contrib[3]="V")) or@|
 ((out_contrib[1]="M")and(out_contrib[2]="O")and(out_contrib[3]="D")) ))or@|
@^uppercase@>
 ((t=misc)and((v="*")or(v="/")))
@y
@ @<Contribution is \.*...@>=
((t=ident)and(v=3)and@|
 (((out_contrib[1]="d")and(out_contrib[2]="i")and(out_contrib[3]="v")) or@|
 ((out_contrib[1]="m")and(out_contrib[2]="o")and(out_contrib[3]="d")) ))or@|
@^uppercase@>
 ((t=misc)and((v="*")or(v="/")))
@z

% [110]
@x
@ @<If previous output was \.{DIV}...@>=
if (out_ptr=break_ptr+3)or
 ((out_ptr=break_ptr+4)and(out_buf[break_ptr]=" ")) then
@^uppercase@>
  if ((out_buf[out_ptr-3]="D")and(out_buf[out_ptr-2]="I")and
    (out_buf[out_ptr-1]="V"))or @/
     ((out_buf[out_ptr-3]="M")and(out_buf[out_ptr-2]="O")and
    (out_buf[out_ptr-1]="D")) then@/ goto bad_case
@y
@ @<If previous output was \.{DIV}...@>=
if (out_ptr=break_ptr+3)or
 ((out_ptr=break_ptr+4)and(out_buf[break_ptr]=" ")) then
@^uppercase@>
  if ((out_buf[out_ptr-3]="d")and(out_buf[out_ptr-2]="i")and
    (out_buf[out_ptr-1]="v"))or @/
     ((out_buf[out_ptr-3]="m")and(out_buf[out_ptr-2]="o")and
    (out_buf[out_ptr-1]="d")) then@/ goto bad_case
@z

% [114] lower-case and/not/in/or
@x
@ @<Cases like \.{<>}...@>=
and_sign: begin out_contrib[1]:="A"; out_contrib[2]:="N"; out_contrib[3]:="D";
@^uppercase@>
  send_out(ident,3);
  end;
not_sign: begin out_contrib[1]:="N"; out_contrib[2]:="O"; out_contrib[3]:="T";
  send_out(ident,3);
  end;
set_element_sign: begin out_contrib[1]:="I"; out_contrib[2]:="N";
  send_out(ident,2);
  end;
or_sign: begin out_contrib[1]:="O"; out_contrib[2]:="R"; send_out(ident,2);
  end;
@y
@ @<Cases like \.{<>}...@>=
and_sign: begin out_contrib[1]:="a"; out_contrib[2]:="n"; out_contrib[3]:="d";
@^uppercase@>
  send_out(ident,3);
  end;
not_sign: begin out_contrib[1]:="n"; out_contrib[2]:="o"; out_contrib[3]:="t";
  send_out(ident,3);
  end;
set_element_sign: begin out_contrib[1]:="i"; out_contrib[2]:="n";
  send_out(ident,2);
  end;
or_sign: begin out_contrib[1]:="o"; out_contrib[2]:="r"; send_out(ident,2);
  end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [116] Allow lowercase and underlines in identifiers.
@x
@<Cases related to identifiers@>=
"A",up_to("Z"): begin out_contrib[1]:=cur_char; send_out(ident,1);
  end;
"a",up_to("z"): begin out_contrib[1]:=cur_char-@'40; send_out(ident,1);
  end;
identifier: begin k:=0; j:=byte_start[cur_val]; w:=cur_val mod ww;
  while (k<max_id_length)and(j<byte_start[cur_val+ww]) do
    begin incr(k); out_contrib[k]:=byte_mem[w,j]; incr(j);
    if out_contrib[k]>="a" then out_contrib[k]:=out_contrib[k]-@'40
    else if out_contrib[k]="_" then decr(k);
    end;
  send_out(ident,k);
  end;
@y
@<Cases related to identifiers@>=
"A",up_to("Z"),"a",up_to("z"): begin out_contrib[1]:=cur_char; send_out(ident,1);
  end;
identifier: begin k:=0; j:=byte_start[cur_val]; w:=cur_val mod ww;
  while (k<max_id_length)and(j<byte_start[cur_val+ww]) do
    begin incr(k); out_contrib[k]:=byte_mem[w,j]; incr(j);
    end;
  send_out(ident,k);
  end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [182] Add a trailing newline.
@x
@<Print the job |history|@>;
@y
@<Print the job |history|@>;
new_line;
@z
