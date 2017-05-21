from __future__ import print_function, division
from pdb import set_trace
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
import csv
import urllib2
import ujson
import subprocess

class MAR(object):
    def __init__(self):
        self.thor_ip = '192.168.56.101'

    def get_files(self):
        command = "dfuplus action=list name=fastread::*.csv server="+self.thor_ip+":8010"
        output = subprocess.check_output(command, shell=True)
        out = output.split('\r\n')
        real_out=[]
        if len(out)>1:
            real_out=[o.split("fastread::")[1].split('.csv')[0] for o in out[1:] if o]

        return real_out

    def create(self,filename):
        self.filename=filename
        self.name=self.filename.split(".")[0]


        try:
            ## if model already exists, load it ##
            stat=self.get_numbers()
        except:
            ## otherwise read from file ##
            # self.loadfile()
            # self.preprocess()
            stat = self.trans()
            if stat == None:
                self.publish_jobs()
                stat = self.trans()
            # self.save()
        return stat


    def loadfile(self):
        with open("../workspace/data/" + str(self.filename), "r") as csvfile:
            content = [x for x in csv.reader(csvfile, delimiter=',')]
        fields = ["Document Title", "Abstract", "Year", "PDF Link"]
        header = content[0]
        for field in fields:
            ind = header.index(field)
            self.body[field] = [c[ind] for c in content[1:]]
        try:
            ind = header.index("label")
            self.body["label"] = [c[ind] for c in content[1:]]
        except:
            self.hasLabel=False
            self.body["label"] = ["unknown"] * (len(content) - 1)
        try:
            ind = header.index("code")
            self.body["code"] = np.array([c[ind] for c in content[1:]])
        except:
            self.body["code"]=np.array(['undetermined']*(len(content) - 1))
        try:
            ind = header.index("time")
            self.body["time"] = np.array([c[ind] for c in content[1:]])
        except:
            self.body["time"]=np.array([0]*(len(content) - 1))
        return

    def get_numbers(self):
        jobname = 'stat'
        url = "http://" + self.thor_ip + ":8002/WsEcl/submit/query/thor/" + jobname + "/json?"
        url += "file=" + self.name
        url = url.replace(' ', '%20')

        response = urllib2.urlopen(url)
        html = response.read()

        what = ujson.loads(html)
        stat = what[jobname + "Response"]["Results"]["stat"]["Row"][0]

        return stat

    def publish_jobs(self):

        jobs_name = ["trans", "export", "label", "show", "ssave", "stat"]
        for job in jobs_name:
            command = "ecl publish thor ../../MAR/jobs/"+job+".ecl -I\"../../;../../../ecl-ml/\" --name="+job+" --activate --server=192.168.56.101:8010"
            subprocess.check_output(command, shell=True)

    def trans(self):
        jobname = 'trans'
        url = "http://" + self.thor_ip + ":8002/WsEcl/submit/query/thor/" + jobname + "/json?"
        url += "file=" + self.name
        url = url.replace(' ', '%20')

        response = urllib2.urlopen(url)
        html = response.read()

        what = ujson.loads(html)
        try:
            stat = what[jobname + "Response"]["Results"]["stat"]["Row"][0]
        except:
            stat=None

        return stat

    def export(self):
        jobname = 'export'
        url = "http://" + self.thor_ip + ":8002/WsEcl/submit/query/thor/" + jobname + "/json?"
        url += "file=" + self.name
        url = url.replace(' ', '%20')

        response = urllib2.urlopen(url)
        html = response.read()

        what = ujson.loads(html)
        records = what[jobname + "Response"]["Results"]["export"]["Row"]

        fields = ["title", "abstract", "year", "pdf", "label", "code","time"]
        with open("../workspace/coded/" + str(self.name) + ".csv", "wb") as csvfile:
            csvwriter = csv.writer(csvfile, delimiter=',')
            csvwriter.writerow(fields)
            for rs in records:
                tmp=[]
                for f in fields:
                    tmp.append(rs[f])
                csvwriter.writerow(tmp)
        return

    def preprocess(self):
        ### Combine title and abstract for training ###########
        content = [self.body["Document Title"][index] + " " + self.body["Abstract"][index] for index in
                   xrange(len(self.body["Document Title"]))]
        #######################################################

        ### Feature selection by tfidf in order to keep vocabulary ###
        tfidfer = TfidfVectorizer(lowercase=True, stop_words="english", norm=None, use_idf=True, smooth_idf=False,
                                sublinear_tf=False,decode_error="ignore")
        tfidf = tfidfer.fit_transform(content)
        weight = tfidf.sum(axis=0).tolist()[0]
        kept = np.argsort(weight)[-self.fea_num:]
        self.voc = np.array(tfidfer.vocabulary_.keys())[np.argsort(tfidfer.vocabulary_.values())][kept]
        ##############################################################

        ### Term frequency as feature, L2 normalization ##########
        tfer = TfidfVectorizer(lowercase=True, stop_words="english", norm=u'l2', use_idf=False,
                        vocabulary=self.voc,decode_error="ignore")
        self.csr_mat=tfer.fit_transform(content)
        ########################################################
        return

    ## save model ##
    def save(self):
        jobname = 'ssave'
        url = "http://" + self.thor_ip + ":8002/WsEcl/submit/query/thor/" + jobname + "/json?"
        url += "file=" + self.name
        url = url.replace(' ', '%20')

        response = urllib2.urlopen(url)
        html = response.read()
        return html

    def train(self):
        jobname = 'show'
        url = "http://" + self.thor_ip + ":8002/WsEcl/submit/query/thor/" + jobname + "/json?"
        url += "file=" + self.name
        url = url.replace(' ', '%20')

        response = urllib2.urlopen(url)
        html = response.read()

        what = ujson.loads(html)
        records = what[jobname + "Response"]["Results"]["show"]["Row"]

        return records




    ## Code candidate studies ##
    def code(self,id,label):
        jobname = 'label'
        url = "http://" + self.thor_ip + ":8002/WsEcl/submit/query/thor/" + jobname + "/json?"
        url += "file=" + self.name +"&"
        url += "id=" + str(id) + "&"
        url += "label=" + str(label)
        url = url.replace(' ', '%20')

        response = urllib2.urlopen(url)
        html = response.read()

        what = ujson.loads(html)
        stat = what[jobname + "Response"]["Results"]["stat"]["Row"][0]

        return stat

    ## Code candidate studies ##
    def labelrest(self,ids):
        jobname = 'labelrest'
        url = "http://" + self.thor_ip + ":8002/WsEcl/submit/query/thor/" + jobname + "/json?"
        url += "file=" + self.name +"&"
        url += "id=" + str(ids)
        url = url.replace(' ', '%20')

        response = urllib2.urlopen(url)
        html = response.read()
        what = ujson.loads(html)





