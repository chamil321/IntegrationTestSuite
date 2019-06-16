import ballerina/http;
import ballerina/mime;
import ballerina/log;
import ballerina/io;

import ballerina/http as network;


//01

final string ACCEPT_ENCODING = "accept-encoding";

listener http:Listener passthroughEP2 = new(9091);

http:Client acceptEncodingAutoEP = new("http://localhost:9091/hello", config = {
    compression:http:COMPRESSION_AUTO
});

http:Client acceptEncodingEnableEP = new("http://localhost:9091/hello", config = {
    compression:http:COMPRESSION_ALWAYS
});

http:Client acceptEncodingDisableEP = new("http://localhost:9091/hello", config = {
    compression:http:COMPRESSION_NEVER
});

service passthrough on passthroughEP2 {
    @http:ResourceConfig {
        path:"/"
    }
    resource function passthrough(http:Caller caller, http:Request req) {
        if (req.getHeader("AcceptValue") == "auto") {
            var clientResponse = acceptEncodingAutoEP -> post("/",untaint req);
            if (clientResponse is http:Response) {
                var responseError = caller->respond(clientResponse);
                if (responseError is error) {
                    log:printError("Error sending response", err = responseError);
                }
            } else {
                http:Response res = new;
                res.statusCode = 500;
                res.setPayload(clientResponse.reason());
                var responseError = caller->respond(res);
                if (responseError is error) {
                    log:printError("Error sending response", err = responseError);
                }
            }
        } else if (req.getHeader("AcceptValue") == "enable") {
            var clientResponse = acceptEncodingEnableEP -> post("/",untaint req);
            if (clientResponse is http:Response) {
                checkpanic caller->respond(clientResponse);
            } else  {
                http:Response res = new;
                res.statusCode = 500;
                res.setPayload(clientResponse.reason());
                var responseError = caller->respond(res);
                if (responseError is error) {
                    log:printError("Error sending response", err = responseError);
                }
            }
        } else if (req.getHeader("AcceptValue") == "disable") {
            var clientResponse = acceptEncodingDisableEP -> post("/",untaint req);
            if (clientResponse is http:Response) {
                checkpanic caller->respond(clientResponse);
            } else {
                http:Response res = new;
                res.statusCode =500;
                res.setPayload(clientResponse.reason());
                var responseError = caller->respond(res);
                if (responseError is error) {
                    log:printError("Error sending response", err = responseError);
                }
            }
        }
    }
}

#
# Sample hello world service.
#
service hello on passthroughEP2 {

    #
    # The helloResource only accepts requests made using the specified HTTP methods
    #
    @http:ResourceConfig {
        methods:["POST", "PUT", "GET"],
        path:"/"
    }
    resource function helloResource(http:Caller caller, http:Request req) {
        http:Response res = new;
        json payload = {};
        boolean hasHeader = req.hasHeader(ACCEPT_ENCODING);
        if (hasHeader) {
            payload = {acceptEncoding:req.getHeader(ACCEPT_ENCODING)};
        } else {
            payload = {acceptEncoding:"Accept-Encoding hdeaer not present."};
        }
        res.setJsonPayload(untaint payload);
        checkpanic caller->respond(res);
    }
}

//02
http:Client clientEndpoint = new("http://localhost:9224");

