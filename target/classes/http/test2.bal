import ballerina/http;
import ballerina/mime;
import ballerina/log;
import ballerina/io;
import ballerina/runtime;

//11
listener http:Listener serviceEndpoint2 = new(9102);

listener http:Listener serviceEndpoint3 = new(9103);

http:ServiceEndpointConfiguration httpsEPConfig = {
    secureSocket: {
        keyStore: {
            path: "${ballerina.home}/bre/security/ballerinaKeystore.p12",
            password: "ballerina"
        }
    }
};

listener http:Listener httpsEP = new(9104, config = httpsEPConfig);

http:ClientEndpointConfig endPoint1Config = {
    followRedirects: { enabled: true, maxCount: 3 }
};

http:ClientEndpointConfig endPoint2Config = {
    followRedirects: { enabled: true, maxCount: 5 }
};

http:ClientEndpointConfig endPoint3Config = {
    followRedirects: { enabled: true }
};

http:ClientEndpointConfig endPoint5Config = {
    followRedirects: { enabled: true }
};

@http:ServiceConfig {
    basePath: "/service1"
}
service testRedirect on serviceEndpoint3 {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    resource function redirectClient(http:Caller caller, http:Request req) {
        http:Client endPoint1 = new("http://localhost:9103", config = endPoint1Config );
        var response = endPoint1->get("/redirect1");
        http:Response finalResponse = new;
        if (response is http:Response) {
            finalResponse.setPayload(response.resolvedRequestedURI);
            checkpanic caller->respond(finalResponse);
        } else {
            io:println("Connector error!");
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/maxRedirect"
    }
    resource function maxRedirectClient(http:Caller caller, http:Request req) {
        http:Client endPoint1 = new("http://localhost:9103", config = endPoint1Config );
        var response = endPoint1->get("/redirect1/round1");
        if (response is http:Response) {
            string value = "";
            if (response.hasHeader(http:LOCATION)) {
                value = response.getHeader(http:LOCATION);
            }
            value = value + ":" + response.resolvedRequestedURI;
            checkpanic caller->respond(untaint value);
        } else {
            io:println("Connector error!");
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/crossDomain"
    }
    resource function crossDomain(http:Caller caller, http:Request req) {
        http:Client endPoint2 = new("http://localhost:9103", config = endPoint2Config );
        var response = endPoint2->get("/redirect1/round1");
        if (response is http:Response) {
            var value = response.getTextPayload();
            if (value is string) {
                value = value + ":" + response.resolvedRequestedURI;
                checkpanic caller->respond(untaint value);
            } else {
                io:println("Payload error!");
            }
        } else {
            io:println("Connector error!");
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/noRedirect"
    }
    resource function NoRedirect(http:Caller caller, http:Request req) {
        http:Client endPoint3 = new("http://localhost:9102", config = endPoint3Config );
        var response = endPoint3->get("/redirect2");
        if (response is http:Response) {
            var value = response.getTextPayload();
            if (value is string) {
                value = value + ":" + response.resolvedRequestedURI;
                checkpanic caller->respond(untaint value);
            } else {
                io:println("Payload error!");
            }
        } else {
            io:println("Connector error!");
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/qpWithRelativePath"
    }
    resource function qpWithRelativePath(http:Caller caller, http:Request req) {
        http:Client endPoint2 = new("http://localhost:9103", config = endPoint2Config );
        var response = endPoint2->get("/redirect1/qpWithRelativePath");
        if (response is http:Response) {
            var value = response.getTextPayload();
            if (value is string) {
                value = value + ":" + response.resolvedRequestedURI;
                checkpanic caller->respond(untaint value);
            } else  {
                io:println("Payload error!");
            }
        } else {
            io:println("Connector error!");
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/qpWithAbsolutePath"
    }
    resource function qpWithAbsolutePath(http:Caller caller, http:Request req) {
        http:Client endPoint2 = new("http://localhost:9103", config = endPoint2Config );
        var response = endPoint2->get("/redirect1/qpWithAbsolutePath");
        if (response is http:Response) {
            var value = response.getTextPayload();
            if (value is string) {
                value = value + ":" + response.resolvedRequestedURI;
                checkpanic caller->respond(untaint value);
            } else {
                io:println("Payload error!");
            }
        } else {
            io:println("Connector error!");
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/originalRequestWithQP"
    }
    resource function originalRequestWithQP(http:Caller caller, http:Request req) {
        http:Client endPoint2 = new("http://localhost:9103", config = endPoint2Config );
        var response = endPoint2->get("/redirect1/round4?key=value&lang=ballerina");
        if (response is http:Response) {
            var value = response.getTextPayload();
            if (value is string) {
                value = value + ":" + response.resolvedRequestedURI;
                checkpanic caller->respond(untaint value);
            } else {
                io:println("Payload error!");
            }
        } else {
            io:println("Connector error!");
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/test303"
    }
    resource function test303(http:Caller caller, http:Request req) {
        http:Client endPoint3 = new("http://localhost:9102", config = endPoint3Config );
        var response = endPoint3->post("/redirect2/test303", "Test value!");
        if (response is http:Response) {
            var value = response.getTextPayload();
            if (value is string) {
                value = value + ":" + response.resolvedRequestedURI;
                checkpanic caller->respond(untaint value);
            } else {
                io:println("Payload error!");
            }
        } else {
            io:println("Connector error!");
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/redirectOff"
    }
    resource function redirectOff(http:Caller caller, http:Request req) {
        http:Client endPoint4 = new("http://localhost:9103");
        var response = endPoint4->get("/redirect1/round1");
        if (response is http:Response) {
            string value = "";
            if (response.hasHeader(http:LOCATION)) {
                value = response.getHeader(http:LOCATION);
            }
            value = value + ":" + response.resolvedRequestedURI;
            checkpanic caller->respond(untaint value);
        } else {
            io:println("Connector error!");
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/httpsRedirect"
    }
    resource function redirectWithHTTPs(http:Caller caller, http:Request req) {
        http:Client endPoint5 = new("https://localhost:9104", config = endPoint5Config );
        var response = endPoint5->get("/redirect3");
        if (response is http:Response) {
            var value = response.getTextPayload();
            if (value is string) {
                value = value + ":" + response.resolvedRequestedURI;
                checkpanic caller->respond(untaint value);
            } else {
                io:println("Payload error!");
            }
        } else {
            io:println("Connector error!");
        }
    }
}

@http:ServiceConfig {
    basePath: "/redirect1"
}
service redirect1 on serviceEndpoint3 {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    resource function redirect1(http:Caller caller, http:Request req) {
        http:Response res = new;
        checkpanic caller->redirect(res, http:REDIRECT_TEMPORARY_REDIRECT_307, ["http://localhost:9102/redirect2"]);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/round1"
    }
    resource function round1(http:Caller caller, http:Request req) {
        http:Response res = new;
        checkpanic caller->redirect(res, http:REDIRECT_PERMANENT_REDIRECT_308, ["/redirect1/round2"]);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/round2"
    }
    resource function round2(http:Caller caller, http:Request req) {
        http:Response res = new;
        checkpanic caller->redirect(res, http:REDIRECT_USE_PROXY_305, ["/redirect1/round3"]);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/round3"
    }
    resource function round3(http:Caller caller, http:Request req) {
        http:Response res = new;
        checkpanic caller->redirect(res, http:REDIRECT_MULTIPLE_CHOICES_300, ["/redirect1/round4"]);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/round4"
    }
    resource function round4(http:Caller caller, http:Request req) {
        http:Response res = new;
        checkpanic caller->redirect(res, http:REDIRECT_MOVED_PERMANENTLY_301, ["/redirect1/round5"]);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/round5"
    }
    resource function round5(http:Caller caller, http:Request req) {
        http:Response res = new;
        checkpanic caller->redirect(res, http:REDIRECT_FOUND_302, ["http://localhost:9102/redirect2"]);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/qpWithRelativePath"
    }
    resource function qpWithRelativePath(http:Caller caller, http:Request req) {
        http:Response res = new;
        checkpanic caller->redirect(res, http:REDIRECT_TEMPORARY_REDIRECT_307, ["/redirect1/processQP?key=value&lang=ballerina"
            ]);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/qpWithAbsolutePath"
    }
    resource function qpWithAbsolutePath(http:Caller caller, http:Request req) {
        http:Response res = new;
        checkpanic caller->redirect(res, http:REDIRECT_TEMPORARY_REDIRECT_307, [
                "http://localhost:9103/redirect1/processQP?key=value&lang=ballerina"]);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/processQP"
    }
    resource function processQP(http:Caller caller, http:Request req) {
        map<string> paramsMap = req.getQueryParams();
        string returnVal = paramsMap.key + ":" + paramsMap.lang;
        checkpanic caller->respond(untaint returnVal);
    }
}

@http:ServiceConfig {
    basePath: "/redirect2"
}
service redirect2 on serviceEndpoint2 {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    resource function redirect2(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setPayload("hello world");
        checkpanic caller->respond(res);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/test303"
    }
    resource function test303(http:Caller caller, http:Request req) {
        http:Response res = new;
        checkpanic caller->redirect(res, http:REDIRECT_SEE_OTHER_303, ["/redirect2"]);
    }
}

@http:ServiceConfig {
    basePath:"/redirect3"
}

service redirect3 on httpsEP {

    @http:ResourceConfig {
        methods:["GET"],
        path:"/"
    }
    resource function firstRedirect(http:Caller caller, http:Request req) {
        http:Response res = new;
        checkpanic caller->redirect(res, http:REDIRECT_SEE_OTHER_303, ["/redirect3/result"]);
    }

    @http:ResourceConfig {
        methods:["GET"],
        path:"/result"
    }
    resource function finalResult(http:Caller caller, http:Request req) {
        checkpanic caller->respond("HTTPs Result");
    }
}

//12
listener http:Listener serviceEndpoint1 = new(9105);

// Define the end point to the call the `mockHelloService`.
http:Client backendClientEP = new ("http://localhost:9105", config = {
    // Retry configuration options.
    retryConfig: {
        interval: 3000,
        count: 3,
        backOffFactor: 0.5
    },
    timeoutMillis: 2000
});

@http:ServiceConfig {
    basePath: "/retry"
}
service retryDemoService on serviceEndpoint1 {
    // Create a REST resource within the API.
    @http:ResourceConfig {
        methods: ["GET", "POST"],
        path: "/"
    }
    // Parameters include a reference to the caller endpoint and an object of
    // the request data.
    resource function invokeEndpoint(http:Caller caller, http:Request request) {
        var backendResponse = backendClientEP->forward("/hello", request);
        if (backendResponse is http:Response) {
            var responseToCaller = caller->respond(backendResponse);
            if (responseToCaller is error) {
                log:printError("Error sending response", err = responseToCaller);
            }
        } else {
            http:Response response = new;
            response.statusCode = http:INTERNAL_SERVER_ERROR_500;
            string errCause = <string> backendResponse.detail().message;
            response.setPayload(errCause);
            var responseToCaller = caller->respond(response);
            if (responseToCaller is error) {
                log:printError("Error sending response", err = responseToCaller);
            }
        }
    }
}

int counter = 0;

// This sample service is used to mock connection timeouts and service outages.
// The service outage is mocked by stopping/starting this service.
// This should run separately from the `retryDemoService` service.
@http:ServiceConfig { basePath: "/hello" }
service mockHelloService on serviceEndpoint1 {
    @http:ResourceConfig {
        methods: ["GET", "POST"],
        path: "/"
    }
    resource function sayHello(http:Caller caller, http:Request req) {
        counter = counter + 1;
        if (counter % 4 != 0) {
            log:printInfo(
                "Request received from the client to delayed service.");
            // Delay the response by 5000 milliseconds to
            // mimic network level delays.
            runtime:sleep(5000);
            http:Response res = new;
            res.setPayload("Hello World!!!");
            var result = caller->respond(res);

            if (result is error) {
                log:printError("Error sending response from mock service", err = result);
            }
        } else {
            log:printInfo("Request received from the client to healthy service.");
            http:Response response = new;
            if (req.hasHeader(mime:CONTENT_TYPE)
                && req.getHeader(mime:CONTENT_TYPE).hasPrefix(http:MULTIPART_AS_PRIMARY_TYPE)) {
                var bodyParts = req.getBodyParts();
                if (bodyParts is mime:Entity[]) {
                    foreach var bodyPart in bodyParts {
                        if (bodyPart.hasHeader(mime:CONTENT_TYPE)
                            && bodyPart.getHeader(mime:CONTENT_TYPE).hasPrefix(http:MULTIPART_AS_PRIMARY_TYPE)) {
                            var nestedParts = bodyPart.getBodyParts();
                            if (nestedParts is error) {
                                log:printError(<string> nestedParts.detail().message);
                                response.setPayload("Error in decoding nested multiparts!");
                                response.statusCode = 500;
                            } else {
                                mime:Entity[] childParts = nestedParts;
                                foreach var childPart in childParts {
                                    // When performing passthrough scenarios, message needs to be built before
                                    // invoking the endpoint to create a message datasource.
                                    var childBlobContent = childPart.getByteArray();
                                }
                                io:println(bodyPart.getContentType());
                                bodyPart.setBodyParts(untaint childParts, contentType = untaint bodyPart.getContentType());
                            }
                        } else {
                            var bodyPartBlobContent = bodyPart.getByteArray();
                        }
                    }
                    response.setBodyParts(untaint bodyParts, contentType = untaint req.getContentType());
                } else {
                    log:printError(bodyParts.reason());
                    response.setPayload("Error in decoding multiparts!");
                    response.statusCode = 500;
                }
            } else {
                response.setPayload("Hello World!!!");
            }
            var responseToCaller = caller->respond(response);
            if (responseToCaller is error) {
                log:printError("Error sending response from mock service", err = responseToCaller);
            }
        }
    }
}


//26
http:Client internalErrorEP = new("http://localhost:8080", config = {
    retryConfig: {
        interval: 3000,
        count: 3,
        backOffFactor: 2.0,
        maxWaitInterval: 20000,
        statusCodes: [501, 502, 503]
    },
    timeoutMillis: 2000
});

@http:ServiceConfig {
    basePath: "/retry"
}
service retryStatusService on new http:Listener(9225) {
    @http:ResourceConfig {
        methods: ["GET", "POST"],
        path: "/"
    }
    resource function invokeEndpoint(http:Caller caller, http:Request request) {
        if (request.getHeader("x-retry") == "recover") {
            var backendResponse = internalErrorEP->get("/status/recover", message = untaint request);
            if (backendResponse is http:Response) {
                var responseError = caller->respond(backendResponse);
                if (responseError is error) {
                    log:printError("Error sending response", err = responseError);
                }
            } else {
                http:Response errorResponse = new;
                errorResponse.statusCode = 500;
                errorResponse.setPayload(backendResponse.reason());
                var responseError = caller->respond(errorResponse);
                if (responseError is error) {
                    log:printError("Error sending response", err = responseError);
                }
            }
        } else if (request.getHeader("x-retry") == "internalError") {
            var backendResponse = internalErrorEP->get("/status/internalError", message = untaint request);
            if (backendResponse is http:Response) {
                var responseError = caller->respond(backendResponse);
                if (responseError is error) {
                    log:printError("Error sending response", err = responseError);
                }
            } else {
                http:Response errorResponse = new;
                errorResponse.statusCode = 500;
                errorResponse.setPayload(backendResponse.reason());
                var responseError = caller->respond(errorResponse);
                if (responseError is error) {
                    log:printError("Error sending response", err = responseError);
                }
            }
        }
    }
}

int retryCounter = 0;

@http:ServiceConfig { basePath: "/status" }
service mockStatusCodeService on new http:Listener(8080) {
    @http:ResourceConfig {
        methods: ["GET", "POST"],
        path: "/recover"
    }
    resource function recoverableResource(http:Caller caller, http:Request req) {
        retryCounter = retryCounter + 1;
        if (retryCounter % 4 != 0) {
            http:Response res = new;
            res.statusCode = 502;
            res.setPayload("Gateway Timed out.");
            var responseError = caller->respond(res);
            if (responseError is error) {
                log:printError("Error sending response from the service", err = responseError);
            }
        } else {
            var responseError = caller->respond("Hello World!!!");
            if (responseError is error) {
                log:printError("Error sending response from the service", err = responseError);
            }
        }
    }

    @http:ResourceConfig {
        methods: ["GET", "POST"],
        path: "/internalError"
    }
    resource function unRecoverableResource(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.statusCode = 502;
        res.setPayload("Gateway Timed out.");
        var responseError = caller->respond(res);
        if (responseError is error) {
            log:printError("Error sending response from the service", err = responseError);
        }
    }
}

//27
http:ServiceEndpointConfiguration strongCipherConfig = {
    secureSocket: {
        keyStore: {
            path: "${ballerina.home}/bre/security/ballerinaKeystore.p12",
            password: "ballerina"
        },
        trustStore: {
            path: "${ballerina.home}/bre/security/ballerinaTruststore.p12",
            password: "ballerina"
        }
        // Service will start with the strong cipher suites. No need to specify.
    }
};

listener http:Listener strongCipher = new(9226, config = strongCipherConfig);

@http:ServiceConfig {
    basePath: "/echo"
}
service strongService on strongCipher {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    resource function sayHello(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setTextPayload("hello world");
        checkpanic caller->respond(res);
        io:println("successful");
    }
}

http:ServiceEndpointConfiguration weakCipherConfig = {
    secureSocket: {
        keyStore: {
            path: "${ballerina.home}/bre/security/ballerinaKeystore.p12",
            password: "ballerina"
        },
        trustStore: {
            path: "${ballerina.home}/bre/security/ballerinaTruststore.p12",
            password: "ballerina"
        },
        ciphers: ["TLS_RSA_WITH_AES_128_CBC_SHA"]
    }
};

listener http:Listener weakCipher = new(9227, config = weakCipherConfig);

@http:ServiceConfig {
    basePath: "/echo"
}
service weakService on weakCipher {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    resource function sayHello(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setTextPayload("hello world");
        checkpanic caller->respond(res);
        io:println("successful");
    }
}

//13
http:Client stockqEP = new("http://localhost:9107");

@http:ServiceConfig {
    basePath:"/product"
}
service headerService on new http:Listener(9106) {

    resource function value(http:Caller caller, http:Request req) {
        req.setHeader("core", "aaa");
        req.addHeader("core", "bbb");

        var result = stockqEP->get("/sample/stocks", message = untaint req);
        if (result is http:Response) {
            checkpanic caller->respond(result);
        } else {
            checkpanic caller->respond(result.reason());
        }
    }

    resource function id(http:Caller caller, http:Request req) {
        http:Response clntResponse = new;
        var clientResponse = stockqEP->forward("/sample/customers", req);
        if (clientResponse is http:Response) {
            json payload = {};
            if (clientResponse.hasHeader("person")) {
                string[] headers = clientResponse.getHeaders("person");
                if (headers.length() == 2) {
                    payload = {header1:headers[0], header2:headers[1]};
                } else {
                    payload = {"response":"expected number of 'person' headers not found"};
                }
            } else {
                payload = {"response":"person header not available"};
            }
            checkpanic caller->respond(payload);
        } else {
            checkpanic caller->respond(clientResponse.reason());
        }
    }

    resource function nonEntityBodyGet(http:Caller caller, http:Request req) {
        var result = stockqEP->get("/sample/entitySizeChecker");
        if (result is http:Response) {
            checkpanic caller->respond(result);
        } else {
            checkpanic caller->respond(result.reason());
        }
    }

    resource function entityBodyGet(http:Caller caller, http:Request req) {
        var result = stockqEP->get("/sample/entitySizeChecker", message = "hello");
        if (result is http:Response) {
            checkpanic caller->respond(result);
        } else {
            checkpanic caller->respond(result.reason());
        }
    }

    resource function entityGet(http:Caller caller, http:Request req) {
        http:Request request = new;
        request.setHeader("X_test", "One header");
        var result = stockqEP->get("/sample/entitySizeChecker", message = request);
        if (result is http:Response) {
            checkpanic caller->respond(result);
        } else {
            checkpanic caller->respond(result.reason());
        }
    }

    resource function entityForward(http:Caller caller, http:Request req) {
        var result = stockqEP->forward("/sample/entitySizeChecker", req);
        if (result is http:Response) {
            checkpanic caller->respond(result);
        } else {
            checkpanic caller->respond(result.reason());
        }
    }

    resource function entityExecute(http:Caller caller, http:Request req) {
        var result = stockqEP->execute("GET", "/sample/entitySizeChecker", "hello ballerina");
        if (result is http:Response) {
            checkpanic caller->respond(result);
        } else {
            checkpanic caller->respond(result.reason());
        }
    }

    resource function noEntityExecute(http:Caller caller, http:Request req) {
        var result = stockqEP->execute("GET", "/sample/entitySizeChecker", ());
        if (result is http:Response) {
            checkpanic caller->respond(result);
        } else {
            checkpanic caller->respond(result.reason());
        }
    }

    resource function passthruGet(http:Caller caller, http:Request req) {
        var result = stockqEP->get("/sample/entitySizeChecker", message = untaint req);
        if (result is http:Response) {
            checkpanic caller->respond(result);
        } else {
            checkpanic caller->respond(result.reason());
        }
    }
}

@http:ServiceConfig {
    basePath:"/sample"
}
service quoteService1 on new http:Listener(9107) {

    @http:ResourceConfig {
        methods:["GET"],
        path:"/stocks"
    }
    resource function company(http:Caller caller, http:Request req) {
        json payload = {};
        if (req.hasHeader("core")) {
            string[] headers = req.getHeaders("core");
            if (headers.length() == 2) {
                payload = {header1:headers[0], header2:headers[1]};
            } else {
                payload = {"response":"expected number of 'core' headers not found"};
            }
        } else {
            payload = {"response":"core header not available"};
        }
        http:Response res = new;
        res.setJsonPayload(untaint payload);
        checkpanic caller->respond(res);
    }

    @http:ResourceConfig {
        methods:["GET"],
        path:"/customers"
    }
    resource function product(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setHeader("person", "kkk");
        res.addHeader("person", "jjj");
        checkpanic caller->respond(res);
    }

    resource function entitySizeChecker(http:Caller caller, http:Request req) {
        if (req.hasHeader("content-length")) {
            checkpanic caller->respond("Content-length header available");
        } else {
            checkpanic caller->respond("No Content size related header present");
        }
    }
}

//14
listener http:Listener serviceEndpoint4 = new(9108);
http:Client endPoint = new("http://localhost:9108");

@http:ServiceConfig {
    basePath:"/headQuote"
}
service headQuoteService on serviceEndpoint4 {

    @http:ResourceConfig {
        path:"/default"
    }
    resource function defaultResource (http:Caller caller, http:Request req) {
        string method = req.method;
        http:Request clientRequest = new;

        var response = endPoint -> execute(untaint method, "/getQuote/stocks", clientRequest);
        if (response is http:Response) {
            checkpanic caller->respond(response);
        } else {
            json errMsg = {"error":"error occurred while invoking the service"};
           checkpanic caller->respond(errMsg);
        }
    }

    @http:ResourceConfig {
        path:"/forward11"
    }
    resource function forwardRes11 (http:Caller caller, http:Request req) {
        var response = endPoint -> forward("/getQuote/stocks", req);
        if (response is http:Response) {
            checkpanic caller->respond(response);
        } else {
            json errMsg = {"error":"error occurred while invoking the service"};
           checkpanic caller->respond(errMsg);
        }
    }

    @http:ResourceConfig {
        path:"/forward22"
    }
    resource function forwardRes22 (http:Caller caller, http:Request req) {
        var response = endPoint -> forward("/getQuote/stocks", req);
        if (response is http:Response) {
            checkpanic caller->respond(response);
        } else {
            json errMsg = {"error":"error occurred while invoking the service"};
           checkpanic caller->respond(errMsg);
        }
    }

    @http:ResourceConfig {
        path:"/getStock/{method}"
    }
    resource function commonResource (http:Caller caller, http:Request req, string method) {
        http:Request clientRequest = new;
        var response = endPoint -> execute(untaint method, "/getQuote/stocks", clientRequest);
        if (response is http:Response) {
            checkpanic caller->respond(response);
        } else {
            json errMsg = {"error":"error occurred while invoking the service"};
           checkpanic caller->respond(errMsg);
        }
    }
}

@http:ServiceConfig {
    basePath:"/sampleHead"
}
service testClientConHEAD on serviceEndpoint4 {

    @http:ResourceConfig {
        methods:["HEAD"],
        path:"/"
    }
    resource function passthrough (http:Caller caller, http:Request req) {
        http:Request clientRequest = new;
        var response = endPoint -> get("/getQuote/stocks", message = clientRequest);
        if (response is http:Response) {
            checkpanic caller->respond(response);
        } else {
            json errMsg = {"error":"error occurred while invoking the service"};
           checkpanic caller->respond(errMsg);
        }
    }
}

@http:ServiceConfig {
    basePath:"/getQuote"
}
service quoteService2 on serviceEndpoint4 {

    @http:ResourceConfig {
        methods:["GET"],
        path:"/stocks"
    }
    resource function company (http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setTextPayload("wso2");
        checkpanic caller->respond(res);
    }

    @http:ResourceConfig {
        methods:["POST"],
        path:"/stocks"
    }
    resource function product (http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setTextPayload("ballerina");
        checkpanic caller->respond(res);
    }

    @http:ResourceConfig {
        path:"/stocks"
    }
    resource function defaultStock (http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setHeader("Method", "any");
        res.setTextPayload("default");
        checkpanic caller->respond(res);
    }

    @http:ResourceConfig {
        methods:["POST"],
        body:"person"
    }
    resource function employee (http:Caller caller, http:Request req, json person) {
        http:Response res = new;
        res.setJsonPayload(untaint person);
        checkpanic caller->respond(res);
    }
}

//16
@http:ServiceConfig {
    basePath: "/idle"
}
service idleTimeout on new http:Listener(9112, config = { timeoutMillis: 1000 }) {
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/timeout408"
    }
    resource function timeoutTest408(http:Caller caller, http:Request req) {
        var result = req.getTextPayload();
        if (result is string) {
            log:printInfo(result);
        } else  {
            log:printError("Error reading request", err = result);
        }
        var responseError = caller->respond("some");
        if (responseError is error) {
            log:printError("Error sending response", err = responseError);
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/timeout500"
    }
    resource function timeoutTest500(http:Caller caller, http:Request req) {
        runtime:sleep(3000);
        var responseError = caller->respond("some");
        if (responseError is error) {
            log:printError("Error sending response", err = responseError);
        }
    }
}


