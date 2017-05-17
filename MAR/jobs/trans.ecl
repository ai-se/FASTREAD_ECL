IMPORT MAR;
IMPORT ML;

file := '': STORED('file', FORMAT(SEQUENCE(1)));

MAR.Types.MarRecord tmp := MAR.Body.transData(file);

rs1:=OUTPUT(tmp, ,'~fastread::'+file+'.out');

stat:= MAR.Body.get_stat(tmp);

rs2:=OUTPUT(stat,NAMED('stat'));

DATASET(ML.Types.NumericField) feature:= MAR.Body.featurize(file);
rs3:=MAR.Body.saveFeature(feature,file);

ORDERED(rs1,rs2,rs3);