@http:ServiceConfig {
    basePath: "/continue"
}
service helloContinue on new http:Listener(9090) {
    @http:ResourceConfig {
        path: "/"
    }
    resource function hello(http:Caller caller, http:Request request) {
        if (request.expects100Continue()) {
            if (request.hasHeader("X-Status")) {
                log:printInfo("Sending 100-Continue response");
                var responseError = caller->continue();
                if (responseError is error) {
                    log:printError("Error sending response", err = responseError);
                }
            } else {
                log:printInfo("Ignore payload by sending 417 response");
                http:Response res = new;
                res.statusCode = 417;
                res.setPayload("Do not send me any payload");
                var responseError = caller->respond(res);
                if (responseError is error) {
                    log:printError("Error sending response", err = responseError);
                }
                return;
            }
        }

        http:Response res = new;
        var result  = request.getTextPayload();

        if (result is string) {
            var responseError = caller->respond(untaint result);
            if (responseError is error) {
                log:printError("Error sending response", err = responseError);
            }
        } else {
            res.statusCode = 500;
            res.setPayload(untaint result.reason());
            log:printError("Failed to retrieve payload from request: " + result.reason());
            var responseError = caller->respond(res);
            if (responseError is error) {
                log:printError("Error sending response", err = responseError);
            }
        }
    }

    @http:ResourceConfig {
        methods: ["POST"]
    }
    resource function getFormParam(http:Caller caller, http:Request req) {
        string replyMsg = "Result =";
        var bodyParts = req.getBodyParts();
        if (bodyParts is mime:Entity[]) {
            int i = 0;
            while (i < bodyParts.length()) {
                mime:Entity part = bodyParts[i];
                mime:ContentDisposition contentDisposition = part.getContentDisposition();
                var result = part.getText();
                if (result is string) {
                    replyMsg += " Key:" + contentDisposition.name + " Value: " + result;
                } else {
                    replyMsg += " Key:" + contentDisposition.name + " Value: " + result.reason();
                }
                i += 1;
            }
            var responseError = caller->respond(untaint replyMsg);
            if (responseError is error) {
                log:printError(responseError.reason(), err = responseError);
            }
        } else {
            log:printError(bodyParts.reason(), err = bodyParts);
        }
    }

    resource function testPassthrough(http:Caller caller, http:Request req) {
        if (req.expects100Continue()) {
            req.removeHeader("Expect");
            var responseError = caller->continue();
            if (responseError is error) {
                log:printError("Error sending response", err = responseError);
            }
        }
        var res = clientEndpoint->forward("/backend/hello", untaint req);
        if (res is http:Response) {
            var responseError = caller->respond(res);
            if (responseError is error) {
                log:printError("Error sending response", err = responseError);
            }
        } else {
            log:printError(res.reason(), err = res);
        }
    }
}

service backend on new http:Listener(9224) {
    resource function hello(http:Caller caller, http:Request request) {
        http:Response response = new;
        var payload = request.getTextPayload();
        if (payload is string) {
            response.setTextPayload(untaint payload);
        } else {
            response.setTextPayload(untaint payload.reason());
        }
        var responseError = caller->respond(response);
        if (responseError is error) {
            log:printError("Error sending response", err = responseError);
        }
    }
}

//03
listener http:Listener serviceEnpoint = new(9092);

http:Client bankInfoService = new("http://localhost:9092/bankinfo/product");

http:Client branchLocatorService = new("http://localhost:9092/branchlocator/product");

@http:ServiceConfig {
    basePath:"/ABCBank"
}
service ATMLocator on serviceEnpoint {
    @http:ResourceConfig {
        methods:["POST"]
    }
    resource function locator(http:Caller caller, http:Request req) {

        http:Request backendServiceReq = new;
        var jsonLocatorReq = req.getJsonPayload();
        if (jsonLocatorReq is json) {
            string zipCode = jsonLocatorReq["ATMLocator"]["ZipCode"].toString();
            io:println("Zip Code " + zipCode);
            json branchLocatorReq = {"BranchLocator":{"ZipCode":""}};
            branchLocatorReq.BranchLocator.ZipCode = zipCode;
            backendServiceReq.setPayload(untaint branchLocatorReq);
        } else {
            io:println("Error occurred while reading ATM locator request");
        }

        http:Response locatorResponse = new;
        var locatorRes = branchLocatorService -> post("", backendServiceReq);
        if (locatorRes is http:Response) {
            locatorResponse = locatorRes;
        } else {
            io:println("Error occurred while reading locator response");
        }

        var branchLocatorRes = locatorResponse.getJsonPayload();
        if (branchLocatorRes is json) {
            string branchCode = branchLocatorRes.ABCBank.BranchCode.toString();
            io:println("Branch Code " + branchCode);
            json bankInfoReq = {"BranchInfo":{"BranchCode":""}};
            bankInfoReq.BranchInfo.BranchCode = branchCode;
            backendServiceReq.setJsonPayload(untaint bankInfoReq);
        } else {
            io:println("Error occurred while reading branch locator response");
        }

        http:Response infomationResponse = new;
        var infoRes = bankInfoService -> post("", backendServiceReq);
        if (infoRes is http:Response) {
            infomationResponse = infoRes;
        } else {
            io:println("Error occurred while writing info response");
        }
        checkpanic caller->respond(infomationResponse);
    }
}

