from selenium import webdriver
from selenium.webdriver.common.proxy import *
import time
import os
from zapv2 import ZAPv2 as ZAP
import time

class WeCareAuthScript(object):
    def __init__(self, proxy_host = 'localhost', proxy_port = '8090', target = 'http://localhost:9000'):
        self.proxy_host = proxy_host
        self.proxy_port = proxy_port
        self.target = target

    def run_script(self):
        profile = webdriver.FirefoxProfile()
        profile.set_preference("network.proxy.type", 1)
        profile.set_preference("network.proxy.http", 'localhost')
        profile.set_preference("network.proxy.http_port", 8090)
        profile.set_preference("network.proxy.ssl", 'localhost')
        profile.set_preference("network.proxy.ssl_port", 8090)
        profile.set_preference("network.proxy.no_proxies_on", "*.googleapis.com,*.google.com,*.gstatic.com,*.googleapis.com,*.mozilla.net,*.mozilla.com,ocsp.pki.goog")
        driver = webdriver.Firefox(firefox_profile=profile)
        print("[+] Initialized firefox driver")
        driver.maximize_window()
        # print("maximized window")
        driver.implicitly_wait(120)
        print("[+] ================ Implicit Wait is Set =================")
        url = self.target
        driver.get('%s/login/' % url)
        print('[+] ' + driver.current_url)
        time.sleep(10)
        driver.find_element_by_xpath('/html/body/div/div/section/form/div[1]/input').clear()
        driver.find_element_by_xpath('/html/body/div/div/section/form/div[1]/input').send_keys('bruce.banner@we45.com')
        driver.find_element_by_xpath('/html/body/div/div/section/form/div[2]/input').clear()
        driver.find_element_by_xpath('/html/body/div/div/section/form/div[2]/input').send_keys('secdevops')
        driver.find_element_by_xpath('/html/body/div/div/section/form/div[3]/button').click()
        time.sleep(10)
        print('[+] ' + driver.current_url)
        driver.implicitly_wait(10)
        time.sleep(10)
        print('[+] ' + driver.current_url)
        driver.implicitly_wait(10)
        time.sleep(10)
        print('[+] ' + driver.current_url)
        driver.get('%s/technicians/' % url)
        time.sleep(10)
        print('[+] ' + driver.current_url)
        driver.get('%s/appointment/plan' % url)
        time.sleep(10)
        print('[+] ' + driver.current_url)
        driver.get('%s/appointment/doctor' % url)
        time.sleep(10)
        print('[+] ' + driver.current_url)
        driver.get('%s/secure_tests/' % url)
        time.sleep(10)
        # Sends keys and clicks on 'Search'
        driver.find_element_by_xpath('/html/body/div[2]/div/div[3]/form/div/input[1]').clear()
        driver.find_element_by_xpath('/html/body/div[2]/div/div[3]/form/div/input[1]').send_keys('selenium test')
        driver.implicitly_wait(5)
        driver.find_element_by_xpath('/html/body/div[2]/div/div[3]/form/div/input[2]').click()
        driver.implicitly_wait(5)
        print('[+] ' + driver.current_url)
        driver.get('%s/tests/' % url)
        time.sleep(10)
        # Sends keys and clicks on 'Search'
        driver.find_element_by_xpath('/html/body/div[2]/div/div[3]/form/div/input[1]').clear()
        driver.find_element_by_xpath('/html/body/div[2]/div/div[3]/form/div/input[1]').send_keys('selenium test')
        driver.implicitly_wait(5)
        driver.find_element_by_xpath('/html/body/div[2]/div/div[3]/form/div/input[2]').click()
        driver.implicitly_wait(5)
        print('[+] ' + driver.current_url)
        driver.get('%s/plans/' % url)
        time.sleep(10)
 


proxy_host = os.environ.get('ZAP_IP','localhost') 
proxy_port = os.environ.get('ZAP_PORT',8090) 
proxy_url = "http://{0}:{1}".format(proxy_host,proxy_port)
target_site = 'http://localhost:9000'

zap = ZAP(proxies = {'http': proxy_url, 'https': proxy_url})
policies = zap.ascan.scan_policy_names
if 'Light' not in policies:
    light = zap.ascan.add_scan_policy('Light', alertthreshold='Low', attackstrength='Low')
    print("[+] ================ Add Policy =================")
    print('[+] Added Scan Policy')
WeCareAuthScript(proxy_host=proxy_host, proxy_port=proxy_port, target=target_site).run_script()       
active_scan_id = zap.ascan.scan(target_site,scanpolicyname='Light')

print("[+] Active scan id: {0}".format(active_scan_id))
print("[+] ================ Scan Started =================")
#now we can start monitoring the spider's status
while int(zap.ascan.status(active_scan_id)) < 100:
    print("[+] Scan progress: {0}%".format(zap.ascan.status(active_scan_id)))
    time.sleep(10)

print("[+] ================ Scan Completed =================")
alerts = zap.core.alerts()

print('_'*125)
print('|'+' '*48+'Name'+' '*47+'  |'+'  Severity  '+'|'+'  CWE  |')
print('_'*125)
for alert in alerts:
    name = alert.get('name')
    l = 100 - len(name)
    sev = alert.get('risk')
    sl = 10 - len(sev) 
    cwe = alert.get('cweid')
    cl = 7 - len(cwe) - 1
    print('| '+name+' '*l+'|  '+sev+' '*sl +'|  '+cwe+' '*cl+ '|')
    print('_'*125)
    
zap.core.shutdown()