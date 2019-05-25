const seleniumServer = require("selenium-server");
const chromedriver = require("chromedriver");

module.exports = {
    selenium : {
        start_process : "true",
        host : "localhost",
        port : 4445,
        server_path: seleniumServer.path,
    },
    src_folders: ['tests'],
    test_settings: {
        default: {
            launch_url: 'http://139.59.88.146',
            selenium_port: 4445,
            selenium_host: 'localhost',
            desiredCapabilities: {
                webdriver: {
                    server_path: chromedriver.path,        
                },
                browserName: 'chrome',
                javascriptEnabled: true,
                acceptSslCerts: true,
                marionette: true,
                chromeOptions: {
                    args: [
                        '--proxy-server=http://127.0.0.1:8090',
                        '--no-sandbox'
                    ]
                }
            }
        }
    }
}