@http:ServiceConfig {
    basePath:"/bankinfo"
}
service Bankinfo on serviceEnpoint {

    @http:ResourceConfig {
        methods:["POST"]
    }
    resource function product(http:Caller caller, http:Request req) {
        http:Response res = new;
        var jsonRequest = req.getJsonPayload();
        if (jsonRequest is json) {
            string branchCode = jsonRequest.BranchInfo.BranchCode.toString();
            json payload = {};
            if (branchCode == "123") {
                payload = {"ABC Bank":{"Address":"111 River Oaks Pkwy, San Jose, CA 95999"}};
            } else {
                payload = {"ABC Bank":{"error":"No branches found."}};
            }
            res.setPayload(payload);
        } else {
            io:println("Error occurred while reading bank info request");
        }

        checkpanic caller->respond(res);
    }
}

@http:ServiceConfig {
    basePath:"/branchlocator"
}
service Banklocator on serviceEnpoint {

    @http:ResourceConfig {
        methods:["POST"]
    }
    resource function product(http:Caller caller, http:Request req) {
        http:Response res = new;
        var jsonRequest = req.getJsonPayload();
        if (jsonRequest is json) {
            string zipCode = jsonRequest.BranchLocator.ZipCode.toString();
            json payload = {};
            if (zipCode == "95999") {
                payload = {"ABCBank":{"BranchCode":"123"}};
            } else {
                payload = {"ABCBank":{"BranchCode":"-1"}};
            }
            res.setPayload(payload);
        } else {
            io:println("Error occurred while reading bank locator request");
        }

        checkpanic caller->respond(res);
    }
}

//04
listener http:Listener mockEP = new(9093);

@http:ServiceConfig {basePath:"/autoCompress", compression: {enable: http:COMPRESSION_AUTO}}
service autoCompress on mockEP {
    @http:ResourceConfig {
        methods:["GET"],
        path:"/"
    }
    resource function test1(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setTextPayload("Hello World!!!");
        checkpanic caller->respond(res);
    }
}

@http:ServiceConfig {basePath:"/alwaysCompress", compression: {enable: http:COMPRESSION_ALWAYS}}
service alwaysCompress on mockEP {
    @http:ResourceConfig {
        methods:["GET"],
        path:"/"
    }
    resource function test2(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setTextPayload("Hello World!!!");
        checkpanic caller->respond(res);
    }
}

@http:ServiceConfig {basePath:"/neverCompress", compression: {enable: http:COMPRESSION_NEVER}}
service neverCompress on mockEP {
    @http:ResourceConfig {
        methods:["GET"],
        path:"/"
    }
    resource function test3(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setTextPayload("Hello World!!!");
        checkpanic caller->respond(res);
    }
}

@http:ServiceConfig {basePath:"/userOverridenValue", compression: {enable: http:COMPRESSION_NEVER}}
service userOverridenValue on mockEP {
    @http:ResourceConfig {
        methods:["GET"],
        path:"/"
    }
    resource function test3(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setTextPayload("Hello World!!!");
        res.setHeader("content-encoding", "deflate");
        checkpanic caller->respond(res);
    }
}

//05
listener http:Listener echoEP1 = new(9094);

@http:ServiceConfig {
    basePath:"/echo"
}
service echo1 on echoEP1 {

    @http:ResourceConfig {
        methods:["POST"],
        path:"/"
    }
    resource function echo1 (http:Caller caller, http:Request req) {
        var payload = req.getTextPayload();
        http:Response resp = new;
        if (payload is string) {
            checkpanic caller->respond(untaint payload);
        } else {
            resp.statusCode = 500;
            string errMsg = <string> payload.detail().message;
            resp.setPayload(untaint errMsg);
            log:printError("Failed to retrieve payload from request: " + payload.reason());
            var responseError = caller->respond(resp);
            if (responseError is error) {
                log:printError("Error sending response", err = responseError);
            }
        }
    }
}

//09
listener http:Listener echoEP3 = new(9099);

listener http:Listener echoEP4 = new(9100);

@http:ServiceConfig {
    basePath:"/echo"
}
service echo3 on echoEP3 {
    @http:ResourceConfig {
        methods:["POST"],
        path:"/"
    }
    resource function echo3 (http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setTextPayload("hello world");
        checkpanic caller->respond(res);
    }
}

@http:ServiceConfig {
    basePath:"/echoOne"
}
service echoOne2 on echoEP3 {
    @http:ResourceConfig {
        methods:["POST"],
        path:"/abc"
    }
    resource function echoAbc (http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setTextPayload("hello world");
        checkpanic caller->respond(res);
    }
}

@http:ServiceConfig {
    basePath:"/echoDummy"
}
service echoDummy2 on echoEP4 {

    @http:ResourceConfig {
        methods:["POST"],
        path:"/"
    }
    resource function echoDummy2 (http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setTextPayload("hello world");
        checkpanic caller->respond(res);
    }

    @http:ResourceConfig {
        methods:["OPTIONS"],
        path:"/getOptions"
    }
    resource function echoOptions (http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setTextPayload("hello Options");
        checkpanic caller->respond(res);
    }
}

