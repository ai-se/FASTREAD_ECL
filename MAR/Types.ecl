EXPORT Types := MODULE

EXPORT CsvRecord := RECORD
    STRING Title;
    STRING Abstract;
    INTEGER Year;
    STRING PDF;
    STRING label;
END;

EXPORT MarRecord := {INTEGER ID, CsvRecord, STRING code, INTEGER time};

EXPORT ScoreRecord := {MarRecord, REAL8 score};

END;
