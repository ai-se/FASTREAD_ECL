IMPORT MAR;

file := '': STORED('file', FORMAT(SEQUENCE(1)));

rs:=MAR.Body.SsaveData(file);

rs2:=OUTPUT('true',NAMED('save'));

ORDERED(rs,rs2);