//15
listener http:Listener echoDummyEP = new(9109);

listener http:Listener echoHttpEP = new(9110);

http:ServiceEndpointConfiguration echoEP2Config = {
    secureSocket: {
        keyStore: {
            path:"${ballerina.home}/bre/security/ballerinaKeystore.p12",
            password:"ballerina"
        }
    }
};

listener http:Listener echoEP2 = new(9111, config = echoEP2Config);

@http:ServiceConfig {
    basePath:"/echo"
}

service echo2 on echoEP2 {
    @http:ResourceConfig {
        methods:["POST"],
        path:"/"
    }
    resource function echo2(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setTextPayload("hello world");
        checkpanic caller->respond(res);
    }
}

@http:ServiceConfig  {
    basePath:"/echoOne"
}
service echoOne1 on echoEP2, echoHttpEP {
    @http:ResourceConfig {
        methods:["POST"],
        path:"/abc"
    }
    resource function echoAbc(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setTextPayload("hello world");
        checkpanic caller->respond(res);
    }
}

@http:ServiceConfig {
    basePath:"/echoDummy"
}
service echoDummy1 on echoDummyEP {

    @http:ResourceConfig {
        methods:["POST"],
        path:"/"
    }
    resource function echoDummy1(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setTextPayload("hello world");
        checkpanic caller->respond(res);
    }
}

//10
listener network:Listener echoEP5 = new(9101);

@network:ServiceConfig {
    basePath:"/echo"
}
service echo4 on echoEP5 {

    @network:ResourceConfig {
        methods:["POST"],
        path:"/"
    }
    resource function echo4(network:Caller caller, network:Request req) {
        var payload = req.getTextPayload();
        network:Response resp = new;
        if (payload is string) {
            checkpanic caller->respond(untaint payload);
        } else {
            resp.statusCode = 500;
            resp.setPayload(untaint payload.reason());
            log:printError("Failed to retrieve payload from request: " + payload.reason());
            var responseError = caller->respond(resp);
            if (responseError is error) {
                log:printError("Error sending response", err = responseError);
            }
        }
    }
}

//06
listener http:Listener serviceEndpoint5 = new(9095);

@http:ServiceConfig {
    basePath:"/customerservice"
}
service CustomerMgtService on serviceEndpoint5 {

    @http:ResourceConfig {
        methods:["GET", "POST"]
    }
    resource function customers(http:Caller caller, http:Request req) {
        json payload = {};
        string httpMethod = req.method;
        if (httpMethod.equalsIgnoreCase("GET")) {
            payload = {"Customer":{"ID":"987654", "Name":"ABC PQR", "Description":"Sample Customer."}};
        } else {
            payload = {"Status":"Customer is successfully added."};
        }

        http:Response res = new;
        res.setJsonPayload(payload);
        checkpanic caller->respond(res);
    }
}

http:Client productsService = new("http://localhost:9095");

