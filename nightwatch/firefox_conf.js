const seleniumServer = require("selenium-server");
const geckodriver = require('geckodriver');

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
                    server_path: geckodriver.path,        
                },
                browserName: 'firefox',
                javascriptEnabled: true,
                acceptSslCerts: true,
                marionette: true,
            },
            proxy: {
                host:'127.0.0.1',
                port:8090,
                protocol: 'http',
            },
        }
    }
}


