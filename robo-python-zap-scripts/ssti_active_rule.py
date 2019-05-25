alert_name = "Jinja2 Server Side Template Injection"
alert_desc = "Server-Side Template Injection, where adversary can manipulate template variables. "
alert_cwe = 90
alert_wasc = 1
alert_soln = 'Jinja2 Server Side Template Injection'
alert_risk = 3
alert_confidence = 1

payload = '{{config.items()}}'

def scanNode(sas, msg):
    orig_msg = msg
    msg = orig_msg.cloneRequest()
    #jwt_segments = dummy_jwt.split('.')
    split_uri = str(msg.getRequestHeader().getURI()).split('/')
    if split_uri[:-1] is not None:
        mangle_var = split_uri[-1]
        del split_uri[-1]
        split_uri.append(payload)
        join_url = '/%s' % payload
        msg.getRequestHeader().getURI().setPath(join_url)
        print msg.getRequestHeader().getURI()
        sas.sendAndReceive(msg)
        print msg.getResponseBody().toString()
        if 'JSON_AS_ASCII' in msg.getResponseBody().toString():
            sas.raiseAlert(alert_risk, alert_confidence, alert_name, alert_desc,
                           msg.getRequestHeader().getURI().toString(), msg.getResponseBody().toString(), '', '',
                           alert_soln, '',
                           alert_cwe, alert_wasc, msg)





def scan(sas, msg, param, value):
    pass