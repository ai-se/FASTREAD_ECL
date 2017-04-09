IMPORT MAR;
IMPORT STD;
file := '': STORED('file', FORMAT(SEQUENCE(1)));
//corpus:= MAR.Body.loadData(file);
corpus:= MAR.Body.loadData('hall');
suggested := MAR.Body.present(corpus);
selected := join(corpus, suggested, LEFT.id=RIGHT.id, TRANSFORM(MAR.Types.MarRecord, SELF.Title := LEFT.Title,SELF.Year := LEFT.Year,SELF.PDF := LEFT.PDF,	SELF.label := LEFT.label,	SELF.Abstract := LEFT.Abstract,	SELF.ID := LEFT.ID,SELF.code := 'check',SELF.time := STD.Date.CurrentTime()) );
corpusnew := join(corpus, suggested, LEFT.id=RIGHT.id, TRANSFORM(MAR.Types.MarRecord, SELF := LEFT), LEFT ONLY)+selected;

//MAR.Body.saveData(corpusnew,file);

OUTPUT(suggested,NAMED('show'));

