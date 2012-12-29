{ 
	This program is lexical and parsing error-free.
        Has multideclaration errors. 
}

program errorfree;
type
	s = string;
	in = integer;
var
	z : string;
	m : in;
         

function foo(a : in) : in; 
begin
   a := a + 1
   foo := a 	
end;


begin
	z := foo(6)
	m := z * 5
end.