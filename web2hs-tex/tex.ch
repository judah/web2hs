% [2]
% We're not TRIP-compliant, so don't claim to be TeX.
@x
@d banner=='This is TeX, Version 3.1415926' {printed when \TeX\ starts}
@y
@d banner=='This is web2hs-TeX, Version 3.1415926' {printed when \TeX\ starts}
@z
% [4]
% Program arguments:
% pool_path: null-terminated path to tex.pool
% first_line: either NULL or a null-terminated C-string.
%     If nonempty/nonblank, it is used as the first line of input.
@x
program TEX; {all file names are defined dynamically}
@y
program TEX(user_options);
@z

% [8]
% Whether or not we run as "initex" depends on command-line options,
% rather than being determined at compile time.
% We add the "ifinit" macro which wraps various initializations in
% an if block.
% (It's simpler to keep around the original unused "init" macro, since it's used
% in several places where "if" statements are not allowed, such as type/variable
% declarations.)
@x
@d init== {change this to `$\\{init}\equiv\.{@@\{}$' in the production version}
@y
@d init== {change this to `$\\{init}\equiv\.{@@\{}$' in the production version}
@d ifinit==if (user_options.explicit_format=0) then begin
@d endifinit==end;
@f ifinit==begin
@fendifinit==end
@z
@x
@!init @<Initialize table entries (done by \.{INITEX} only)@>@;@+tini
@y
@!ifinit @<Initialize table entries (done by \.{INITEX} only)@>@;@+endifinit
@z


% [11]
% - Use a larger file name size.
% - Don't need the pool_name variable anymore.
@x
@!file_name_size=40; {file names shouldn't be longer than this}
@y
@!file_name_size=200; {file names shouldn't be longer than this}
@z

@x
@!pool_name='TeXformats:TEX.POOL                     ';
  {string of length |file_name_size|; tells where the string pool appears}
@y
@z

% [31]
% Modified input_ln to always "get" the trailing newline.
% 
% TODO: make this a custom C function.
@x
@p function input_ln(var f:alpha_file;@!bypass_eoln:boolean):boolean;
  {inputs the next line or returns |false|}
var last_nonblank:0..buf_size; {|last| with trailing blanks removed}
begin if bypass_eoln then if not eof(f) then get(f);
  {input the first character of the line into |f^|}
last:=first; {cf.\ Matthew 19\thinspace:\thinspace30}
if eof(f) then input_ln:=false
else  begin last_nonblank:=first;
  while not eoln(f) do
    begin if last>=max_buf_stack then
      begin max_buf_stack:=last+1;
      if max_buf_stack=buf_size then
        @<Report overflow of the input buffer, and abort@>;
      end;
    buffer[last]:=xord[f^]; get(f); incr(last);
    if buffer[last-1]<>" " then last_nonblank:=last;
    end;
  last:=last_nonblank; input_ln:=true;
  end;
end;
@y
@p function input_ln(var f:alpha_file;@!bypass_eoln:boolean):boolean;
  {inputs the next line or returns |false|}
var last_nonblank:0..buf_size; {|last| with trailing blanks removed}
begin
last:=first; {cf.\ Matthew 19\thinspace:\thinspace30}
if eof(f) then input_ln:=false
else  begin last_nonblank:=first;
  while not eoln(f) do
    begin if last>=max_buf_stack then
      begin max_buf_stack:=last+1;
      if max_buf_stack=buf_size then
        @<Report overflow of the input buffer, and abort@>;
      end;
    buffer[last]:=xord[f^]; get(f); incr(last);
    if buffer[last-1]<>" " then last_nonblank:=last;
    end;
  last:=last_nonblank; input_ln:=true;
  end;
  { Skip trailing newline, if there is one. }
  if not eof(f) and eoln(f) then get(f);
end;
@z

% [37]
% A couple changes when reading the first line of input:
% Use the specified first_line, if it's available and not empty.
% Also, make 
% Don't call get(term_in) at the start of the program.  Otherwise, we would
% ignore the first character of input.
@x
@p function init_terminal:boolean; {gets the terminal input started}
label exit;
begin t_open_in;
loop@+begin wake_up_terminal; write(term_out,'**'); update_terminal;
@.**@>
  if not input_ln(term_in,true) then {this shouldn't happen}
    begin write_ln(term_out);
    write(term_out,'! End of file on the terminal... why?');
@.End of file on the terminal@>
    init_terminal:=false; return;
    end;
  loc:=first;
  while (loc<last)and(buffer[loc]=" ") do incr(loc);
  if loc<last then
    begin init_terminal:=true;
    return; {return unless the line was all blank}
    end;
  write_ln(term_out,'Please type the name of your input file.');
  end;
exit:end;
@y
@p function init_terminal:boolean; {gets the terminal input started}
label exit;
begin t_open_in;
{ Try to use the manual first_line argument, if provided. }
if (user_options.first_line <> 0) then begin
  { Copy the first_line into the buffer }
  last:=first;
  while user_options.first_line[last-first]<> 0 do begin
     { Check for overflow }
    if last+1>=buf_size then begin
      write_ln(term_out, 'Buffer size exceeded!'); goto final_end;
    end;
    buffer[last]:=user_options.first_line[last-first];
    incr(last);
  end;
  { Look for the first nonblank character.  If first_line
    wasn't completely blank, we're done. }
  loc:=first;
  while (loc<last)and(buffer[loc]=" ") do incr(loc);
  if loc<last then 
    begin
      init_terminal:=true;
      return;
    end;
end;
{ Read the first line from the terminal }
loop@+begin wake_up_terminal; write(term_out,'**'); update_terminal;
@.**@>
  if not input_ln(term_in,true) then {this shouldn't happen}
    begin write_ln(term_out);
    write_ln(term_out,'! End of file on the terminal... why?');
@.End of file on the terminal@>
    init_terminal:=false; return;
    end;
  loc:=first;
  while (loc<last)and(buffer[loc]=" ") do incr(loc);
  if loc<last then
    begin init_terminal:=true;
    return; {return unless the line was all blank}
    end;
  write_ln(term_out,'Please type the name of your input file.');
  end;
exit:end;
@z

% [51]
% Explicitly copy the pool_path C-string into the name_of_file buffer.
@x
name_of_file:=pool_name; {we needn't set |name_length|}
@y
k:=0;
repeat
  name_of_file[k+1] := user_options.pool_path[k];
  incr(k);
  until user_options.pool_path[k-1] = 0;
@z

% [61]
% Don't print the format string; format_ident is not useful at this point.
% TODO: something better.
@x
if format_ident=0 then wterm_ln(' (no format preloaded)')
else  begin slow_print(format_ident); print_ln;
  end;
@y
print_ln;
@z

% [74]
% Set the initial interaction behavior.  (The Haskell modules make
% ErrorStop the default.)
@x
@ @<Set init...@>=interaction:=error_stop_mode;
@y
@ @<Set init...@>=interaction:=user_options.interaction;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%
% Prevent a few warnings of superfluous tests.
% font(p),text(p),info(p) are all unsigned types in C,
% so, e.g., font(p)<0 is always false.
%
% [173]
@x
        begin if (font(p)<font_base)or(font(p)>font_max) then
@y
        begin if font(p)>font_max then
@z

% [176]
%Prevent warning, since font_base=0<=font(p).
@x
else  begin if (font(p)<font_base)or(font(p)>font_max) then print_char("*")
@y
else  begin if font(p)>font_max then print_char("*")
@z

% [241]
@x
@p procedure fix_date_and_time;
begin time:=12*60; {minutes since midnight}
day:=4; {fourth day of the month}
month:=7; {seventh month of the year}
year:=1776; {Anno Domini}
end;
@y

@p procedure fix_date_and_time;
begin
web2hs_set_time_and_date(time,day,month,year);
time := time div 60; { TeX time is in minutes, not seconds }
end;
@z

% [262]
% Prevent warning, since text(p) is unsigned.
@x
else if (text(p)<0)or(text(p)>=str_ptr) then print_esc("NONEXISTENT.")
@y
else if text(p)>=str_ptr then print_esc("NONEXISTENT.")
@z

% [293]
% Prevent warning, since info(p) is unsigned.
@x
  if info(p)<0 then print_esc("BAD.")
@.BAD@>
  else @<Display the token $(|m|,|c|)$@>;
@y
  @<Display the token $(|m|,|c|)$@>;
@z


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [514]
% Fonts and input files are read from the file cache,
% so "areas" aren't needed.
@x
@d TEX_area=="TeXinputs:"
@.TeXinputs@>
@d TEX_font_area=="TeXfonts:"
@.TeXfonts@>
@y
@d TEX_area==""
@.TeXinputs@>
@d TEX_font_area==""
@.TeXfonts@>
@z

% [519]
% Null-terminate the file name size, in preparation of passing it to fopen.
@x
for k:=name_length+1 to file_name_size do name_of_file[k]:=' ';
@y
for k:=name_length+1 to file_name_size do name_of_file[k]:=chr(0);
@z

% [520]
% Change the format default location into a C-string.
% Also, the "area" part isn't needed.
@x
@d format_default_length=20 {length of the |TEX_format_default| string}
@d format_area_length=11 {length of its area part}
@y
@d format_default_length=9 {length of the |TEX_format_default| string}
@d format_area_length=0 {length of its area part}
@z

@x
@!TEX_format_default:packed array[1..format_default_length] of char;
@y
@!TEX_format_default:^char;
@z

% [521]
@x
TEX_format_default:='TeXformats:plain.fmt';
@y
TEX_format_default:='plain.fmt';
@z

% [523]
% Track the change of TEX_format_default into a C-string (indexed starting at 0)
% instead of an array (indexed starting at 1).
@x
for j:=1 to n do append_to_name(xord[TEX_format_default[j]]);
for j:=a to b do append_to_name(buffer[j]);
for j:=format_default_length-format_ext_length+1 to format_default_length do
  append_to_name(xord[TEX_format_default[j]]);
@y
for j:=0 to n-1 do append_to_name(xord[TEX_format_default[j]]);
for j:=a to b do append_to_name(buffer[j]);
for j:=format_default_length-format_ext_length to format_default_length-1 do
  append_to_name(xord[TEX_format_default[j]]);
@z

% [523]
% Null-terminate the file name, in preparation of passing it to fopen.
@x
for k:=name_length+1 to file_name_size do name_of_file[k]:=' ';
@y
for k:=name_length+1 to file_name_size do name_of_file[k]:=chr(0);
@z

% [524]
% If the input started with "&plain", or if explicit_format was set,
% load the format file.
% Search both the local dir and the cache, rather than trying the "area".
@x
@<Declare the function called |open_fmt_file|@>=
function open_fmt_file:boolean;
label found,exit;
var j:0..buf_size; {the first space after the format file name}
begin j:=loc;
if buffer[loc]="&" then
  begin incr(loc); j:=loc; buffer[last]:=" ";
  while buffer[j]<>" " do incr(j);
  pack_buffered_name(0,loc,j-1); {try first without the system file area}
  if w_open_in(fmt_file) then goto found;
  pack_buffered_name(format_area_length,loc,j-1);
    {now try the system format file area}
  if w_open_in(fmt_file) then goto found;
  wake_up_terminal;
  wterm_ln('Sorry, I can''t find that format;',' will try PLAIN.');
@.Sorry, I can't find...@>
  update_terminal;
  end;
  {now pull out all the stops: try for the system \.{plain} file}
pack_buffered_name(format_default_length-format_ext_length,1,0);
if not w_open_in(fmt_file) then
  begin wake_up_terminal;
  wterm_ln('I can''t find the PLAIN format file!');
@.I can't find PLAIN...@>
@.plain@>
  open_fmt_file:=false; return;
  end;
found:loc:=j; open_fmt_file:=true;
exit:end;
@y
@<Declare the function called |open_fmt_file|@>=
function open_fmt_file:boolean;
label found,exit;
var j:0..buf_size; {the first space after the format file name}
    k:integer;
begin 
j:=loc;
if buffer[loc]="&" then
  begin incr(loc); j:=loc; buffer[last]:=" ";
  while buffer[j]<>" " do incr(j);
  pack_buffered_name(0,loc,j-1); { append ".fmt" }
  end
else { format_ident=0, so we're not in initex, so explicit_format <> 0 }
  begin
  k:=0;
  repeat
    name_of_file[k+1] := user_options.explicit_format[k];
    incr(k);
    until user_options.explicit_format[k-1] = 0;
  end;
{try looking for the local or cached file }
name_length := web2hs_find_cached(name_of_file,name_of_file,file_name_size);
if (name_length>0) and w_open_in(fmt_file) then goto found;
wake_up_terminal;
wterm_ln('I can''t find the specified format file!');
@.I can't find PLAIN...@>
@.plain@>
open_fmt_file:=false; return;
found:loc:=j; open_fmt_file:=true;
exit:end;
@z


% [534]
% Make the months array into a C-string.
@x
@!months:packed array [1..36] of char; {abbreviations of month names}
@y
@!months:^char;
@z

% [536]
% Since months is now a C-string, it's zero-indexed.
@x
for k:=3*month-2 to 3*month do wlog(months[k]);
@y
for k:=3*month-3 to 3*month-1 do wlog(months[k]);
@z

% [537]
% Use the cache to find .tex files.
@x
  if a_open_in(cur_file) then goto done;
  if cur_area="" then
    begin pack_file_name(cur_name,TEX_area,cur_ext);
    if a_open_in(cur_file) then goto done;
    end;
@y
  name_length := web2hs_find_cached(name_of_file,name_of_file,file_name_size);
  if (name_length>0) and a_open_in(cur_file) then goto done;
@z


% [563]
% Use the cache to find .tfm files.
@x
if not b_open_in(tfm_file) then abort;
@y
name_length := web2hs_find_cached(name_of_file,name_of_file,file_name_size);
if (name_length <= 0) or (not b_open_in(tfm_file)) then abort;
@z

% [891]
% More "init"=>"ifinit" changes
@x
begin @!init if trie_not_ready then init_trie;@+tini@;@/
@y
begin @!ifinit if trie_not_ready then init_trie;@+endifinit@;@/
@z

% [1252]
% More "init"=>"ifinit" changes
@x
    begin @!init new_patterns; goto done;@;@+tini@/
@y
    begin @!ifinit new_patterns; goto done;@;@+endifinit@/
@z


% [1305]
% Use writeBinary to dump 32-bit structures/integers.
% Note that we use a separate writeInt32 function
% which can handle arbitrary integer expressions.
% (writeBinary itself must take in a reference.)
@x
@d dump_wd(#)==begin fmt_file^:=#; put(fmt_file);@+end
@d dump_int(#)==begin fmt_file^.int:=#; put(fmt_file);@+end
@d dump_hh(#)==begin fmt_file^.hh:=#; put(fmt_file);@+end
@d dump_qqqq(#)==begin fmt_file^.qqqq:=#; put(fmt_file);@+end
@y
@d dump_wd(#)==writeBinary(fmt_file, #,4)
@d dump_int(#)==writeInt32(fmt_file, #)
@d dump_hh(#)==writeBinary(fmt_file, #,4)
@d dump_qqqq(#)==writeBinary(fmt_file, #,4)
@z

% [1306]
% Use readBinary to read 32-bit structures/integers.
@x
@d undump_wd(#)==begin get(fmt_file); #:=fmt_file^;@+end
@d undump_int(#)==begin get(fmt_file); #:=fmt_file^.int;@+end
@d undump_hh(#)==begin get(fmt_file); #:=fmt_file^.hh;@+end
@d undump_qqqq(#)==begin get(fmt_file); #:=fmt_file^.qqqq;@+end
@y
@d undump_wd(#)==begin readBinary(fmt_file,#,4);@+end
@d undump_int(#)==begin readBinary(fmt_file,#,4);@+end
@d undump_hh(#)==begin readBinary(fmt_file,#,4);@+end
@d undump_qqqq(#)==begin readBinary(fmt_file,#,4);@+end
@z

% [1308]
% Use readBinary.
@x
x:=fmt_file^.int;
@y
readBinary(fmt_file,x,4);
@z

% [1325]
% More init=>ifinit changes.
@x
undump_size(0)(trie_size)('trie size')(j); @+init trie_max:=j;@+tini
@y
undump_size(0)(trie_size)('trie size')(j); @+ifinit trie_max:=j;@+endifinit
@z

@x
undump_size(0)(trie_op_size)('trie op size')(j); @+init trie_op_ptr:=j;@+tini
@y
undump_size(0)(trie_op_size)('trie op size')(j); @+ifinit trie_op_ptr:=j;@+endifinit
@z

@x
init for k:=0 to 255 do trie_used[k]:=min_quarterword;@+tini@;@/
@y
ifinit for k:=0 to 255 do trie_used[k]:=min_quarterword;@+endifinit@;@/
@z

@x
  begin undump(0)(k-1)(k); undump(1)(j)(x);@+init trie_used[k]:=qi(x);@+tini@;@/
@y
  begin undump(0)(k-1)(k); undump(1)(j)(x);@+ifinit trie_used[k]:=qi(x);@+endifinit@;@/
@z

@x
@!init trie_not_ready:=false @+tini
@y
@!ifinit trie_not_ready:=false @+endifinit
@z

% [1326]
% Temporary workaround: prevent the final eof() from failing when reading
% the .fmt file.
@x
dump_int(interaction); dump_int(format_ident); dump_int(69069);
@y
dump_int(interaction); dump_int(format_ident); dump_int(69069);dump_int(69069);
@z

% [1332]
% More init=>ifinit changes.
@x
@!init if not get_strings_started then goto final_end;
@y
@!ifinit if not get_strings_started then goto final_end;
@z

@x
tini@/
@y
endifinit@/
@z

@x
final_end: ready_already:=0;
@y
final_end: ready_already:=0; web2hs_return(history);
@z

% [1333]
% Ensure that there's an ending newline.
@x
    slow_print(log_name); print_char(".");
@y
    slow_print(log_name); print_char("."); print_ln;
@z

% [1335]
% More init=>ifinit changes.
@x
  begin @!init for c:=top_mark_code to split_bot_mark_code do
@y
  begin @!ifinit for c:=top_mark_code to split_bot_mark_code do
@z

@x
  store_fmt_file; return;@+tini@/
@y
  store_fmt_file; return;@+endifinit@/
@z

% [1379]
@x
@* \[54] System-dependent changes.
This section should be replaced, if necessary, by any special
modifications of the program
that are necessary to make \TeX\ work at a particular installation.
It is usually best to design your change file so that all changes to
previous sections preserve the section numbering; then everybody's version
will be consistent with the published program. More extensive changes,
which introduce new sections, can be inserted here; then only the index
itself will get a new section number.
@^system dependencies@>
@y
@* \[54] System-dependent changes.
We add a record type to manage the command-line arguments.
@<Types...@>=
@!options=record@!pool_path:^char;@+ { null-terminated path to tex.pool }
    @!explicit_format:^char; {either NULL, or null-termianted path }
    @!first_line:^ASCII_code; {null-terminated array; 
                            if nonempty, it's used as the first input line}
    @!interaction:batch_mode..error_stop_mode;
    @!end;

@ @<Global...@>=
@!user_options:options;
@z
