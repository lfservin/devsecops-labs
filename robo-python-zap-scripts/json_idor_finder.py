"""
The scanNode function will typically be called once for every page
The scan function will typically be called for every parameter in every URL and Form for every page

Note that new active scripts will initially be disabled
Right click the script in the Scripts tree and select "enable"
"""

import json
import re

account_list = ['id', 'ID', 'Id', 'account']

alert_title = 'Potential Insecure Direct Object Reference (Primary Key) - JSON'
alert_desc = 'ZAP was able to potentially identify authorization bypass possibilities by tampering with Primary Key values that have been injected into fields with ID values.'
alert_cwe = 639
alert_wasc = 2
alert_soln = 'Ensure that authorization checks are performed for every application function. Consider using un-guessable Object Referencing System'
alert_risk = 2
alert_confidence = 1



def mutate_and_send(sas, msg, json_key, orig_msg_length):
    if isinstance(json_key,dict):
        for key, value in json_key.iteritems():
            if re.search('id', key, re.IGNORECASE):
                if isinstance(value, int):
                    print "ID value", value
                    for i in range(1,10):
                        json_key[key] = value + i
                        json_str = json.dumps(json_key)
                        print json_str
                        msg.setRequestBody(json_str)
                        sas.sendAndReceive(msg, False, False)
                        status_code = msg.getResponseHeader().getStatusCode()
                        new_msg_length = msg.getResponseBody().length()
                        delta_length = 0.0
                        if new_msg_length - orig_msg_length != 0:
                            delta_length = ((float(new_msg_length) / float(orig_msg_length)) / float(orig_msg_length))
                        if (status_code == 200 and delta_length < 2.0):
                            # print "Vulnerability created: ", param, value
                            sas.raiseAlert(alert_risk, alert_confidence, alert_title, alert_desc,
                                           msg.getRequestHeader().getURI().toString(), key, str(value), '',
                                           alert_soln, '',
                                           alert_cwe, alert_wasc, msg)





def scanNode(sas, msg):
    orig_msg = msg
    msg = orig_msg.cloneRequest()
    sas.sendAndReceive(orig_msg, False, False)
    orig_msg_length = orig_msg.getResponseBody().length()

    req_method = msg.getRequestHeader().getMethod()
    if req_method == 'POST':
        if 'json' in orig_msg.getRequestHeader().getHeader("Content-Type"):
            body = str(orig_msg.getRequestBody())
            json_val = json.loads(body)
            print dict(json_val)
            mutate_and_send(sas, msg, dict(json_val), orig_msg_length)


        

def scan(sas, msg, param, value):
    pass