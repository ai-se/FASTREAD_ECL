IMPORT MAR.Types;
IMPORT STD;
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
		
		justten := TOPN(randData,10,score);
		RETURN justten;
	END;

	EXPORT Types.ScoreRecord certainSample(DATASET(Types.MarRecord) corpus):= FUNCTION	
		Types.ScoreRecord randscore(Types.MarRecord old,REAL8 rand) := TRANSFORM
			SELF := old;
			SELF.score := rand;
		END;		
		randData := PROJECT(corpus(code='undetermined'), randscore(LEFT,RANDOM()/4294967296));	
		
		justten := TOPN(randData,10,score);
		RETURN justten;
	END;

END;