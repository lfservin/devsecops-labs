*** Settings ***
Library  Collections
Library  OperatingSystem
Library  RoboZap  http://127.0.0.1:8090/  8090
Library  RoboNodeJSScan
Library  REST  http://localhost:3000  proxies={"http": "http://127.0.0.1:8090", "https": "http://127.0.0.1:8090"}
Library  RoboNpmAudit

*** Variables ***
${TARGET_NAME}  Cut the Funds Expenser Application
${TARGET_URI}  localhost:3000
${TARGET_HOST}  localhost

${RESULTS_PATH}  ${CURDIR}/results

#ZAP
${ZAP_PATH}  /root/zap/ZAP_2.7.0/
${APPNAME}  Cut the Funds NodeJS API
${CONTEXT}  Cut_The_Funds_API
${REPORT_TITLE}  Cut the Funds NodeJS API Test Report - ZAP
${REPORT_FORMAT}  json
${ZAP_REPORT_FILE}  ctf.json
${REPORT_AUTHOR}  Abhay Bhargav
${SCANPOLICY}  Light

${TO_PATH}  ${CURDIR}/Cut-The-Funds-NodeJS

*** Test Cases ***
Setup directories
    Create Directory  ${RESULTS_PATH}

Run NodeJSScanner
    run nodejsscan against source  ${TO_PATH}  ${RESULTS_PATH}

Run NPM Audit against packageJSON
    run npmaudit against source  ${TO_PATH}  ${RESULTS_PATH}

Initialize ZAP
    [Tags]  zap_init
    start headless zap  ${ZAP_PATH}
    sleep  30
    zap open url  http://${TARGET_URI}

Authenticate to Cut the Funds as Admin
    [Tags]  walk_web_service
    &{res}=  POST  /users/login  {"email": "andy.roberts@widget.co", "password": "spiderman"}
    Integer  response status  200
    Boolean  response body auth  true
    set suite variable  ${TOKEN}  ${res.body["token"]}
    log  ${TOKEN}

Search the Currency Lookup Service
    [Tags]  walk_web_service
    [Setup]  Set Headers  { "Authorization": "${TOKEN}" }
    POST  /projects/search_expense_db  { "search": "Chile" }
    Integer  response status  200
    String  $[0].country  Chile

ZAP Contextualize
    [Tags]  zap_context
    ${contextid}=  zap define context  ${CONTEXT}  http://${TARGET_URI}
    set suite variable  ${CONTEXT_ID}  ${contextid}

ZAP Active Scan
    [Tags]  zap_scan
    ${scan_id}=  zap start ascan  ${CONTEXT_ID}  http://${TARGET_URI}  ${SCANPOLICY}
    set suite variable  ${SCAN_ID}  ${scan_id}
    zap scan status  ${scan_id}

ZAP Generate Report
    [Tags]  zap_generate_report
    zap export report  ${RESULTS_PATH}/${ZAP_REPORT_FILE}  ${REPORT_FORMAT}  ${REPORT_TITLE}  ${REPORT_AUTHOR}

ZAP Die
    [Tags]  zap_kill
    zap shutdown
    sleep  3