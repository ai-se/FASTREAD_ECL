IMPORT MAR;

file := '': STORED('file', FORMAT(SEQUENCE(1)));

DATASET(MAR.Types.MarRecord) tmp := MAR.Body.transData(file);

OUTPUT(tmp, ,'~work::'+file+'.out',OVERWRITE);