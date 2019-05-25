*** Settings ***
Library  RoboBurp2  http://localhost:9000/

*** Variables ***
${BURP_EXEC}  ${CURDIR}/burpsuite_pro_v2.0.20beta.jar
${CONFIG_JSON}  ${CURDIR}/user_options.json
${SCAN_CONFIG}  Audit coverage - thorough     

*** Test Cases ***
Burp Start
    start headless burpsuite  ${BURP_EXEC}  ${CONFIG_JSON}
    sleep  30

Burp Authenticated Scan Only    
    ${auth}=  create dictionary  username=bruce.banner@we45.com  password=secdevops
    ${id}=  initiate crawl and scan against target  auth_logins=${auth}  config_name=${SCAN_CONFIG}
    set suite variable  ${SCAN_ID}  ${id}

Burp Scan Status
    sleep  3
    get burp scan status for id  ${SCAN_ID}

Burp Write Results to File
    get burp scan results for id  ${SCAN_ID}

Stop burp process
    stop burpsuite     
