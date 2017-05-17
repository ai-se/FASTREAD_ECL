IMPORT MAR;

file := '': STORED('file', FORMAT(SEQUENCE(1)));

tmp :=MAR.Body.loadData(file);

stat:= MAR.Body.get_stat(tmp);
OUTPUT(stat,NAMED('stat'));