% [5]
@x
@!name_length=50; {a file name shouldn't be longer than this}
@y
@!name_length=200; {a file name shouldn't be longer than this}
@z

% [7]
@x
@p procedure jump_out;
begin goto final_end;
end;
@y
@p procedure jump_out;
begin write_ln; goto final_end;
end;
@z

% [47]
@x
begin update_terminal; reset(term_in);
@y
begin update_terminal; reset(term_in,'TTY:');
@z



% [50]
@x
begin rewrite(term_out); {prepare the terminal for output}
@y
begin rewrite(term_out,'TTY:'); {prepare the terminal for output}
@z

% [64-65]
@x
@ If |p=0|, i.e., if no font directory has been specified, \.{DVItype}
is supposed to use the default font directory, which is a
system-dependent place where the standard fonts are kept.
The string variable |default_directory| contains the name of this area.
@^system dependencies@>

@d default_directory_name=='TeXfonts:' {change this to the correct name}
@d default_directory_name_length=9 {change this to the correct length}

@<Glob...@>=
@!default_directory:packed array[1..default_directory_name_length] of char;

@ @<Set init...@>=
default_directory:=default_directory_name;
@y
@z


% [66] TFM filename
% - append ".tfm\0" instead of ".TFM"
% - No case change
% - search for file path
%
% Questions:
% Why did p affect things?
@x
@<Move font name into the |cur_name| string@>=
for k:=1 to name_length do cur_name[k]:=' ';
if p=0 then
  begin for k:=1 to default_directory_name_length do
    cur_name[k]:=default_directory[k];
  r:=default_directory_name_length;
  end
else r:=0;
for k:=font_name[nf] to font_name[nf+1]-1 do
  begin incr(r);
  if r+4>name_length then
    abort('DVItype capacity exceeded (max font name length=',
      name_length:1,')!');
@.DVItype capacity exceeded...@>
  if (names[k]>="a")and(names[k]<="z") then
      cur_name[r]:=xchr[names[k]-@'40]
  else cur_name[r]:=xchr[names[k]];
  end;
cur_name[r+1]:='.'; cur_name[r+2]:='T'; cur_name[r+3]:='F'; cur_name[r+4]:='M'
@y
@<Move font name into the |cur_name| string@>=
r:=0;
for k:=font_name[nf] to font_name[nf+1]-1 do
  begin
    incr(r);
    if r+5>name_length then
      abort('DVItype capacity exceeded (max font name length=',
        name_length:1,')!');
@.DVItype capacity exceeded...@>
    cur_name[r]:=xchr[names[k]];
  end;
cur_name[r+1]:='.'; cur_name[r+2]:='t'; cur_name[r+3]:='f';
cur_name[r+4]:='m'; cur_name[r+5]:=chr(0);
web2hs_find_cached(cur_name,name_length,cur_name,name_length);
@z