@http:ServiceConfig {
    basePath:"/ecommerceservice"
}
service Ecommerce on serviceEndpoint5 {

    @http:ResourceConfig {
        methods:["GET"],
        path:"/products/{prodId}"
    }
    resource function productsInfo(http:Caller caller, http:Request req, string prodId) {
        string reqPath = "/productsservice/" + untaint prodId;
        http:Request clientRequest = new;
        var clientResponse = productsService->get(untaint reqPath, message = clientRequest);
        if (clientResponse is http:Response) {
            checkpanic caller->respond(clientResponse);
        } else {
            io:println("Error occurred while reading product response");
        }
    }

    @http:ResourceConfig {
        methods:["POST"],
        path:"/products"
    }
    resource function productMgt(http:Caller caller, http:Request req) {
        http:Request clientRequest = new;
        var jsonReq = req.getJsonPayload();
        if (jsonReq is json) {
            clientRequest.setPayload(untaint jsonReq);
        } else {
            io:println("Error occurred while reading products payload");
        }

        http:Response clientResponse = new;
        var clientRes = productsService->post("/productsservice", clientRequest);
        if (clientRes is http:Response) {
            clientResponse = clientRes;
        } else {
            io:println("Error occurred while reading locator response");
        }
        checkpanic caller->respond(clientResponse);
    }

    @http:ResourceConfig {
        methods:["GET"],
        path:"/orders"
    }
    resource function ordersInfo(http:Caller caller, http:Request req) {
        http:Request clientRequest = new;
        var clientResponse = productsService->get("/orderservice/orders", message = clientRequest);
        if (clientResponse is http:Response) {
            checkpanic caller->respond(clientResponse);
        } else {
            io:println("Error occurred while reading orders response");
        }
    }

    @http:ResourceConfig {
        methods:["POST"],
        path:"/orders"
    }
    resource function ordersMgt(http:Caller caller, http:Request req) {
        http:Request clientRequest = new;
        var clientResponse = productsService->post("/orderservice/orders", clientRequest);
        if (clientResponse is http:Response) {
            checkpanic caller->respond(clientResponse);
        } else {
            io:println("Error occurred while writing orders respons");
        }
    }

    @http:ResourceConfig {
        methods:["GET"],
        path:"/customers"
    }
    resource function customersInfo(http:Caller caller, http:Request req) {
        http:Request clientRequest = new;
        var clientResponse = productsService->get("/customerservice/customers", message = clientRequest);
        if (clientResponse is http:Response) {
            checkpanic caller->respond(clientResponse);
        } else {
            io:println("Error occurred while reading customers response");
        }
    }

    @http:ResourceConfig {
        methods:["POST"],
        path:"/customers"
    }
    resource function customerMgt(http:Caller caller, http:Request req) {
        http:Request clientRequest = new;
        var clientResponse = productsService->post("/customerservice/customers", clientRequest);
        if (clientResponse is http:Response) {
            checkpanic caller->respond(clientResponse);
        } else {
            io:println("Error occurred while writing customers response");
        }
    }
}

@http:ServiceConfig {
    basePath:"/orderservice"
}
service OrderMgtService on serviceEndpoint5 {

    @http:ResourceConfig {
        methods:["GET", "POST"]
    }
    resource function orders(http:Caller caller, http:Request req) {
        json payload = {};
        string httpMethod = req.method;
        if (httpMethod.equalsIgnoreCase("GET")) {
            payload = {"Order":{"ID":"111999", "Name":"ABC123", "Description":"Sample order."}};
        } else {
            payload = {"Status":"Order is successfully added."};
        }

        http:Response res = new;
        res.setJsonPayload(payload);
        checkpanic caller->respond(res);
    }
}

@http:ServiceConfig {
    basePath:"/productsservice"
}
service productmgt on serviceEndpoint5 {

    map<any> productsMap = populateSampleProducts();

    @http:ResourceConfig {
        methods:["GET"],
        path:"/{prodId}"
    }
    resource function product(http:Caller caller, http:Request req, string prodId) {
        http:Response res = new;
        var result = json.convert(self.productsMap[prodId]);
        if (result is json) {
            res.setPayload(result);
        } else {
            res.setPayload(result.reason());
        }
        checkpanic caller->respond(res);
    }

    @http:ResourceConfig {
        methods:["POST"],
        path:"/"
    }
    resource function addProduct(http:Caller caller, http:Request req) {
        var jsonReq = req.getJsonPayload();
        if (jsonReq is json) {
            string productId = jsonReq.Product.ID.toString();
            self.productsMap[productId] = jsonReq;
            json payload = {"Status":"Product is successfully added."};

            http:Response res = new;
            res.setPayload(payload);
            checkpanic caller->respond(res);
        } else {
            io:println("Error occurred while reading bank locator request");
        }
    }
}

function populateSampleProducts() returns (map<any>) {
    map<any> productsMap = {};
    json prod_1 = {"Product":{"ID":"123000", "Name":"ABC_1", "Description":"Sample product."}};
    json prod_2 = {"Product":{"ID":"123001", "Name":"ABC_2", "Description":"Sample product."}};
    json prod_3 = {"Product":{"ID":"123002", "Name":"ABC_3", "Description":"Sample product."}};
    productsMap["123000"] = prod_1;
    productsMap["123001"] = prod_2;
    productsMap["123002"] = prod_3;
    io:println("Sample products are added.");
    return productsMap;
}

//07
listener http:Listener helloWorldEp = new(9096);

@http:ServiceConfig {
    basePath:"/hello"
}
service helloWorld on helloWorldEp {
    @http:ResourceConfig {
        methods:["GET"],
        path:"/"
    }
    resource function sayHello(http:Caller caller, http:Request req) {
        http:Response resp = new;
        resp.setTextPayload("Hello, World!");
        checkpanic caller->respond(resp);
    }
}
