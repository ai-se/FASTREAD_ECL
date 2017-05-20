IMPORT MAR.Types;
IMPORT MAR;
IMPORT STD;
IMPORT ML;
IMPORT ML.Docs AS Docs;
EXPORT Body := MODULE


	
	EXPORT saveData(DATASET(Types.MarRecord) corpus, STRING path):= OUTPUT(corpus, ,'~fastread::'+path+'.tmp',OVERWRITE);
	
	EXPORT SsaveData(STRING path):= OUTPUT(DATASET('~fastread::'+path+'.tmp',Types.MarRecord,FLAT), ,'~fastread::'+path+'.out', OVERWRITE);
	
	EXPORT Types.MarRecord loadData(STRING path):= DATASET('~fastread::'+path+'.out', Types.MarRecord, FLAT);

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
		newData := PROJECT(DATASET('~fastread::'+path+'.csv',Types.CsvRecord,CSV), getNew(LEFT,COUNTER));		
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
	
	EXPORT Types.ScoreRecord certainSample(DATASET(Types.MarRecord) corpus, STRING path):= FUNCTION
		ML.Types.DiscreteField dependent(Types.MarRecord corpus,INTEGER4 code) := TRANSFORM
			SELF.id := corpus.id;
			SELF.number := 1;
			SELF.value := code;
		END;
		csrmat := DATASET('~fastread::'+path+'.feature',ML.Types.NumericField,FLAT);
		poses := join(csrmat, corpus(code='yes'), LEFT.id=RIGHT.id, TRANSFORM(ML.Types.NumericField, SELF := LEFT) );
		posesCode := PROJECT(corpus(code='yes'), dependent(LEFT,1));
		negs := join(csrmat, corpus(code='no'), LEFT.id=RIGHT.id, TRANSFORM(ML.Types.NumericField, SELF := LEFT) );
		negsCode := PROJECT(corpus(code='no'), dependent(LEFT,0));
		und := join(csrmat, corpus(code='undetermined'), LEFT.id=RIGHT.id, TRANSFORM(ML.Types.NumericField, SELF := LEFT) );
		model := MAR.Classify.SVM();
		nl := model.LearnC(poses+negs,posesCode+negsCode);
		rs := model.ClassifyC(und,nl);
		justten := TOPN(rs,10,conf);
		rt := join(corpus, justten, LEFT.id=RIGHT.id, TRANSFORM(Types.ScoreRecord, SELF := LEFT, SELF.score:=RIGHT.conf));
		RETURN SORT(rt,score);		
	END;

	EXPORT Types.ScoreRecord present(DATASET(Types.MarRecord) corpus, STRING path):= FUNCTION			
		//RETURN randomSample(corpus);
		RETURN IF(COUNT(corpus(code='yes'))=0,randomSample(corpus),certainSample(corpus,path));
	END;

	
	EXPORT Types.Stat get_stat(DATASET(Types.MarRecord) corpus):= FUNCTION		
		RETURN DATASET([{COUNT(corpus(code='yes')),COUNT(corpus(code='no')),COUNT(corpus)}]
              ,Types.Stat);
	END;	
	
	EXPORT ML.Types.NumericField featurize(STRING file):= FUNCTION		
		d := loadData(file);
		Docs.Types.Raw getString(Types.MarRecord old) := TRANSFORM
			SELF.ID := old.ID;
			SELF.Txt := old.Title+old.Abstract;
		END;
		d1 := PROJECT(d,getString(LEFT));
		d3 := Docs.Tokenize.Clean(d1);
		d4 := Docs.Tokenize.Split(d3);
		lex := Docs.Tokenize.Lexicon(d4);
		o1 := Docs.Tokenize.ToO(d4,lex);
		o2:=Docs.Trans(o1).WordBag;

		ML.Types.NumericField toMatrix(Docs.Types.OWordElement old) := TRANSFORM
			SELF.id := old.id;
			SELF.number := old.word;
			SELF.value := old.words_in_doc;
		END;

		RETURN PROJECT(o2,toMatrix(LEFT));
	END;	
	
	EXPORT saveFeature(DATASET(ML.Types.NumericField) feature, STRING path):= OUTPUT(feature, ,'~fastread::'+path+'.feature',OVERWRITE);
END;