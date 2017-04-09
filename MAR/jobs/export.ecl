IMPORT MAR;

file := '': STORED('file', FORMAT(SEQUENCE(1)));
corpus:= MAR.Body.loadData(file);

rs := SORT(corpus(code='yes' OR code='no'),-code, time);
OUTPUT(rs,NAMED('export'),ALL);

