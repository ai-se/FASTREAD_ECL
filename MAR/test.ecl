IMPORT MAR;
MAR.Types.MarRecord corpus := MAR.Body.loadData('~Hall.csv');
OUTPUT(corpus(label='yes'));
randsample := MAR.Body.randomSample(corpus);
OUTPUT(randsample);