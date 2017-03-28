IMPORT Std;
IMPORT MAR;


//---------------------------------------------------------------------------------------
 
//---------------------------------------------------------------------------------------
 
 
in_command := '': STORED('command', FORMAT(SEQUENCE(1)));

 
#IF(in_command = 'load')
	in_name := '': STORED('name', FORMAT(SEQUENCE(2)));
	MAR.Types.MarRecord corpus := MAR.Body.loadData(in_name);
#ELIF(in_command = 'label')
	in_id := '': STORED('id', FORMAT(SEQUENCE(2)));
	in_label := '': STORED('label', FORMAT(SEQUENCE(3)));
#END
 
act1 := OUTPUT(corpus, NAMED('data'));
ORDERED(act1);