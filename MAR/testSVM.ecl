IMPORT ML;


value_record := RECORD
      unsigned 	rid;
      real 		age;
      real 		height;
      integer1 	sex; // 0 = female, 1 = male
END;
/*         
d := DATASET([{1,35,149,0},{2,11,138,0},{3,12,148,1},{4,16,156,0},
              {5,32,152,0},{6,16,157,0},{7,14,165,0},{8,8,152,1},
	            {9,35,177,0},{10,33,158,1},{11,40,166,0},{12,28,165,0},	
	            {13,23,160,0},{14,52,178,1},{15,46,169,0},{16,29,173,1},
	            {17,30,172,0},{18,21,163,0},{19,21,164,0},{20,20,189,1},
	            {21,34,182,1},{22,43,184,1},{23,35,174,1},{24,39,177,1},
	            {25,43,183,1},{26,37,175,1},{27,32,173,1},{28,24,173,1},
	            {29,20,162,0},{30,25,180,1},{31,22,173,1},{32,25,171,1}]
              ,value_record);
                                                                                                                
ML.ToField(d,flds0);
*/

flds0 := DATASET([{1,2,149},{1,3,0},{2,1,12},{2,3,1},{3,1,21},{3,2,12},{3,3,1},{4,2,-12},{4,3,0}]
              ,ML.Types.NumericField);
flds := ML.Discretize.ByRounding(flds0(Number=3));

flds1 := DATASET([{1,2,100},{2,1,11},{2,2,13},{3,1,0},{3,2,124},{4,1,-100}]
              ,ML.Types.NumericField);

OUTPUT(flds0);

model := ML.Classify.SVM();
nl := model.LearnC(flds0(Number<3),flds);
rs := model.ClassifyC(flds1,nl);
//justten := TOPN(rs,10,IF(d[0].sex=0, -conf, conf));
OUTPUT(rs,,ALL);
//OUTPUT(justten,,ALL);