What is FASTREAD_ECL?
-----
FASTREAD_ECL is a tool to support primary study selection in systematic literature review implemented on HPCC for massive scale-up.

Latest Versions:

- On Github repo: [https://github.com/ai-se/FASTREAD_ECL](https://github.com/ai-se/FASTREAD_ECL).

Setting up FASTREAD
-----

1. Setting up HPCC:
  + Install HPCC [virtual machine](https://hpccsystems.com/download/virtual-machine-image)
  + Install [HPCC Client Tools](https://hpccsystems.com/download/developer-tools/client-tools)
    - add *C:\Program Files (x86)\HPCCSystems\xx.xx\clienttools\bin* (the installation path to ecl.exe) to your environment path.

2. Setting up Python:
  + We use anaconda by continuum.io (see [Why?](https://www.continuum.io/why-anaconda))
    - We won't need the entire distribution. [Download](http://conda.pydata.org/miniconda.html) a Python 2.7 version & install a minimal version of anaconda.
  + Make sure you select add to PATH during install.

3. Getting dependencies:
  + get flask package from anaconda: run *conda install flask* in your terminal/shell.
  + get ecl-ml from [github](https://github.com/hpcc-systems/ecl-ml)
  + get [libsvm](https://www.csie.ntu.edu.tw/~cjlin/libsvm/)
  + put ecl-ml and libsvm in the same directory alongside FASTREAD_ECL

4. Running HPCC in virtual box:
  + follow the instruction [here](https://hpccsystems.com/download/virtual-machine-image)

5. Running script:
  + Navigate to *src* and run `index.py`.
  + If all is well, you'll be greeted by this:
  ![](https://github.com/fastread/src/blob/master/tutorial/screenshots/run.png?raw=yes)

6. The Interface:
  + Fire up your browser and go to [`http://localhost:5000/hello/`](http://localhost:5000/hello/). You'll see a page like below:
  ![](https://github.com/fastread/src/blob/master/tutorial/screenshots/start.png?raw=yes)
    
Use FASTREAD_ECL
-----

1. Get data ready:
  + Put your data (a csv file) in *workspace > data*.
  + One copy of the data should be uploaded onto HPCC landing zone, then spray it. (Using ECL_Watch)
  + The data file can be as the same format as the example file *workspace > data > Hall.csv* or a csv file exported from [IEEExplore](http://ieeexplore.ieee.org/).
  
2. Load the data:
  + Click **Choose File** button to select your csv file in *workspace > data*. Wait up to minutes for the first time. Once the data is successfully loaded, you will see the following:
  ![](https://github.com/fastread/src/blob/master/tutorial/screenshots/load.png?raw=yes)
  
3. Begin reviewing studies:
  - choose from **Relevant**, **Irrelevant**, or **Undetermined** for each study and hit **Submit**.
  - hit **Next** when you want a to review more.
  - statistics are displayed as **Documents Coded: x/y (z)**, where **x** is the number of relevant studies retrieved, **y** is the number of studies reviewed, and **z** is the total number of candidate studies.
  - when **x** is greater than or equal to 1, an SVM model will be trained after hitting **Next**.
  - rather than **Random** sampling, you can now select **certain** or **uncertain** for reviewing studies. **certain** returns the studies that the model thinks are most possible to be relevant while **uncertain** returns the studies that model is least confident to classify.
  - keep reviewing studies until you think most relevant ones have been retrieved.
  
3.5. Auto review:
  + If your data contains true label, like Hall.csv does, another button called **Auto Review** will be enabled. By clicking it, it automatically labels all your current studies (depending on the selection **Random**, **certain** or **uncertain**).

4. Plot the curve:
  + Click **Plot** button will plot a **Relevant studies retrieved** vs. **Studies reviewed** curve.
  + Check **Auto Plot** so that every time you hit next, a curve will be automatically generated.
  + You can also find the figure in *src > static > image*.
  ![](https://github.com/fastread/src/blob/master/tutorial/screenshots/plot.png?raw=yes)
  
5. Export csv:
  + Click **Export** button will generate a csv file with your coding in *workspace > coded*.

6. Restart:
  + Click **Restart** button will give you a fresh start and loose all your previous effort on the current data.
  
7. Remember to click **Next** button:
  + User data will be saved when and only when you hit **Next** button, so please don't forget to hit it before you want to stop reviewing.
  

  
Version Logs
-----
May 20, 2017. **v1.0.0** The very first, basic version is released.

