IMPORT Std;
IMPORT MAR;

 
in_command := '': STORED('command', FORMAT(SEQUENCE(1)));

 
#IF(in_command = 'load')
	act1 := OUTPUT('hello', NAMED('data'));
#ELSE
	act1 := OUTPUT('no', NAMED('data'));
#END

ORDERED(act1);