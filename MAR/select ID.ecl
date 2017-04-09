recordds1 := RECORD
	INTEGER id;
	INTEGER num;
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
], recordds1);

extract_id := join(datads1, datads2, LEFT.id=RIGHT.id, TRANSFORM(recordds1, SELF := RIGHT));
extract_id2 := join(datads1, datads2, LEFT.id=RIGHT.id, TRANSFORM(recordds1, SELF := LEFT),LEFT ONLY);


OUTPUT(extract_id+extract_id2);
