IMPORT MAR;

file := '': STORED('file', FORMAT(SEQUENCE(1)));

id := (INTEGER)'': STORED('id', FORMAT(SEQUENCE(2)));

label := '': STORED('label', FORMAT(SEQUENCE(3)));



corpus:= MAR.Body.loadData(file);
corpusnew:=MAR.Body.labelData(corpus,id,label);
MAR.Body.saveData(corpusnew,file);