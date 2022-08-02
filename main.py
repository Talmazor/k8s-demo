from msilib.schema import Environment
import flask
import logging
import os

app = flask.Flask(__name__)
port_key = 'PORT'
environment = 'ENVIRONMENT'
port = os.getenv(port_key, 5000)
is_debug = True if os.getenv(environment, 'dev') == 'production' else False


# Return host IP
@app.route("/host_ip")
def host():
    ip_address = flask.request.remote_addr
    return "Server IP: " + ip_address


# Return health
@app.route("/health")
def health_message():
    return "Service is healthy!"


# Return health status
@app.route("/")
def health():
    return "200"


# Log file
logging.basicConfig(filename='/var/log/record.log', level=logging.DEBUG, format=f'%(asctime)s %(levelname)s %(name)s %(threadName)s : %(message)s')


app.run(host='localhost', port=port, debug=is_debug)
