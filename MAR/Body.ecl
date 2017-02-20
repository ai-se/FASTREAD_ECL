IMPORT MAR.Types;
IMPORT STD;
EXPORT Body := MODULE

	EXPORT Types.MarRecord loadData(STRING path):= FUNCTION
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
		myData := DATASET(path,Types.CsvRecord,CSV);
		sortedData := SORT(myData,myData.Year);
		newData := PROJECT(sortedData, getNew(LEFT,COUNTER));
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
			SELF.time := IF(self.ID=id, STD.Date.CurrentTime(), old.time);
		END;
		newData := PROJECT(corpus, labeling(LEFT,id,mylabel));
		RETURN newData;
	END;
	
	EXPORT Types.ScoreRecord randomSample(DATASET(Types.MarRecord) corpus):= FUNCTION	
		Types.ScoreRecord randscore(Types.MarRecord old,REAL8 rand) := TRANSFORM
			SELF.Title := old.Title;
			SELF.Year := old.Year;
			SELF.PDF := old.PDF;
			SELF.label := old.label;
			SELF.Abstract := old.Abstract;
			SELF.ID := old.ID;			
			SELF.code := old.code;
			SELF.time := old.time;
			SELF.score := rand;
		END;		
		randData := PROJECT(corpus(code='undetermined'), randscore(LEFT,RANDOM()/4294967296));
		sortedData := SORT(randData,randData.score);		
				
		justten := DATASET(10, TRANSFORM(Types.ScoreRecord,
                                SELF.Title := sortedData[COUNTER].Title;
																SELF.Year := sortedData[COUNTER].Year;
																SELF.PDF := sortedData[COUNTER].PDF;
																SELF.label := sortedData[COUNTER].label;
																SELF.Abstract := sortedData[COUNTER].Abstract;
																SELF.ID := sortedData[COUNTER].ID;			
																SELF.code := sortedData[COUNTER].code;
																SELF.time := sortedData[COUNTER].time;
																SELF.score := sortedData[COUNTER].score;
                            ));
		RETURN justten;
	END;

END;