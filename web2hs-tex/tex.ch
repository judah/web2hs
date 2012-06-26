% [11]
% Make pool_name point to the local file "tex.pool".
@x
@!file_name_size=40; {file names shouldn't be longer than this}
@!pool_name='TeXformats:TEX.POOL                     ';
  {string of length |file_name_size|; tells where the string pool appears}
@y
@!file_name_size=200; {file names shouldn't be longer than this}
@!pool_name_size=8;
@!pool_name='tex.pool';
  {string of length |pool_name_size|; tells where the string pool appears}
@z

% [37]
% Don't call get(term_in) at the start of the program.  Otherwise, we would
% ignore the first character of input.
@x
  if not input_ln(term_in,true) then {this shouldn't happen}
@y
  if not input_ln(term_in,false) then {this shouldn't happen}
@z

% [51]
% Explicitly copy the pool_name C-string into the name_of_file buffer.
@x
name_of_file:=pool_name; {we needn't set |name_length|}
@y
for k:=1 to pool_name_size do name_of_file[k] := pool_name[k-1];
name_of_file[k+1] := chr(0); {we needn't set |name_length|}
web2hs_find_cached(name_of_file,name_of_file,file_name_size);
@z

% [514]
% Make the fonts area a unix-style folder.
@x
@d TEX_font_area=="TeXfonts:"
@y
@d TEX_font_area=="TeXfonts/"
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
