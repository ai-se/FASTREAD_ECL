IMPORT ML;
IMPORT ML.Docs AS Docs;
IMPORT MAR;
IMPORT STD;
file:='hall.csv';
d := MAR.Body.loadData(file);
OUTPUT(d);

Docs.Types.Raw getString(MAR.Types.MarRecord old) := TRANSFORM
	SELF.ID := old.ID;
	SELF.Txt := old.Title+old.Abstract;
END;

d1 := PROJECT(d,getString(LEFT));
OUTPUT(d1);


d3 := Docs.Tokenize.Clean(d1);
OUTPUT(d3);

d4 := Docs.Tokenize.Split(d3);
OUTPUT(d4);
/*
lex := Docs.Tokenize.Lexicon(d4);
lex;
o1 := Docs.Tokenize.ToO(d4,lex);
o1;
Docs.Trans(o1).WordBag;
Docs.Trans(o1).WordsCounted;
o2 := Docs.Tokenize.FromO(o1,lex);
o2;

*/