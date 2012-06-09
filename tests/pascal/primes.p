{1:}{2:}program print_primes(output);const m=1000;{5:}rr=50;cc=4;ww=10;
{:5}{19:}ord_max=30;{:19}var{4:}p:array[1..m]of integer;
{:4}{7:}page_number:integer;page_offset:integer;row_offset:integer;
c:0..cc;{:7}{12:}j:integer;k:0..m;{:12}{15:}j_prime:boolean;
{:15}{17:}ord:2..ord_max;square:integer;{:17}{23:}n:2..ord_max;
{:23}{24:}mult:array[2..ord_max]of integer;{:24}begin{3:}{11:}{16:}j:=1;
k:=1;p[1]:=2;{:16}{18:}ord:=2;square:=9;{:18};
while k<m do begin{14:}repeat j:=j+2;
{20:}if j=square then begin ord:=ord+1;{21:}square:=p[ord]*p[ord];
{:21}{25:}mult[ord-1]:=j;{:25};end{:20};{22:}n:=2;j_prime:=true;
while(n<ord)and j_prime do begin{26:}while mult[n]<j do mult[n]:=mult[n]
+p[n]+p[n];if mult[n]=j then j_prime:=false{:26};n:=n+1;end{:22};
until j_prime{:14};k:=k+1;p[k]:=j;end{:11};{8:}begin page_number:=1;
page_offset:=1;
while page_offset<=m do begin{9:}begin write('The First ');write(m:1);
write(' Prime Numbers --- Page ');write(page_number:1);write_ln;
write_ln;
for row_offset:=page_offset to page_offset+rr-1 do{10:}begin for c:=0 to
cc-1 do if row_offset+c*rr<=m then write(p[row_offset+c*rr]:ww);
write_ln;end{:10};page;end{:9};page_number:=page_number+1;
page_offset:=page_offset+rr*cc;end;end{:8}{:3};end.{:2}{:1}
