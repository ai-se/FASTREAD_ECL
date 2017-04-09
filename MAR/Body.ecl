IMPORT MAR.Types;
IMPORT STD;
IMPORT ML;
EXPORT Body := MODULE


	
	EXPORT saveData(DATASET(Types.MarRecord) corpus, STRING path):= OUTPUT(corpus, ,'~work::'+path+'.tmp',OVERWRITE);
	
	EXPORT SsaveData(STRING path):= OUTPUT(DATASET('~work::'+path+'.tmp',Types.MarRecord,FLAT), ,'~work::'+path+'.out', OVERWRITE);
	
	EXPORT Types.MarRecord loadData(STRING path):= DATASET('~work::'+path+'.out', Types.MarRecord, FLAT);

	EXPORT Types.MarRecord transData(STRING path):= FUNCTION
		Types.MarRecord getNew(Types.CsvRecord old,INTEGER c) := TRANSFORM
			SELF.Title := old.Title;
			SELF.Year := old.Year;
			SELF.PDF := old.PDF;
			SELF.label := old.label;
			SELF.Abstract := old.Abstract;
			SELF.ID := c;
			SELF.code := 'undetermined';
			SELF.time := 0;
		END;
		//act1 := DATASET('~work::'+path+'.out', Types.MarRecord, FLAT);
		//act2 := PROJECT(DATASET('~initial::'+path+'.csv',Types.CsvRecord,CSV), getNew(LEFT,COUNTER));
		//newData := IF (STD.File.FileExists('~work::'+path+'.out'),act1,act2);
		newData := PROJECT(DATASET('~initial::'+path+'.csv',Types.CsvRecord,CSV), getNew(LEFT,COUNTER));		
		RETURN newData;
	END;
	
	EXPORT Types.MarRecord labelData(DATASET(Types.MarRecord) corpus, INTEGER id, STRING mylabel):= FUNCTION
		Types.MarRecord labeling(Types.MarRecord old,INTEGER id, STRING mylabel) := TRANSFORM
			SELF.Title := old.Title;
			SELF.Year := old.Year;
			SELF.PDF := old.PDF;
			SELF.label := old.label;
			SELF.Abstract := old.Abstract;
			SELF.ID := old.ID;			
			SELF.code := IF(self.ID=id, mylabel, old.code);
			SELF.time := IF(self.ID=id, IF(mylabel='undetermined', 0, STD.Date.CurrentTime()), old.time);
		END;
		newData := PROJECT(corpus, labeling(LEFT,id,mylabel));
		RETURN newData;
	END;
	
		
	EXPORT Types.ScoreRecord randomSample(DATASET(Types.MarRecord) corpus):= FUNCTION	
		Types.ScoreRecord randscore(Types.MarRecord old,REAL8 rand) := TRANSFORM
			SELF := old;
			SELF.score := rand;
		END;		
		randData := PROJECT(corpus(code='undetermined'), randscore(LEFT,RANDOM()/4294967296));	
		
		justten := TOPN(randData,10,-score);
		RETURN justten;
	END;
	
	EXPORT Types.ScoreRecord certainSample(DATASET(Types.MarRecord) corpus):= FUNCTION
		ML.Types.DiscreteField dependent(Types.MarRecord corpus,INTEGER4 code) := TRANSFORM
			SELF.id := corpus.id;
			SELF.number := 1;
			SELF.value := code;
		END;
		csrmat := DATASET('~feature::feature.csv',ML.Types.NumericField,CSV);
		poses := join(csrmat, corpus(code='yes'), LEFT.id=RIGHT.id, TRANSFORM(ML.Types.NumericField, SELF := LEFT) );
		posesCode := PROJECT(corpus(code='yes'), dependent(LEFT,1));
		negs := join(csrmat, corpus(code='no'), LEFT.id=RIGHT.id, TRANSFORM(ML.Types.NumericField, SELF := LEFT) );
		negsCode := PROJECT(corpus(code='no'), dependent(LEFT,0));
		und := join(csrmat, corpus(code='undetermined'), LEFT.id=RIGHT.id, TRANSFORM(ML.Types.NumericField, SELF := LEFT) );
		model := ML.Classify.SVM();
		nl := model.LearnC(poses+negs,posesCode+negsCode);
		rs := model.ClassifyC(und,nl);
		justten := TOPN(rs,10,conf);
		rt := join(corpus, justten, LEFT.id=RIGHT.id, TRANSFORM(Types.ScoreRecord, SELF := LEFT, SELF.score:=RIGHT.conf));
		RETURN SORT(rt,score);		
	END;

	EXPORT Types.ScoreRecord present(DATASET(Types.MarRecord) corpus):= FUNCTION			
		//RETURN randomSample(corpus);
		RETURN IF(COUNT(corpus(code='yes'))=0,randomSample(corpus),certainSample(corpus));
	END;

	
	EXPORT Types.Stat get_stat(DATASET(Types.MarRecord) corpus):= FUNCTION		
		RETURN DATASET([{COUNT(corpus(code='yes')),COUNT(corpus(code='no')),COUNT(corpus)}]
              ,Types.Stat);
	END;	
	
END;