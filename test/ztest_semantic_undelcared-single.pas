{ 
	This program is lexical and parsing error-free
        and contains undeclared variable  
}

program errorundeclared;
type
	s = string;
	in = integer;
var
	z : in;
	m : in;

function foo(n : in) : in; 
begin
   n := b + 1  {error: b has not been declared }	
end;

begin
	m := 5;
	z := m;  
end.