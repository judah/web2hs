{10:}{11:}{$C-,A+,D-}{[$C+,D+]}{:11}program BibTEX;
label 9998,9999{109:},31{:109}{146:},32,9932{:146};
const{14:}buf_size=1000;min_print_line=3;max_print_line=79;
aux_stack_size=20;max_bib_files=20;pool_size=65000;max_strings=4000;
max_cites=750;min_crossrefs=2;wiz_fn_space=3000;single_fn_space=100;
max_ent_ints=3000;max_ent_strs=3000;ent_str_size=100;glob_str_size=1000;
max_fields=17250;lit_stk_size=100;{:14}{333:}num_blt_in_fns=37;
{:333}type{22:}ASCII_code=0..127;{:22}{31:}lex_type=0..5;id_type=0..1;
{:31}{36:}alpha_file=packed file of char;
{:36}{42:}buf_pointer=0..buf_size;
buf_type=array[buf_pointer]of ASCII_code;
{:42}{49:}pool_pointer=0..pool_size;str_number=0..max_strings;
{:49}{64:}hash_loc=1..5000;hash_pointer=0..5000;str_ilk=0..14;
{:64}{73:}pds_loc=1..12;pds_len=0..12;
pds_type=packed array[pds_loc]of char;
{:73}{105:}aux_number=0..aux_stack_size;
{:105}{118:}bib_number=0..max_bib_files;
{:118}{130:}cite_number=0..max_cites;{:130}{160:}fn_class=0..8;
wiz_fn_loc=0..wiz_fn_space;int_ent_loc=0..max_ent_ints;
str_ent_loc=0..max_ent_strs;str_glob_loc=0..9;field_loc=0..max_fields;
hash_ptr2=0..5001;{:160}{291:}lit_stk_loc=0..lit_stk_size;stk_type=0..4;
{:291}{332:}blt_in_range=0..num_blt_in_fns;{:332}var{16:}bad:integer;
{:16}{19:}history:0..3;err_count:integer;
{:19}{24:}xord:array[char]of ASCII_code;xchr:array[ASCII_code]of char;
{:24}{30:}lex_class:array[ASCII_code]of lex_type;
id_class:array[ASCII_code]of id_type;
{:30}{34:}char_width:array[ASCII_code]of integer;string_width:integer;
{:34}{37:}name_of_file:packed array[1..40]of char;name_length:0..40;
name_ptr:0..41;{:37}{41:}buffer:buf_type;last:buf_pointer;
{:41}{43:}sv_buffer:buf_type;sv_ptr1:buf_pointer;sv_ptr2:buf_pointer;
tmp_ptr,tmp_end_ptr:integer;
{:43}{48:}str_pool:packed array[pool_pointer]of ASCII_code;
str_start:packed array[str_number]of pool_pointer;pool_ptr:pool_pointer;
str_ptr:str_number;str_num:str_number;p_ptr1,p_ptr2:pool_pointer;
{:48}{65:}hash_next:packed array[hash_loc]of hash_pointer;
hash_text:packed array[hash_loc]of str_number;
hash_ilk:packed array[hash_loc]of str_ilk;
ilk_info:packed array[hash_loc]of integer;hash_used:1..5001;
hash_found:boolean;dummy_loc:hash_loc;
{:65}{74:}s_aux_extension:str_number;s_log_extension:str_number;
s_bbl_extension:str_number;s_bst_extension:str_number;
s_bib_extension:str_number;s_bst_area:str_number;s_bib_area:str_number;
{:74}{76:}pre_def_loc:hash_loc;{:76}{78:}command_num:integer;
{:78}{80:}buf_ptr1:buf_pointer;buf_ptr2:buf_pointer;
{:80}{89:}scan_result:0..3;{:89}{91:}token_value:integer;
{:91}{97:}aux_name_length:0..41;
{:97}{104:}aux_file:array[aux_number]of alpha_file;
aux_list:array[aux_number]of str_number;aux_ptr:aux_number;
aux_ln_stack:array[aux_number]of integer;top_lev_str:str_number;
log_file:alpha_file;bbl_file:alpha_file;
{:104}{117:}bib_list:array[bib_number]of str_number;bib_ptr:bib_number;
num_bib_files:bib_number;bib_seen:boolean;
bib_file:array[bib_number]of alpha_file;{:117}{124:}bst_seen:boolean;
bst_str:str_number;bst_file:alpha_file;
{:124}{129:}cite_list:packed array[cite_number]of str_number;
cite_ptr:cite_number;entry_cite_ptr:cite_number;num_cites:cite_number;
old_num_cites:cite_number;citation_seen:boolean;cite_loc:hash_loc;
lc_cite_loc:hash_loc;lc_xcite_loc:hash_loc;cite_found:boolean;
all_entries:boolean;all_marker:cite_number;
{:129}{147:}bbl_line_num:integer;bst_line_num:integer;
{:147}{161:}fn_loc:hash_loc;wiz_loc:hash_loc;literal_loc:hash_loc;
macro_name_loc:hash_loc;macro_def_loc:hash_loc;
fn_type:packed array[hash_loc]of fn_class;wiz_def_ptr:wiz_fn_loc;
wiz_fn_ptr:wiz_fn_loc;
wiz_functions:packed array[wiz_fn_loc]of hash_ptr2;
int_ent_ptr:int_ent_loc;entry_ints:array[int_ent_loc]of integer;
num_ent_ints:int_ent_loc;str_ent_ptr:str_ent_loc;
entry_strs:array[str_ent_loc]of packed array[0..ent_str_size]of
ASCII_code;num_ent_strs:str_ent_loc;str_glb_ptr:0..10;
glb_str_ptr:array[str_glob_loc]of str_number;
global_strs:array[str_glob_loc]of array[0..glob_str_size]of ASCII_code;
glb_str_end:array[str_glob_loc]of 0..glob_str_size;num_glb_strs:0..10;
field_ptr:field_loc;field_parent_ptr,field_end_ptr:field_loc;
cite_parent_ptr,cite_xptr:cite_number;
field_info:packed array[field_loc]of str_number;num_fields:field_loc;
num_pre_defined_fields:field_loc;crossref_num:field_loc;
no_fields:boolean;{:161}{163:}entry_seen:boolean;read_seen:boolean;
read_performed:boolean;reading_completed:boolean;read_completed:boolean;
{:163}{195:}impl_fn_num:integer;{:195}{219:}bib_line_num:integer;
entry_type_loc:hash_loc;type_list:packed array[cite_number]of hash_ptr2;
type_exists:boolean;entry_exists:packed array[cite_number]of boolean;
store_entry:boolean;field_name_loc:hash_loc;field_val_loc:hash_loc;
store_field:boolean;store_token:boolean;right_outer_delim:ASCII_code;
right_str_delim:ASCII_code;at_bib_command:boolean;
cur_macro_loc:hash_loc;cite_info:packed array[cite_number]of str_number;
cite_hash_found:boolean;preamble_ptr:bib_number;
num_preamble_strings:bib_number;{:219}{247:}bib_brace_level:integer;
{:247}{290:}lit_stack:array[lit_stk_loc]of integer;
lit_stk_type:array[lit_stk_loc]of stk_type;lit_stk_ptr:lit_stk_loc;
cmd_str_ptr:str_number;ent_chr_ptr:0..ent_str_size;
glob_chr_ptr:0..glob_str_size;ex_buf:buf_type;ex_buf_ptr:buf_pointer;
ex_buf_length:buf_pointer;out_buf:buf_type;out_buf_ptr:buf_pointer;
out_buf_length:buf_pointer;mess_with_entries:boolean;
sort_cite_ptr:cite_number;sort_key_num:str_ent_loc;brace_level:integer;
{:290}{331:}b_equals:hash_loc;b_greater_than:hash_loc;
b_less_than:hash_loc;b_plus:hash_loc;b_minus:hash_loc;
b_concatenate:hash_loc;b_gets:hash_loc;b_add_period:hash_loc;
b_call_type:hash_loc;b_change_case:hash_loc;b_chr_to_int:hash_loc;
b_cite:hash_loc;b_duplicate:hash_loc;b_empty:hash_loc;
b_format_name:hash_loc;b_if:hash_loc;b_int_to_chr:hash_loc;
b_int_to_str:hash_loc;b_missing:hash_loc;b_newline:hash_loc;
b_num_names:hash_loc;b_pop:hash_loc;b_preamble:hash_loc;
b_purify:hash_loc;b_quote:hash_loc;b_skip:hash_loc;b_stack:hash_loc;
b_substring:hash_loc;b_swap:hash_loc;b_text_length:hash_loc;
b_text_prefix:hash_loc;b_top_stack:hash_loc;b_type:hash_loc;
b_warning:hash_loc;b_while:hash_loc;b_width:hash_loc;b_write:hash_loc;
b_default:hash_loc;{blt_in_loc:array[blt_in_range]of hash_loc;
execution_count:array[blt_in_range]of integer;total_ex_count:integer;
blt_in_ptr:blt_in_range;}{:331}{337:}s_null:str_number;
s_default:str_number;s_t:str_number;s_l:str_number;s_u:str_number;
s_preamble:array[bib_number]of str_number;
{:337}{344:}pop_lit1,pop_lit2,pop_lit3:integer;
pop_typ1,pop_typ2,pop_typ3:stk_type;sp_ptr:pool_pointer;
sp_xptr1,sp_xptr2:pool_pointer;sp_end:pool_pointer;
sp_length,sp2_length:pool_pointer;sp_brace_level:integer;
ex_buf_xptr,ex_buf_yptr:buf_pointer;control_seq_loc:hash_loc;
preceding_white:boolean;and_found:boolean;num_names:integer;
name_bf_ptr:buf_pointer;name_bf_xptr,name_bf_yptr:buf_pointer;
nm_brace_level:integer;name_tok:packed array[buf_pointer]of buf_pointer;
name_sep_char:packed array[buf_pointer]of ASCII_code;
num_tokens:buf_pointer;token_starting:boolean;alpha_found:boolean;
double_letter,end_of_group,to_be_written:boolean;
first_start:buf_pointer;first_end:buf_pointer;last_end:buf_pointer;
von_start:buf_pointer;von_end:buf_pointer;jr_end:buf_pointer;
cur_token,last_token:buf_pointer;use_default:boolean;
num_commas:buf_pointer;comma1,comma2:buf_pointer;
num_text_chars:buf_pointer;{:344}{365:}conversion_type:0..3;
prev_colon:boolean;{:365}{12:}{3:}procedure print_a_newline;
begin write_ln(log_file);write_ln(tty);end;
{:3}{18:}procedure mark_warning;
begin if(history=1)then err_count:=err_count+1 else if(history=0)then
begin history:=1;err_count:=1;end;end;procedure mark_error;
begin if(history<2)then begin history:=2;err_count:=1;
end else err_count:=err_count+1;end;procedure mark_fatal;
begin history:=3;end;{:18}{44:}procedure print_overflow;
begin begin write(log_file,'Sorry---you''ve exceeded BibTeX''s ');
write(tty,'Sorry---you''ve exceeded BibTeX''s ');end;mark_fatal;end;
{:44}{45:}procedure print_confusion;
begin begin write_ln(log_file,'---this can''t happen');
write_ln(tty,'---this can''t happen');end;
begin write_ln(log_file,'*Please notify the BibTeX maintainer*');
write_ln(tty,'*Please notify the BibTeX maintainer*');end;mark_fatal;
end;{:45}{46:}procedure buffer_overflow;begin begin print_overflow;
begin write_ln(log_file,'buffer size ',buf_size:0);
write_ln(tty,'buffer size ',buf_size:0);end;goto 9998;end;end;
{:46}{47:}function input_ln(var f:alpha_file):boolean;label 15;
begin last:=0;
if(eof(f))then input_ln:=false else begin while(not eoln(f))do begin if(
last>=buf_size)then buffer_overflow;buffer[last]:=xord[f^];get(f);
last:=last+1;end;get(f);
while(last>0)do if(lex_class[buffer[last-1]]=1)then last:=last-1 else
goto 15;15:input_ln:=true;end;end;
{:47}{51:}procedure out_pool_str(var f:alpha_file;s:str_number);
var i:pool_pointer;
begin if((s<0)or(s>=str_ptr+3)or(s>=max_strings))then begin begin write(
log_file,'Illegal string number:',s:0);
write(tty,'Illegal string number:',s:0);end;print_confusion;goto 9998;
end;
for i:=str_start[s]to str_start[s+1]-1 do write(f,xchr[str_pool[i]]);
end;procedure print_a_pool_str(s:str_number);begin out_pool_str(tty,s);
out_pool_str(log_file,s);end;{:51}{53:}procedure pool_overflow;
begin begin print_overflow;
begin write_ln(log_file,'pool size ',pool_size:0);
write_ln(tty,'pool size ',pool_size:0);end;goto 9998;end;end;
{:53}{59:}procedure file_nm_size_overflow;begin begin print_overflow;
begin write_ln(log_file,'file name size ',40:0);
write_ln(tty,'file name size ',40:0);end;goto 9998;end;end;
{:59}{82:}procedure out_token(var f:alpha_file);var i:buf_pointer;
begin i:=buf_ptr1;while(i<buf_ptr2)do begin write(f,xchr[buffer[i]]);
i:=i+1;end;end;procedure print_a_token;begin out_token(tty);
out_token(log_file);end;{:82}{95:}procedure print_bad_input_line;
var bf_ptr:buf_pointer;begin begin write(log_file,' : ');
write(tty,' : ');end;bf_ptr:=0;
while(bf_ptr<buf_ptr2)do begin if(lex_class[buffer[bf_ptr]]=1)then begin
write(log_file,xchr[32]);write(tty,xchr[32]);
end else begin write(log_file,xchr[buffer[bf_ptr]]);
write(tty,xchr[buffer[bf_ptr]]);end;bf_ptr:=bf_ptr+1;end;
print_a_newline;begin write(log_file,' : ');write(tty,' : ');end;
bf_ptr:=0;while(bf_ptr<buf_ptr2)do begin begin write(log_file,xchr[32]);
write(tty,xchr[32]);end;bf_ptr:=bf_ptr+1;end;bf_ptr:=buf_ptr2;
while(bf_ptr<last)do begin if(lex_class[buffer[bf_ptr]]=1)then begin
write(log_file,xchr[32]);write(tty,xchr[32]);
end else begin write(log_file,xchr[buffer[bf_ptr]]);
write(tty,xchr[buffer[bf_ptr]]);end;bf_ptr:=bf_ptr+1;end;
print_a_newline;bf_ptr:=0;
while((bf_ptr<buf_ptr2)and(lex_class[buffer[bf_ptr]]=1))do bf_ptr:=
bf_ptr+1;if(bf_ptr=buf_ptr2)then begin write_ln(log_file,
'(Error may have been on previous line)');
write_ln(tty,'(Error may have been on previous line)');end;mark_error;
end;{:95}{96:}procedure print_skipping_whatever_remains;
begin begin write(log_file,'I''m skipping whatever remains of this ');
write(tty,'I''m skipping whatever remains of this ');end;end;
{:96}{98:}procedure sam_too_long_file_name_print;
begin write(tty,'File name `');name_ptr:=1;
while(name_ptr<=aux_name_length)do begin write(tty,name_of_file[name_ptr
]);name_ptr:=name_ptr+1;end;write_ln(tty,''' is too long');end;
{:98}{99:}procedure sam_wrong_file_name_print;
begin write(tty,'I couldn''t open file name `');name_ptr:=1;
while(name_ptr<=name_length)do begin write(tty,name_of_file[name_ptr]);
name_ptr:=name_ptr+1;end;write_ln(tty,'''');end;
{:99}{108:}procedure print_aux_name;
begin print_a_pool_str(aux_list[aux_ptr]);print_a_newline;end;
{:108}{111:}procedure aux_err_print;
begin begin write(log_file,'---line ',aux_ln_stack[aux_ptr]:0,
' of file ');write(tty,'---line ',aux_ln_stack[aux_ptr]:0,' of file ');
end;print_aux_name;print_bad_input_line;print_skipping_whatever_remains;
begin write_ln(log_file,'command');write_ln(tty,'command');end end;
{:111}{112:}procedure aux_err_illegal_another_print(cmd_num:integer);
begin begin write(log_file,'Illegal, another \bib');
write(tty,'Illegal, another \bib');end;
case(cmd_num)of 0:begin write(log_file,'data');write(tty,'data');end;
1:begin write(log_file,'style');write(tty,'style');end;
others:begin begin write(log_file,'Illegal auxiliary-file command');
write(tty,'Illegal auxiliary-file command');end;print_confusion;
goto 9998;end end;begin write(log_file,' command');
write(tty,' command');end;end;
{:112}{113:}procedure aux_err_no_right_brace_print;
begin begin write(log_file,'No "',xchr[125],'"');
write(tty,'No "',xchr[125],'"');end;end;
{:113}{114:}procedure aux_err_stuff_after_right_brace_print;
begin begin write(log_file,'Stuff after "',xchr[125],'"');
write(tty,'Stuff after "',xchr[125],'"');end;end;
{:114}{115:}procedure aux_err_white_space_in_argument_print;
begin begin write(log_file,'White space in argument');
write(tty,'White space in argument');end;end;
{:115}{121:}procedure print_bib_name;
begin print_a_pool_str(bib_list[bib_ptr]);
print_a_pool_str(s_bib_extension);print_a_newline;end;
{:121}{128:}procedure print_bst_name;begin print_a_pool_str(bst_str);
print_a_pool_str(s_bst_extension);print_a_newline;end;
{:128}{137:}procedure hash_cite_confusion;
begin begin begin write(log_file,'Cite hash error');
write(tty,'Cite hash error');end;print_confusion;goto 9998;end;end;
{:137}{138:}procedure check_cite_overflow(last_cite:cite_number);
begin if(last_cite=max_cites)then begin print_a_pool_str(hash_text[
cite_loc]);begin write_ln(log_file,' is the key:');
write_ln(tty,' is the key:');end;begin print_overflow;
begin write_ln(log_file,'number of cite keys ',max_cites:0);
write_ln(tty,'number of cite keys ',max_cites:0);end;goto 9998;end;end;
end;{:138}{144:}procedure aux_end1_err_print;
begin begin write(log_file,'I found no ');write(tty,'I found no ');end;
end;procedure aux_end2_err_print;
begin begin write(log_file,'---while reading file ');
write(tty,'---while reading file ');end;print_aux_name;mark_error;end;
{:144}{148:}procedure bst_ln_num_print;
begin begin write(log_file,'--line ',bst_line_num:0,' of file ');
write(tty,'--line ',bst_line_num:0,' of file ');end;print_bst_name;end;
{:148}{149:}procedure bst_err_print_and_look_for_blank_line;
begin begin write(log_file,'-');write(tty,'-');end;bst_ln_num_print;
print_bad_input_line;
while(last<>0)do if(not input_ln(bst_file))then goto 32 else
bst_line_num:=bst_line_num+1;buf_ptr2:=last;end;
{:149}{150:}procedure bst_warn_print;begin bst_ln_num_print;
mark_warning;end;{:150}{153:}procedure eat_bst_print;
begin begin write(log_file,'Illegal end of style file in command: ');
write(tty,'Illegal end of style file in command: ');end;end;
{:153}{157:}procedure unknwn_function_class_confusion;
begin begin begin write(log_file,'Unknown function class');
write(tty,'Unknown function class');end;print_confusion;goto 9998;end;
end;{:157}{158:}procedure print_fn_class(fn_loc:hash_loc);
begin case(fn_type[fn_loc])of 0:begin write(log_file,'built-in');
write(tty,'built-in');end;1:begin write(log_file,'wizard-defined');
write(tty,'wizard-defined');end;
2:begin write(log_file,'integer-literal');write(tty,'integer-literal');
end;3:begin write(log_file,'string-literal');
write(tty,'string-literal');end;4:begin write(log_file,'field');
write(tty,'field');end;5:begin write(log_file,'integer-entry-variable');
write(tty,'integer-entry-variable');end;
6:begin write(log_file,'string-entry-variable');
write(tty,'string-entry-variable');end;
7:begin write(log_file,'integer-global-variable');
write(tty,'integer-global-variable');end;
8:begin write(log_file,'string-global-variable');
write(tty,'string-global-variable');end;
others:unknwn_function_class_confusion end;end;
{:158}{159:}{procedure trace_pr_fn_class(fn_loc:hash_loc);
begin case(fn_type[fn_loc])of 0:begin write(log_file,'built-in');end;
1:begin write(log_file,'wizard-defined');end;
2:begin write(log_file,'integer-literal');end;
3:begin write(log_file,'string-literal');end;
4:begin write(log_file,'field');end;
5:begin write(log_file,'integer-entry-variable');end;
6:begin write(log_file,'string-entry-variable');end;
7:begin write(log_file,'integer-global-variable');end;
8:begin write(log_file,'string-global-variable');end;
others:unknwn_function_class_confusion end;end;}
{:159}{165:}procedure id_scanning_confusion;
begin begin begin write(log_file,'Identifier scanning error');
write(tty,'Identifier scanning error');end;print_confusion;goto 9998;
end;end;{:165}{166:}procedure bst_id_print;
begin if(scan_result=0)then begin write(log_file,'"',xchr[buffer[
buf_ptr2]],'" begins identifier, command: ');
write(tty,'"',xchr[buffer[buf_ptr2]],'" begins identifier, command: ');
end else if(scan_result=2)then begin write(log_file,'"',xchr[buffer[
buf_ptr2]],'" immediately follows identifier, command: ');
write(tty,'"',xchr[buffer[buf_ptr2]],
'" immediately follows identifier, command: ');
end else id_scanning_confusion;end;
{:166}{167:}procedure bst_left_brace_print;
begin begin write(log_file,'"',xchr[123],'" is missing in command: ');
write(tty,'"',xchr[123],'" is missing in command: ');end;end;
{:167}{168:}procedure bst_right_brace_print;
begin begin write(log_file,'"',xchr[125],'" is missing in command: ');
write(tty,'"',xchr[125],'" is missing in command: ');end;end;
{:168}{169:}procedure already_seen_function_print(seen_fn_loc:hash_loc);
label 10;begin print_a_pool_str(hash_text[seen_fn_loc]);
begin write(log_file,' is already a type "');
write(tty,' is already a type "');end;print_fn_class(seen_fn_loc);
begin write_ln(log_file,'" function name');
write_ln(tty,'" function name');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;10:end;
{:169}{188:}procedure singl_fn_overflow;begin begin print_overflow;
begin write_ln(log_file,'single function space ',single_fn_space:0);
write_ln(tty,'single function space ',single_fn_space:0);end;goto 9998;
end;end;{:188}{220:}procedure bib_ln_num_print;
begin begin write(log_file,'--line ',bib_line_num:0,' of file ');
write(tty,'--line ',bib_line_num:0,' of file ');end;print_bib_name;end;
{:220}{221:}procedure bib_err_print;begin begin write(log_file,'-');
write(tty,'-');end;bib_ln_num_print;print_bad_input_line;
print_skipping_whatever_remains;
if(at_bib_command)then begin write_ln(log_file,'command');
write_ln(tty,'command');end else begin write_ln(log_file,'entry');
write_ln(tty,'entry');end;end;{:221}{222:}procedure bib_warn_print;
begin bib_ln_num_print;mark_warning;end;
{:222}{226:}procedure check_field_overflow(total_fields:integer);
begin if(total_fields>max_fields)then begin begin write_ln(log_file,
total_fields:0,' fields:');write_ln(tty,total_fields:0,' fields:');end;
begin print_overflow;
begin write_ln(log_file,'total number of fields ',max_fields:0);
write_ln(tty,'total number of fields ',max_fields:0);end;goto 9998;end;
end;end;{:226}{229:}procedure eat_bib_print;label 10;
begin begin begin write(log_file,'Illegal end of database file');
write(tty,'Illegal end of database file');end;bib_err_print;goto 10;end;
10:end;
{:229}{230:}procedure bib_one_of_two_print(char1,char2:ASCII_code);
label 10;
begin begin begin write(log_file,'I was expecting a `',xchr[char1],
''' or a `',xchr[char2],'''');
write(tty,'I was expecting a `',xchr[char1],''' or a `',xchr[char2],''''
);end;bib_err_print;goto 10;end;10:end;
{:230}{231:}procedure bib_equals_sign_print;label 10;
begin begin begin write(log_file,'I was expecting an "',xchr[61],'"');
write(tty,'I was expecting an "',xchr[61],'"');end;bib_err_print;
goto 10;end;10:end;{:231}{232:}procedure bib_unbalanced_braces_print;
label 10;begin begin begin write(log_file,'Unbalanced braces');
write(tty,'Unbalanced braces');end;bib_err_print;goto 10;end;10:end;
{:232}{233:}procedure bib_field_too_long_print;label 10;
begin begin begin write(log_file,'Your field is more than ',buf_size:0,
' characters');
write(tty,'Your field is more than ',buf_size:0,' characters');end;
bib_err_print;goto 10;end;10:end;{:233}{234:}procedure macro_warn_print;
begin begin write(log_file,'Warning--string name "');
write(tty,'Warning--string name "');end;print_a_token;
begin write(log_file,'" is ');write(tty,'" is ');end;end;
{:234}{235:}procedure bib_id_print;
begin if(scan_result=0)then begin write(log_file,'You''re missing ');
write(tty,'You''re missing ');
end else if(scan_result=2)then begin write(log_file,'"',xchr[buffer[
buf_ptr2]],'" immediately follows ');
write(tty,'"',xchr[buffer[buf_ptr2]],'" immediately follows ');
end else id_scanning_confusion;end;
{:235}{240:}procedure bib_cmd_confusion;
begin begin begin write(log_file,'Unknown database-file command');
write(tty,'Unknown database-file command');end;print_confusion;
goto 9998;end;end;{:240}{271:}procedure cite_key_disappeared_confusion;
begin begin begin write(log_file,'A cite key disappeared');
write(tty,'A cite key disappeared');end;print_confusion;goto 9998;end;
end;{:271}{280:}procedure bad_cross_reference_print(s:str_number);
begin begin write(log_file,'--entry "');write(tty,'--entry "');end;
print_a_pool_str(cite_list[cite_ptr]);begin write_ln(log_file,'"');
write_ln(tty,'"');end;begin write(log_file,'refers to entry "');
write(tty,'refers to entry "');end;print_a_pool_str(s);end;
{:280}{281:}procedure nonexistent_cross_reference_error;
begin begin write(log_file,'A bad cross reference-');
write(tty,'A bad cross reference-');end;
bad_cross_reference_print(field_info[field_ptr]);
begin write_ln(log_file,'", which doesn''t exist');
write_ln(tty,'", which doesn''t exist');end;mark_error;end;
{:281}{284:}procedure print_missing_entry(s:str_number);
begin begin write(log_file,
'Warning--I didn''t find a database entry for "');
write(tty,'Warning--I didn''t find a database entry for "');end;
print_a_pool_str(s);begin write_ln(log_file,'"');write_ln(tty,'"');end;
mark_warning;end;{:284}{293:}procedure bst_ex_warn_print;
begin if(mess_with_entries)then begin begin write(log_file,' for entry '
);write(tty,' for entry ');end;print_a_pool_str(cite_list[cite_ptr]);
end;print_a_newline;begin write(log_file,'while executing-');
write(tty,'while executing-');end;bst_ln_num_print;mark_error;end;
{:293}{294:}procedure bst_mild_ex_warn_print;
begin if(mess_with_entries)then begin begin write(log_file,' for entry '
);write(tty,' for entry ');end;print_a_pool_str(cite_list[cite_ptr]);
end;print_a_newline;begin begin write(log_file,'while executing');
write(tty,'while executing');end;bst_warn_print;end;end;
{:294}{295:}procedure bst_cant_mess_with_entries_print;
begin begin begin write(log_file,'You can''t mess with entries here');
write(tty,'You can''t mess with entries here');end;bst_ex_warn_print;
end;end;{:295}{310:}procedure illegl_literal_confusion;
begin begin begin write(log_file,'Illegal literal type');
write(tty,'Illegal literal type');end;print_confusion;goto 9998;end;end;
procedure unknwn_literal_confusion;
begin begin begin write(log_file,'Unknown literal type');
write(tty,'Unknown literal type');end;print_confusion;goto 9998;end;end;
{:310}{311:}procedure print_stk_lit(stk_lt:integer;stk_tp:stk_type);
begin case(stk_tp)of 0:begin write(log_file,stk_lt:0,
' is an integer literal');write(tty,stk_lt:0,' is an integer literal');
end;1:begin begin write(log_file,'"');write(tty,'"');end;
print_a_pool_str(stk_lt);begin write(log_file,'" is a string literal');
write(tty,'" is a string literal');end;end;
2:begin begin write(log_file,'`');write(tty,'`');end;
print_a_pool_str(hash_text[stk_lt]);
begin write(log_file,''' is a function literal');
write(tty,''' is a function literal');end;end;
3:begin begin write(log_file,'`');write(tty,'`');end;
print_a_pool_str(stk_lt);begin write(log_file,''' is a missing field');
write(tty,''' is a missing field');end;end;4:illegl_literal_confusion;
others:unknwn_literal_confusion end;end;
{:311}{313:}procedure print_lit(stk_lt:integer;stk_tp:stk_type);
begin case(stk_tp)of 0:begin write_ln(log_file,stk_lt:0);
write_ln(tty,stk_lt:0);end;1:begin print_a_pool_str(stk_lt);
print_a_newline;end;2:begin print_a_pool_str(hash_text[stk_lt]);
print_a_newline;end;3:begin print_a_pool_str(stk_lt);print_a_newline;
end;4:illegl_literal_confusion;others:unknwn_literal_confusion end;end;
{:313}{321:}procedure output_bbl_line;label 15,10;
begin if(out_buf_length<>0)then begin while(out_buf_length>0)do if(
lex_class[out_buf[out_buf_length-1]]=1)then out_buf_length:=
out_buf_length-1 else goto 15;15:if(out_buf_length=0)then goto 10;
out_buf_ptr:=0;
while(out_buf_ptr<out_buf_length)do begin write(bbl_file,xchr[out_buf[
out_buf_ptr]]);out_buf_ptr:=out_buf_ptr+1;end;end;write_ln(bbl_file);
bbl_line_num:=bbl_line_num+1;out_buf_length:=0;10:end;
{:321}{356:}procedure bst_1print_string_size_exceeded;
begin begin write(log_file,'Warning--you''ve exceeded ');
write(tty,'Warning--you''ve exceeded ');end;end;
procedure bst_2print_string_size_exceeded;
begin begin write(log_file,'-string-size,');write(tty,'-string-size,');
end;bst_mild_ex_warn_print;
begin write_ln(log_file,'*Please notify the bibstyle designer*');
write_ln(tty,'*Please notify the bibstyle designer*');end;end;
{:356}{368:}procedure braces_unbalanced_complaint(pop_lit_var:str_number
);begin begin write(log_file,'Warning--"');write(tty,'Warning--"');end;
print_a_pool_str(pop_lit_var);
begin begin write(log_file,'" isn''t a brace-balanced string');
write(tty,'" isn''t a brace-balanced string');end;
bst_mild_ex_warn_print;end;end;
{:368}{373:}procedure case_conversion_confusion;
begin begin begin write(log_file,'Unknown type of case conversion');
write(tty,'Unknown type of case conversion');end;print_confusion;
goto 9998;end;end;{:373}{456:}procedure trace_and_stat_printing;
begin{[457:]begin if(num_bib_files=1)then begin write_ln(log_file,
'The 1 database file is');
end else begin write_ln(log_file,'The ',num_bib_files:0,
' database files are');end;
if(num_bib_files=0)then begin write_ln(log_file,'   undefined');
end else begin bib_ptr:=0;
while(bib_ptr<num_bib_files)do begin begin write(log_file,'   ');end;
begin out_pool_str(log_file,bib_list[bib_ptr]);end;
begin out_pool_str(log_file,s_bib_extension);end;
begin write_ln(log_file);end;bib_ptr:=bib_ptr+1;end;end;
begin write(log_file,'The style file is ');end;
if(bst_str=0)then begin write_ln(log_file,'undefined');
end else begin begin out_pool_str(log_file,bst_str);end;
begin out_pool_str(log_file,s_bst_extension);end;
begin write_ln(log_file);end;end;end[:457];
[458:]begin if(all_entries)then begin write(log_file,'all_marker=',
all_marker:0,', ');end;
if(read_performed)then begin write_ln(log_file,'old_num_cites=',
old_num_cites:0);end else begin write_ln(log_file);end;
begin write(log_file,'The ',num_cites:0);end;
if(num_cites=1)then begin write_ln(log_file,' entry:');
end else begin write_ln(log_file,' entries:');end;
if(num_cites=0)then begin write_ln(log_file,'   undefined');
end else begin sort_cite_ptr:=0;
while(sort_cite_ptr<num_cites)do begin if(not read_completed)then
cite_ptr:=sort_cite_ptr else cite_ptr:=cite_info[sort_cite_ptr];
begin out_pool_str(log_file,cite_list[cite_ptr]);end;
if(read_performed)then[459:]begin begin write(log_file,', entry-type ');
end;
if(type_list[cite_ptr]=5001)then 5001:begin write(log_file,'unknown');
end else if(type_list[cite_ptr]=0)then begin write(log_file,
'--- no type found');
end else begin out_pool_str(log_file,hash_text[type_list[cite_ptr]]);
end;begin write_ln(log_file,', has entry strings');end;
[460:]begin if(num_ent_strs=0)then begin write_ln(log_file,
'    undefined');
end else if(not read_completed)then begin write_ln(log_file,
'    uninitialized');end else begin str_ent_ptr:=cite_ptr*num_ent_strs;
while(str_ent_ptr<(cite_ptr+1)*num_ent_strs)do begin ent_chr_ptr:=0;
begin write(log_file,'    "');end;
while(entry_strs[str_ent_ptr][ent_chr_ptr]<>127)do begin begin write(
log_file,xchr[entry_strs[str_ent_ptr][ent_chr_ptr]]);end;
ent_chr_ptr:=ent_chr_ptr+1;end;begin write_ln(log_file,'"');end;
str_ent_ptr:=str_ent_ptr+1;end;end;end[:460];
begin write(log_file,'  has entry integers');end;
[461:]begin if(num_ent_ints=0)then begin write(log_file,' undefined');
end else if(not read_completed)then begin write(log_file,
' uninitialized');end else begin int_ent_ptr:=cite_ptr*num_ent_ints;
while(int_ent_ptr<(cite_ptr+1)*num_ent_ints)do begin begin write(
log_file,' ',entry_ints[int_ent_ptr]:0);end;int_ent_ptr:=int_ent_ptr+1;
end;end;begin write_ln(log_file);end;end[:461];
begin write_ln(log_file,'  and has fields');end;
[462:]begin if(not read_performed)then begin write_ln(log_file,
'    uninitialized');end else begin field_ptr:=cite_ptr*num_fields;
field_end_ptr:=field_ptr+num_fields;no_fields:=true;
while(field_ptr<field_end_ptr)do begin if(field_info[field_ptr]<>0)then
begin begin write(log_file,'    "');end;
begin out_pool_str(log_file,field_info[field_ptr]);end;
begin write_ln(log_file,'"');end;no_fields:=false;end;
field_ptr:=field_ptr+1;end;
if(no_fields)then begin write_ln(log_file,'    missing');end;end;
end[:462];end[:459]else begin write_ln(log_file);end;
sort_cite_ptr:=sort_cite_ptr+1;end;end;end[:458];
[463:]begin begin write_ln(log_file,'The wiz-defined functions are');
end;if(wiz_def_ptr=0)then begin write_ln(log_file,'   nonexistent');
end else begin wiz_fn_ptr:=0;
while(wiz_fn_ptr<wiz_def_ptr)do begin if(wiz_functions[wiz_fn_ptr]=5001)
then begin write_ln(log_file,wiz_fn_ptr:0,'--end-of-def--');
end else if(wiz_functions[wiz_fn_ptr]=0)then begin write(log_file,
wiz_fn_ptr:0,'  quote_next_function    ');
end else begin begin write(log_file,wiz_fn_ptr:0,'  `');end;
begin out_pool_str(log_file,hash_text[wiz_functions[wiz_fn_ptr]]);end;
begin write_ln(log_file,'''');end;end;wiz_fn_ptr:=wiz_fn_ptr+1;end;end;
end[:463];[464:]begin begin write_ln(log_file,'The string pool is');end;
str_num:=1;
while(str_num<str_ptr)do begin begin write(log_file,str_num:4,str_start[
str_num]:6,' "');end;begin out_pool_str(log_file,str_num);end;
begin write_ln(log_file,'"');end;str_num:=str_num+1;end;end[:464];}
{[465:]begin begin write(log_file,'You''ve used ',num_cites:0);end;
if(num_cites=1)then begin write_ln(log_file,' entry,');
end else begin write_ln(log_file,' entries,');end;
begin write_ln(log_file,'            ',wiz_def_ptr:0,
' wiz_defined-function locations,');end;
begin write_ln(log_file,'            ',str_ptr:0,' strings with ',
str_start[str_ptr]:0,' characters,');end;blt_in_ptr:=0;
total_ex_count:=0;
while(blt_in_ptr<num_blt_in_fns)do begin total_ex_count:=total_ex_count+
execution_count[blt_in_ptr];blt_in_ptr:=blt_in_ptr+1;end;
begin write_ln(log_file,'and the built_in function-call counts, ',
total_ex_count:0,' in all, are:');end;blt_in_ptr:=0;
while(blt_in_ptr<num_blt_in_fns)do begin begin out_pool_str(log_file,
hash_text[blt_in_loc[blt_in_ptr]]);end;
begin write_ln(log_file,' -- ',execution_count[blt_in_ptr]:0);end;
blt_in_ptr:=blt_in_ptr+1;end;end[:465];}end;
{:456}{38:}function erstat(var f:file):integer;extern;
function a_open_in(var f:alpha_file):boolean;
begin reset(f,name_of_file,'/O');a_open_in:=erstat(f)=0;end;
function a_open_out(var f:alpha_file):boolean;
begin rewrite(f,name_of_file,'/O');a_open_out:=erstat(f)=0;end;
{:38}{39:}procedure a_close(var f:alpha_file);begin close(f);end;
{:39}{58:}procedure start_name(file_name:str_number);
var p_ptr:pool_pointer;
begin if((str_start[file_name+1]-str_start[file_name])>40)then begin
begin write(log_file,'File=');write(tty,'File=');end;
print_a_pool_str(file_name);begin write_ln(log_file,',');
write_ln(tty,',');end;file_nm_size_overflow;end;name_ptr:=1;
p_ptr:=str_start[file_name];
while(p_ptr<str_start[file_name+1])do begin name_of_file[name_ptr]:=chr(
str_pool[p_ptr]);name_ptr:=name_ptr+1;p_ptr:=p_ptr+1;end;
name_length:=(str_start[file_name+1]-str_start[file_name]);end;
{:58}{60:}procedure add_extension(ext:str_number);
var p_ptr:pool_pointer;
begin if(name_length+(str_start[ext+1]-str_start[ext])>40)then begin
begin write(log_file,'File=',name_of_file,', extension=');
write(tty,'File=',name_of_file,', extension=');end;
print_a_pool_str(ext);begin write_ln(log_file,',');write_ln(tty,',');
end;file_nm_size_overflow;end;name_ptr:=name_length+1;
p_ptr:=str_start[ext];
while(p_ptr<str_start[ext+1])do begin name_of_file[name_ptr]:=chr(
str_pool[p_ptr]);name_ptr:=name_ptr+1;p_ptr:=p_ptr+1;end;
name_length:=name_length+(str_start[ext+1]-str_start[ext]);
name_ptr:=name_length+1;
while(name_ptr<=40)do begin name_of_file[name_ptr]:=' ';
name_ptr:=name_ptr+1;end;end;
{:60}{61:}procedure add_area(area:str_number);var p_ptr:pool_pointer;
begin if(name_length+(str_start[area+1]-str_start[area])>40)then begin
begin write(log_file,'File=');write(tty,'File=');end;
print_a_pool_str(area);begin write(log_file,name_of_file,',');
write(tty,name_of_file,',');end;file_nm_size_overflow;end;
name_ptr:=name_length;
while(name_ptr>0)do begin name_of_file[name_ptr+(str_start[area+1]-
str_start[area])]:=name_of_file[name_ptr];name_ptr:=name_ptr-1;end;
name_ptr:=1;p_ptr:=str_start[area];
while(p_ptr<str_start[area+1])do begin name_of_file[name_ptr]:=chr(
str_pool[p_ptr]);name_ptr:=name_ptr+1;p_ptr:=p_ptr+1;end;
name_length:=name_length+(str_start[area+1]-str_start[area]);end;
{:61}{54:}function make_string:str_number;
begin if(str_ptr=max_strings)then begin print_overflow;
begin write_ln(log_file,'number of strings ',max_strings:0);
write_ln(tty,'number of strings ',max_strings:0);end;goto 9998;end;
str_ptr:=str_ptr+1;str_start[str_ptr]:=pool_ptr;make_string:=str_ptr-1;
end;{:54}{56:}function str_eq_buf(s:str_number;var buf:buf_type;
bf_ptr,len:buf_pointer):boolean;label 10;var i:buf_pointer;
j:pool_pointer;
begin if((str_start[s+1]-str_start[s])<>len)then begin str_eq_buf:=false
;goto 10;end;i:=bf_ptr;j:=str_start[s];
while(j<str_start[s+1])do begin if(str_pool[j]<>buf[i])then begin
str_eq_buf:=false;goto 10;end;i:=i+1;j:=j+1;end;str_eq_buf:=true;10:end;
{:56}{57:}function str_eq_str(s1,s2:str_number):boolean;label 10;
begin if((str_start[s1+1]-str_start[s1])<>(str_start[s2+1]-str_start[s2]
))then begin str_eq_str:=false;goto 10;end;p_ptr1:=str_start[s1];
p_ptr2:=str_start[s2];
while(p_ptr1<str_start[s1+1])do begin if(str_pool[p_ptr1]<>str_pool[
p_ptr2])then begin str_eq_str:=false;goto 10;end;p_ptr1:=p_ptr1+1;
p_ptr2:=p_ptr2+1;end;str_eq_str:=true;10:end;
{:57}{62:}procedure lower_case(var buf:buf_type;bf_ptr,len:buf_pointer);
var i:buf_pointer;
begin if(len>0)then for i:=bf_ptr to bf_ptr+len-1 do if((buf[i]>=65)and(
buf[i]<=90))then buf[i]:=buf[i]+32;end;
{:62}{63:}procedure upper_case(var buf:buf_type;bf_ptr,len:buf_pointer);
var i:buf_pointer;
begin if(len>0)then for i:=bf_ptr to bf_ptr+len-1 do if((buf[i]>=97)and(
buf[i]<=122))then buf[i]:=buf[i]-32;end;
{:63}{68:}function str_lookup(var buf:buf_type;j,l:buf_pointer;
ilk:str_ilk;insert_it:boolean):hash_loc;label 40,45;var h:0..8631;
p:hash_loc;k:buf_pointer;old_string:boolean;str_num:str_number;
begin{69:}begin h:=0;k:=j;while(k<j+l)do begin h:=h+h+buf[k];
while(h>=4253)do h:=h-4253;k:=k+1;end;end{:69};p:=h+1;hash_found:=false;
old_string:=false;
while true do begin{70:}begin if(hash_text[p]>0)then if(str_eq_buf(
hash_text[p],buf,j,l))then if(hash_ilk[p]=ilk)then begin hash_found:=
true;goto 40;end else begin old_string:=true;str_num:=hash_text[p];end;
end{:70};if(hash_next[p]=0)then begin if(not insert_it)then goto 45;
{71:}begin if(hash_text[p]>0)then begin repeat if((hash_used=1))then
begin print_overflow;begin write_ln(log_file,'hash size ',5000:0);
write_ln(tty,'hash size ',5000:0);end;goto 9998;end;
hash_used:=hash_used-1;until(hash_text[hash_used]=0);
hash_next[p]:=hash_used;p:=hash_used;end;
if(old_string)then hash_text[p]:=str_num else begin begin if(pool_ptr+l>
pool_size)then pool_overflow;end;k:=j;
while(k<j+l)do begin begin str_pool[pool_ptr]:=buf[k];
pool_ptr:=pool_ptr+1;end;k:=k+1;end;hash_text[p]:=make_string;end;
hash_ilk[p]:=ilk;end{:71};goto 40;end;p:=hash_next[p];end;45:;
40:str_lookup:=p;end;{:68}{77:}procedure pre_define(pds:pds_type;
len:pds_len;ilk:str_ilk);var i:pds_len;
begin for i:=1 to len do buffer[i]:=xord[pds[i]];
pre_def_loc:=str_lookup(buffer,1,len,ilk,true);end;
{:77}{198:}procedure int_to_ASCII(int:integer;var int_buf:buf_type;
int_begin:buf_pointer;var int_end:buf_pointer);
var int_ptr,int_xptr:buf_pointer;int_tmp_val:ASCII_code;
begin int_ptr:=int_begin;
if(int<0)then begin begin if(int_ptr=buf_size)then buffer_overflow;
int_buf[int_ptr]:=45;int_ptr:=int_ptr+1;end;int:=-int;end;
int_xptr:=int_ptr;repeat begin if(int_ptr=buf_size)then buffer_overflow;
int_buf[int_ptr]:=48+(int mod 10);int_ptr:=int_ptr+1;end;
int:=int div 10;until(int=0);int_end:=int_ptr;int_ptr:=int_ptr-1;
while(int_xptr<int_ptr)do begin int_tmp_val:=int_buf[int_xptr];
int_buf[int_xptr]:=int_buf[int_ptr];int_buf[int_ptr]:=int_tmp_val;
int_ptr:=int_ptr-1;int_xptr:=int_xptr+1;end end;
{:198}{265:}procedure add_database_cite(var new_cite:cite_number);
begin check_cite_overflow(new_cite);
check_field_overflow(num_fields*new_cite);
cite_list[new_cite]:=hash_text[cite_loc];ilk_info[cite_loc]:=new_cite;
ilk_info[lc_cite_loc]:=cite_loc;new_cite:=new_cite+1;end;
{:265}{278:}function find_cite_locs_for_this_cite_key(cite_str:
str_number):boolean;begin ex_buf_ptr:=0;tmp_ptr:=str_start[cite_str];
tmp_end_ptr:=str_start[cite_str+1];
while(tmp_ptr<tmp_end_ptr)do begin ex_buf[ex_buf_ptr]:=str_pool[tmp_ptr]
;ex_buf_ptr:=ex_buf_ptr+1;tmp_ptr:=tmp_ptr+1;end;
cite_loc:=str_lookup(ex_buf,0,(str_start[cite_str+1]-str_start[cite_str]
),9,false);cite_hash_found:=hash_found;
lower_case(ex_buf,0,(str_start[cite_str+1]-str_start[cite_str]));
lc_cite_loc:=str_lookup(ex_buf,0,(str_start[cite_str+1]-str_start[
cite_str]),10,false);
if(hash_found)then find_cite_locs_for_this_cite_key:=true else
find_cite_locs_for_this_cite_key:=false;end;
{:278}{300:}procedure swap(swap1,swap2:cite_number);
var innocent_bystander:cite_number;
begin innocent_bystander:=cite_info[swap2];
cite_info[swap2]:=cite_info[swap1];cite_info[swap1]:=innocent_bystander;
end;{:300}{301:}function less_than(arg1,arg2:cite_number):boolean;
label 10;var char_ptr:0..ent_str_size;ptr1,ptr2:str_ent_loc;
char1,char2:ASCII_code;begin ptr1:=arg1*num_ent_strs+sort_key_num;
ptr2:=arg2*num_ent_strs+sort_key_num;char_ptr:=0;
while true do begin char1:=entry_strs[ptr1][char_ptr];
char2:=entry_strs[ptr2][char_ptr];
if(char1=127)then if(char2=127)then if(arg1<arg2)then begin less_than:=
true;goto 10;end else if(arg1>arg2)then begin less_than:=false;goto 10;
end else begin begin write(log_file,'Duplicate sort key');
write(tty,'Duplicate sort key');end;print_confusion;goto 9998;
end else begin less_than:=true;goto 10;
end else if(char2=127)then begin less_than:=false;goto 10;
end else if(char1<char2)then begin less_than:=true;goto 10;
end else if(char1>char2)then begin less_than:=false;goto 10;end;
char_ptr:=char_ptr+1;end;10:end;
{:301}{303:}procedure quick_sort(left_end,right_end:cite_number);
label 24;var left,right:cite_number;insert_ptr:cite_number;
middle:cite_number;partition:cite_number;
begin{begin write_ln(log_file,'Sorting ',left_end:0,' through ',
right_end:0);end;}
if(right_end-left_end<10)then{304:}begin for insert_ptr:=left_end+1 to
right_end do begin for right:=insert_ptr downto left_end+1 do begin if(
less_than(cite_info[right-1],cite_info[right]))then goto 24;
swap(right-1,right);end;24:end;
end{:304}else begin{305:}begin left:=left_end+4;
middle:=(left_end+right_end)div 2;right:=right_end-4;
if(less_than(cite_info[left],cite_info[middle]))then if(less_than(
cite_info[middle],cite_info[right]))then swap(left_end,middle)else if(
less_than(cite_info[left],cite_info[right]))then swap(left_end,right)
else swap(left_end,left)else if(less_than(cite_info[right],cite_info[
middle]))then swap(left_end,middle)else if(less_than(cite_info[right],
cite_info[left]))then swap(left_end,right)else swap(left_end,left);
end{:305};{306:}begin partition:=cite_info[left_end];left:=left_end+1;
right:=right_end;
repeat while(less_than(cite_info[left],partition))do left:=left+1;
while(less_than(partition,cite_info[right]))do right:=right-1;
if(left<right)then begin swap(left,right);left:=left+1;right:=right-1;
end;until(left=right+1);swap(left_end,right);
quick_sort(left_end,right-1);quick_sort(left,right_end);end{:306};end;
end;{:303}{335:}procedure build_in(pds:pds_type;len:pds_len;
var fn_hash_loc:hash_loc;blt_in_num:blt_in_range);
begin pre_define(pds,len,11);fn_hash_loc:=pre_def_loc;
fn_type[fn_hash_loc]:=0;ilk_info[fn_hash_loc]:=blt_in_num;
{blt_in_loc[blt_in_num]:=fn_hash_loc;execution_count[blt_in_num]:=0;}
end;{:335}{336:}procedure pre_def_certain_strings;
begin{75:}pre_define('.aux        ',4,7);
s_aux_extension:=hash_text[pre_def_loc];pre_define('.bbl        ',4,7);
s_bbl_extension:=hash_text[pre_def_loc];pre_define('.blg        ',4,7);
s_log_extension:=hash_text[pre_def_loc];pre_define('.bst        ',4,7);
s_bst_extension:=hash_text[pre_def_loc];pre_define('.bib        ',4,7);
s_bib_extension:=hash_text[pre_def_loc];pre_define('texinputs:  ',10,8);
s_bst_area:=hash_text[pre_def_loc];pre_define('texbib:     ',7,8);
s_bib_area:=hash_text[pre_def_loc];
{:75}{79:}pre_define('\citation   ',9,2);ilk_info[pre_def_loc]:=2;
pre_define('\bibdata    ',8,2);ilk_info[pre_def_loc]:=0;
pre_define('\bibstyle   ',9,2);ilk_info[pre_def_loc]:=1;
pre_define('\@input     ',7,2);ilk_info[pre_def_loc]:=3;
pre_define('entry       ',5,4);ilk_info[pre_def_loc]:=0;
pre_define('execute     ',7,4);ilk_info[pre_def_loc]:=1;
pre_define('function    ',8,4);ilk_info[pre_def_loc]:=2;
pre_define('integers    ',8,4);ilk_info[pre_def_loc]:=3;
pre_define('iterate     ',7,4);ilk_info[pre_def_loc]:=4;
pre_define('macro       ',5,4);ilk_info[pre_def_loc]:=5;
pre_define('read        ',4,4);ilk_info[pre_def_loc]:=6;
pre_define('reverse     ',7,4);ilk_info[pre_def_loc]:=7;
pre_define('sort        ',4,4);ilk_info[pre_def_loc]:=8;
pre_define('strings     ',7,4);ilk_info[pre_def_loc]:=9;
pre_define('comment     ',7,12);ilk_info[pre_def_loc]:=0;
pre_define('preamble    ',8,12);ilk_info[pre_def_loc]:=1;
pre_define('string      ',6,12);ilk_info[pre_def_loc]:=2;
{:79}{334:}build_in('=           ',1,b_equals,0);
build_in('>           ',1,b_greater_than,1);
build_in('<           ',1,b_less_than,2);
build_in('+           ',1,b_plus,3);
build_in('-           ',1,b_minus,4);
build_in('*           ',1,b_concatenate,5);
build_in(':=          ',2,b_gets,6);
build_in('add.period$ ',11,b_add_period,7);
build_in('call.type$  ',10,b_call_type,8);
build_in('change.case$',12,b_change_case,9);
build_in('chr.to.int$ ',11,b_chr_to_int,10);
build_in('cite$       ',5,b_cite,11);
build_in('duplicate$  ',10,b_duplicate,12);
build_in('empty$      ',6,b_empty,13);
build_in('format.name$',12,b_format_name,14);
build_in('if$         ',3,b_if,15);
build_in('int.to.chr$ ',11,b_int_to_chr,16);
build_in('int.to.str$ ',11,b_int_to_str,17);
build_in('missing$    ',8,b_missing,18);
build_in('newline$    ',8,b_newline,19);
build_in('num.names$  ',10,b_num_names,20);
build_in('pop$        ',4,b_pop,21);
build_in('preamble$   ',9,b_preamble,22);
build_in('purify$     ',7,b_purify,23);
build_in('quote$      ',6,b_quote,24);
build_in('skip$       ',5,b_skip,25);
build_in('stack$      ',6,b_stack,26);
build_in('substring$  ',10,b_substring,27);
build_in('swap$       ',5,b_swap,28);
build_in('text.length$',12,b_text_length,29);
build_in('text.prefix$',12,b_text_prefix,30);
build_in('top$        ',4,b_top_stack,31);
build_in('type$       ',5,b_type,32);
build_in('warning$    ',8,b_warning,33);
build_in('width$      ',6,b_width,35);
build_in('while$      ',6,b_while,34);
build_in('width$      ',6,b_width,35);
build_in('write$      ',6,b_write,36);
{:334}{339:}pre_define('            ',0,0);
s_null:=hash_text[pre_def_loc];fn_type[pre_def_loc]:=3;
pre_define('default.type',12,0);s_default:=hash_text[pre_def_loc];
fn_type[pre_def_loc]:=3;b_default:=b_skip;preamble_ptr:=0;
pre_define('i           ',1,14);ilk_info[pre_def_loc]:=0;
pre_define('j           ',1,14);ilk_info[pre_def_loc]:=1;
pre_define('oe          ',2,14);ilk_info[pre_def_loc]:=2;
pre_define('OE          ',2,14);ilk_info[pre_def_loc]:=3;
pre_define('ae          ',2,14);ilk_info[pre_def_loc]:=4;
pre_define('AE          ',2,14);ilk_info[pre_def_loc]:=5;
pre_define('aa          ',2,14);ilk_info[pre_def_loc]:=6;
pre_define('AA          ',2,14);ilk_info[pre_def_loc]:=7;
pre_define('o           ',1,14);ilk_info[pre_def_loc]:=8;
pre_define('O           ',1,14);ilk_info[pre_def_loc]:=9;
pre_define('l           ',1,14);ilk_info[pre_def_loc]:=10;
pre_define('L           ',1,14);ilk_info[pre_def_loc]:=11;
pre_define('ss          ',2,14);ilk_info[pre_def_loc]:=12;
{:339}{340:}pre_define('crossref    ',8,11);fn_type[pre_def_loc]:=4;
ilk_info[pre_def_loc]:=num_fields;crossref_num:=num_fields;
num_fields:=num_fields+1;num_pre_defined_fields:=num_fields;
pre_define('sort.key$   ',9,11);fn_type[pre_def_loc]:=6;
ilk_info[pre_def_loc]:=num_ent_strs;sort_key_num:=num_ent_strs;
num_ent_strs:=num_ent_strs+1;pre_define('entry.max$  ',10,11);
fn_type[pre_def_loc]:=7;ilk_info[pre_def_loc]:=ent_str_size;
pre_define('global.max$ ',11,11);fn_type[pre_def_loc]:=7;
ilk_info[pre_def_loc]:=glob_str_size;{:340}end;
{:336}{83:}function scan1(char1:ASCII_code):boolean;
begin buf_ptr1:=buf_ptr2;
while((buffer[buf_ptr2]<>char1)and(buf_ptr2<last))do buf_ptr2:=buf_ptr2
+1;if(buf_ptr2<last)then scan1:=true else scan1:=false;end;
{:83}{84:}function scan1_white(char1:ASCII_code):boolean;
begin buf_ptr1:=buf_ptr2;
while((lex_class[buffer[buf_ptr2]]<>1)and(buffer[buf_ptr2]<>char1)and(
buf_ptr2<last))do buf_ptr2:=buf_ptr2+1;
if(buf_ptr2<last)then scan1_white:=true else scan1_white:=false;end;
{:84}{85:}function scan2(char1,char2:ASCII_code):boolean;
begin buf_ptr1:=buf_ptr2;
while((buffer[buf_ptr2]<>char1)and(buffer[buf_ptr2]<>char2)and(buf_ptr2<
last))do buf_ptr2:=buf_ptr2+1;
if(buf_ptr2<last)then scan2:=true else scan2:=false;end;
{:85}{86:}function scan2_white(char1,char2:ASCII_code):boolean;
begin buf_ptr1:=buf_ptr2;
while((buffer[buf_ptr2]<>char1)and(buffer[buf_ptr2]<>char2)and(lex_class
[buffer[buf_ptr2]]<>1)and(buf_ptr2<last))do buf_ptr2:=buf_ptr2+1;
if(buf_ptr2<last)then scan2_white:=true else scan2_white:=false;end;
{:86}{87:}function scan3(char1,char2,char3:ASCII_code):boolean;
begin buf_ptr1:=buf_ptr2;
while((buffer[buf_ptr2]<>char1)and(buffer[buf_ptr2]<>char2)and(buffer[
buf_ptr2]<>char3)and(buf_ptr2<last))do buf_ptr2:=buf_ptr2+1;
if(buf_ptr2<last)then scan3:=true else scan3:=false;end;
{:87}{88:}function scan_alpha:boolean;begin buf_ptr1:=buf_ptr2;
while((lex_class[buffer[buf_ptr2]]=2)and(buf_ptr2<last))do buf_ptr2:=
buf_ptr2+1;
if((buf_ptr2-buf_ptr1)=0)then scan_alpha:=false else scan_alpha:=true;
end;{:88}{90:}procedure scan_identifier(char1,char2,char3:ASCII_code);
begin buf_ptr1:=buf_ptr2;
if(lex_class[buffer[buf_ptr2]]<>3)then while((id_class[buffer[buf_ptr2]]
=1)and(buf_ptr2<last))do buf_ptr2:=buf_ptr2+1;
if((buf_ptr2-buf_ptr1)=0)then scan_result:=0 else if((lex_class[buffer[
buf_ptr2]]=1)or(buf_ptr2=last))then scan_result:=3 else if((buffer[
buf_ptr2]=char1)or(buffer[buf_ptr2]=char2)or(buffer[buf_ptr2]=char3))
then scan_result:=1 else scan_result:=2;end;
{:90}{92:}function scan_nonneg_integer:boolean;begin buf_ptr1:=buf_ptr2;
token_value:=0;
while((lex_class[buffer[buf_ptr2]]=3)and(buf_ptr2<last))do begin
token_value:=token_value*10+(buffer[buf_ptr2]-48);buf_ptr2:=buf_ptr2+1;
end;if((buf_ptr2-buf_ptr1)=0)then scan_nonneg_integer:=false else
scan_nonneg_integer:=true;end;{:92}{93:}function scan_integer:boolean;
var sign_length:0..1;begin buf_ptr1:=buf_ptr2;
if(buffer[buf_ptr2]=45)then begin sign_length:=1;buf_ptr2:=buf_ptr2+1;
end else sign_length:=0;token_value:=0;
while((lex_class[buffer[buf_ptr2]]=3)and(buf_ptr2<last))do begin
token_value:=token_value*10+(buffer[buf_ptr2]-48);buf_ptr2:=buf_ptr2+1;
end;if((sign_length=1))then token_value:=-token_value;
if((buf_ptr2-buf_ptr1)=sign_length)then scan_integer:=false else
scan_integer:=true;end;{:93}{94:}function scan_white_space:boolean;
begin while((lex_class[buffer[buf_ptr2]]=1)and(buf_ptr2<last))do
buf_ptr2:=buf_ptr2+1;
if(buf_ptr2<last)then scan_white_space:=true else scan_white_space:=
false;end;{:94}{152:}function eat_bst_white_space:boolean;label 10;
begin while true do begin if(scan_white_space)then if(buffer[buf_ptr2]<>
37)then begin eat_bst_white_space:=true;goto 10;end;
if(not input_ln(bst_file))then begin eat_bst_white_space:=false;goto 10;
end;bst_line_num:=bst_line_num+1;buf_ptr2:=0;end;10:end;
{:152}{183:}procedure skip_token_print;begin begin write(log_file,'-');
write(tty,'-');end;bst_ln_num_print;mark_error;
if(scan2_white(125,37))then;end;
{:183}{184:}procedure print_recursion_illegal;
begin{begin write_ln(log_file);end;}
begin write_ln(log_file,'Curse you, wizard, before you recurse me:');
write_ln(tty,'Curse you, wizard, before you recurse me:');end;
begin write(log_file,'function ');write(tty,'function ');end;
print_a_token;
begin write_ln(log_file,' is illegal in its own definition');
write_ln(tty,' is illegal in its own definition');end;
{print_recursion_illegal;}skip_token_print;end;
{:184}{185:}procedure skp_token_unknown_function_print;
begin print_a_token;begin write(log_file,' is an unknown function');
write(tty,' is an unknown function');end;skip_token_print;end;
{:185}{186:}procedure skip_illegal_stuff_after_token_print;
begin begin write(log_file,'"',xchr[buffer[buf_ptr2]],
'" can''t follow a literal');
write(tty,'"',xchr[buffer[buf_ptr2]],'" can''t follow a literal');end;
skip_token_print;end;
{:186}{187:}procedure scan_fn_def(fn_hash_loc:hash_loc);label 25,10;
type fn_def_loc=0..single_fn_space;
var singl_function:packed array[fn_def_loc]of hash_ptr2;
single_ptr:fn_def_loc;copy_ptr:fn_def_loc;end_of_num:buf_pointer;
impl_fn_loc:hash_loc;
begin begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'function');write(tty,'function');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
single_ptr:=0;
while(buffer[buf_ptr2]<>125)do begin{189:}case(buffer[buf_ptr2])of 35:
{190:}begin buf_ptr2:=buf_ptr2+1;
if(not scan_integer)then begin begin write(log_file,
'Illegal integer in integer literal');
write(tty,'Illegal integer in integer literal');end;skip_token_print;
goto 25;end;{begin write(log_file,'#');end;begin out_token(log_file);
end;
begin write_ln(log_file,' is an integer literal with value ',token_value
:0);end;}
literal_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),1,true);
if(not hash_found)then begin fn_type[literal_loc]:=2;
ilk_info[literal_loc]:=token_value;end;
if((lex_class[buffer[buf_ptr2]]<>1)and(buf_ptr2<last)and(buffer[buf_ptr2
]<>125)and(buffer[buf_ptr2]<>37))then begin
skip_illegal_stuff_after_token_print;goto 25;end;
begin singl_function[single_ptr]:=literal_loc;
if(single_ptr=single_fn_space)then singl_fn_overflow;
single_ptr:=single_ptr+1;end;end{:190};
34:{191:}begin buf_ptr2:=buf_ptr2+1;
if(not scan1(34))then begin begin write(log_file,'No `',xchr[34],
''' to end string literal');
write(tty,'No `',xchr[34],''' to end string literal');end;
skip_token_print;goto 25;end;{begin write(log_file,'"');end;
begin out_token(log_file);end;begin write(log_file,'"');end;
begin write_ln(log_file,' is a string literal');end;}
literal_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),0,true);
fn_type[literal_loc]:=3;buf_ptr2:=buf_ptr2+1;
if((lex_class[buffer[buf_ptr2]]<>1)and(buf_ptr2<last)and(buffer[buf_ptr2
]<>125)and(buffer[buf_ptr2]<>37))then begin
skip_illegal_stuff_after_token_print;goto 25;end;
begin singl_function[single_ptr]:=literal_loc;
if(single_ptr=single_fn_space)then singl_fn_overflow;
single_ptr:=single_ptr+1;end;end{:191};
39:{192:}begin buf_ptr2:=buf_ptr2+1;if(scan2_white(125,37))then;
{begin write(log_file,'''');end;begin out_token(log_file);end;
begin write(log_file,' is a quoted function ');end;}
lower_case(buffer,buf_ptr1,(buf_ptr2-buf_ptr1));
fn_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),11,false);
if(not hash_found)then begin skp_token_unknown_function_print;goto 25;
end else{193:}begin if(fn_loc=wiz_loc)then begin print_recursion_illegal
;goto 25;end else begin{begin write(log_file,'of type ');end;
trace_pr_fn_class(fn_loc);begin write_ln(log_file);end;}
begin singl_function[single_ptr]:=0;
if(single_ptr=single_fn_space)then singl_fn_overflow;
single_ptr:=single_ptr+1;end;begin singl_function[single_ptr]:=fn_loc;
if(single_ptr=single_fn_space)then singl_fn_overflow;
single_ptr:=single_ptr+1;end;end end{:193};end{:192};
123:{194:}begin ex_buf[0]:=39;
int_to_ASCII(impl_fn_num,ex_buf,1,end_of_num);
impl_fn_loc:=str_lookup(ex_buf,0,end_of_num,11,true);
if(hash_found)then begin begin write(log_file,
'Already encountered implicit function');
write(tty,'Already encountered implicit function');end;print_confusion;
goto 9998;end;{begin out_pool_str(log_file,hash_text[impl_fn_loc]);end;
begin write_ln(log_file,' is an implicit function');end;}
impl_fn_num:=impl_fn_num+1;fn_type[impl_fn_loc]:=1;
begin singl_function[single_ptr]:=0;
if(single_ptr=single_fn_space)then singl_fn_overflow;
single_ptr:=single_ptr+1;end;
begin singl_function[single_ptr]:=impl_fn_loc;
if(single_ptr=single_fn_space)then singl_fn_overflow;
single_ptr:=single_ptr+1;end;buf_ptr2:=buf_ptr2+1;
scan_fn_def(impl_fn_loc);end{:194};
others:{199:}begin if(scan2_white(125,37))then;
{begin out_token(log_file);end;begin write(log_file,' is a function ');
end;}lower_case(buffer,buf_ptr1,(buf_ptr2-buf_ptr1));
fn_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),11,false);
if(not hash_found)then begin skp_token_unknown_function_print;goto 25;
end else if(fn_loc=wiz_loc)then begin print_recursion_illegal;goto 25;
end else begin{begin write(log_file,'of type ');end;
trace_pr_fn_class(fn_loc);begin write_ln(log_file);end;}
begin singl_function[single_ptr]:=fn_loc;
if(single_ptr=single_fn_space)then singl_fn_overflow;
single_ptr:=single_ptr+1;end;end;end{:199}end{:189};
25:begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'function');write(tty,'function');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;end;
{200:}begin begin singl_function[single_ptr]:=5001;
if(single_ptr=single_fn_space)then singl_fn_overflow;
single_ptr:=single_ptr+1;end;
if(single_ptr+wiz_def_ptr>wiz_fn_space)then begin begin write(log_file,
single_ptr+wiz_def_ptr:0,': ');write(tty,single_ptr+wiz_def_ptr:0,': ');
end;begin print_overflow;
begin write_ln(log_file,'wizard-defined function space ',wiz_fn_space:0)
;write_ln(tty,'wizard-defined function space ',wiz_fn_space:0);end;
goto 9998;end;end;ilk_info[fn_hash_loc]:=wiz_def_ptr;copy_ptr:=0;
while(copy_ptr<single_ptr)do begin wiz_functions[wiz_def_ptr]:=
singl_function[copy_ptr];copy_ptr:=copy_ptr+1;
wiz_def_ptr:=wiz_def_ptr+1;end;end{:200};buf_ptr2:=buf_ptr2+1;10:end;
{:187}{228:}function eat_bib_white_space:boolean;label 10;
begin while(not scan_white_space)do begin if(not input_ln(bib_file[
bib_ptr]))then begin eat_bib_white_space:=false;goto 10;end;
bib_line_num:=bib_line_num+1;buf_ptr2:=0;end;eat_bib_white_space:=true;
10:end;{:228}{248:}{252:}function compress_bib_white:boolean;label 10;
begin compress_bib_white:=false;
begin if(ex_buf_ptr=buf_size)then begin bib_field_too_long_print;
goto 10;end else begin ex_buf[ex_buf_ptr]:=32;ex_buf_ptr:=ex_buf_ptr+1;
end;end;
while(not scan_white_space)do begin if(not input_ln(bib_file[bib_ptr]))
then begin eat_bib_print;goto 10;end;bib_line_num:=bib_line_num+1;
buf_ptr2:=0;end;compress_bib_white:=true;10:end;
{:252}{253:}function scan_balanced_braces:boolean;label 15,10;
begin scan_balanced_braces:=false;buf_ptr2:=buf_ptr2+1;
begin if((lex_class[buffer[buf_ptr2]]=1)or(buf_ptr2=last))then if(not
compress_bib_white)then goto 10;end;
if(ex_buf_ptr>1)then if(ex_buf[ex_buf_ptr-1]=32)then if(ex_buf[
ex_buf_ptr-2]=32)then ex_buf_ptr:=ex_buf_ptr-1;bib_brace_level:=0;
if(store_field)then{256:}begin while(buffer[buf_ptr2]<>right_str_delim)
do case(buffer[buf_ptr2])of 123:begin bib_brace_level:=bib_brace_level+1
;begin if(ex_buf_ptr=buf_size)then begin bib_field_too_long_print;
goto 10;end else begin ex_buf[ex_buf_ptr]:=123;ex_buf_ptr:=ex_buf_ptr+1;
end;end;buf_ptr2:=buf_ptr2+1;
begin if((lex_class[buffer[buf_ptr2]]=1)or(buf_ptr2=last))then if(not
compress_bib_white)then goto 10;end;
{257:}begin while true do case(buffer[buf_ptr2])of 125:begin
bib_brace_level:=bib_brace_level-1;
begin if(ex_buf_ptr=buf_size)then begin bib_field_too_long_print;
goto 10;end else begin ex_buf[ex_buf_ptr]:=125;ex_buf_ptr:=ex_buf_ptr+1;
end;end;buf_ptr2:=buf_ptr2+1;
begin if((lex_class[buffer[buf_ptr2]]=1)or(buf_ptr2=last))then if(not
compress_bib_white)then goto 10;end;if(bib_brace_level=0)then goto 15;
end;123:begin bib_brace_level:=bib_brace_level+1;
begin if(ex_buf_ptr=buf_size)then begin bib_field_too_long_print;
goto 10;end else begin ex_buf[ex_buf_ptr]:=123;ex_buf_ptr:=ex_buf_ptr+1;
end;end;buf_ptr2:=buf_ptr2+1;
begin if((lex_class[buffer[buf_ptr2]]=1)or(buf_ptr2=last))then if(not
compress_bib_white)then goto 10;end;end;
others:begin begin if(ex_buf_ptr=buf_size)then begin
bib_field_too_long_print;goto 10;
end else begin ex_buf[ex_buf_ptr]:=buffer[buf_ptr2];
ex_buf_ptr:=ex_buf_ptr+1;end;end;buf_ptr2:=buf_ptr2+1;
begin if((lex_class[buffer[buf_ptr2]]=1)or(buf_ptr2=last))then if(not
compress_bib_white)then goto 10;end;end end;15:end{:257};end;
125:begin bib_unbalanced_braces_print;goto 10;end;
others:begin begin if(ex_buf_ptr=buf_size)then begin
bib_field_too_long_print;goto 10;
end else begin ex_buf[ex_buf_ptr]:=buffer[buf_ptr2];
ex_buf_ptr:=ex_buf_ptr+1;end;end;buf_ptr2:=buf_ptr2+1;
begin if((lex_class[buffer[buf_ptr2]]=1)or(buf_ptr2=last))then if(not
compress_bib_white)then goto 10;end;end end;
end{:256}else{254:}begin while(buffer[buf_ptr2]<>right_str_delim)do if(
buffer[buf_ptr2]=123)then begin bib_brace_level:=bib_brace_level+1;
buf_ptr2:=buf_ptr2+1;
begin if(not eat_bib_white_space)then begin eat_bib_print;goto 10;end;
end;
while(bib_brace_level>0)do{255:}begin if(buffer[buf_ptr2]=125)then begin
bib_brace_level:=bib_brace_level-1;buf_ptr2:=buf_ptr2+1;
begin if(not eat_bib_white_space)then begin eat_bib_print;goto 10;end;
end;end else if(buffer[buf_ptr2]=123)then begin bib_brace_level:=
bib_brace_level+1;buf_ptr2:=buf_ptr2+1;
begin if(not eat_bib_white_space)then begin eat_bib_print;goto 10;end;
end;end else begin buf_ptr2:=buf_ptr2+1;
if(not scan2(125,123))then begin if(not eat_bib_white_space)then begin
eat_bib_print;goto 10;end;end;end end{:255};
end else if(buffer[buf_ptr2]=125)then begin bib_unbalanced_braces_print;
goto 10;end else begin buf_ptr2:=buf_ptr2+1;
if(not scan3(right_str_delim,123,125))then begin if(not
eat_bib_white_space)then begin eat_bib_print;goto 10;end;end;
end end{:254};buf_ptr2:=buf_ptr2+1;scan_balanced_braces:=true;10:end;
{:253}{250:}function scan_a_field_token_and_eat_white:boolean;label 10;
begin scan_a_field_token_and_eat_white:=false;
case(buffer[buf_ptr2])of 123:begin right_str_delim:=125;
if(not scan_balanced_braces)then goto 10;end;
34:begin right_str_delim:=34;if(not scan_balanced_braces)then goto 10;
end;
48,49,50,51,52,53,54,55,56,57:{258:}begin if(not scan_nonneg_integer)
then begin begin write(log_file,'A digit disappeared');
write(tty,'A digit disappeared');end;print_confusion;goto 9998;end;
if(store_field)then begin tmp_ptr:=buf_ptr1;
while(tmp_ptr<buf_ptr2)do begin begin if(ex_buf_ptr=buf_size)then begin
bib_field_too_long_print;goto 10;
end else begin ex_buf[ex_buf_ptr]:=buffer[tmp_ptr];
ex_buf_ptr:=ex_buf_ptr+1;end;end;tmp_ptr:=tmp_ptr+1;end;end;end{:258};
others:{259:}begin scan_identifier(44,right_outer_delim,35);
begin if((scan_result=3)or(scan_result=1))then else begin bib_id_print;
begin begin write(log_file,'a field part');write(tty,'a field part');
end;bib_err_print;goto 10;end;end;end;
if(store_field)then begin lower_case(buffer,buf_ptr1,(buf_ptr2-buf_ptr1)
);
macro_name_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),13,false)
;store_token:=true;
if(at_bib_command)then if(command_num=2)then if(macro_name_loc=
cur_macro_loc)then begin store_token:=false;begin macro_warn_print;
begin begin write_ln(log_file,'used in its own definition');
write_ln(tty,'used in its own definition');end;bib_warn_print;end;end;
end;if(not hash_found)then begin store_token:=false;
begin macro_warn_print;begin begin write_ln(log_file,'undefined');
write_ln(tty,'undefined');end;bib_warn_print;end;end;end;
if(store_token)then{260:}begin tmp_ptr:=str_start[ilk_info[
macro_name_loc]];tmp_end_ptr:=str_start[ilk_info[macro_name_loc]+1];
if(ex_buf_ptr=0)then if((lex_class[str_pool[tmp_ptr]]=1)and(tmp_ptr<
tmp_end_ptr))then begin begin if(ex_buf_ptr=buf_size)then begin
bib_field_too_long_print;goto 10;end else begin ex_buf[ex_buf_ptr]:=32;
ex_buf_ptr:=ex_buf_ptr+1;end;end;tmp_ptr:=tmp_ptr+1;
while((lex_class[str_pool[tmp_ptr]]=1)and(tmp_ptr<tmp_end_ptr))do
tmp_ptr:=tmp_ptr+1;end;
while(tmp_ptr<tmp_end_ptr)do begin if(lex_class[str_pool[tmp_ptr]]<>1)
then begin if(ex_buf_ptr=buf_size)then begin bib_field_too_long_print;
goto 10;end else begin ex_buf[ex_buf_ptr]:=str_pool[tmp_ptr];
ex_buf_ptr:=ex_buf_ptr+1;end;
end else if(ex_buf[ex_buf_ptr-1]<>32)then begin if(ex_buf_ptr=buf_size)
then begin bib_field_too_long_print;goto 10;
end else begin ex_buf[ex_buf_ptr]:=32;ex_buf_ptr:=ex_buf_ptr+1;end;end;
tmp_ptr:=tmp_ptr+1;end;end{:260};end;end{:259}end;
begin if(not eat_bib_white_space)then begin eat_bib_print;goto 10;end;
end;scan_a_field_token_and_eat_white:=true;10:end;
{:250}{:248}{249:}function scan_and_store_the_field_value_and_eat_white:
boolean;label 10;
begin scan_and_store_the_field_value_and_eat_white:=false;ex_buf_ptr:=0;
if(not scan_a_field_token_and_eat_white)then goto 10;
while(buffer[buf_ptr2]=35)do begin buf_ptr2:=buf_ptr2+1;
begin if(not eat_bib_white_space)then begin eat_bib_print;goto 10;end;
end;if(not scan_a_field_token_and_eat_white)then goto 10;end;
if(store_field)then{261:}begin if(not at_bib_command)then if(ex_buf_ptr>
0)then if(ex_buf[ex_buf_ptr-1]=32)then ex_buf_ptr:=ex_buf_ptr-1;
if((not at_bib_command)and(ex_buf[0]=32)and(ex_buf_ptr>0))then
ex_buf_xptr:=1 else ex_buf_xptr:=0;
field_val_loc:=str_lookup(ex_buf,ex_buf_xptr,ex_buf_ptr-ex_buf_xptr,0,
true);fn_type[field_val_loc]:=3;{begin write(log_file,'"');end;
begin out_pool_str(log_file,hash_text[field_val_loc]);end;
begin write_ln(log_file,'" is a field value');end;}
if(at_bib_command)then{262:}begin case(command_num)of 1:begin s_preamble
[preamble_ptr]:=hash_text[field_val_loc];preamble_ptr:=preamble_ptr+1;
end;2:ilk_info[cur_macro_loc]:=hash_text[field_val_loc];
others:bib_cmd_confusion end;
end{:262}else{263:}begin field_ptr:=entry_cite_ptr*num_fields+ilk_info[
field_name_loc];
if(field_info[field_ptr]<>0)then begin begin write(log_file,
'Warning--I''m ignoring ');write(tty,'Warning--I''m ignoring ');end;
print_a_pool_str(cite_list[entry_cite_ptr]);
begin write(log_file,'''s extra "');write(tty,'''s extra "');end;
print_a_pool_str(hash_text[field_name_loc]);
begin begin write_ln(log_file,'" field');write_ln(tty,'" field');end;
bib_warn_print;end;
end else begin field_info[field_ptr]:=hash_text[field_val_loc];
if((ilk_info[field_name_loc]=crossref_num)and(not all_entries))then
{264:}begin tmp_ptr:=ex_buf_xptr;
while(tmp_ptr<ex_buf_ptr)do begin out_buf[tmp_ptr]:=ex_buf[tmp_ptr];
tmp_ptr:=tmp_ptr+1;end;
lower_case(out_buf,ex_buf_xptr,ex_buf_ptr-ex_buf_xptr);
lc_cite_loc:=str_lookup(out_buf,ex_buf_xptr,ex_buf_ptr-ex_buf_xptr,10,
true);if(hash_found)then begin cite_loc:=ilk_info[lc_cite_loc];
if(ilk_info[cite_loc]>=old_num_cites)then cite_info[ilk_info[cite_loc]]
:=cite_info[ilk_info[cite_loc]]+1;
end else begin cite_loc:=str_lookup(ex_buf,ex_buf_xptr,ex_buf_ptr-
ex_buf_xptr,9,true);if(hash_found)then hash_cite_confusion;
add_database_cite(cite_ptr);cite_info[ilk_info[cite_loc]]:=1;end;
end{:264};end;end{:263};end{:261};
scan_and_store_the_field_value_and_eat_white:=true;10:end;
{:249}{367:}procedure decr_brace_level(pop_lit_var:str_number);
begin if(brace_level=0)then braces_unbalanced_complaint(pop_lit_var)else
brace_level:=brace_level-1;end;
{:367}{369:}procedure check_brace_level(pop_lit_var:str_number);
begin if(brace_level>0)then braces_unbalanced_complaint(pop_lit_var);
end;{:369}{384:}procedure name_scan_for_and(pop_lit_var:str_number);
begin brace_level:=0;preceding_white:=false;and_found:=false;
while((not and_found)and(ex_buf_ptr<ex_buf_length))do case(ex_buf[
ex_buf_ptr])of 97,65:begin ex_buf_ptr:=ex_buf_ptr+1;
if(preceding_white)then{386:}begin if(ex_buf_ptr<=(ex_buf_length-3))then
if((ex_buf[ex_buf_ptr]=110)or(ex_buf[ex_buf_ptr]=78))then if((ex_buf[
ex_buf_ptr+1]=100)or(ex_buf[ex_buf_ptr+1]=68))then if(lex_class[ex_buf[
ex_buf_ptr+2]]=1)then begin ex_buf_ptr:=ex_buf_ptr+2;and_found:=true;
end;end{:386};preceding_white:=false;end;
123:begin brace_level:=brace_level+1;ex_buf_ptr:=ex_buf_ptr+1;
{385:}while((brace_level>0)and(ex_buf_ptr<ex_buf_length))do begin if(
ex_buf[ex_buf_ptr]=125)then brace_level:=brace_level-1 else if(ex_buf[
ex_buf_ptr]=123)then brace_level:=brace_level+1;
ex_buf_ptr:=ex_buf_ptr+1;end{:385};preceding_white:=false;end;
125:begin decr_brace_level(pop_lit_var);ex_buf_ptr:=ex_buf_ptr+1;
preceding_white:=false;end;
others:if(lex_class[ex_buf[ex_buf_ptr]]=1)then begin ex_buf_ptr:=
ex_buf_ptr+1;preceding_white:=true;
end else begin ex_buf_ptr:=ex_buf_ptr+1;preceding_white:=false;end end;
check_brace_level(pop_lit_var);end;
{:384}{397:}function von_token_found:boolean;label 10;
begin nm_brace_level:=0;von_token_found:=false;
while(name_bf_ptr<name_bf_xptr)do if((sv_buffer[name_bf_ptr]>=65)and(
sv_buffer[name_bf_ptr]<=90))then goto 10 else if((sv_buffer[name_bf_ptr]
>=97)and(sv_buffer[name_bf_ptr]<=122))then begin von_token_found:=true;
goto 10;
end else if(sv_buffer[name_bf_ptr]=123)then begin nm_brace_level:=
nm_brace_level+1;name_bf_ptr:=name_bf_ptr+1;
if((name_bf_ptr+2<name_bf_xptr)and(sv_buffer[name_bf_ptr]=92))then{398:}
begin name_bf_ptr:=name_bf_ptr+1;name_bf_yptr:=name_bf_ptr;
while((name_bf_ptr<name_bf_xptr)and(lex_class[sv_buffer[name_bf_ptr]]=2)
)do name_bf_ptr:=name_bf_ptr+1;
control_seq_loc:=str_lookup(sv_buffer,name_bf_yptr,name_bf_ptr-
name_bf_yptr,14,false);
if(hash_found)then{399:}begin case(ilk_info[control_seq_loc])of 3,5,7,9,
11:goto 10;0,1,2,4,6,8,10,12:begin von_token_found:=true;goto 10;end;
others:begin begin write(log_file,'Control-sequence hash error');
write(tty,'Control-sequence hash error');end;print_confusion;goto 9998;
end end;end{:399};
while((name_bf_ptr<name_bf_xptr)and(nm_brace_level>0))do begin if((
sv_buffer[name_bf_ptr]>=65)and(sv_buffer[name_bf_ptr]<=90))then goto 10
else if((sv_buffer[name_bf_ptr]>=97)and(sv_buffer[name_bf_ptr]<=122))
then begin von_token_found:=true;goto 10;
end else if(sv_buffer[name_bf_ptr]=125)then nm_brace_level:=
nm_brace_level-1 else if(sv_buffer[name_bf_ptr]=123)then nm_brace_level
:=nm_brace_level+1;name_bf_ptr:=name_bf_ptr+1;end;goto 10;
end{:398}else{400:}while((nm_brace_level>0)and(name_bf_ptr<name_bf_xptr)
)do begin if(sv_buffer[name_bf_ptr]=125)then nm_brace_level:=
nm_brace_level-1 else if(sv_buffer[name_bf_ptr]=123)then nm_brace_level
:=nm_brace_level+1;name_bf_ptr:=name_bf_ptr+1;end{:400};
end else name_bf_ptr:=name_bf_ptr+1;10:end;
{:397}{401:}procedure von_name_ends_and_last_name_starts_stuff;label 10;
begin von_end:=last_end-1;
while(von_end>von_start)do begin name_bf_ptr:=name_tok[von_end-1];
name_bf_xptr:=name_tok[von_end];if(von_token_found)then goto 10;
von_end:=von_end-1;end;10:end;
{:401}{404:}procedure skip_stuff_at_sp_brace_level_greater_than_one;
begin while((sp_brace_level>1)and(sp_ptr<sp_end))do begin if(str_pool[
sp_ptr]=125)then sp_brace_level:=sp_brace_level-1 else if(str_pool[
sp_ptr]=123)then sp_brace_level:=sp_brace_level+1;sp_ptr:=sp_ptr+1;end;
end;{:404}{406:}procedure brace_lvl_one_letters_complaint;
begin begin write(log_file,'The format string "');
write(tty,'The format string "');end;print_a_pool_str(pop_lit1);
begin begin write(log_file,'" has an illegal brace-level-1 letter');
write(tty,'" has an illegal brace-level-1 letter');end;
bst_ex_warn_print;end;end;
{:406}{418:}function enough_text_chars(enough_chars:buf_pointer):boolean
;begin num_text_chars:=0;ex_buf_yptr:=ex_buf_xptr;
while((ex_buf_yptr<ex_buf_ptr)and(num_text_chars<enough_chars))do begin
ex_buf_yptr:=ex_buf_yptr+1;
if(ex_buf[ex_buf_yptr-1]=123)then begin brace_level:=brace_level+1;
if((brace_level=1)and(ex_buf_yptr<ex_buf_ptr))then if(ex_buf[ex_buf_yptr
]=92)then begin ex_buf_yptr:=ex_buf_yptr+1;
while((ex_buf_yptr<ex_buf_ptr)and(brace_level>0))do begin if(ex_buf[
ex_buf_yptr]=125)then brace_level:=brace_level-1 else if(ex_buf[
ex_buf_yptr]=123)then brace_level:=brace_level+1;
ex_buf_yptr:=ex_buf_yptr+1;end;end;
end else if(ex_buf[ex_buf_yptr-1]=125)then brace_level:=brace_level-1;
num_text_chars:=num_text_chars+1;end;
if(num_text_chars<enough_chars)then enough_text_chars:=false else
enough_text_chars:=true;end;
{:418}{420:}procedure figure_out_the_formatted_name;label 15;
begin{402:}begin ex_buf_ptr:=0;sp_brace_level:=0;
sp_ptr:=str_start[pop_lit1];sp_end:=str_start[pop_lit1+1];
while(sp_ptr<sp_end)do if(str_pool[sp_ptr]=123)then begin sp_brace_level
:=sp_brace_level+1;sp_ptr:=sp_ptr+1;{403:}begin sp_xptr1:=sp_ptr;
alpha_found:=false;double_letter:=false;end_of_group:=false;
to_be_written:=true;
while((not end_of_group)and(sp_ptr<sp_end))do if(lex_class[str_pool[
sp_ptr]]=2)then begin sp_ptr:=sp_ptr+1;
{405:}begin if(alpha_found)then begin brace_lvl_one_letters_complaint;
to_be_written:=false;
end else begin case(str_pool[sp_ptr-1])of 102,70:{407:}begin cur_token:=
first_start;last_token:=first_end;
if(cur_token=last_token)then to_be_written:=false;
if((str_pool[sp_ptr]=102)or(str_pool[sp_ptr]=70))then double_letter:=
true;end{:407};118,86:{408:}begin cur_token:=von_start;
last_token:=von_end;if(cur_token=last_token)then to_be_written:=false;
if((str_pool[sp_ptr]=118)or(str_pool[sp_ptr]=86))then double_letter:=
true;end{:408};108,76:{409:}begin cur_token:=von_end;
last_token:=last_end;if(cur_token=last_token)then to_be_written:=false;
if((str_pool[sp_ptr]=108)or(str_pool[sp_ptr]=76))then double_letter:=
true;end{:409};106,74:{410:}begin cur_token:=last_end;
last_token:=jr_end;if(cur_token=last_token)then to_be_written:=false;
if((str_pool[sp_ptr]=106)or(str_pool[sp_ptr]=74))then double_letter:=
true;end{:410};others:begin brace_lvl_one_letters_complaint;
to_be_written:=false;end end;if(double_letter)then sp_ptr:=sp_ptr+1;end;
alpha_found:=true;end{:405};
end else if(str_pool[sp_ptr]=125)then begin sp_brace_level:=
sp_brace_level-1;sp_ptr:=sp_ptr+1;end_of_group:=true;
end else if(str_pool[sp_ptr]=123)then begin sp_brace_level:=
sp_brace_level+1;sp_ptr:=sp_ptr+1;
skip_stuff_at_sp_brace_level_greater_than_one;end else sp_ptr:=sp_ptr+1;
if((end_of_group)and(to_be_written))then{411:}begin ex_buf_xptr:=
ex_buf_ptr;sp_ptr:=sp_xptr1;sp_brace_level:=1;
while(sp_brace_level>0)do if((lex_class[str_pool[sp_ptr]]=2)and(
sp_brace_level=1))then begin sp_ptr:=sp_ptr+1;
{412:}begin if(double_letter)then sp_ptr:=sp_ptr+1;use_default:=true;
sp_xptr2:=sp_ptr;if(str_pool[sp_ptr]=123)then begin use_default:=false;
sp_brace_level:=sp_brace_level+1;sp_ptr:=sp_ptr+1;sp_xptr1:=sp_ptr;
skip_stuff_at_sp_brace_level_greater_than_one;sp_xptr2:=sp_ptr-1;end;
{413:}while(cur_token<last_token)do begin if(double_letter)then{414:}
begin name_bf_ptr:=name_tok[cur_token];
name_bf_xptr:=name_tok[cur_token+1];
if(ex_buf_length+(name_bf_xptr-name_bf_ptr)>buf_size)then
buffer_overflow;
while(name_bf_ptr<name_bf_xptr)do begin begin ex_buf[ex_buf_ptr]:=
sv_buffer[name_bf_ptr];ex_buf_ptr:=ex_buf_ptr+1;end;
name_bf_ptr:=name_bf_ptr+1;end;
end{:414}else{415:}begin name_bf_ptr:=name_tok[cur_token];
name_bf_xptr:=name_tok[cur_token+1];
while(name_bf_ptr<name_bf_xptr)do begin if(lex_class[sv_buffer[
name_bf_ptr]]=2)then begin begin if(ex_buf_ptr=buf_size)then
buffer_overflow;begin ex_buf[ex_buf_ptr]:=sv_buffer[name_bf_ptr];
ex_buf_ptr:=ex_buf_ptr+1;end;end;goto 15;
end else if((sv_buffer[name_bf_ptr]=123)and(name_bf_ptr+1<name_bf_xptr))
then if(sv_buffer[name_bf_ptr+1]=92)then{416:}begin if(ex_buf_ptr+2>
buf_size)then buffer_overflow;begin ex_buf[ex_buf_ptr]:=123;
ex_buf_ptr:=ex_buf_ptr+1;end;begin ex_buf[ex_buf_ptr]:=92;
ex_buf_ptr:=ex_buf_ptr+1;end;name_bf_ptr:=name_bf_ptr+2;
nm_brace_level:=1;
while((name_bf_ptr<name_bf_xptr)and(nm_brace_level>0))do begin if(
sv_buffer[name_bf_ptr]=125)then nm_brace_level:=nm_brace_level-1 else if
(sv_buffer[name_bf_ptr]=123)then nm_brace_level:=nm_brace_level+1;
begin if(ex_buf_ptr=buf_size)then buffer_overflow;
begin ex_buf[ex_buf_ptr]:=sv_buffer[name_bf_ptr];
ex_buf_ptr:=ex_buf_ptr+1;end;end;name_bf_ptr:=name_bf_ptr+1;end;goto 15;
end{:416};name_bf_ptr:=name_bf_ptr+1;end;15:end{:415};
cur_token:=cur_token+1;
if(cur_token<last_token)then{417:}begin if(use_default)then begin if(not
double_letter)then begin if(ex_buf_ptr=buf_size)then buffer_overflow;
begin ex_buf[ex_buf_ptr]:=46;ex_buf_ptr:=ex_buf_ptr+1;end;end;
if(lex_class[name_sep_char[cur_token]]=4)then begin if(ex_buf_ptr=
buf_size)then buffer_overflow;
begin ex_buf[ex_buf_ptr]:=name_sep_char[cur_token];
ex_buf_ptr:=ex_buf_ptr+1;end;
end else if((cur_token=last_token-1)or(not enough_text_chars(3)))then
begin if(ex_buf_ptr=buf_size)then buffer_overflow;
begin ex_buf[ex_buf_ptr]:=126;ex_buf_ptr:=ex_buf_ptr+1;end;
end else begin if(ex_buf_ptr=buf_size)then buffer_overflow;
begin ex_buf[ex_buf_ptr]:=32;ex_buf_ptr:=ex_buf_ptr+1;end;end;
end else begin if(ex_buf_length+(sp_xptr2-sp_xptr1)>buf_size)then
buffer_overflow;sp_ptr:=sp_xptr1;
while(sp_ptr<sp_xptr2)do begin begin ex_buf[ex_buf_ptr]:=str_pool[sp_ptr
];ex_buf_ptr:=ex_buf_ptr+1;end;sp_ptr:=sp_ptr+1;end end;end{:417};
end{:413};if(not use_default)then sp_ptr:=sp_xptr2+1;end{:412};
end else if(str_pool[sp_ptr]=125)then begin sp_brace_level:=
sp_brace_level-1;sp_ptr:=sp_ptr+1;
if(sp_brace_level>0)then begin if(ex_buf_ptr=buf_size)then
buffer_overflow;begin ex_buf[ex_buf_ptr]:=125;ex_buf_ptr:=ex_buf_ptr+1;
end;end;end else if(str_pool[sp_ptr]=123)then begin sp_brace_level:=
sp_brace_level+1;sp_ptr:=sp_ptr+1;
begin if(ex_buf_ptr=buf_size)then buffer_overflow;
begin ex_buf[ex_buf_ptr]:=123;ex_buf_ptr:=ex_buf_ptr+1;end;end;
end else begin begin if(ex_buf_ptr=buf_size)then buffer_overflow;
begin ex_buf[ex_buf_ptr]:=str_pool[sp_ptr];ex_buf_ptr:=ex_buf_ptr+1;end;
end;sp_ptr:=sp_ptr+1;end;
if(ex_buf_ptr>0)then if(ex_buf[ex_buf_ptr-1]=126)then{419:}begin
ex_buf_ptr:=ex_buf_ptr-1;
if(ex_buf[ex_buf_ptr-1]=126)then else if(not enough_text_chars(3))then
ex_buf_ptr:=ex_buf_ptr+1 else begin ex_buf[ex_buf_ptr]:=32;
ex_buf_ptr:=ex_buf_ptr+1;end;end{:419};end{:411};end{:403};
end else if(str_pool[sp_ptr]=125)then begin braces_unbalanced_complaint(
pop_lit1);sp_ptr:=sp_ptr+1;
end else begin begin if(ex_buf_ptr=buf_size)then buffer_overflow;
begin ex_buf[ex_buf_ptr]:=str_pool[sp_ptr];ex_buf_ptr:=ex_buf_ptr+1;end;
end;sp_ptr:=sp_ptr+1;end;
if(sp_brace_level>0)then braces_unbalanced_complaint(pop_lit1);
ex_buf_length:=ex_buf_ptr;end{:402};end;
{:420}{307:}procedure push_lit_stk(push_lt:integer;push_type:stk_type);
{var dum_ptr:lit_stk_loc;}begin lit_stack[lit_stk_ptr]:=push_lt;
lit_stk_type[lit_stk_ptr]:=push_type;
{for dum_ptr:=0 to lit_stk_ptr do begin write(log_file,'  ');end;
begin write(log_file,'Pushing ');end;
case(lit_stk_type[lit_stk_ptr])of 0:begin write_ln(log_file,lit_stack[
lit_stk_ptr]:0);end;1:begin begin write(log_file,'"');end;
begin out_pool_str(log_file,lit_stack[lit_stk_ptr]);end;
begin write_ln(log_file,'"');end;end;2:begin begin write(log_file,'`');
end;begin out_pool_str(log_file,hash_text[lit_stack[lit_stk_ptr]]);end;
begin write_ln(log_file,'''');end;end;
3:begin begin write(log_file,'missing field `');end;
begin out_pool_str(log_file,lit_stack[lit_stk_ptr]);end;
begin write_ln(log_file,'''');end;end;
4:begin write_ln(log_file,'a bad literal--popped from an empty stack');
end;others:unknwn_literal_confusion end;}
if(lit_stk_ptr=lit_stk_size)then begin print_overflow;
begin write_ln(log_file,'literal-stack size ',lit_stk_size:0);
write_ln(tty,'literal-stack size ',lit_stk_size:0);end;goto 9998;end;
lit_stk_ptr:=lit_stk_ptr+1;end;
{:307}{309:}procedure pop_lit_stk(var pop_lit:integer;
var pop_type:stk_type);
begin if(lit_stk_ptr=0)then begin begin begin write(log_file,
'You can''t pop an empty literal stack');
write(tty,'You can''t pop an empty literal stack');end;
bst_ex_warn_print;end;pop_type:=4;
end else begin lit_stk_ptr:=lit_stk_ptr-1;
pop_lit:=lit_stack[lit_stk_ptr];pop_type:=lit_stk_type[lit_stk_ptr];
if(pop_type=1)then if(pop_lit>=cmd_str_ptr)then begin if(pop_lit<>
str_ptr-1)then begin begin write(log_file,'Nontop top of string stack');
write(tty,'Nontop top of string stack');end;print_confusion;goto 9998;
end;begin str_ptr:=str_ptr-1;pool_ptr:=str_start[str_ptr];end;end;end;
end;{:309}{312:}procedure print_wrong_stk_lit(stk_lt:integer;
stk_tp1,stk_tp2:stk_type);
begin if(stk_tp1<>4)then begin print_stk_lit(stk_lt,stk_tp1);
case(stk_tp2)of 0:begin write(log_file,', not an integer,');
write(tty,', not an integer,');end;
1:begin write(log_file,', not a string,');write(tty,', not a string,');
end;2:begin write(log_file,', not a function,');
write(tty,', not a function,');end;3,4:illegl_literal_confusion;
others:unknwn_literal_confusion end;bst_ex_warn_print;end;end;
{:312}{314:}procedure pop_top_and_print;var stk_lt:integer;
stk_tp:stk_type;begin pop_lit_stk(stk_lt,stk_tp);
if(stk_tp=4)then begin write_ln(log_file,'Empty literal');
write_ln(tty,'Empty literal');end else print_lit(stk_lt,stk_tp);end;
{:314}{315:}procedure pop_whole_stack;
begin while(lit_stk_ptr>0)do pop_top_and_print;end;
{:315}{316:}procedure init_command_execution;begin lit_stk_ptr:=0;
cmd_str_ptr:=str_ptr;end;{:316}{317:}procedure check_command_execution;
begin if(lit_stk_ptr<>0)then begin begin write_ln(log_file,'ptr=',
lit_stk_ptr:0,', stack=');write_ln(tty,'ptr=',lit_stk_ptr:0,', stack=');
end;pop_whole_stack;
begin begin write(log_file,'---the literal stack isn''t empty');
write(tty,'---the literal stack isn''t empty');end;bst_ex_warn_print;
end;end;
if(cmd_str_ptr<>str_ptr)then begin{begin write_ln(log_file,'Pointer is '
,str_ptr:0,' but should be ',cmd_str_ptr:0);
write_ln(tty,'Pointer is ',str_ptr:0,' but should be ',cmd_str_ptr:0);
end;}begin begin write(log_file,'Nonempty empty string stack');
write(tty,'Nonempty empty string stack');end;print_confusion;goto 9998;
end;end;end;{:317}{318:}procedure add_pool_buf_and_push;
begin begin if(pool_ptr+ex_buf_length>pool_size)then pool_overflow;end;
ex_buf_ptr:=0;
while(ex_buf_ptr<ex_buf_length)do begin begin str_pool[pool_ptr]:=ex_buf
[ex_buf_ptr];pool_ptr:=pool_ptr+1;end;ex_buf_ptr:=ex_buf_ptr+1;end;
push_lit_stk(make_string,1);end;
{:318}{320:}procedure add_buf_pool(p_str:str_number);
begin p_ptr1:=str_start[p_str];p_ptr2:=str_start[p_str+1];
if(ex_buf_length+(p_ptr2-p_ptr1)>buf_size)then buffer_overflow;
ex_buf_ptr:=ex_buf_length;
while(p_ptr1<p_ptr2)do begin begin ex_buf[ex_buf_ptr]:=str_pool[p_ptr1];
ex_buf_ptr:=ex_buf_ptr+1;end;p_ptr1:=p_ptr1+1;end;
ex_buf_length:=ex_buf_ptr;end;
{:320}{322:}procedure add_out_pool(p_str:str_number);label 16,17;
var break_ptr:buf_pointer;end_ptr:buf_pointer;break_pt_found:boolean;
unbreakable_tail:boolean;begin p_ptr1:=str_start[p_str];
p_ptr2:=str_start[p_str+1];
if(out_buf_length+(p_ptr2-p_ptr1)>buf_size)then begin print_overflow;
begin write_ln(log_file,'output buffer size ',buf_size:0);
write_ln(tty,'output buffer size ',buf_size:0);end;goto 9998;end;
out_buf_ptr:=out_buf_length;
while(p_ptr1<p_ptr2)do begin out_buf[out_buf_ptr]:=str_pool[p_ptr1];
p_ptr1:=p_ptr1+1;out_buf_ptr:=out_buf_ptr+1;end;
out_buf_length:=out_buf_ptr;unbreakable_tail:=false;
while((out_buf_length>max_print_line)and(not unbreakable_tail))do{323:}
begin end_ptr:=out_buf_length;out_buf_ptr:=max_print_line;
break_pt_found:=false;
while((lex_class[out_buf[out_buf_ptr]]<>1)and(out_buf_ptr>=
min_print_line))do out_buf_ptr:=out_buf_ptr-1;
if(out_buf_ptr=min_print_line-1)then{324:}begin out_buf_ptr:=
max_print_line+1;
while(out_buf_ptr<end_ptr)do if(lex_class[out_buf[out_buf_ptr]]<>1)then
out_buf_ptr:=out_buf_ptr+1 else goto 16;
16:if(out_buf_ptr=end_ptr)then unbreakable_tail:=true else begin
break_pt_found:=true;
while(out_buf_ptr+1<end_ptr)do if(lex_class[out_buf[out_buf_ptr+1]]=1)
then out_buf_ptr:=out_buf_ptr+1 else goto 17;17:end;
end{:324}else break_pt_found:=true;
if(break_pt_found)then begin out_buf_length:=out_buf_ptr;
break_ptr:=out_buf_length+1;output_bbl_line;out_buf[0]:=32;
out_buf[1]:=32;out_buf_ptr:=2;tmp_ptr:=break_ptr;
while(tmp_ptr<end_ptr)do begin out_buf[out_buf_ptr]:=out_buf[tmp_ptr];
out_buf_ptr:=out_buf_ptr+1;tmp_ptr:=tmp_ptr+1;end;
out_buf_length:=end_ptr-break_ptr+2;end;end{:323};end;
{:322}{342:}{345:}procedure x_equals;
begin pop_lit_stk(pop_lit1,pop_typ1);pop_lit_stk(pop_lit2,pop_typ2);
if(pop_typ1<>pop_typ2)then begin if((pop_typ1<>4)and(pop_typ2<>4))then
begin print_stk_lit(pop_lit1,pop_typ1);begin write(log_file,', ');
write(tty,', ');end;print_stk_lit(pop_lit2,pop_typ2);print_a_newline;
begin begin write(log_file,'---they aren''t the same literal types');
write(tty,'---they aren''t the same literal types');end;
bst_ex_warn_print;end;end;push_lit_stk(0,0);
end else if((pop_typ1<>0)and(pop_typ1<>1))then begin if(pop_typ1<>4)then
begin print_stk_lit(pop_lit1,pop_typ1);
begin begin write(log_file,', not an integer or a string,');
write(tty,', not an integer or a string,');end;bst_ex_warn_print;end;
end;push_lit_stk(0,0);
end else if(pop_typ1=0)then if(pop_lit2=pop_lit1)then push_lit_stk(1,0)
else push_lit_stk(0,0)else if(str_eq_str(pop_lit2,pop_lit1))then
push_lit_stk(1,0)else push_lit_stk(0,0);end;
{:345}{346:}procedure x_greater_than;
begin pop_lit_stk(pop_lit1,pop_typ1);pop_lit_stk(pop_lit2,pop_typ2);
if(pop_typ1<>0)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,0);
push_lit_stk(0,0);
end else if(pop_typ2<>0)then begin print_wrong_stk_lit(pop_lit2,pop_typ2
,0);push_lit_stk(0,0);
end else if(pop_lit2>pop_lit1)then push_lit_stk(1,0)else push_lit_stk(0,
0);end;{:346}{347:}procedure x_less_than;
begin pop_lit_stk(pop_lit1,pop_typ1);pop_lit_stk(pop_lit2,pop_typ2);
if(pop_typ1<>0)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,0);
push_lit_stk(0,0);
end else if(pop_typ2<>0)then begin print_wrong_stk_lit(pop_lit2,pop_typ2
,0);push_lit_stk(0,0);
end else if(pop_lit2<pop_lit1)then push_lit_stk(1,0)else push_lit_stk(0,
0);end;{:347}{348:}procedure x_plus;
begin pop_lit_stk(pop_lit1,pop_typ1);pop_lit_stk(pop_lit2,pop_typ2);
if(pop_typ1<>0)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,0);
push_lit_stk(0,0);
end else if(pop_typ2<>0)then begin print_wrong_stk_lit(pop_lit2,pop_typ2
,0);push_lit_stk(0,0);end else push_lit_stk(pop_lit2+pop_lit1,0);end;
{:348}{349:}procedure x_minus;begin pop_lit_stk(pop_lit1,pop_typ1);
pop_lit_stk(pop_lit2,pop_typ2);
if(pop_typ1<>0)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,0);
push_lit_stk(0,0);
end else if(pop_typ2<>0)then begin print_wrong_stk_lit(pop_lit2,pop_typ2
,0);push_lit_stk(0,0);end else push_lit_stk(pop_lit2-pop_lit1,0);end;
{:349}{350:}procedure x_concatenate;
begin pop_lit_stk(pop_lit1,pop_typ1);pop_lit_stk(pop_lit2,pop_typ2);
if(pop_typ1<>1)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,1);
push_lit_stk(s_null,1);
end else if(pop_typ2<>1)then begin print_wrong_stk_lit(pop_lit2,pop_typ2
,1);push_lit_stk(s_null,1);
end else{351:}begin if(pop_lit2>=cmd_str_ptr)then if(pop_lit1>=
cmd_str_ptr)then begin str_start[pop_lit1]:=str_start[pop_lit1+1];
begin str_ptr:=str_ptr+1;pool_ptr:=str_start[str_ptr];end;
lit_stk_ptr:=lit_stk_ptr+1;
end else if((str_start[pop_lit2+1]-str_start[pop_lit2])=0)then
push_lit_stk(pop_lit1,1)else begin pool_ptr:=str_start[pop_lit2+1];
begin if(pool_ptr+(str_start[pop_lit1+1]-str_start[pop_lit1])>pool_size)
then pool_overflow;end;sp_ptr:=str_start[pop_lit1];
sp_end:=str_start[pop_lit1+1];
while(sp_ptr<sp_end)do begin begin str_pool[pool_ptr]:=str_pool[sp_ptr];
pool_ptr:=pool_ptr+1;end;sp_ptr:=sp_ptr+1;end;
push_lit_stk(make_string,1);
end else{352:}begin if(pop_lit1>=cmd_str_ptr)then if((str_start[pop_lit2
+1]-str_start[pop_lit2])=0)then begin begin str_ptr:=str_ptr+1;
pool_ptr:=str_start[str_ptr];end;lit_stack[lit_stk_ptr]:=pop_lit1;
lit_stk_ptr:=lit_stk_ptr+1;
end else if((str_start[pop_lit1+1]-str_start[pop_lit1])=0)then
lit_stk_ptr:=lit_stk_ptr+1 else begin sp_length:=(str_start[pop_lit1+1]-
str_start[pop_lit1]);
sp2_length:=(str_start[pop_lit2+1]-str_start[pop_lit2]);
begin if(pool_ptr+sp_length+sp2_length>pool_size)then pool_overflow;end;
sp_ptr:=str_start[pop_lit1+1];sp_end:=str_start[pop_lit1];
sp_xptr1:=sp_ptr+sp2_length;
while(sp_ptr>sp_end)do begin sp_ptr:=sp_ptr-1;sp_xptr1:=sp_xptr1-1;
str_pool[sp_xptr1]:=str_pool[sp_ptr];end;sp_ptr:=str_start[pop_lit2];
sp_end:=str_start[pop_lit2+1];
while(sp_ptr<sp_end)do begin begin str_pool[pool_ptr]:=str_pool[sp_ptr];
pool_ptr:=pool_ptr+1;end;sp_ptr:=sp_ptr+1;end;
pool_ptr:=pool_ptr+sp_length;push_lit_stk(make_string,1);
end else{353:}begin if((str_start[pop_lit1+1]-str_start[pop_lit1])=0)
then lit_stk_ptr:=lit_stk_ptr+1 else if((str_start[pop_lit2+1]-str_start
[pop_lit2])=0)then push_lit_stk(pop_lit1,1)else begin begin if(pool_ptr+
(str_start[pop_lit1+1]-str_start[pop_lit1])+(str_start[pop_lit2+1]-
str_start[pop_lit2])>pool_size)then pool_overflow;end;
sp_ptr:=str_start[pop_lit2];sp_end:=str_start[pop_lit2+1];
while(sp_ptr<sp_end)do begin begin str_pool[pool_ptr]:=str_pool[sp_ptr];
pool_ptr:=pool_ptr+1;end;sp_ptr:=sp_ptr+1;end;
sp_ptr:=str_start[pop_lit1];sp_end:=str_start[pop_lit1+1];
while(sp_ptr<sp_end)do begin begin str_pool[pool_ptr]:=str_pool[sp_ptr];
pool_ptr:=pool_ptr+1;end;sp_ptr:=sp_ptr+1;end;
push_lit_stk(make_string,1);end;end{:353};end{:352};end{:351};end;
{:350}{354:}procedure x_gets;begin pop_lit_stk(pop_lit1,pop_typ1);
pop_lit_stk(pop_lit2,pop_typ2);
if(pop_typ1<>2)then print_wrong_stk_lit(pop_lit1,pop_typ1,2)else if((not
mess_with_entries)and((fn_type[pop_lit1]=6)or(fn_type[pop_lit1]=5)))then
bst_cant_mess_with_entries_print else case(fn_type[pop_lit1])of 5:{355:}
if(pop_typ2<>0)then print_wrong_stk_lit(pop_lit2,pop_typ2,0)else
entry_ints[cite_ptr*num_ent_ints+ilk_info[pop_lit1]]:=pop_lit2{:355};
6:{357:}begin if(pop_typ2<>1)then print_wrong_stk_lit(pop_lit2,pop_typ2,
1)else begin str_ent_ptr:=cite_ptr*num_ent_strs+ilk_info[pop_lit1];
ent_chr_ptr:=0;sp_ptr:=str_start[pop_lit2];
sp_xptr1:=str_start[pop_lit2+1];
if(sp_xptr1-sp_ptr>ent_str_size)then begin begin
bst_1print_string_size_exceeded;
begin write(log_file,ent_str_size:0,', the entry');
write(tty,ent_str_size:0,', the entry');end;
bst_2print_string_size_exceeded;end;sp_xptr1:=sp_ptr+ent_str_size;end;
while(sp_ptr<sp_xptr1)do begin entry_strs[str_ent_ptr][ent_chr_ptr]:=
str_pool[sp_ptr];ent_chr_ptr:=ent_chr_ptr+1;sp_ptr:=sp_ptr+1;end;
entry_strs[str_ent_ptr][ent_chr_ptr]:=127;end end{:357};
7:{358:}if(pop_typ2<>0)then print_wrong_stk_lit(pop_lit2,pop_typ2,0)else
ilk_info[pop_lit1]:=pop_lit2{:358};
8:{359:}begin if(pop_typ2<>1)then print_wrong_stk_lit(pop_lit2,pop_typ2,
1)else begin str_glb_ptr:=ilk_info[pop_lit1];
if(pop_lit2<cmd_str_ptr)then glb_str_ptr[str_glb_ptr]:=pop_lit2 else
begin glb_str_ptr[str_glb_ptr]:=0;glob_chr_ptr:=0;
sp_ptr:=str_start[pop_lit2];sp_end:=str_start[pop_lit2+1];
if(sp_end-sp_ptr>glob_str_size)then begin begin
bst_1print_string_size_exceeded;
begin write(log_file,glob_str_size:0,', the global');
write(tty,glob_str_size:0,', the global');end;
bst_2print_string_size_exceeded;end;sp_end:=sp_ptr+glob_str_size;end;
while(sp_ptr<sp_end)do begin global_strs[str_glb_ptr][glob_chr_ptr]:=
str_pool[sp_ptr];glob_chr_ptr:=glob_chr_ptr+1;sp_ptr:=sp_ptr+1;end;
glb_str_end[str_glb_ptr]:=glob_chr_ptr;end;end end{:359};
others:begin begin write(log_file,'You can''t assign to type ');
write(tty,'You can''t assign to type ');end;print_fn_class(pop_lit1);
begin begin write(log_file,', a nonvariable function class');
write(tty,', a nonvariable function class');end;bst_ex_warn_print;end;
end end;end;{:354}{360:}procedure x_add_period;label 15;
begin pop_lit_stk(pop_lit1,pop_typ1);
if(pop_typ1<>1)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,1);
push_lit_stk(s_null,1);
end else if((str_start[pop_lit1+1]-str_start[pop_lit1])=0)then
push_lit_stk(s_null,1)else{361:}begin sp_ptr:=str_start[pop_lit1+1];
sp_end:=str_start[pop_lit1];
while(sp_ptr>sp_end)do begin sp_ptr:=sp_ptr-1;
if(str_pool[sp_ptr]<>125)then goto 15;end;
15:case(str_pool[sp_ptr])of 46,63,33:begin if(lit_stack[lit_stk_ptr]>=
cmd_str_ptr)then begin str_ptr:=str_ptr+1;pool_ptr:=str_start[str_ptr];
end;lit_stk_ptr:=lit_stk_ptr+1;end;
others:{362:}begin if(pop_lit1<cmd_str_ptr)then begin begin if(pool_ptr+
(str_start[pop_lit1+1]-str_start[pop_lit1])+1>pool_size)then
pool_overflow;end;sp_ptr:=str_start[pop_lit1];
sp_end:=str_start[pop_lit1+1];
while(sp_ptr<sp_end)do begin begin str_pool[pool_ptr]:=str_pool[sp_ptr];
pool_ptr:=pool_ptr+1;end;sp_ptr:=sp_ptr+1;end;
end else begin pool_ptr:=str_start[pop_lit1+1];
begin if(pool_ptr+1>pool_size)then pool_overflow;end;end;
begin str_pool[pool_ptr]:=46;pool_ptr:=pool_ptr+1;end;
push_lit_stk(make_string,1);end{:362}end;end{:361};end;
{:360}{364:}procedure x_change_case;label 21;
begin pop_lit_stk(pop_lit1,pop_typ1);pop_lit_stk(pop_lit2,pop_typ2);
if(pop_typ1<>1)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,1);
push_lit_stk(s_null,1);
end else if(pop_typ2<>1)then begin print_wrong_stk_lit(pop_lit2,pop_typ2
,1);push_lit_stk(s_null,1);
end else begin{366:}begin case(str_pool[str_start[pop_lit1]])of 116,84:
conversion_type:=0;108,76:conversion_type:=1;117,85:conversion_type:=2;
others:conversion_type:=3 end;
if(((str_start[pop_lit1+1]-str_start[pop_lit1])<>1)or(conversion_type=3)
)then begin conversion_type:=3;print_a_pool_str(pop_lit1);
begin begin write(log_file,' is an illegal case-conversion string');
write(tty,' is an illegal case-conversion string');end;
bst_ex_warn_print;end;end;end{:366};ex_buf_length:=0;
add_buf_pool(pop_lit2);{370:}begin brace_level:=0;ex_buf_ptr:=0;
while(ex_buf_ptr<ex_buf_length)do begin if(ex_buf[ex_buf_ptr]=123)then
begin brace_level:=brace_level+1;if(brace_level<>1)then goto 21;
if(ex_buf_ptr+4>ex_buf_length)then goto 21 else if(ex_buf[ex_buf_ptr+1]
<>92)then goto 21;
if(conversion_type=0)then if(ex_buf_ptr=0)then goto 21 else if((
prev_colon)and(lex_class[ex_buf[ex_buf_ptr-1]]=1))then goto 21;
{371:}begin ex_buf_ptr:=ex_buf_ptr+1;
while((ex_buf_ptr<ex_buf_length)and(brace_level>0))do begin ex_buf_ptr:=
ex_buf_ptr+1;ex_buf_xptr:=ex_buf_ptr;
while((ex_buf_ptr<ex_buf_length)and(lex_class[ex_buf[ex_buf_ptr]]=2))do
ex_buf_ptr:=ex_buf_ptr+1;
control_seq_loc:=str_lookup(ex_buf,ex_buf_xptr,ex_buf_ptr-ex_buf_xptr,14
,false);
if(hash_found)then{372:}begin case(conversion_type)of 0,1:case(ilk_info[
control_seq_loc])of 11,9,3,5,7:lower_case(ex_buf,ex_buf_xptr,ex_buf_ptr-
ex_buf_xptr);others:end;
2:case(ilk_info[control_seq_loc])of 10,8,2,4,6:upper_case(ex_buf,
ex_buf_xptr,ex_buf_ptr-ex_buf_xptr);
0,1,12:{374:}begin upper_case(ex_buf,ex_buf_xptr,ex_buf_ptr-ex_buf_xptr)
;while(ex_buf_xptr<ex_buf_ptr)do begin ex_buf[ex_buf_xptr-1]:=ex_buf[
ex_buf_xptr];ex_buf_xptr:=ex_buf_xptr+1;end;ex_buf_xptr:=ex_buf_xptr-1;
while((ex_buf_ptr<ex_buf_length)and(lex_class[ex_buf[ex_buf_ptr]]=1))do
ex_buf_ptr:=ex_buf_ptr+1;tmp_ptr:=ex_buf_ptr;
while(tmp_ptr<ex_buf_length)do begin ex_buf[tmp_ptr-(ex_buf_ptr-
ex_buf_xptr)]:=ex_buf[tmp_ptr];tmp_ptr:=tmp_ptr+1 end;
ex_buf_length:=tmp_ptr-(ex_buf_ptr-ex_buf_xptr);ex_buf_ptr:=ex_buf_xptr;
end{:374};others:end;3:;others:case_conversion_confusion end;end{:372};
ex_buf_xptr:=ex_buf_ptr;
while((ex_buf_ptr<ex_buf_length)and(brace_level>0)and(ex_buf[ex_buf_ptr]
<>92))do begin if(ex_buf[ex_buf_ptr]=125)then brace_level:=brace_level-1
else if(ex_buf[ex_buf_ptr]=123)then brace_level:=brace_level+1;
ex_buf_ptr:=ex_buf_ptr+1;end;
{375:}begin case(conversion_type)of 0,1:lower_case(ex_buf,ex_buf_xptr,
ex_buf_ptr-ex_buf_xptr);
2:upper_case(ex_buf,ex_buf_xptr,ex_buf_ptr-ex_buf_xptr);3:;
others:case_conversion_confusion end;end{:375};end;
ex_buf_ptr:=ex_buf_ptr-1;end{:371};21:prev_colon:=false;
end else if(ex_buf[ex_buf_ptr]=125)then begin decr_brace_level(pop_lit2)
;prev_colon:=false;
end else if(brace_level=0)then{376:}begin case(conversion_type)of 0:
begin if(ex_buf_ptr=0)then else if((prev_colon)and(lex_class[ex_buf[
ex_buf_ptr-1]]=1))then else lower_case(ex_buf,ex_buf_ptr,1);
if(ex_buf[ex_buf_ptr]=58)then prev_colon:=true else if(lex_class[ex_buf[
ex_buf_ptr]]<>1)then prev_colon:=false;end;
1:lower_case(ex_buf,ex_buf_ptr,1);2:upper_case(ex_buf,ex_buf_ptr,1);3:;
others:case_conversion_confusion end;end{:376};ex_buf_ptr:=ex_buf_ptr+1;
end;check_brace_level(pop_lit2);end{:370};add_pool_buf_and_push;end;end;
{:364}{377:}procedure x_chr_to_int;begin pop_lit_stk(pop_lit1,pop_typ1);
if(pop_typ1<>1)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,1);
push_lit_stk(0,0);
end else if((str_start[pop_lit1+1]-str_start[pop_lit1])<>1)then begin
begin write(log_file,'"');write(tty,'"');end;print_a_pool_str(pop_lit1);
begin begin write(log_file,'" isn''t a single character');
write(tty,'" isn''t a single character');end;bst_ex_warn_print;end;
push_lit_stk(0,0);
end else push_lit_stk(str_pool[str_start[pop_lit1]],0);end;
{:377}{378:}procedure x_cite;
begin if(not mess_with_entries)then bst_cant_mess_with_entries_print
else push_lit_stk(cite_list[cite_ptr],1);end;
{:378}{379:}procedure x_duplicate;begin pop_lit_stk(pop_lit1,pop_typ1);
if(pop_typ1<>1)then begin push_lit_stk(pop_lit1,pop_typ1);
push_lit_stk(pop_lit1,pop_typ1);
end else begin begin if(lit_stack[lit_stk_ptr]>=cmd_str_ptr)then begin
str_ptr:=str_ptr+1;pool_ptr:=str_start[str_ptr];end;
lit_stk_ptr:=lit_stk_ptr+1;end;
if(pop_lit1<cmd_str_ptr)then push_lit_stk(pop_lit1,pop_typ1)else begin
begin if(pool_ptr+(str_start[pop_lit1+1]-str_start[pop_lit1])>pool_size)
then pool_overflow;end;sp_ptr:=str_start[pop_lit1];
sp_end:=str_start[pop_lit1+1];
while(sp_ptr<sp_end)do begin begin str_pool[pool_ptr]:=str_pool[sp_ptr];
pool_ptr:=pool_ptr+1;end;sp_ptr:=sp_ptr+1;end;
push_lit_stk(make_string,1);end;end;end;{:379}{380:}procedure x_empty;
label 10;begin pop_lit_stk(pop_lit1,pop_typ1);
case(pop_typ1)of 1:{381:}begin sp_ptr:=str_start[pop_lit1];
sp_end:=str_start[pop_lit1+1];
while(sp_ptr<sp_end)do begin if(lex_class[str_pool[sp_ptr]]<>1)then
begin push_lit_stk(0,0);goto 10;end;sp_ptr:=sp_ptr+1;end;
push_lit_stk(1,0);end{:381};3:push_lit_stk(1,0);4:push_lit_stk(0,0);
others:begin print_stk_lit(pop_lit1,pop_typ1);
begin begin write(log_file,', not a string or missing field,');
write(tty,', not a string or missing field,');end;bst_ex_warn_print;end;
push_lit_stk(0,0);end end;10:end;{:380}{382:}procedure x_format_name;
label 16,17,52;begin pop_lit_stk(pop_lit1,pop_typ1);
pop_lit_stk(pop_lit2,pop_typ2);pop_lit_stk(pop_lit3,pop_typ3);
if(pop_typ1<>1)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,1);
push_lit_stk(s_null,1);
end else if(pop_typ2<>0)then begin print_wrong_stk_lit(pop_lit2,pop_typ2
,0);push_lit_stk(s_null,1);
end else if(pop_typ3<>1)then begin print_wrong_stk_lit(pop_lit3,pop_typ3
,1);push_lit_stk(s_null,1);end else begin ex_buf_length:=0;
add_buf_pool(pop_lit3);{383:}begin ex_buf_ptr:=0;num_names:=0;
while((num_names<pop_lit2)and(ex_buf_ptr<ex_buf_length))do begin
num_names:=num_names+1;ex_buf_xptr:=ex_buf_ptr;
name_scan_for_and(pop_lit3);end;
if(ex_buf_ptr<ex_buf_length)then ex_buf_ptr:=ex_buf_ptr-4;
if(num_names<pop_lit2)then begin if(pop_lit2=1)then begin write(log_file
,'There is no name in "');write(tty,'There is no name in "');
end else begin write(log_file,'There aren''t ',pop_lit2:0,' names in "')
;write(tty,'There aren''t ',pop_lit2:0,' names in "');end;
print_a_pool_str(pop_lit3);begin begin write(log_file,'"');
write(tty,'"');end;bst_ex_warn_print;end;end end{:383};
{387:}begin{388:}begin while((ex_buf_xptr<ex_buf_ptr)and(lex_class[
ex_buf[ex_buf_ptr]]=1)and(lex_class[ex_buf[ex_buf_ptr]]=4))do
ex_buf_xptr:=ex_buf_xptr+1;
while(ex_buf_ptr>ex_buf_xptr)do case(lex_class[ex_buf[ex_buf_ptr-1]])of
1,4:ex_buf_ptr:=ex_buf_ptr-1;
others:if(ex_buf[ex_buf_ptr-1]=44)then begin begin write(log_file,
'Name ',pop_lit2:0,' in "');write(tty,'Name ',pop_lit2:0,' in "');end;
print_a_pool_str(pop_lit3);
begin write(log_file,'" has a comma at the end');
write(tty,'" has a comma at the end');end;bst_ex_warn_print;
ex_buf_ptr:=ex_buf_ptr-1;end else goto 16 end;16:end{:388};
name_bf_ptr:=0;num_commas:=0;num_tokens:=0;token_starting:=true;
while(ex_buf_xptr<ex_buf_ptr)do case(ex_buf[ex_buf_xptr])of 44:{389:}
begin if(num_commas=2)then begin begin write(log_file,
'Too many commas in name ',pop_lit2:0,' of "');
write(tty,'Too many commas in name ',pop_lit2:0,' of "');end;
print_a_pool_str(pop_lit3);begin write(log_file,'"');write(tty,'"');end;
bst_ex_warn_print;end else begin num_commas:=num_commas+1;
if(num_commas=1)then comma1:=num_tokens else comma2:=num_tokens;
name_sep_char[num_tokens]:=44;end;ex_buf_xptr:=ex_buf_xptr+1;
token_starting:=true;end{:389};
123:{390:}begin brace_level:=brace_level+1;
if(token_starting)then begin name_tok[num_tokens]:=name_bf_ptr;
num_tokens:=num_tokens+1;end;
sv_buffer[name_bf_ptr]:=ex_buf[ex_buf_xptr];name_bf_ptr:=name_bf_ptr+1;
ex_buf_xptr:=ex_buf_xptr+1;
while((brace_level>0)and(ex_buf_xptr<ex_buf_ptr))do begin if(ex_buf[
ex_buf_xptr]=125)then brace_level:=brace_level-1 else if(ex_buf[
ex_buf_xptr]=123)then brace_level:=brace_level+1;
sv_buffer[name_bf_ptr]:=ex_buf[ex_buf_xptr];name_bf_ptr:=name_bf_ptr+1;
ex_buf_xptr:=ex_buf_xptr+1;end;token_starting:=false;end{:390};
125:{391:}begin if(token_starting)then begin name_tok[num_tokens]:=
name_bf_ptr;num_tokens:=num_tokens+1;end;
begin write(log_file,'Name ',pop_lit2:0,' of "');
write(tty,'Name ',pop_lit2:0,' of "');end;print_a_pool_str(pop_lit3);
begin begin write(log_file,'" isn''t brace balanced');
write(tty,'" isn''t brace balanced');end;bst_ex_warn_print;end;
ex_buf_xptr:=ex_buf_xptr+1;token_starting:=false;end{:391};
others:case(lex_class[ex_buf[ex_buf_xptr]])of 1:{392:}begin if(not
token_starting)then name_sep_char[num_tokens]:=32;
ex_buf_xptr:=ex_buf_xptr+1;token_starting:=true;end{:392};
4:{393:}begin if(not token_starting)then name_sep_char[num_tokens]:=
ex_buf[ex_buf_xptr];ex_buf_xptr:=ex_buf_xptr+1;token_starting:=true;
end{:393};
others:{394:}begin if(token_starting)then begin name_tok[num_tokens]:=
name_bf_ptr;num_tokens:=num_tokens+1;end;
sv_buffer[name_bf_ptr]:=ex_buf[ex_buf_xptr];name_bf_ptr:=name_bf_ptr+1;
ex_buf_xptr:=ex_buf_xptr+1;token_starting:=false;end{:394}end end;
name_tok[num_tokens]:=name_bf_ptr;end{:387};
{395:}begin if(num_commas=0)then begin first_start:=0;
last_end:=num_tokens;jr_end:=last_end;{396:}begin von_start:=0;
while(von_start<last_end-1)do begin name_bf_ptr:=name_tok[von_start];
name_bf_xptr:=name_tok[von_start+1];
if(von_token_found)then begin von_name_ends_and_last_name_starts_stuff;
goto 52;end;von_start:=von_start+1;end;
while(von_start>0)do begin if((lex_class[name_sep_char[von_start]]<>4)or
(name_sep_char[von_start]=126))then goto 17;von_start:=von_start-1;end;
17:von_end:=von_start;52:first_end:=von_start;end{:396};
end else if(num_commas=1)then begin von_start:=0;last_end:=comma1;
jr_end:=last_end;first_start:=jr_end;first_end:=num_tokens;
von_name_ends_and_last_name_starts_stuff;
end else if(num_commas=2)then begin von_start:=0;last_end:=comma1;
jr_end:=comma2;first_start:=jr_end;first_end:=num_tokens;
von_name_ends_and_last_name_starts_stuff;
end else begin begin write(log_file,'Illegal number of comma,s');
write(tty,'Illegal number of comma,s');end;print_confusion;goto 9998;
end;end{:395};ex_buf_length:=0;add_buf_pool(pop_lit1);
figure_out_the_formatted_name;add_pool_buf_and_push;end;end;
{:382}{422:}procedure x_int_to_chr;begin pop_lit_stk(pop_lit1,pop_typ1);
if(pop_typ1<>0)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,0);
push_lit_stk(s_null,1);
end else if((pop_lit1<0)or(pop_lit1>127))then begin begin begin write(
log_file,pop_lit1:0,' isn''t valid ASCII');
write(tty,pop_lit1:0,' isn''t valid ASCII');end;bst_ex_warn_print;end;
push_lit_stk(s_null,1);
end else begin begin if(pool_ptr+1>pool_size)then pool_overflow;end;
begin str_pool[pool_ptr]:=pop_lit1;pool_ptr:=pool_ptr+1;end;
push_lit_stk(make_string,1);end;end;{:422}{423:}procedure x_int_to_str;
begin pop_lit_stk(pop_lit1,pop_typ1);
if(pop_typ1<>0)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,0);
push_lit_stk(s_null,1);
end else begin int_to_ASCII(pop_lit1,ex_buf,0,ex_buf_length);
add_pool_buf_and_push;end;end;{:423}{424:}procedure x_missing;
begin pop_lit_stk(pop_lit1,pop_typ1);
if(not mess_with_entries)then bst_cant_mess_with_entries_print else if((
pop_typ1<>1)and(pop_typ1<>3))then begin if(pop_typ1<>4)then begin
print_stk_lit(pop_lit1,pop_typ1);
begin begin write(log_file,', not a string or missing field,');
write(tty,', not a string or missing field,');end;bst_ex_warn_print;end;
end;push_lit_stk(0,0);
end else if(pop_typ1=3)then push_lit_stk(1,0)else push_lit_stk(0,0);end;
{:424}{426:}procedure x_num_names;begin pop_lit_stk(pop_lit1,pop_typ1);
if(pop_typ1<>1)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,1);
push_lit_stk(0,0);end else begin ex_buf_length:=0;
add_buf_pool(pop_lit1);{427:}begin ex_buf_ptr:=0;num_names:=0;
while(ex_buf_ptr<ex_buf_length)do begin name_scan_for_and(pop_lit1);
num_names:=num_names+1;end;end{:427};push_lit_stk(num_names,0);end;end;
{:426}{429:}procedure x_preamble;begin ex_buf_length:=0;preamble_ptr:=0;
while(preamble_ptr<num_preamble_strings)do begin add_buf_pool(s_preamble
[preamble_ptr]);preamble_ptr:=preamble_ptr+1;end;add_pool_buf_and_push;
end;{:429}{430:}procedure x_purify;begin pop_lit_stk(pop_lit1,pop_typ1);
if(pop_typ1<>1)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,1);
push_lit_stk(s_null,1);end else begin ex_buf_length:=0;
add_buf_pool(pop_lit1);{431:}begin brace_level:=0;ex_buf_xptr:=0;
ex_buf_ptr:=0;
while(ex_buf_ptr<ex_buf_length)do begin case(lex_class[ex_buf[ex_buf_ptr
]])of 1,4:begin ex_buf[ex_buf_xptr]:=32;ex_buf_xptr:=ex_buf_xptr+1;end;
2,3:begin ex_buf[ex_buf_xptr]:=ex_buf[ex_buf_ptr];
ex_buf_xptr:=ex_buf_xptr+1;end;
others:if(ex_buf[ex_buf_ptr]=123)then begin brace_level:=brace_level+1;
if((brace_level=1)and(ex_buf_ptr+1<ex_buf_length))then if(ex_buf[
ex_buf_ptr+1]=92)then{432:}begin ex_buf_ptr:=ex_buf_ptr+1;
while((ex_buf_ptr<ex_buf_length)and(brace_level>0))do begin ex_buf_ptr:=
ex_buf_ptr+1;ex_buf_yptr:=ex_buf_ptr;
while((ex_buf_ptr<ex_buf_length)and(lex_class[ex_buf[ex_buf_ptr]]=2))do
ex_buf_ptr:=ex_buf_ptr+1;
control_seq_loc:=str_lookup(ex_buf,ex_buf_yptr,ex_buf_ptr-ex_buf_yptr,14
,false);
if(hash_found)then{433:}begin ex_buf[ex_buf_xptr]:=ex_buf[ex_buf_yptr];
ex_buf_xptr:=ex_buf_xptr+1;
case(ilk_info[control_seq_loc])of 2,3,4,5,12:begin ex_buf[ex_buf_xptr]:=
ex_buf[ex_buf_yptr+1];ex_buf_xptr:=ex_buf_xptr+1;end;others:end;
end{:433};
while((ex_buf_ptr<ex_buf_length)and(brace_level>0)and(ex_buf[ex_buf_ptr]
<>92))do begin case(lex_class[ex_buf[ex_buf_ptr]])of 2,3:begin ex_buf[
ex_buf_xptr]:=ex_buf[ex_buf_ptr];ex_buf_xptr:=ex_buf_xptr+1;end;
others:if(ex_buf[ex_buf_ptr]=125)then brace_level:=brace_level-1 else if
(ex_buf[ex_buf_ptr]=123)then brace_level:=brace_level+1 end;
ex_buf_ptr:=ex_buf_ptr+1;end;end;ex_buf_ptr:=ex_buf_ptr-1;end{:432};
end else if(ex_buf[ex_buf_ptr]=125)then if(brace_level>0)then
brace_level:=brace_level-1 end;ex_buf_ptr:=ex_buf_ptr+1;end;
ex_buf_length:=ex_buf_xptr;end{:431};add_pool_buf_and_push;end;end;
{:430}{434:}procedure x_quote;
begin begin if(pool_ptr+1>pool_size)then pool_overflow;end;
begin str_pool[pool_ptr]:=34;pool_ptr:=pool_ptr+1;end;
push_lit_stk(make_string,1);end;{:434}{437:}procedure x_substring;
label 10;begin pop_lit_stk(pop_lit1,pop_typ1);
pop_lit_stk(pop_lit2,pop_typ2);pop_lit_stk(pop_lit3,pop_typ3);
if(pop_typ1<>0)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,0);
push_lit_stk(s_null,1);
end else if(pop_typ2<>0)then begin print_wrong_stk_lit(pop_lit2,pop_typ2
,0);push_lit_stk(s_null,1);
end else if(pop_typ3<>1)then begin print_wrong_stk_lit(pop_lit3,pop_typ3
,1);push_lit_stk(s_null,1);
end else begin sp_length:=(str_start[pop_lit3+1]-str_start[pop_lit3]);
if(pop_lit1>=sp_length)then if((pop_lit2=1)or(pop_lit2=-1))then begin
begin if(lit_stack[lit_stk_ptr]>=cmd_str_ptr)then begin str_ptr:=str_ptr
+1;pool_ptr:=str_start[str_ptr];end;lit_stk_ptr:=lit_stk_ptr+1;end;
goto 10;end;
if((pop_lit1<=0)or(pop_lit2=0)or(pop_lit2>sp_length)or(pop_lit2<-
sp_length))then begin push_lit_stk(s_null,1);goto 10;
end else{438:}begin if(pop_lit2>0)then begin if(pop_lit1>sp_length-(
pop_lit2-1))then pop_lit1:=sp_length-(pop_lit2-1);
sp_ptr:=str_start[pop_lit3]+(pop_lit2-1);sp_end:=sp_ptr+pop_lit1;
if(pop_lit2=1)then if(pop_lit3>=cmd_str_ptr)then begin str_start[
pop_lit3+1]:=sp_end;begin str_ptr:=str_ptr+1;
pool_ptr:=str_start[str_ptr];end;lit_stk_ptr:=lit_stk_ptr+1;goto 10;end;
end else begin pop_lit2:=-pop_lit2;
if(pop_lit1>sp_length-(pop_lit2-1))then pop_lit1:=sp_length-(pop_lit2-1)
;sp_end:=str_start[pop_lit3+1]-(pop_lit2-1);sp_ptr:=sp_end-pop_lit1;end;
while(sp_ptr<sp_end)do begin begin str_pool[pool_ptr]:=str_pool[sp_ptr];
pool_ptr:=pool_ptr+1;end;sp_ptr:=sp_ptr+1;end;
push_lit_stk(make_string,1);end{:438};end;10:end;
{:437}{439:}procedure x_swap;begin pop_lit_stk(pop_lit1,pop_typ1);
pop_lit_stk(pop_lit2,pop_typ2);
if((pop_typ1<>1)or(pop_lit1<cmd_str_ptr))then begin push_lit_stk(
pop_lit1,pop_typ1);
if((pop_typ2=1)and(pop_lit2>=cmd_str_ptr))then begin str_ptr:=str_ptr+1;
pool_ptr:=str_start[str_ptr];end;push_lit_stk(pop_lit2,pop_typ2);
end else if((pop_typ2<>1)or(pop_lit2<cmd_str_ptr))then begin begin
str_ptr:=str_ptr+1;pool_ptr:=str_start[str_ptr];end;
push_lit_stk(pop_lit1,1);push_lit_stk(pop_lit2,pop_typ2);
end else{440:}begin ex_buf_length:=0;add_buf_pool(pop_lit2);
sp_ptr:=str_start[pop_lit1];sp_end:=str_start[pop_lit1+1];
while(sp_ptr<sp_end)do begin begin str_pool[pool_ptr]:=str_pool[sp_ptr];
pool_ptr:=pool_ptr+1;end;sp_ptr:=sp_ptr+1;end;
push_lit_stk(make_string,1);add_pool_buf_and_push;end{:440};end;
{:439}{441:}procedure x_text_length;
begin pop_lit_stk(pop_lit1,pop_typ1);
if(pop_typ1<>1)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,1);
push_lit_stk(s_null,1);end else begin num_text_chars:=0;
{442:}begin sp_ptr:=str_start[pop_lit1];sp_end:=str_start[pop_lit1+1];
sp_brace_level:=0;while(sp_ptr<sp_end)do begin sp_ptr:=sp_ptr+1;
if(str_pool[sp_ptr-1]=123)then begin sp_brace_level:=sp_brace_level+1;
if((sp_brace_level=1)and(sp_ptr<sp_end))then if(str_pool[sp_ptr]=92)then
begin sp_ptr:=sp_ptr+1;
while((sp_ptr<sp_end)and(sp_brace_level>0))do begin if(str_pool[sp_ptr]=
125)then sp_brace_level:=sp_brace_level-1 else if(str_pool[sp_ptr]=123)
then sp_brace_level:=sp_brace_level+1;sp_ptr:=sp_ptr+1;end;
num_text_chars:=num_text_chars+1;end;
end else if(str_pool[sp_ptr-1]=125)then begin if(sp_brace_level>0)then
sp_brace_level:=sp_brace_level-1;
end else num_text_chars:=num_text_chars+1;end;end{:442};
push_lit_stk(num_text_chars,0);end;end;
{:441}{443:}procedure x_text_prefix;label 10;
begin pop_lit_stk(pop_lit1,pop_typ1);pop_lit_stk(pop_lit2,pop_typ2);
if(pop_typ1<>0)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,0);
push_lit_stk(s_null,1);
end else if(pop_typ2<>1)then begin print_wrong_stk_lit(pop_lit2,pop_typ2
,1);push_lit_stk(s_null,1);
end else if(pop_lit1<=0)then begin push_lit_stk(s_null,1);goto 10;
end else{444:}begin sp_ptr:=str_start[pop_lit2];
sp_end:=str_start[pop_lit2+1];{445:}begin num_text_chars:=0;
sp_brace_level:=0;sp_xptr1:=sp_ptr;
while((sp_xptr1<sp_end)and(num_text_chars<pop_lit1))do begin sp_xptr1:=
sp_xptr1+1;
if(str_pool[sp_xptr1-1]=123)then begin sp_brace_level:=sp_brace_level+1;
if((sp_brace_level=1)and(sp_xptr1<sp_end))then if(str_pool[sp_xptr1]=92)
then begin sp_xptr1:=sp_xptr1+1;
while((sp_xptr1<sp_end)and(sp_brace_level>0))do begin if(str_pool[
sp_xptr1]=125)then sp_brace_level:=sp_brace_level-1 else if(str_pool[
sp_xptr1]=123)then sp_brace_level:=sp_brace_level+1;
sp_xptr1:=sp_xptr1+1;end;num_text_chars:=num_text_chars+1;end;
end else if(str_pool[sp_xptr1-1]=125)then begin if(sp_brace_level>0)then
sp_brace_level:=sp_brace_level-1;
end else num_text_chars:=num_text_chars+1;end;sp_end:=sp_xptr1;
end{:445};
if(pop_lit2>=cmd_str_ptr)then pool_ptr:=sp_end else while(sp_ptr<sp_end)
do begin begin str_pool[pool_ptr]:=str_pool[sp_ptr];
pool_ptr:=pool_ptr+1;end;sp_ptr:=sp_ptr+1;end;
while(sp_brace_level>0)do begin begin str_pool[pool_ptr]:=125;
pool_ptr:=pool_ptr+1;end;sp_brace_level:=sp_brace_level-1;end;
push_lit_stk(make_string,1);end{:444};10:end;
{:443}{447:}procedure x_type;
begin if(not mess_with_entries)then bst_cant_mess_with_entries_print
else if((type_list[cite_ptr]=5001)or(type_list[cite_ptr]=0))then
push_lit_stk(s_null,1)else push_lit_stk(hash_text[type_list[cite_ptr]],1
);end;{:447}{448:}procedure x_warning;
begin pop_lit_stk(pop_lit1,pop_typ1);
if(pop_typ1<>1)then print_wrong_stk_lit(pop_lit1,pop_typ1,1)else begin
begin write(log_file,'Warning--');write(tty,'Warning--');end;
print_lit(pop_lit1,pop_typ1);mark_warning;end;end;
{:448}{450:}procedure x_width;begin pop_lit_stk(pop_lit1,pop_typ1);
if(pop_typ1<>1)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,1);
push_lit_stk(0,0);end else begin ex_buf_length:=0;
add_buf_pool(pop_lit1);string_width:=0;{451:}begin brace_level:=0;
ex_buf_ptr:=0;
while(ex_buf_ptr<ex_buf_length)do begin if(ex_buf[ex_buf_ptr]=123)then
begin brace_level:=brace_level+1;
if((brace_level=1)and(ex_buf_ptr+1<ex_buf_length))then if(ex_buf[
ex_buf_ptr+1]=92)then{452:}begin ex_buf_ptr:=ex_buf_ptr+1;
while((ex_buf_ptr<ex_buf_length)and(brace_level>0))do begin ex_buf_ptr:=
ex_buf_ptr+1;ex_buf_xptr:=ex_buf_ptr;
while((ex_buf_ptr<ex_buf_length)and(lex_class[ex_buf[ex_buf_ptr]]=2))do
ex_buf_ptr:=ex_buf_ptr+1;
if((ex_buf_ptr<ex_buf_length)and(ex_buf_ptr=ex_buf_xptr))then ex_buf_ptr
:=ex_buf_ptr+1 else begin control_seq_loc:=str_lookup(ex_buf,ex_buf_xptr
,ex_buf_ptr-ex_buf_xptr,14,false);
if(hash_found)then{453:}begin case(ilk_info[control_seq_loc])of 12:
string_width:=string_width+500;4:string_width:=string_width+722;
2:string_width:=string_width+778;5:string_width:=string_width+903;
3:string_width:=string_width+1014;
others:string_width:=string_width+char_width[ex_buf[ex_buf_xptr]]end;
end{:453};end;
while((ex_buf_ptr<ex_buf_length)and(lex_class[ex_buf[ex_buf_ptr]]=1))do
ex_buf_ptr:=ex_buf_ptr+1;
while((ex_buf_ptr<ex_buf_length)and(brace_level>0)and(ex_buf[ex_buf_ptr]
<>92))do begin if(ex_buf[ex_buf_ptr]=125)then brace_level:=brace_level-1
else if(ex_buf[ex_buf_ptr]=123)then brace_level:=brace_level+1 else
string_width:=string_width+char_width[ex_buf[ex_buf_ptr]];
ex_buf_ptr:=ex_buf_ptr+1;end;end;ex_buf_ptr:=ex_buf_ptr-1;
end{:452}else string_width:=string_width+char_width[123]else
string_width:=string_width+char_width[123];
end else if(ex_buf[ex_buf_ptr]=125)then begin decr_brace_level(pop_lit1)
;string_width:=string_width+char_width[125];
end else string_width:=string_width+char_width[ex_buf[ex_buf_ptr]];
ex_buf_ptr:=ex_buf_ptr+1;end;check_brace_level(pop_lit1);end{:451};
push_lit_stk(string_width,0);end end;{:450}{454:}procedure x_write;
begin pop_lit_stk(pop_lit1,pop_typ1);
if(pop_typ1<>1)then print_wrong_stk_lit(pop_lit1,pop_typ1,1)else
add_out_pool(pop_lit1);end;
{:454}{325:}procedure execute_fn(ex_fn_loc:hash_loc);{343:}label 51;
var r_pop_lt1,r_pop_lt2:integer;r_pop_tp1,r_pop_tp2:stk_type;
{:343}wiz_ptr:wiz_fn_loc;begin{begin write(log_file,'execute_fn `');end;
begin out_pool_str(log_file,hash_text[ex_fn_loc]);end;
begin write_ln(log_file,'''');end;}
case(fn_type[ex_fn_loc])of 0:{341:}begin{execution_count[ilk_info[
ex_fn_loc]]:=execution_count[ilk_info[ex_fn_loc]]+1;}
case(ilk_info[ex_fn_loc])of 0:x_equals;1:x_greater_than;2:x_less_than;
3:x_plus;4:x_minus;5:x_concatenate;6:x_gets;7:x_add_period;
8:{363:}begin if(not mess_with_entries)then
bst_cant_mess_with_entries_print else if(type_list[cite_ptr]=5001)then
execute_fn(b_default)else if(type_list[cite_ptr]=0)then else execute_fn(
type_list[cite_ptr]);end{:363};9:x_change_case;10:x_chr_to_int;
11:x_cite;12:x_duplicate;13:x_empty;14:x_format_name;
15:{421:}begin pop_lit_stk(pop_lit1,pop_typ1);
pop_lit_stk(pop_lit2,pop_typ2);pop_lit_stk(pop_lit3,pop_typ3);
if(pop_typ1<>2)then print_wrong_stk_lit(pop_lit1,pop_typ1,2)else if(
pop_typ2<>2)then print_wrong_stk_lit(pop_lit2,pop_typ2,2)else if(
pop_typ3<>0)then print_wrong_stk_lit(pop_lit3,pop_typ3,0)else if(
pop_lit3>0)then execute_fn(pop_lit2)else execute_fn(pop_lit1);end{:421};
16:x_int_to_chr;17:x_int_to_str;18:x_missing;
19:{425:}begin output_bbl_line;end{:425};20:x_num_names;
21:{428:}begin pop_lit_stk(pop_lit1,pop_typ1);end{:428};22:x_preamble;
23:x_purify;24:x_quote;25:{435:}begin;end{:435};
26:{436:}begin pop_whole_stack;end{:436};27:x_substring;28:x_swap;
29:x_text_length;30:x_text_prefix;31:{446:}begin pop_top_and_print;
end{:446};32:x_type;33:x_warning;
34:{449:}begin pop_lit_stk(r_pop_lt1,r_pop_tp1);
pop_lit_stk(r_pop_lt2,r_pop_tp2);
if(r_pop_tp1<>2)then print_wrong_stk_lit(r_pop_lt1,r_pop_tp1,2)else if(
r_pop_tp2<>2)then print_wrong_stk_lit(r_pop_lt2,r_pop_tp2,2)else while
true do begin execute_fn(r_pop_lt2);pop_lit_stk(pop_lit1,pop_typ1);
if(pop_typ1<>0)then begin print_wrong_stk_lit(pop_lit1,pop_typ1,0);
goto 51;end else if(pop_lit1>0)then execute_fn(r_pop_lt1)else goto 51;
end;51:end{:449};35:x_width;36:x_write;
others:begin begin write(log_file,'Unknown built-in function');
write(tty,'Unknown built-in function');end;print_confusion;goto 9998;
end end;end{:341};1:{326:}begin wiz_ptr:=ilk_info[ex_fn_loc];
while(wiz_functions[wiz_ptr]<>5001)do begin if(wiz_functions[wiz_ptr]<>0
)then execute_fn(wiz_functions[wiz_ptr])else begin wiz_ptr:=wiz_ptr+1;
push_lit_stk(wiz_functions[wiz_ptr],2);end;wiz_ptr:=wiz_ptr+1;end;
end{:326};2:push_lit_stk(ilk_info[ex_fn_loc],0);
3:push_lit_stk(hash_text[ex_fn_loc],1);
4:{327:}begin if(not mess_with_entries)then
bst_cant_mess_with_entries_print else begin field_ptr:=cite_ptr*
num_fields+ilk_info[ex_fn_loc];
if(field_info[field_ptr]=0)then push_lit_stk(hash_text[ex_fn_loc],3)else
push_lit_stk(field_info[field_ptr],1);end end{:327};
5:{328:}begin if(not mess_with_entries)then
bst_cant_mess_with_entries_print else push_lit_stk(entry_ints[cite_ptr*
num_ent_ints+ilk_info[ex_fn_loc]],0);end{:328};
6:{329:}begin if(not mess_with_entries)then
bst_cant_mess_with_entries_print else begin str_ent_ptr:=cite_ptr*
num_ent_strs+ilk_info[ex_fn_loc];ex_buf_ptr:=0;
while(entry_strs[str_ent_ptr][ex_buf_ptr]<>127)do begin ex_buf[
ex_buf_ptr]:=entry_strs[str_ent_ptr][ex_buf_ptr];
ex_buf_ptr:=ex_buf_ptr+1;end;ex_buf_length:=ex_buf_ptr;
add_pool_buf_and_push;end;end{:329};
7:push_lit_stk(ilk_info[ex_fn_loc],0);
8:{330:}begin str_glb_ptr:=ilk_info[ex_fn_loc];
if(glb_str_ptr[str_glb_ptr]>0)then push_lit_stk(glb_str_ptr[str_glb_ptr]
,1)else begin begin if(pool_ptr+glb_str_end[str_glb_ptr]>pool_size)then
pool_overflow;end;glob_chr_ptr:=0;
while(glob_chr_ptr<glb_str_end[str_glb_ptr])do begin begin str_pool[
pool_ptr]:=global_strs[str_glb_ptr][glob_chr_ptr];pool_ptr:=pool_ptr+1;
end;glob_chr_ptr:=glob_chr_ptr+1;end;push_lit_stk(make_string,1);end;
end{:330};others:unknwn_function_class_confusion end;end;
{:325}{:342}{100:}procedure get_the_top_level_aux_file_name;label 41,46;
var{101:}check_cmnd_line:boolean;{:101}begin check_cmnd_line:=false;
while true do begin if(check_cmnd_line)then{102:}begin;
end{:102}else begin write(tty,
'Please type input file name (no extension)--');
if(eoln(tty))then read_ln(tty);aux_name_length:=0;
while(not eoln(tty))do begin if(aux_name_length=40)then begin while(not
eoln(tty))do get(tty);begin sam_too_long_file_name_print;goto 46;end;
end;aux_name_length:=aux_name_length+1;
name_of_file[aux_name_length]:=tty^;get(tty);end;end;
{103:}begin if((aux_name_length+(str_start[s_aux_extension+1]-str_start[
s_aux_extension])>40)or(aux_name_length+(str_start[s_log_extension+1]-
str_start[s_log_extension])>40)or(aux_name_length+(str_start[
s_bbl_extension+1]-str_start[s_bbl_extension])>40))then begin
sam_too_long_file_name_print;goto 46;end;
{106:}begin name_length:=aux_name_length;add_extension(s_aux_extension);
aux_ptr:=0;
if(not a_open_in(aux_file[aux_ptr]))then begin sam_wrong_file_name_print
;goto 46;end;name_length:=aux_name_length;
add_extension(s_log_extension);
if(not a_open_out(log_file))then begin sam_wrong_file_name_print;
goto 46;end;name_length:=aux_name_length;add_extension(s_bbl_extension);
if(not a_open_out(bbl_file))then begin sam_wrong_file_name_print;
goto 46;end;end{:106};{107:}begin name_length:=aux_name_length;
add_extension(s_aux_extension);name_ptr:=1;
while(name_ptr<=name_length)do begin buffer[name_ptr]:=xord[name_of_file
[name_ptr]];name_ptr:=name_ptr+1;end;
top_lev_str:=hash_text[str_lookup(buffer,1,aux_name_length,0,true)];
aux_list[aux_ptr]:=hash_text[str_lookup(buffer,1,name_length,3,true)];
if(hash_found)then begin{print_aux_name;}
begin begin write(log_file,'Already encountered auxiliary file');
write(tty,'Already encountered auxiliary file');end;print_confusion;
goto 9998;end;end;aux_ln_stack[aux_ptr]:=0;end{:107};goto 41;end{:103};
46:check_cmnd_line:=false;end;41:end;
{:100}{120:}procedure aux_bib_data_command;label 10;
begin if(bib_seen)then begin aux_err_illegal_another_print(0);
begin aux_err_print;goto 10;end;end;bib_seen:=true;
while(buffer[buf_ptr2]<>125)do begin buf_ptr2:=buf_ptr2+1;
if(not scan2_white(125,44))then begin aux_err_no_right_brace_print;
begin aux_err_print;goto 10;end;end;
if(lex_class[buffer[buf_ptr2]]=1)then begin
aux_err_white_space_in_argument_print;begin aux_err_print;goto 10;end;
end;if((last>buf_ptr2+1)and(buffer[buf_ptr2]=125))then begin
aux_err_stuff_after_right_brace_print;begin aux_err_print;goto 10;end;
end;{123:}begin if(bib_ptr=max_bib_files)then begin print_overflow;
begin write_ln(log_file,'number of database files ',max_bib_files:0);
write_ln(tty,'number of database files ',max_bib_files:0);end;goto 9998;
end;bib_list[bib_ptr]:=hash_text[str_lookup(buffer,buf_ptr1,(buf_ptr2-
buf_ptr1),6,true)];if(hash_found)then begin begin write(log_file,
'This database file appears more than once: ');
write(tty,'This database file appears more than once: ');end;
print_bib_name;begin aux_err_print;goto 10;end;end;
start_name(bib_list[bib_ptr]);add_extension(s_bib_extension);
if(not a_open_in(bib_file[bib_ptr]))then begin add_area(s_bib_area);
if(not a_open_in(bib_file[bib_ptr]))then begin begin write(log_file,
'I couldn''t open database file ');
write(tty,'I couldn''t open database file ');end;print_bib_name;
begin aux_err_print;goto 10;end;end;end;
{begin out_pool_str(log_file,bib_list[bib_ptr]);end;
begin out_pool_str(log_file,s_bib_extension);end;
begin write_ln(log_file,' is a bibdata file');end;}bib_ptr:=bib_ptr+1;
end{:123};end;10:end;{:120}{126:}procedure aux_bib_style_command;
label 10;begin if(bst_seen)then begin aux_err_illegal_another_print(1);
begin aux_err_print;goto 10;end;end;bst_seen:=true;buf_ptr2:=buf_ptr2+1;
if(not scan1_white(125))then begin aux_err_no_right_brace_print;
begin aux_err_print;goto 10;end;end;
if(lex_class[buffer[buf_ptr2]]=1)then begin
aux_err_white_space_in_argument_print;begin aux_err_print;goto 10;end;
end;if(last>buf_ptr2+1)then begin aux_err_stuff_after_right_brace_print;
begin aux_err_print;goto 10;end;end;
{127:}begin bst_str:=hash_text[str_lookup(buffer,buf_ptr1,(buf_ptr2-
buf_ptr1),5,true)];if(hash_found)then begin{print_bst_name;}
begin begin write(log_file,'Already encountered style file');
write(tty,'Already encountered style file');end;print_confusion;
goto 9998;end;end;start_name(bst_str);add_extension(s_bst_extension);
if(not a_open_in(bst_file))then begin add_area(s_bst_area);
if(not a_open_in(bst_file))then begin begin write(log_file,
'I couldn''t open style file ');
write(tty,'I couldn''t open style file ');end;print_bst_name;bst_str:=0;
begin aux_err_print;goto 10;end;end;end;
begin write(log_file,'The style file: ');write(tty,'The style file: ');
end;print_bst_name;end{:127};10:end;
{:126}{132:}procedure aux_citation_command;label 23,10;
begin citation_seen:=true;
while(buffer[buf_ptr2]<>125)do begin buf_ptr2:=buf_ptr2+1;
if(not scan2_white(125,44))then begin aux_err_no_right_brace_print;
begin aux_err_print;goto 10;end;end;
if(lex_class[buffer[buf_ptr2]]=1)then begin
aux_err_white_space_in_argument_print;begin aux_err_print;goto 10;end;
end;if((last>buf_ptr2+1)and(buffer[buf_ptr2]=125))then begin
aux_err_stuff_after_right_brace_print;begin aux_err_print;goto 10;end;
end;{133:}begin{begin out_token(log_file);end;
begin write(log_file,' cite key encountered');end;}
{134:}begin if((buf_ptr2-buf_ptr1)=1)then if(buffer[buf_ptr1]=42)then
begin{begin write_ln(log_file,'---entire database to be included');end;}
if(all_entries)then begin begin write_ln(log_file,
'Multiple inclusions of entire database');
write_ln(tty,'Multiple inclusions of entire database');end;
begin aux_err_print;goto 10;end;end else begin all_entries:=true;
all_marker:=cite_ptr;goto 23;end;end;end{:134};tmp_ptr:=buf_ptr1;
while(tmp_ptr<buf_ptr2)do begin ex_buf[tmp_ptr]:=buffer[tmp_ptr];
tmp_ptr:=tmp_ptr+1;end;lower_case(ex_buf,buf_ptr1,(buf_ptr2-buf_ptr1));
lc_cite_loc:=str_lookup(ex_buf,buf_ptr1,(buf_ptr2-buf_ptr1),10,true);
if(hash_found)then{135:}begin{begin write_ln(log_file,' previously');
end;}dummy_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),9,false);
if(not hash_found)then begin begin write(log_file,
'Case mismatch error between cite keys ');
write(tty,'Case mismatch error between cite keys ');end;print_a_token;
begin write(log_file,' and ');write(tty,' and ');end;
print_a_pool_str(cite_list[ilk_info[ilk_info[lc_cite_loc]]]);
print_a_newline;begin aux_err_print;goto 10;end;end;
end{:135}else{136:}begin{begin write_ln(log_file);end;}
cite_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),9,true);
if(hash_found)then hash_cite_confusion;check_cite_overflow(cite_ptr);
cite_list[cite_ptr]:=hash_text[cite_loc];ilk_info[cite_loc]:=cite_ptr;
ilk_info[lc_cite_loc]:=cite_loc;cite_ptr:=cite_ptr+1;end{:136};
end{:133};23:end;10:end;{:132}{139:}procedure aux_input_command;
label 10;var aux_extension_ok:boolean;begin buf_ptr2:=buf_ptr2+1;
if(not scan1_white(125))then begin aux_err_no_right_brace_print;
begin aux_err_print;goto 10;end;end;
if(lex_class[buffer[buf_ptr2]]=1)then begin
aux_err_white_space_in_argument_print;begin aux_err_print;goto 10;end;
end;if(last>buf_ptr2+1)then begin aux_err_stuff_after_right_brace_print;
begin aux_err_print;goto 10;end;end;{140:}begin aux_ptr:=aux_ptr+1;
if(aux_ptr=aux_stack_size)then begin print_a_token;
begin write(log_file,': ');write(tty,': ');end;begin print_overflow;
begin write_ln(log_file,'auxiliary file depth ',aux_stack_size:0);
write_ln(tty,'auxiliary file depth ',aux_stack_size:0);end;goto 9998;
end;end;aux_extension_ok:=true;
if((buf_ptr2-buf_ptr1)<(str_start[s_aux_extension+1]-str_start[
s_aux_extension]))then aux_extension_ok:=false else if(not str_eq_buf(
s_aux_extension,buffer,buf_ptr2-(str_start[s_aux_extension+1]-str_start[
s_aux_extension]),(str_start[s_aux_extension+1]-str_start[
s_aux_extension])))then aux_extension_ok:=false;
if(not aux_extension_ok)then begin print_a_token;
begin write(log_file,' has a wrong extension');
write(tty,' has a wrong extension');end;aux_ptr:=aux_ptr-1;
begin aux_err_print;goto 10;end;end;
aux_list[aux_ptr]:=hash_text[str_lookup(buffer,buf_ptr1,(buf_ptr2-
buf_ptr1),3,true)];if(hash_found)then begin begin write(log_file,
'Already encountered file ');write(tty,'Already encountered file ');end;
print_aux_name;aux_ptr:=aux_ptr-1;begin aux_err_print;goto 10;end;end;
{141:}begin start_name(aux_list[aux_ptr]);name_ptr:=name_length+1;
while(name_ptr<=40)do begin name_of_file[name_ptr]:=' ';
name_ptr:=name_ptr+1;end;
if(not a_open_in(aux_file[aux_ptr]))then begin begin write(log_file,
'I couldn''t open auxiliary file ');
write(tty,'I couldn''t open auxiliary file ');end;print_aux_name;
aux_ptr:=aux_ptr-1;begin aux_err_print;goto 10;end;end;
begin write(log_file,'A level-',aux_ptr:0,' auxiliary file: ');
write(tty,'A level-',aux_ptr:0,' auxiliary file: ');end;print_aux_name;
aux_ln_stack[aux_ptr]:=0;end{:141};end{:140};10:end;
{:139}{142:}procedure pop_the_aux_stack;
begin a_close(aux_file[aux_ptr]);
if(aux_ptr=0)then goto 31 else aux_ptr:=aux_ptr-1;end;
{:142}{143:}{116:}procedure get_aux_command_and_process;label 10;
begin buf_ptr2:=0;if(not scan1(123))then goto 10;
command_num:=ilk_info[str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),2,
false)];if(hash_found)then case(command_num)of 0:aux_bib_data_command;
1:aux_bib_style_command;2:aux_citation_command;3:aux_input_command;
others:begin begin write(log_file,'Unknown auxiliary-file command');
write(tty,'Unknown auxiliary-file command');end;print_confusion;
goto 9998;end end;10:end;
{:116}{:143}{145:}procedure last_check_for_aux_errors;
begin num_cites:=cite_ptr;num_bib_files:=bib_ptr;
if(not citation_seen)then begin aux_end1_err_print;
begin write(log_file,'\citation commands');
write(tty,'\citation commands');end;aux_end2_err_print;
end else if((num_cites=0)and(not all_entries))then begin
aux_end1_err_print;begin write(log_file,'cite keys');
write(tty,'cite keys');end;aux_end2_err_print;end;
if(not bib_seen)then begin aux_end1_err_print;
begin write(log_file,'\bibdata command');write(tty,'\bibdata command');
end;aux_end2_err_print;
end else if(num_bib_files=0)then begin aux_end1_err_print;
begin write(log_file,'database files');write(tty,'database files');end;
aux_end2_err_print;end;if(not bst_seen)then begin aux_end1_err_print;
begin write(log_file,'\bibstyle command');
write(tty,'\bibstyle command');end;aux_end2_err_print;
end else if(bst_str=0)then begin aux_end1_err_print;
begin write(log_file,'style file');write(tty,'style file');end;
aux_end2_err_print;end;end;{:145}{170:}procedure bst_entry_command;
label 10;begin if(entry_seen)then begin begin write(log_file,
'Illegal, another entry command');
write(tty,'Illegal, another entry command');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;
entry_seen:=true;
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'entry');write(tty,'entry');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
{171:}begin begin if(buffer[buf_ptr2]<>123)then begin
bst_left_brace_print;begin begin write(log_file,'entry');
write(tty,'entry');end;begin bst_err_print_and_look_for_blank_line;
goto 10;end;end;end;buf_ptr2:=buf_ptr2+1;end;
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'entry');write(tty,'entry');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
while(buffer[buf_ptr2]<>125)do begin begin scan_identifier(125,37,37);
if((scan_result=3)or(scan_result=1))then else begin bst_id_print;
begin begin write(log_file,'entry');write(tty,'entry');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
{172:}begin{begin out_token(log_file);end;
begin write_ln(log_file,' is a field');end;}
lower_case(buffer,buf_ptr1,(buf_ptr2-buf_ptr1));
fn_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),11,true);
begin if(hash_found)then begin already_seen_function_print(fn_loc);
goto 10;end;end;fn_type[fn_loc]:=4;ilk_info[fn_loc]:=num_fields;
num_fields:=num_fields+1;end{:172};
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'entry');write(tty,'entry');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;end;
buf_ptr2:=buf_ptr2+1;end{:171};
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'entry');write(tty,'entry');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
if(num_fields=num_pre_defined_fields)then begin begin write(log_file,
'Warning--I didn''t find any fields');
write(tty,'Warning--I didn''t find any fields');end;bst_warn_print;end;
{173:}begin begin if(buffer[buf_ptr2]<>123)then begin
bst_left_brace_print;begin begin write(log_file,'entry');
write(tty,'entry');end;begin bst_err_print_and_look_for_blank_line;
goto 10;end;end;end;buf_ptr2:=buf_ptr2+1;end;
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'entry');write(tty,'entry');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
while(buffer[buf_ptr2]<>125)do begin begin scan_identifier(125,37,37);
if((scan_result=3)or(scan_result=1))then else begin bst_id_print;
begin begin write(log_file,'entry');write(tty,'entry');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
{174:}begin{begin out_token(log_file);end;
begin write_ln(log_file,' is an integer entry-variable');end;}
lower_case(buffer,buf_ptr1,(buf_ptr2-buf_ptr1));
fn_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),11,true);
begin if(hash_found)then begin already_seen_function_print(fn_loc);
goto 10;end;end;fn_type[fn_loc]:=5;ilk_info[fn_loc]:=num_ent_ints;
num_ent_ints:=num_ent_ints+1;end{:174};
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'entry');write(tty,'entry');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;end;
buf_ptr2:=buf_ptr2+1;end{:173};
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'entry');write(tty,'entry');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
{175:}begin begin if(buffer[buf_ptr2]<>123)then begin
bst_left_brace_print;begin begin write(log_file,'entry');
write(tty,'entry');end;begin bst_err_print_and_look_for_blank_line;
goto 10;end;end;end;buf_ptr2:=buf_ptr2+1;end;
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'entry');write(tty,'entry');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
while(buffer[buf_ptr2]<>125)do begin begin scan_identifier(125,37,37);
if((scan_result=3)or(scan_result=1))then else begin bst_id_print;
begin begin write(log_file,'entry');write(tty,'entry');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
{176:}begin{begin out_token(log_file);end;
begin write_ln(log_file,' is a string entry-variable');end;}
lower_case(buffer,buf_ptr1,(buf_ptr2-buf_ptr1));
fn_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),11,true);
begin if(hash_found)then begin already_seen_function_print(fn_loc);
goto 10;end;end;fn_type[fn_loc]:=6;ilk_info[fn_loc]:=num_ent_strs;
num_ent_strs:=num_ent_strs+1;end{:176};
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'entry');write(tty,'entry');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;end;
buf_ptr2:=buf_ptr2+1;end{:175};10:end;
{:170}{177:}function bad_argument_token:boolean;label 10;
begin bad_argument_token:=true;
lower_case(buffer,buf_ptr1,(buf_ptr2-buf_ptr1));
fn_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),11,false);
if(not hash_found)then begin print_a_token;
begin begin write(log_file,' is an unknown function');
write(tty,' is an unknown function');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;
end else if((fn_type[fn_loc]<>0)and(fn_type[fn_loc]<>1))then begin
print_a_token;begin write(log_file,' has bad function type ');
write(tty,' has bad function type ');end;print_fn_class(fn_loc);
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;
bad_argument_token:=false;10:end;
{:177}{178:}procedure bst_execute_command;label 10;
begin if(not read_seen)then begin begin write(log_file,
'Illegal, execute command before read command');
write(tty,'Illegal, execute command before read command');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'execute');write(tty,'execute');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
begin if(buffer[buf_ptr2]<>123)then begin bst_left_brace_print;
begin begin write(log_file,'execute');write(tty,'execute');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;
buf_ptr2:=buf_ptr2+1;end;
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'execute');write(tty,'execute');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
begin scan_identifier(125,37,37);
if((scan_result=3)or(scan_result=1))then else begin bst_id_print;
begin begin write(log_file,'execute');write(tty,'execute');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
{179:}begin{begin out_token(log_file);end;
begin write_ln(log_file,' is a to be executed function');end;}
if(bad_argument_token)then goto 10;end{:179};
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'execute');write(tty,'execute');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
begin if(buffer[buf_ptr2]<>125)then begin bst_right_brace_print;
begin begin write(log_file,'execute');write(tty,'execute');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;
buf_ptr2:=buf_ptr2+1;end;{296:}begin init_command_execution;
mess_with_entries:=false;execute_fn(fn_loc);check_command_execution;
end{:296};10:end;{:178}{180:}procedure bst_function_command;label 10;
begin begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'function');write(tty,'function');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
{181:}begin begin if(buffer[buf_ptr2]<>123)then begin
bst_left_brace_print;begin begin write(log_file,'function');
write(tty,'function');end;begin bst_err_print_and_look_for_blank_line;
goto 10;end;end;end;buf_ptr2:=buf_ptr2+1;end;
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'function');write(tty,'function');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
begin scan_identifier(125,37,37);
if((scan_result=3)or(scan_result=1))then else begin bst_id_print;
begin begin write(log_file,'function');write(tty,'function');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
{182:}begin{begin out_token(log_file);end;
begin write_ln(log_file,' is a wizard-defined function');end;}
lower_case(buffer,buf_ptr1,(buf_ptr2-buf_ptr1));
wiz_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),11,true);
begin if(hash_found)then begin already_seen_function_print(wiz_loc);
goto 10;end;end;fn_type[wiz_loc]:=1;
if(hash_text[wiz_loc]=s_default)then b_default:=wiz_loc;end{:182};
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'function');write(tty,'function');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
begin if(buffer[buf_ptr2]<>125)then begin bst_right_brace_print;
begin begin write(log_file,'function');write(tty,'function');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;
buf_ptr2:=buf_ptr2+1;end;end{:181};
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'function');write(tty,'function');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
begin if(buffer[buf_ptr2]<>123)then begin bst_left_brace_print;
begin begin write(log_file,'function');write(tty,'function');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;
buf_ptr2:=buf_ptr2+1;end;scan_fn_def(wiz_loc);10:end;
{:180}{201:}procedure bst_integers_command;label 10;
begin begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'integers');write(tty,'integers');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
begin if(buffer[buf_ptr2]<>123)then begin bst_left_brace_print;
begin begin write(log_file,'integers');write(tty,'integers');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;
buf_ptr2:=buf_ptr2+1;end;
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'integers');write(tty,'integers');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
while(buffer[buf_ptr2]<>125)do begin begin scan_identifier(125,37,37);
if((scan_result=3)or(scan_result=1))then else begin bst_id_print;
begin begin write(log_file,'integers');write(tty,'integers');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
{202:}begin{begin out_token(log_file);end;
begin write_ln(log_file,' is an integer global-variable');end;}
lower_case(buffer,buf_ptr1,(buf_ptr2-buf_ptr1));
fn_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),11,true);
begin if(hash_found)then begin already_seen_function_print(fn_loc);
goto 10;end;end;fn_type[fn_loc]:=7;ilk_info[fn_loc]:=0;end{:202};
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'integers');write(tty,'integers');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;end;
buf_ptr2:=buf_ptr2+1;10:end;{:201}{203:}procedure bst_iterate_command;
label 10;begin if(not read_seen)then begin begin write(log_file,
'Illegal, iterate command before read command');
write(tty,'Illegal, iterate command before read command');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'iterate');write(tty,'iterate');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
begin if(buffer[buf_ptr2]<>123)then begin bst_left_brace_print;
begin begin write(log_file,'iterate');write(tty,'iterate');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;
buf_ptr2:=buf_ptr2+1;end;
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'iterate');write(tty,'iterate');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
begin scan_identifier(125,37,37);
if((scan_result=3)or(scan_result=1))then else begin bst_id_print;
begin begin write(log_file,'iterate');write(tty,'iterate');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
{204:}begin{begin out_token(log_file);end;
begin write_ln(log_file,' is a to be iterated function');end;}
if(bad_argument_token)then goto 10;end{:204};
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'iterate');write(tty,'iterate');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
begin if(buffer[buf_ptr2]<>125)then begin bst_right_brace_print;
begin begin write(log_file,'iterate');write(tty,'iterate');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;
buf_ptr2:=buf_ptr2+1;end;{297:}begin init_command_execution;
mess_with_entries:=true;sort_cite_ptr:=0;
while(sort_cite_ptr<num_cites)do begin cite_ptr:=cite_info[sort_cite_ptr
];{begin out_pool_str(log_file,hash_text[fn_loc]);end;
begin write(log_file,' to be iterated on ');end;
begin out_pool_str(log_file,cite_list[cite_ptr]);end;
begin write_ln(log_file);end;}execute_fn(fn_loc);
check_command_execution;sort_cite_ptr:=sort_cite_ptr+1;end;end{:297};
10:end;{:203}{205:}procedure bst_macro_command;label 10;
begin if(read_seen)then begin begin write(log_file,
'Illegal, macro command after read command');
write(tty,'Illegal, macro command after read command');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'macro');write(tty,'macro');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
{206:}begin begin if(buffer[buf_ptr2]<>123)then begin
bst_left_brace_print;begin begin write(log_file,'macro');
write(tty,'macro');end;begin bst_err_print_and_look_for_blank_line;
goto 10;end;end;end;buf_ptr2:=buf_ptr2+1;end;
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'macro');write(tty,'macro');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
begin scan_identifier(125,37,37);
if((scan_result=3)or(scan_result=1))then else begin bst_id_print;
begin begin write(log_file,'macro');write(tty,'macro');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
{207:}begin{begin out_token(log_file);end;
begin write_ln(log_file,' is a macro');end;}
lower_case(buffer,buf_ptr1,(buf_ptr2-buf_ptr1));
macro_name_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),13,true);
if(hash_found)then begin print_a_token;
begin begin write(log_file,' is already defined as a macro');
write(tty,' is already defined as a macro');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;
ilk_info[macro_name_loc]:=hash_text[macro_name_loc];end{:207};
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'macro');write(tty,'macro');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
begin if(buffer[buf_ptr2]<>125)then begin bst_right_brace_print;
begin begin write(log_file,'macro');write(tty,'macro');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;
buf_ptr2:=buf_ptr2+1;end;end{:206};
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'macro');write(tty,'macro');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
{208:}begin begin if(buffer[buf_ptr2]<>123)then begin
bst_left_brace_print;begin begin write(log_file,'macro');
write(tty,'macro');end;begin bst_err_print_and_look_for_blank_line;
goto 10;end;end;end;buf_ptr2:=buf_ptr2+1;end;
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'macro');write(tty,'macro');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
if(buffer[buf_ptr2]<>34)then begin begin write(log_file,
'A macro definition must be ',xchr[34],'-delimited');
write(tty,'A macro definition must be ',xchr[34],'-delimited');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;
{209:}begin buf_ptr2:=buf_ptr2+1;
if(not scan1(34))then begin begin write(log_file,'There''s no `',xchr[34
],''' to end macro definition');
write(tty,'There''s no `',xchr[34],''' to end macro definition');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;
{begin write(log_file,'"');end;begin out_token(log_file);end;
begin write(log_file,'"');end;
begin write_ln(log_file,' is a macro string');end;}
macro_def_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),0,true);
fn_type[macro_def_loc]:=3;
ilk_info[macro_name_loc]:=hash_text[macro_def_loc];buf_ptr2:=buf_ptr2+1;
end{:209};begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'macro');write(tty,'macro');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
begin if(buffer[buf_ptr2]<>125)then begin bst_right_brace_print;
begin begin write(log_file,'macro');write(tty,'macro');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;
buf_ptr2:=buf_ptr2+1;end;end{:208};10:end;
{:205}{210:}{236:}procedure get_bib_command_or_entry_and_process;
label 22,26,15,10;begin at_bib_command:=false;
{237:}while(not scan1(64))do begin if(not input_ln(bib_file[bib_ptr]))
then goto 10;bib_line_num:=bib_line_num+1;buf_ptr2:=0;end{:237};
{238:}begin if(buffer[buf_ptr2]<>64)then begin begin write(log_file,
'An "',xchr[64],'" disappeared');
write(tty,'An "',xchr[64],'" disappeared');end;print_confusion;
goto 9998;end;buf_ptr2:=buf_ptr2+1;
begin if(not eat_bib_white_space)then begin eat_bib_print;goto 10;end;
end;scan_identifier(123,40,40);
begin if((scan_result=3)or(scan_result=1))then else begin bib_id_print;
begin begin write(log_file,'an entry type');write(tty,'an entry type');
end;bib_err_print;goto 10;end;end;end;{begin out_token(log_file);end;
begin write_ln(log_file,' is an entry type or a database-file command');
end;}lower_case(buffer,buf_ptr1,(buf_ptr2-buf_ptr1));
command_num:=ilk_info[str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),12,
false)];if(hash_found)then{239:}begin at_bib_command:=true;
case(command_num)of 0:{241:}begin goto 10;end{:241};
1:{242:}begin if(preamble_ptr=max_bib_files)then begin begin write(
log_file,'You''ve exceeded ',max_bib_files:0,' preamble commands');
write(tty,'You''ve exceeded ',max_bib_files:0,' preamble commands');end;
bib_err_print;goto 10;end;
begin if(not eat_bib_white_space)then begin eat_bib_print;goto 10;end;
end;if(buffer[buf_ptr2]=123)then right_outer_delim:=125 else if(buffer[
buf_ptr2]=40)then right_outer_delim:=41 else begin bib_one_of_two_print(
123,40);goto 10;end;buf_ptr2:=buf_ptr2+1;
begin if(not eat_bib_white_space)then begin eat_bib_print;goto 10;end;
end;store_field:=true;
if(not scan_and_store_the_field_value_and_eat_white)then goto 10;
if(buffer[buf_ptr2]<>right_outer_delim)then begin begin write(log_file,
'Missing "',xchr[right_outer_delim],'" in preamble command');
write(tty,'Missing "',xchr[right_outer_delim],'" in preamble command');
end;bib_err_print;goto 10;end;buf_ptr2:=buf_ptr2+1;goto 10;end{:242};
2:{243:}begin begin if(not eat_bib_white_space)then begin eat_bib_print;
goto 10;end;end;
{244:}begin if(buffer[buf_ptr2]=123)then right_outer_delim:=125 else if(
buffer[buf_ptr2]=40)then right_outer_delim:=41 else begin
bib_one_of_two_print(123,40);goto 10;end;buf_ptr2:=buf_ptr2+1;
begin if(not eat_bib_white_space)then begin eat_bib_print;goto 10;end;
end;scan_identifier(61,61,61);
begin if((scan_result=3)or(scan_result=1))then else begin bib_id_print;
begin begin write(log_file,'a string name');write(tty,'a string name');
end;bib_err_print;goto 10;end;end;end;
{245:}begin{begin out_token(log_file);end;
begin write_ln(log_file,' is a database-defined macro');end;}
lower_case(buffer,buf_ptr1,(buf_ptr2-buf_ptr1));
cur_macro_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),13,true);
ilk_info[cur_macro_loc]:=hash_text[cur_macro_loc];
{if(hash_found)then begin macro_warn_print;
begin begin write_ln(log_file,'having its definition overwritten');
write_ln(tty,'having its definition overwritten');end;bib_warn_print;
end;end;}end{:245};end{:244};
begin if(not eat_bib_white_space)then begin eat_bib_print;goto 10;end;
end;
{246:}begin if(buffer[buf_ptr2]<>61)then begin bib_equals_sign_print;
goto 10;end;buf_ptr2:=buf_ptr2+1;
begin if(not eat_bib_white_space)then begin eat_bib_print;goto 10;end;
end;store_field:=true;
if(not scan_and_store_the_field_value_and_eat_white)then goto 10;
if(buffer[buf_ptr2]<>right_outer_delim)then begin begin write(log_file,
'Missing "',xchr[right_outer_delim],'" in string command');
write(tty,'Missing "',xchr[right_outer_delim],'" in string command');
end;bib_err_print;goto 10;end;buf_ptr2:=buf_ptr2+1;end{:246};goto 10;
end{:243};others:bib_cmd_confusion end;
end{:239}else begin entry_type_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2
-buf_ptr1),11,false);
if((not hash_found)or(fn_type[entry_type_loc]<>1))then type_exists:=
false else type_exists:=true;end;end{:238};
begin if(not eat_bib_white_space)then begin eat_bib_print;goto 10;end;
end;
{266:}begin if(buffer[buf_ptr2]=123)then right_outer_delim:=125 else if(
buffer[buf_ptr2]=40)then right_outer_delim:=41 else begin
bib_one_of_two_print(123,40);goto 10;end;buf_ptr2:=buf_ptr2+1;
begin if(not eat_bib_white_space)then begin eat_bib_print;goto 10;end;
end;if(right_outer_delim=41)then begin if(scan1_white(44))then;
end else if(scan2_white(44,125))then;
{267:}begin{begin out_token(log_file);end;
begin write_ln(log_file,' is a database key');end;}tmp_ptr:=buf_ptr1;
while(tmp_ptr<buf_ptr2)do begin ex_buf[tmp_ptr]:=buffer[tmp_ptr];
tmp_ptr:=tmp_ptr+1;end;lower_case(ex_buf,buf_ptr1,(buf_ptr2-buf_ptr1));
if(all_entries)then lc_cite_loc:=str_lookup(ex_buf,buf_ptr1,(buf_ptr2-
buf_ptr1),10,true)else lc_cite_loc:=str_lookup(ex_buf,buf_ptr1,(buf_ptr2
-buf_ptr1),10,false);
if(hash_found)then begin entry_cite_ptr:=ilk_info[ilk_info[lc_cite_loc]]
;{268:}begin if((not all_entries)or(entry_cite_ptr<all_marker)or(
entry_cite_ptr>=old_num_cites))then begin if(type_list[entry_cite_ptr]=0
)then begin{269:}begin if((not all_entries)and(entry_cite_ptr>=
old_num_cites))then begin cite_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2
-buf_ptr1),9,true);
if(not hash_found)then begin ilk_info[lc_cite_loc]:=cite_loc;
ilk_info[cite_loc]:=entry_cite_ptr;
cite_list[entry_cite_ptr]:=hash_text[cite_loc];hash_found:=true;end;end;
end{:269};goto 26;end;
end else if(not entry_exists[entry_cite_ptr])then begin{270:}begin
ex_buf_ptr:=0;tmp_ptr:=str_start[cite_info[entry_cite_ptr]];
tmp_end_ptr:=str_start[cite_info[entry_cite_ptr]+1];
while(tmp_ptr<tmp_end_ptr)do begin ex_buf[ex_buf_ptr]:=str_pool[tmp_ptr]
;ex_buf_ptr:=ex_buf_ptr+1;tmp_ptr:=tmp_ptr+1;end;
lower_case(ex_buf,0,(str_start[cite_info[entry_cite_ptr]+1]-str_start[
cite_info[entry_cite_ptr]]));
lc_xcite_loc:=str_lookup(ex_buf,0,(str_start[cite_info[entry_cite_ptr]+1
]-str_start[cite_info[entry_cite_ptr]]),10,false);
if(not hash_found)then cite_key_disappeared_confusion;end{:270};
if(lc_xcite_loc=lc_cite_loc)then goto 26;end;
if(type_list[entry_cite_ptr]=0)then begin begin write(log_file,
'The cite list is messed up');write(tty,'The cite list is messed up');
end;print_confusion;goto 9998;end;
begin begin write(log_file,'Repeated entry');
write(tty,'Repeated entry');end;bib_err_print;goto 10;end;26:end{:268};
end;store_entry:=true;
if(all_entries)then{272:}begin if(hash_found)then begin if(
entry_cite_ptr<all_marker)then goto 22 else begin entry_exists[
entry_cite_ptr]:=true;cite_loc:=ilk_info[lc_cite_loc];end;
end else begin cite_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),
9,true);if(hash_found)then hash_cite_confusion;end;
entry_cite_ptr:=cite_ptr;add_database_cite(cite_ptr);
22:end{:272}else if(not hash_found)then store_entry:=false;
if(store_entry)then{273:}begin{dummy_loc:=str_lookup(buffer,buf_ptr1,(
buf_ptr2-buf_ptr1),9,false);
if(not hash_found)then begin begin write(log_file,
'Warning--case mismatch, database key "');
write(tty,'Warning--case mismatch, database key "');end;print_a_token;
begin write(log_file,'", cite key "');write(tty,'", cite key "');end;
print_a_pool_str(cite_list[entry_cite_ptr]);
begin begin write_ln(log_file,'"');write_ln(tty,'"');end;bib_warn_print;
end;end;}
if(type_exists)then type_list[entry_cite_ptr]:=entry_type_loc else begin
type_list[entry_cite_ptr]:=5001;
begin write(log_file,'Warning--entry type for "');
write(tty,'Warning--entry type for "');end;print_a_token;
begin begin write_ln(log_file,'" isn''t style-file defined');
write_ln(tty,'" isn''t style-file defined');end;bib_warn_print;end;end;
end{:273};end{:267};end{:266};
begin if(not eat_bib_white_space)then begin eat_bib_print;goto 10;end;
end;
{274:}begin while(buffer[buf_ptr2]<>right_outer_delim)do begin if(buffer
[buf_ptr2]<>44)then begin bib_one_of_two_print(44,right_outer_delim);
goto 10;end;buf_ptr2:=buf_ptr2+1;
begin if(not eat_bib_white_space)then begin eat_bib_print;goto 10;end;
end;if(buffer[buf_ptr2]=right_outer_delim)then goto 15;
{275:}begin scan_identifier(61,61,61);
begin if((scan_result=3)or(scan_result=1))then else begin bib_id_print;
begin begin write(log_file,'a field name');write(tty,'a field name');
end;bib_err_print;goto 10;end;end;end;{begin out_token(log_file);end;
begin write_ln(log_file,' is a field name');end;}store_field:=false;
if(store_entry)then begin lower_case(buffer,buf_ptr1,(buf_ptr2-buf_ptr1)
);
field_name_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),11,false)
;if(hash_found)then if(fn_type[field_name_loc]=4)then store_field:=true;
end;begin if(not eat_bib_white_space)then begin eat_bib_print;goto 10;
end;end;if(buffer[buf_ptr2]<>61)then begin bib_equals_sign_print;
goto 10;end;buf_ptr2:=buf_ptr2+1;end{:275};
begin if(not eat_bib_white_space)then begin eat_bib_print;goto 10;end;
end;if(not scan_and_store_the_field_value_and_eat_white)then goto 10;
end;15:buf_ptr2:=buf_ptr2+1;end{:274};10:end;
{:236}{:210}{211:}procedure bst_read_command;label 10;
begin if(read_seen)then begin begin write(log_file,
'Illegal, another read command');
write(tty,'Illegal, another read command');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;
read_seen:=true;if(not entry_seen)then begin begin write(log_file,
'Illegal, read command before entry command');
write(tty,'Illegal, read command before entry command');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;
sv_ptr1:=buf_ptr2;sv_ptr2:=last;tmp_ptr:=sv_ptr1;
while(tmp_ptr<sv_ptr2)do begin sv_buffer[tmp_ptr]:=buffer[tmp_ptr];
tmp_ptr:=tmp_ptr+1;end;
{223:}begin{224:}begin{225:}begin check_field_overflow(num_fields*
num_cites);field_ptr:=0;
while(field_ptr<max_fields)do begin field_info[field_ptr]:=0;
field_ptr:=field_ptr+1;end;end{:225};{227:}begin cite_ptr:=0;
while(cite_ptr<max_cites)do begin type_list[cite_ptr]:=0;
cite_info[cite_ptr]:=0;cite_ptr:=cite_ptr+1;end;
old_num_cites:=num_cites;if(all_entries)then begin cite_ptr:=all_marker;
while(cite_ptr<old_num_cites)do begin cite_info[cite_ptr]:=cite_list[
cite_ptr];entry_exists[cite_ptr]:=false;cite_ptr:=cite_ptr+1;end;
cite_ptr:=all_marker;end else begin cite_ptr:=num_cites;all_marker:=0;
end;end{:227};end{:224};read_performed:=true;bib_ptr:=0;
while(bib_ptr<num_bib_files)do begin begin write(log_file,
'Database file #',bib_ptr+1:0,': ');
write(tty,'Database file #',bib_ptr+1:0,': ');end;print_bib_name;
bib_line_num:=0;buf_ptr2:=last;
while(not eof(bib_file[bib_ptr]))do get_bib_command_or_entry_and_process
;a_close(bib_file[bib_ptr]);bib_ptr:=bib_ptr+1;end;
reading_completed:=true;
{begin write_ln(log_file,'Finished reading the database file(s)');end;}
{276:}begin num_cites:=cite_ptr;num_preamble_strings:=preamble_ptr;
{277:}begin cite_ptr:=0;
while(cite_ptr<num_cites)do begin field_ptr:=cite_ptr*num_fields+
crossref_num;
if(field_info[field_ptr]<>0)then if(find_cite_locs_for_this_cite_key(
field_info[field_ptr]))then begin cite_loc:=ilk_info[lc_cite_loc];
field_info[field_ptr]:=hash_text[cite_loc];
cite_parent_ptr:=ilk_info[cite_loc];
field_ptr:=cite_ptr*num_fields+num_pre_defined_fields;
field_end_ptr:=field_ptr-num_pre_defined_fields+num_fields;
field_parent_ptr:=cite_parent_ptr*num_fields+num_pre_defined_fields;
while(field_ptr<field_end_ptr)do begin if(field_info[field_ptr]=0)then
field_info[field_ptr]:=field_info[field_parent_ptr];
field_ptr:=field_ptr+1;field_parent_ptr:=field_parent_ptr+1;end;end;
cite_ptr:=cite_ptr+1;end;end{:277};{279:}begin cite_ptr:=0;
while(cite_ptr<num_cites)do begin field_ptr:=cite_ptr*num_fields+
crossref_num;
if(field_info[field_ptr]<>0)then if(not find_cite_locs_for_this_cite_key
(field_info[field_ptr]))then begin if(cite_hash_found)then
hash_cite_confusion;nonexistent_cross_reference_error;
field_info[field_ptr]:=0;
end else begin if(cite_loc<>ilk_info[lc_cite_loc])then
hash_cite_confusion;cite_parent_ptr:=ilk_info[cite_loc];
if(type_list[cite_parent_ptr]=0)then begin
nonexistent_cross_reference_error;field_info[field_ptr]:=0;
end else begin field_parent_ptr:=cite_parent_ptr*num_fields+crossref_num
;
if(field_info[field_parent_ptr]<>0)then{282:}begin begin write(log_file,
'Warning--you''ve nested cross references');
write(tty,'Warning--you''ve nested cross references');end;
bad_cross_reference_print(cite_list[cite_parent_ptr]);
begin write_ln(log_file,'", which also refers to something');
write_ln(tty,'", which also refers to something');end;mark_warning;
end{:282};
if((not all_entries)and(cite_parent_ptr>=old_num_cites)and(cite_info[
cite_parent_ptr]<min_crossrefs))then field_info[field_ptr]:=0;end;end;
cite_ptr:=cite_ptr+1;end;end{:279};{283:}begin cite_ptr:=0;
while(cite_ptr<num_cites)do begin if(type_list[cite_ptr]=0)then
print_missing_entry(cite_list[cite_ptr])else if((all_entries)or(cite_ptr
<old_num_cites)or(cite_info[cite_ptr]>=min_crossrefs))then begin if(
cite_ptr>cite_xptr)then{285:}begin cite_list[cite_xptr]:=cite_list[
cite_ptr];type_list[cite_xptr]:=type_list[cite_ptr];
if(not find_cite_locs_for_this_cite_key(cite_list[cite_ptr]))then
cite_key_disappeared_confusion;
if((not cite_hash_found)or(cite_loc<>ilk_info[lc_cite_loc]))then
hash_cite_confusion;ilk_info[cite_loc]:=cite_xptr;
field_ptr:=cite_xptr*num_fields;field_end_ptr:=field_ptr+num_fields;
tmp_ptr:=cite_ptr*num_fields;
while(field_ptr<field_end_ptr)do begin field_info[field_ptr]:=field_info
[tmp_ptr];field_ptr:=field_ptr+1;tmp_ptr:=tmp_ptr+1;end;end{:285};
cite_xptr:=cite_xptr+1;end;cite_ptr:=cite_ptr+1;end;
num_cites:=cite_xptr;
if(all_entries)then{286:}begin cite_ptr:=all_marker;
while(cite_ptr<old_num_cites)do begin if(not entry_exists[cite_ptr])then
print_missing_entry(cite_info[cite_ptr]);cite_ptr:=cite_ptr+1;end;
end{:286};end{:283};
{287:}begin if(num_ent_ints*num_cites>max_ent_ints)then begin begin
write(log_file,num_ent_ints*num_cites,': ');
write(tty,num_ent_ints*num_cites,': ');end;begin print_overflow;
begin write_ln(log_file,'total number of integer entry-variables ',
max_ent_ints:0);
write_ln(tty,'total number of integer entry-variables ',max_ent_ints:0);
end;goto 9998;end;end;int_ent_ptr:=0;
while(int_ent_ptr<num_ent_ints*num_cites)do begin entry_ints[int_ent_ptr
]:=0;int_ent_ptr:=int_ent_ptr+1;end;end{:287};
{288:}begin if(num_ent_strs*num_cites>max_ent_strs)then begin begin
write(log_file,num_ent_strs*num_cites,': ');
write(tty,num_ent_strs*num_cites,': ');end;begin print_overflow;
begin write_ln(log_file,'total number of string entry-variables ',
max_ent_strs:0);
write_ln(tty,'total number of string entry-variables ',max_ent_strs:0);
end;goto 9998;end;end;str_ent_ptr:=0;
while(str_ent_ptr<num_ent_strs*num_cites)do begin entry_strs[str_ent_ptr
][0]:=127;str_ent_ptr:=str_ent_ptr+1;end;end{:288};
{289:}begin cite_ptr:=0;
while(cite_ptr<num_cites)do begin cite_info[cite_ptr]:=cite_ptr;
cite_ptr:=cite_ptr+1;end;end{:289};end{:276};read_completed:=true;
end{:223};buf_ptr2:=sv_ptr1;last:=sv_ptr2;tmp_ptr:=buf_ptr2;
while(tmp_ptr<last)do begin buffer[tmp_ptr]:=sv_buffer[tmp_ptr];
tmp_ptr:=tmp_ptr+1;end;10:end;{:211}{212:}procedure bst_reverse_command;
label 10;begin if(not read_seen)then begin begin write(log_file,
'Illegal, reverse command before read command');
write(tty,'Illegal, reverse command before read command');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'reverse');write(tty,'reverse');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
begin if(buffer[buf_ptr2]<>123)then begin bst_left_brace_print;
begin begin write(log_file,'reverse');write(tty,'reverse');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;
buf_ptr2:=buf_ptr2+1;end;
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'reverse');write(tty,'reverse');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
begin scan_identifier(125,37,37);
if((scan_result=3)or(scan_result=1))then else begin bst_id_print;
begin begin write(log_file,'reverse');write(tty,'reverse');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
{213:}begin{begin out_token(log_file);end;
begin write_ln(log_file,' is a to be iterated in reverse function');end;
}if(bad_argument_token)then goto 10;end{:213};
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'reverse');write(tty,'reverse');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
begin if(buffer[buf_ptr2]<>125)then begin bst_right_brace_print;
begin begin write(log_file,'reverse');write(tty,'reverse');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;
buf_ptr2:=buf_ptr2+1;end;{298:}begin init_command_execution;
mess_with_entries:=true;
if(num_cites>0)then begin sort_cite_ptr:=num_cites;
repeat sort_cite_ptr:=sort_cite_ptr-1;
cite_ptr:=cite_info[sort_cite_ptr];
{begin out_pool_str(log_file,hash_text[fn_loc]);end;
begin write(log_file,' to be iterated in reverse on ');end;
begin out_pool_str(log_file,cite_list[cite_ptr]);end;
begin write_ln(log_file);end;}execute_fn(fn_loc);
check_command_execution;until(sort_cite_ptr=0);end;end{:298};10:end;
{:212}{214:}procedure bst_sort_command;label 10;
begin if(not read_seen)then begin begin write(log_file,
'Illegal, sort command before read command');
write(tty,'Illegal, sort command before read command');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;
{299:}begin{begin write_ln(log_file,'Sorting the entries');end;}
if(num_cites>1)then quick_sort(0,num_cites-1);
{begin write_ln(log_file,'Done sorting');end;}end{:299};10:end;
{:214}{215:}procedure bst_strings_command;label 10;
begin begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'strings');write(tty,'strings');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
begin if(buffer[buf_ptr2]<>123)then begin bst_left_brace_print;
begin begin write(log_file,'strings');write(tty,'strings');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;
buf_ptr2:=buf_ptr2+1;end;
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'strings');write(tty,'strings');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
while(buffer[buf_ptr2]<>125)do begin begin scan_identifier(125,37,37);
if((scan_result=3)or(scan_result=1))then else begin bst_id_print;
begin begin write(log_file,'strings');write(tty,'strings');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;
{216:}begin{begin out_token(log_file);end;
begin write_ln(log_file,' is a string global-variable');end;}
lower_case(buffer,buf_ptr1,(buf_ptr2-buf_ptr1));
fn_loc:=str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),11,true);
begin if(hash_found)then begin already_seen_function_print(fn_loc);
goto 10;end;end;fn_type[fn_loc]:=8;ilk_info[fn_loc]:=num_glb_strs;
if(num_glb_strs=10)then begin print_overflow;
begin write_ln(log_file,'number of string global-variables ',10:0);
write_ln(tty,'number of string global-variables ',10:0);end;goto 9998;
end;num_glb_strs:=num_glb_strs+1;end{:216};
begin if(not eat_bst_white_space)then begin eat_bst_print;
begin begin write(log_file,'strings');write(tty,'strings');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;end;end;
buf_ptr2:=buf_ptr2+1;10:end;
{:215}{217:}{154:}procedure get_bst_command_and_process;label 10;
begin if(not scan_alpha)then begin begin write(log_file,'"',xchr[buffer[
buf_ptr2]],'" can''t start a style-file command');
write(tty,'"',xchr[buffer[buf_ptr2]],
'" can''t start a style-file command');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;
lower_case(buffer,buf_ptr1,(buf_ptr2-buf_ptr1));
command_num:=ilk_info[str_lookup(buffer,buf_ptr1,(buf_ptr2-buf_ptr1),4,
false)];if(not hash_found)then begin print_a_token;
begin begin write(log_file,' is an illegal style-file command');
write(tty,' is an illegal style-file command');end;
begin bst_err_print_and_look_for_blank_line;goto 10;end;end;end;
{155:}case(command_num)of 0:bst_entry_command;1:bst_execute_command;
2:bst_function_command;3:bst_integers_command;4:bst_iterate_command;
5:bst_macro_command;6:bst_read_command;7:bst_reverse_command;
8:bst_sort_command;9:bst_strings_command;
others:begin begin write(log_file,'Unknown style-file command');
write(tty,'Unknown style-file command');end;print_confusion;goto 9998;
end end{:155};10:end;{:154}{:217}{:12}{13:}procedure initialize;
var{23:}i:0..127;{:23}{66:}k:hash_loc;{:66}begin{17:}bad:=0;
if(min_print_line<3)then bad:=1;
if(max_print_line<=min_print_line)then bad:=10*bad+2;
if(max_print_line>=buf_size)then bad:=10*bad+3;
if(4253<128)then bad:=10*bad+4;if(4253>5000)then bad:=10*bad+5;
if(4253>=(16320))then bad:=10*bad+6;
if(max_strings>5000)then bad:=10*bad+7;
if(max_cites>max_strings)then bad:=10*bad+8;
if(ent_str_size>buf_size)then bad:=10*bad+9;
if(glob_str_size>buf_size)then bad:=100*bad+11;
{:17}{302:}if(10<2*4+2)then bad:=100*bad+22;{:302};
if(bad>0)then begin write_ln(tty,bad:0,' is a bad bad');goto 9999;end;
{20:}history:=0;{:20}{25:}xchr[32]:=' ';xchr[33]:='!';xchr[34]:='"';
xchr[35]:='#';xchr[36]:='$';xchr[37]:='%';xchr[38]:='&';xchr[39]:='''';
xchr[40]:='(';xchr[41]:=')';xchr[42]:='*';xchr[43]:='+';xchr[44]:=',';
xchr[45]:='-';xchr[46]:='.';xchr[47]:='/';xchr[48]:='0';xchr[49]:='1';
xchr[50]:='2';xchr[51]:='3';xchr[52]:='4';xchr[53]:='5';xchr[54]:='6';
xchr[55]:='7';xchr[56]:='8';xchr[57]:='9';xchr[58]:=':';xchr[59]:=';';
xchr[60]:='<';xchr[61]:='=';xchr[62]:='>';xchr[63]:='?';xchr[64]:='@';
xchr[65]:='A';xchr[66]:='B';xchr[67]:='C';xchr[68]:='D';xchr[69]:='E';
xchr[70]:='F';xchr[71]:='G';xchr[72]:='H';xchr[73]:='I';xchr[74]:='J';
xchr[75]:='K';xchr[76]:='L';xchr[77]:='M';xchr[78]:='N';xchr[79]:='O';
xchr[80]:='P';xchr[81]:='Q';xchr[82]:='R';xchr[83]:='S';xchr[84]:='T';
xchr[85]:='U';xchr[86]:='V';xchr[87]:='W';xchr[88]:='X';xchr[89]:='Y';
xchr[90]:='Z';xchr[91]:='[';xchr[92]:='\';xchr[93]:=']';xchr[94]:='^';
xchr[95]:='_';xchr[96]:='`';xchr[97]:='a';xchr[98]:='b';xchr[99]:='c';
xchr[100]:='d';xchr[101]:='e';xchr[102]:='f';xchr[103]:='g';
xchr[104]:='h';xchr[105]:='i';xchr[106]:='j';xchr[107]:='k';
xchr[108]:='l';xchr[109]:='m';xchr[110]:='n';xchr[111]:='o';
xchr[112]:='p';xchr[113]:='q';xchr[114]:='r';xchr[115]:='s';
xchr[116]:='t';xchr[117]:='u';xchr[118]:='v';xchr[119]:='w';
xchr[120]:='x';xchr[121]:='y';xchr[122]:='z';xchr[123]:='{';
xchr[124]:='|';xchr[125]:='}';xchr[126]:='~';xchr[0]:=' ';
xchr[127]:=' ';{:25}{27:}for i:=1 to 31 do xchr[i]:=' ';xchr[9]:=chr(9);
{:27}{28:}for i:=0 to 127 do xord[chr(i)]:=127;
for i:=1 to 126 do xord[xchr[i]]:=i;
{:28}{32:}for i:=0 to 127 do lex_class[i]:=5;
for i:=0 to 31 do lex_class[i]:=0;lex_class[127]:=0;lex_class[9]:=1;
lex_class[32]:=1;lex_class[126]:=4;lex_class[45]:=4;
for i:=48 to 57 do lex_class[i]:=3;for i:=65 to 90 do lex_class[i]:=2;
for i:=97 to 122 do lex_class[i]:=2;
{:32}{33:}for i:=0 to 127 do id_class[i]:=1;
for i:=0 to 31 do id_class[i]:=0;id_class[32]:=0;id_class[9]:=0;
id_class[34]:=0;id_class[35]:=0;id_class[37]:=0;id_class[39]:=0;
id_class[40]:=0;id_class[41]:=0;id_class[44]:=0;id_class[61]:=0;
id_class[123]:=0;id_class[125]:=0;
{:33}{35:}for i:=0 to 127 do char_width[i]:=0;char_width[32]:=278;
char_width[33]:=278;char_width[34]:=500;char_width[35]:=833;
char_width[36]:=500;char_width[37]:=833;char_width[38]:=778;
char_width[39]:=278;char_width[40]:=389;char_width[41]:=389;
char_width[42]:=500;char_width[43]:=778;char_width[44]:=278;
char_width[45]:=333;char_width[46]:=278;char_width[47]:=500;
char_width[48]:=500;char_width[49]:=500;char_width[50]:=500;
char_width[51]:=500;char_width[52]:=500;char_width[53]:=500;
char_width[54]:=500;char_width[55]:=500;char_width[56]:=500;
char_width[57]:=500;char_width[58]:=278;char_width[59]:=278;
char_width[60]:=278;char_width[61]:=778;char_width[62]:=472;
char_width[63]:=472;char_width[64]:=778;char_width[65]:=750;
char_width[66]:=708;char_width[67]:=722;char_width[68]:=764;
char_width[69]:=681;char_width[70]:=653;char_width[71]:=785;
char_width[72]:=750;char_width[73]:=361;char_width[74]:=514;
char_width[75]:=778;char_width[76]:=625;char_width[77]:=917;
char_width[78]:=750;char_width[79]:=778;char_width[80]:=681;
char_width[81]:=778;char_width[82]:=736;char_width[83]:=556;
char_width[84]:=722;char_width[85]:=750;char_width[86]:=750;
char_width[87]:=1028;char_width[88]:=750;char_width[89]:=750;
char_width[90]:=611;char_width[91]:=278;char_width[92]:=500;
char_width[93]:=278;char_width[94]:=500;char_width[95]:=278;
char_width[96]:=278;char_width[97]:=500;char_width[98]:=556;
char_width[99]:=444;char_width[100]:=556;char_width[101]:=444;
char_width[102]:=306;char_width[103]:=500;char_width[104]:=556;
char_width[105]:=278;char_width[106]:=306;char_width[107]:=528;
char_width[108]:=278;char_width[109]:=833;char_width[110]:=556;
char_width[111]:=500;char_width[112]:=556;char_width[113]:=528;
char_width[114]:=392;char_width[115]:=394;char_width[116]:=389;
char_width[117]:=556;char_width[118]:=528;char_width[119]:=722;
char_width[120]:=528;char_width[121]:=528;char_width[122]:=444;
char_width[123]:=500;char_width[124]:=1000;char_width[125]:=500;
char_width[126]:=500;
{:35}{67:}for k:=1 to 5000 do begin hash_next[k]:=0;hash_text[k]:=0;end;
hash_used:=5001;{:67}{72:}pool_ptr:=0;str_ptr:=1;
str_start[str_ptr]:=pool_ptr;{:72}{119:}bib_ptr:=0;bib_seen:=false;
{:119}{125:}bst_str:=0;bst_seen:=false;{:125}{131:}cite_ptr:=0;
citation_seen:=false;all_entries:=false;{:131}{162:}wiz_def_ptr:=0;
num_ent_ints:=0;num_ent_strs:=0;num_fields:=0;str_glb_ptr:=0;
while(str_glb_ptr<10)do begin glb_str_ptr[str_glb_ptr]:=0;
glb_str_end[str_glb_ptr]:=0;str_glb_ptr:=str_glb_ptr+1;end;
num_glb_strs:=0;{:162}{164:}entry_seen:=false;read_seen:=false;
read_performed:=false;reading_completed:=false;read_completed:=false;
{:164}{196:}impl_fn_num:=0;{:196}{292:}out_buf_length:=0;{:292};
pre_def_certain_strings;get_the_top_level_aux_file_name;end;
{:13}begin initialize;
begin write_ln(log_file,'This is BibTeX, Version 0.99d');
write_ln(tty,'This is BibTeX, Version 0.99d');end;
{110:}begin write(log_file,'The top-level auxiliary file: ');
write(tty,'The top-level auxiliary file: ');end;print_aux_name;
while true do begin aux_ln_stack[aux_ptr]:=aux_ln_stack[aux_ptr]+1;
if(not input_ln(aux_file[aux_ptr]))then pop_the_aux_stack else
get_aux_command_and_process;end;
{begin write_ln(log_file,'Finished reading the auxiliary file(s)');end;}
31:last_check_for_aux_errors;{:110};{151:}if(bst_str=0)then goto 9932;
bst_line_num:=0;bbl_line_num:=1;buf_ptr2:=last;
while true do begin if(not eat_bst_white_space)then goto 32;
get_bst_command_and_process;end;32:a_close(bst_file);
9932:a_close(bbl_file);{:151};
9998:{455:}begin if((read_performed)and(not reading_completed))then
begin begin write(log_file,'Aborted at line ',bib_line_num:0,' of file '
);write(tty,'Aborted at line ',bib_line_num:0,' of file ');end;
print_bib_name;end;trace_and_stat_printing;{466:}case(history)of 0:;
1:begin if(err_count=1)then begin write_ln(log_file,
'(There was 1 warning)');write_ln(tty,'(There was 1 warning)');
end else begin write_ln(log_file,'(There were ',err_count:0,' warnings)'
);write_ln(tty,'(There were ',err_count:0,' warnings)');end;end;
2:begin if(err_count=1)then begin write_ln(log_file,
'(There was 1 error message)');
write_ln(tty,'(There was 1 error message)');
end else begin write_ln(log_file,'(There were ',err_count:0,
' error messages)');
write_ln(tty,'(There were ',err_count:0,' error messages)');end;end;
3:begin write_ln(log_file,'(That was a fatal error)');
write_ln(tty,'(That was a fatal error)');end;
others:begin begin write(log_file,'History is bunk');
write(tty,'History is bunk');end;print_confusion;end end{:466};
a_close(log_file);end{:455};9999:end.{:10}
