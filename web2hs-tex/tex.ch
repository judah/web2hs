% [4]
% Program arguments:
% pool_path: null-terminated path to tex.pool
% first_line: either NULL or a null-terminated C-string.
%     If nonempty/nonblank, it is used as the first line of input.
@x
program TEX; {all file names are defined dynamically}
@y
program TEX(pool_path, first_line); {all file names are defined dynamically}
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

% [32]
% Add global variables for the program arguments.
@x
@!term_in:alpha_file; {the terminal as an input file}
@y
@!term_in:alpha_file; {the terminal as an input file}
@!pool_path: ^char;
@!first_line:^ASCII_code;
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
if (first_line <> 0) then begin
  { Copy the first_line into the buffer }
  last:=first;
  while first_line[last-first]<> 0 do begin
     { Check for overflow }
    if last+1>=buf_size then begin
      write_ln(term_out, 'Buffer size exceeded!'); goto final_end;
    end;
    buffer[last]:=first_line[last-first];
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
  name_of_file[k+1] := pool_path[k];
  incr(k);
  until pool_path[k-1] = 0;
@z

% [514]
% Make the fonts area a unix-style folder.
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
@x
@!TEX_format_default:packed array[1..format_default_length] of char;
@y
@!TEX_format_default:^char;
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

% [532]
% Null-terminate the file name, in preparation of passing it to fopen.
@x
for k:=name_length+1 to file_name_size do name_of_file[k]:=' ';
@y
for k:=name_length+1 to file_name_size do name_of_file[k]:=chr(0);
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
% Note that immediately before this code, TeX calls a_open_in on the
% unexpanded name_of_file; this is how it tries to open local files.
@x
    if a_open_in(cur_file) then goto done;
@y
    name_length := web2hs_find_cached(name_of_file,name_of_file,file_name_size);
    if (name_length>0) and (a_open_in(cur_file)<>false) then goto done;
@z


% [563]
% Use the cache to find .tfm files.
@x
if not b_open_in(tfm_file) then abort;
@y
name_length := web2hs_find_cached(name_of_file,name_of_file,file_name_size);
if (name_length <= 0) or (not b_open_in(tfm_file)) then abort;
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

% [1326]
% Temporary workaround: prevent the final eof() from failing when reading
% the .fmt file.
@x
dump_int(interaction); dump_int(format_ident); dump_int(69069);
@y
dump_int(interaction); dump_int(format_ident); dump_int(69069);dump_int(69069);
@z

% [1333]
% Ensure that there's an ending newline.
@x
    slow_print(log_name); print_char(".");
@y
    slow_print(log_name); print_char("."); print_ln;
@z
