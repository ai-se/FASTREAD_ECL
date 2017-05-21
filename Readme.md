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
  + put ecl-ml and libsvm in the same directory alongside FASTREAD_ECL: ![](https://github.com/ai-se/FASTREAD_ECL/blob/master/tutorials/files.png?raw=yes)


    
Use FASTREAD_ECL
-----
  
1. Running HPCC in virtual box:
  + follow the instruction [here](https://hpccsystems.com/download/virtual-machine-image)
  
2. Get data ready:
  + Prepare a csv file like this:
  ![](https://github.com/ai-se/FASTREAD_ECL/blob/master/tutorials/data.png)
    - the 'label' column stores the TRUE label of each entry, if not applicable, leave it as blank or 'unknown'.
  + Remove the header (first row) of your data file.
  + Open ECL_Watch: *http://ecl_watch_ip::8010*
  ![](https://github.com/ai-se/FASTREAD_ECL/blob/master/tutorials/watch.png?raw=yes)
  + Upload your data file onto HPCC landing zone (**files** > **Landing Zones** > **Upload**):
  ![](https://github.com/ai-se/FASTREAD_ECL/blob/master/tutorials/upload.png?raw=yes)
  + Spray it:
    - Select uploaded file
    - Click **Spray: Delimited**
    - Change the **Target Scope** to *fastread::*
    - Hit **Spray** at bottom right
  ![](https://github.com/ai-se/FASTREAD_ECL/blob/master/tutorials/spray.png?raw=yes)

3. Running script:
  + Navigate to *FASTREAD_ECL > UI > src* and run `index.py`.
  + If all is well, you'll be greeted by this:
  ![](https://github.com/ai-se/FASTREAD_ECL/blob/master/tutorials/run.png?raw=yes)

4. The Interface:
  + Fire up your browser and go to [`http://localhost:5000/hello/`](http://localhost:5000/hello/). You'll see a page like below:
  ![](https://github.com/ai-se/FASTREAD_ECL/blob/master/tutorials/init.png?raw=yes)
  
5. Load the data:
  + Click **Scan** button to see what data files are on your HPCC system. Then select the data to work on from the selection tab. 
  ![](https://github.com/ai-se/FASTREAD_ECL/blob/master/tutorials/load.png?raw=yes)
  + Wait up to minutes for the first time. Once the data is successfully loaded, you will see the following:
  ![](https://github.com/ai-se/FASTREAD_ECL/blob/master/tutorials/start.png?raw=yes)
  
6. Begin reviewing studies:
  - choose from **Relevant**, **Irrelevant**, or **Undetermined** for each study and hit **Submit**.
  - hit **Next** when you want a to review more.
  - statistics are displayed as **Documents Coded: x/y (z)**, where **x** is the number of relevant studies retrieved, **y** is the number of studies reviewed, and **z** is the total number of candidate studies.
  - when **x** is greater than or equal to 1, an SVM model will be trained after hitting **Next**.
  - keep reviewing studies until you think most relevant ones have been retrieved.  

7. Export csv:
  + Click **Export** button will generate a csv file with your coding in *FASTREAD_ECL > UI > workspace > coded*.

6. Restart:
  + Click **Restart** button will give you a fresh start and loose all your previous effort on the current data.
  
 

  
Version Logs
-----
May 20, 2017. **v1.0.0** The very first, basic version is released.

