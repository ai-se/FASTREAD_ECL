IMPORT MAR.Types;
IMPORT STD;
//OUTPUT(STD.Date.CurrentTime());

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