IMPORT MAR;
IMPORT STD;



ESP_SERVER := '192.168.56.101';
USERNAME := '';
USER_PW := '';
CLUSTER_NAME := 'thor';
 
credentials := MAP
    (
        USERNAME != '' AND USER_PW != ''    =>  USERNAME + ':' + USER_PW + '@',
        USERNAME != ''                      =>  USERNAME + '@',
        ''
    );
 
soapURL := 'http://' + TRIM(credentials) + ESP_SERVER + ':8010/WsWorkunits/';
 
//---------------------------------------------------------------------------------------
 
CreateWorkunit(STRING eclCode) := FUNCTION
    ExceptionsRec := RECORD
        STRING  source      {XPATH('Source')};
        STRING  severity    {XPATH('Severity')};
        INTEGER code        {XPATH('Code')};
        STRING  message     {XPATH('Message')};
        STRING  filename    {XPATH('FileName')};
        INTEGER lineNum     {XPATH('LineNo')};
        INTEGER column      {XPATH('Column')};
    END;
 
    CreateWorkunitResultRec := RECORD
        STRING  wuid                        {XPATH('Workunit/Wuid')};
        DATASET(ExceptionsRec)  exceptions  {XPATH('Exceptions/Exception')};
    END;
 
    createWorkunitResult := SOAPCALL
        (
            soapURL,
            'WUUpdate',
            {
                STRING  ecl {XPATH('QueryText')} := eclCode
            },
            CreateWorkunitResultRec,
            XPATH('WUUpdateResponse')
        );
 
    RETURN createWorkunitResult;
END;
 
//---------------------------------------------------------------------------------------
 
SubmitWorkunit(STRING wuid) := FUNCTION
    ExceptionsRec := RECORD
        INTEGER code        {XPATH('Code')};
        STRING  audience    {XPATH('Audience')};
        STRING  source      {XPATH('Source')};
        STRING  message     {XPATH('Message')};
    END;
 
    submitWorkunitResultRec := RECORD
        STRING  source                      {XPATH('Exceptions/Source')};
        DATASET(ExceptionsRec)  exceptions  {XPATH('Exceptions/Exception')};
    END;
 
    submitWorkunitResult := SOAPCALL
        (
            soapURL,
            'WUSubmit',
            {
                STRING  wuid                {XPATH('Wuid')} := wuid,
                STRING  clusterName         {XPATH('Cluster')} := CLUSTER_NAME
 
            },
            submitWorkunitResultRec,
            XPATH('WUSubmitResponse')
        );
 
    WaitWorkunitCompleteResultRec := RECORD
        INTEGER                 stateID     {XPATH('StateID')};
        DATASET(ExceptionsRec)  exceptions  {XPATH('Exceptions/Exception')};
    END;
 
    waitForWorkunitCompleteResult := SOAPCALL
        (
            soapURL,
            'WUWaitComplete',
            {
                STRING  wuid                {XPATH('Wuid')} := wuid
            },
            WaitWorkunitCompleteResultRec,
            XPATH('WUWaitResponse'),
            LITERAL
        );
 
    RETURN IF
        (
            ~EXISTS(submitWorkunitResult.exceptions),
            waitForWorkunitCompleteResult
        );
END;
 
//---------------------------------------------------------------------------------------
 
GetWorkunitResult(STRING wuid) := FUNCTION
    ExceptionsRec := RECORD
        INTEGER code        {XPATH('Code')};
        STRING  audience    {XPATH('Audience')};
        STRING  source      {XPATH('Source')};
        STRING  message     {XPATH('Message')};
    END;
 
    submitWorkunitResultRec := RECORD
        STRING  wuid                            {XPATH('Wuid')};
        STRING  result                          {XPATH('Result')};
        DATASET(ExceptionsRec)  exceptions      {XPATH('Exceptions/Exception')};
    END;
 
    GetWorkunitResult := SOAPCALL
        (
            soapURL,
            'WUResult',
            {
                STRING  result      {XPATH('Wuid')} := wuid,
                INTEGER seq         {XPATH('Sequence')} := 0
            },
            submitWorkunitResultRec,
            XPATH('WUResultResponse')
        );
 
    RETURN GetWorkunitResult;
END;
 
//---------------------------------------------------------------------------------------
 
STRING in_filename := '\'~work::Hall.out\'';
 
//eclStr := 'IMPORT MAR;\n' + 'STRING filename := ' + in_filename +';\n'+ 'tmp := DATASET(filename,MAR.Types.CSVRecord,FLAT);\n' + 'OUTPUT(tmp);';
eclStr := 'OUTPUT(\'hello\');\n';

createWorkunitResult := CreateWorkunit(eclStr);
 
STRING createdWorkunit := createWorkunitResult.wuid;
submitWorkunitResult := SubmitWorkunit(createdWorkunit);
 
WorkunitResult := GetWorkunitResult(createdWorkunit);
OUTPUT(WorkunitResult)
/*
dummy := DATASET([{'1', '1', 1, '1', '1'}], MAR.Types.CSVRecord);
new_tmp := tmp + dummy;

eclStr2 := 'OUTPUT(new_tmp, ,\'~work::hall.csv\', CSV);\n' + 'OUTPUT(new_tmp)';

 
createWorkunitResult2 := CreateWorkunit(eclStr2);
 
STRING createdWorkunit2 := createWorkunitResult2.wuid;
submitWorkunitResult2 := SubmitWorkunit(createdWorkunit2);
*/
