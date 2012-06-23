% [3]
@x
@p program DVI_type(@!dvi_file,@!output);
@y
@p program DVI_type(@!dvi_file,@!user_options,@!output);
@z


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

% [8]
% Option record type
% NOTE: if the fields change, then setStartPage in DVIType.chs should also
% change since it's hard-coded.
@x
@!ASCII_code=" ".."~"; {a subrange of the integers}
@y
@!ASCII_code=" ".."~"; {a subrange of the integers}
@!options=record@!out_mode:3..5;
  @!start_there:array [0..9] of boolean;
  @!start_count:array [0..9] of integer;
  @!start_vals:0..9;
  @!max_pages:integer;
  @!resolution:real;
  @!new_mag:integer;
  end;
@z

% [41]
@x
@!new_mag:integer; {if positive, overrides the postamble's magnification}
@y
@!new_mag:integer; {if positive, overrides the postamble's magnification}
@!user_options:options;
@z

@d errors_only=0 {value of |out_mode| when minimal printing occurs}
%@d terse=1 {value of |out_mode| for abbreviated output}
%@d mnemonics_only=2 {value of |out_mode| for medium-quantity output}
%@d verbose=3 {value of |out_mode| for detailed tracing}
%@d the_works=4 {|verbose|, plus check of postamble if |random_reading|}
%@y
%@d errors_only=0 {value of |out_mode| when minimal printing occurs}
%@d terse=1 {value of |out_mode| for abbreviated output}
%@d mnemonics_only=2 {value of |out_mode| for medium-quantity output}
%@d verbose=3 {value of |out_mode| for detailed tracing}
%@d the_works=4 {|verbose|, plus check of postamble if |random_reading|}
%
%@<Types...@>=
%@!options=record@!
%  @!out_mode:errors_only..the_works; {controls the amount of output}
%  @!max_pages:integer; {at most this many |bop..eop| pages will be printed}
%  @!resolution:real; {pixels per inch}
%  @!new_mag:integer; {if positive, overrides the postamble's magnification}
%  end;
%
%@z
%


% [47]
@x
begin update_terminal; reset(term_in);
@y
begin update_terminal; reset(term_in,'TTY:');
@z


% [50]
@x
begin rewrite(term_out); {prepare the terminal for output}
write_ln(term_out,banner);
@y
begin rewrite(term_out,'TTY:'); {prepare the terminal for output}
@z

% [51]
@x
@ @<Determine the desired |out_mode|@>=
1: write(term_out,'Output level (default=4, ? for help): ');
out_mode:=the_works; input_ln;
if buffer[0]<>" " then
  if (buffer[0]>="0")and(buffer[0]<="4") then out_mode:=buffer[0]-"0"
  else  begin write(term_out,'Type 4 for complete listing,');
    write(term_out,' 0 for errors and fonts only,');
    write_ln(term_out,' 1 or 2 or 3 for something in between.');
    goto 1;
    end
@y
@ @<Determine the desired |out_mode|@>=
out_mode:=user_options.out_mode;
{ It's guaranteed that out_mode<0, since the C type of out_mode
  is unsigned. }
if out_mode > 4 then out_mode:=4;
@z

@x
@ @<Determine the desired |start...@>=
2: write(term_out,'Starting page (default=*): ');
start_vals:=0; start_there[0]:=false;
input_ln; buf_ptr:=0; k:=0;
if buffer[0]<>" " then
  repeat if buffer[buf_ptr]="*" then
    begin start_there[k]:=false; incr(buf_ptr);
    end
  else  begin start_there[k]:=true; start_count[k]:=get_integer;
    end;
  if (k<9)and(buffer[buf_ptr]=".") then
    begin incr(k); incr(buf_ptr);
    end
  else if buffer[buf_ptr]=" " then start_vals:=k
  else  begin write(term_out,'Type, e.g., 1.*.-5 to specify the ');
    write_ln(term_out,'first page with \count0=1, \count2=-5.');
    goto 2;
    end;
  until start_vals=k
@y
@ @<Determine the desired |start...@>=
start_vals := user_options.start_vals;
for k:=0 to 9 do
  begin
    start_there[k] := user_options.start_there[k];
    start_count[k] := user_options.start_count[k];
  end;
@z

@x
@ @<Determine the desired |max_pages|@>=
3: write(term_out,'Maximum number of pages (default=1000000): ');
max_pages:=1000000; input_ln; buf_ptr:=0;
if buffer[0]<>" " then
  begin max_pages:=get_integer;
  if max_pages<=0 then
    begin write_ln(term_out,'Please type a positive number.');
    goto 3;
    end;
  end
@y
@ @<Determine the desired |max_pages|@>=
max_pages:=user_options.max_pages;
if max_pages<=0 then max_pages:=1;
@z

@x
@ @<Determine the desired |resolution|@>=
4: write(term_out,'Assumed device resolution');
write(term_out,' in pixels per inch (default=300/1): ');
resolution:=300.0; input_ln; buf_ptr:=0;
if buffer[0]<>" " then
  begin k:=get_integer;
  if (k>0)and(buffer[buf_ptr]="/")and
    (buffer[buf_ptr+1]>"0")and(buffer[buf_ptr+1]<="9") then
    begin incr(buf_ptr); resolution:=k/get_integer;
    end
  else  begin write(term_out,'Type a ratio of positive integers;');
    write_ln(term_out,' (1 pixel per mm would be 254/10).');
    goto 4;
    end;
  end
@y
@ @<Determine the desired |resolution|@>=
resolution:=user_options.resolution;
if resolution<0 then resolution:=300;
@z

@x
@ @<Determine the desired |new_mag|@>=
5: write(term_out,'New magnification (default=0 to keep the old one): ');
new_mag:=0; input_ln; buf_ptr:=0;
if buffer[0]<>" " then
  if (buffer[0]>="0")and(buffer[0]<="9") then new_mag:=get_integer
  else  begin write(term_out,'Type a positive integer to override ');
    write_ln(term_out,'the magnification in the DVI file.');
    goto 5;
    end
@y
@ @<Determine the desired |new_mag|@>=
new_mag:=user_options.new_mag;
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

