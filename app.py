import os, tempfile, json
from flask import Flask, request, abort
from flask import send_file

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

    tfile = tempfile.NamedTemporaryFile(mode="w+")
    json.dump(request_json['token'], tfile)
    tfile.flush()

    os.system( ''.join(['Rscript ', 'ChAMP_Process_GDrive.R ', request_json["gfolder"], ' ',
                request_json['email'], ' ', tfile.name]) )

    o = tfile.name #request_json["gfolder"]

    resultDict = {"RESULT":"OK",
                "DATA":o}
    return send_file('/tmp/01_load_filtered.Rda')

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080, debug=True)