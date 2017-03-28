recordds1 := RECORD
	INTEGER id;
	INTEGER num;
END;

recordds2 := RECORD
	INTEGER id;
	INTEGER num2;
END;

datads1 := DATASET([
{1, 1},
{2, 2},
{3, 3},
{4, 4},
{5, 5}], recordds1);

datads2 := DATASET([
{2, 4},
{3, 4}
], recordds2);

extract_id := join(datads1, datads2, LEFT.id=RIGHT.id, TRANSFORM(recordds1, SELF := LEFT) );
OUTPUT(extract_id);