IMPORT MAR;
IMPORT STD;
file := '': STORED('file', FORMAT(SEQUENCE(1)));
corpus:= MAR.Body.loadData(file);
suggested := MAR.Body.present(corpus,file);
selected := join(corpus, suggested, LEFT.id=RIGHT.id, TRANSFORM(MAR.Types.MarRecord, SELF.Title := LEFT.Title,SELF.Year := LEFT.Year,SELF.PDF := LEFT.PDF,	SELF.label := LEFT.label,	SELF.Abstract := LEFT.Abstract,	SELF.ID := LEFT.ID,SELF.code := 'check',SELF.time := STD.Date.CurrentTime()) );
corpusnew := join(corpus, suggested, LEFT.id=RIGHT.id, TRANSFORM(MAR.Types.MarRecord, SELF := LEFT), LEFT ONLY)+selected;

MAR.Body.saveData(corpusnew,file);

OUTPUT(suggested,NAMED('show'));

