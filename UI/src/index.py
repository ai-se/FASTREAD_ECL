from __future__ import print_function, division

import os
import sys

root = os.getcwd().split("UI")[0] + "UI/src/util"
sys.path.append(root)

from flask import Flask, url_for, render_template, request, jsonify, Response, json
from pdb import set_trace
from mar import MAR

app = Flask(__name__,static_url_path='/static')


global file
target=MAR()

@app.route('/hello/')
def hello():
    return render_template('hello.html')


@app.route('/load',methods=['POST'])
def load():
    global target
    file=request.form['file']
    stat=target.create(file)
    return jsonify({"hasLabel": True, "flag": True, "pos": stat['pos'],"done": int(stat['pos']) + int(stat['neg']), "total": stat['total']})

@app.route('/export',methods=['POST'])
def export():
    try:
        target.export()
        flag=True
    except:
        flag=False
    return jsonify({"flag": flag})


@app.route('/labeling',methods=['POST'])
def labeling():
    id = int(request.form['id'])
    label = request.form['label']
    stat = target.code(id,label)
    x=target.save()
    return jsonify(
        {"flag": True, "pos": stat['pos'], "done": int(stat['pos']) + int(stat['neg']), "total": stat['total']})


@app.route('/restart',methods=['POST'])
def restart():
    stat = target.trans()
    return jsonify(
        {"hasLabel": True, "flag": True, "pos": stat['pos'], "done": int(stat['pos']) + int(stat['neg']), "total": stat['total']})

@app.route('/train',methods=['POST'])
def train():
    records=target.train()
    x=target.save()
    res={'show':records}
    return jsonify(res)

@app.route('/labelrest',methods=['POST'])
def labelrest():
    ids = request.form['id'].strip()
    target.labelrest(ids)
    return


if __name__ == "__main__":
    app.run(debug=False,use_debugger=False)