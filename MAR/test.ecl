IMPORT MAR;
IMPORT STD;

file:='hall';

//tmp := DATASET('~work::hall.out',MAR.Types.CSVRecord,FLAT);

/*
DATASET(MAR.Types.MarRecord) tmp := MAR.Body.loadData(file);
OUTPUT(tmp);
MAR.Body.saveData(tmp,file);
*/
//OUTPUT(tmp, ,'~work::'+file+'.out',OVERWRITE);

MAR.Body.SsaveData(file);

/*
tmp2 := MAR.Body.labelData(tmp,1,'yes');
OUTPUT(tmp2);
tmp3 := MAR.Body.labelData(tmp2,1,'undetermined');
OUTPUT(tmp3);
randsample := MAR.Body.randomSample(tmp);
OUTPUT(randsample);
*/