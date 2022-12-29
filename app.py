import os, subprocess
from flask import Flask, request, abort

app = Flask(__name__)

@app.route("/test", methods=["POST"])
def test():
    # o = subprocess.run(
    #     'TZ="Europe/Prague" Rscript calculateAttribution.R',
    #     stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)

    # FOR POST
    # request_json = request.get_json()
    resultDict = {"RESULT":"OK",
                "DATA":[0,2,6]}
    return {"results": resultDict }


@app.route("/load_and_filter", methods=["POST"])
def load_and_filter():
    request_json = request.get_json()
    o = subprocess.run(
         ''.join(['Rscript ChAMP_Process_GDrive.R ', request_json["gfolder"]]),
         stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)

    resultDict = {"RESULT":"OK",
                "DATA":o}
    return {"results": resultDict }

if __name__ == "__main__":
    app.run(
       debug=True,
       host="0.0.0.0",
       port=int(os.environ.get("PORT",8080)))