/*
 *  Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  WSO2 Inc. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */
package testcases;

import io.netty.handler.codec.http.HttpHeaderNames;
import org.testng.Assert;
import utils.HttpClientRequest;
import utils.HttpResponse;
import utils.ServerInstance;
import utils.TestConstant;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * Testing the passthrough service for HTTP methods.
 */
public class HTTPVerbsPassthruTestCases {

    private static final int servicePort = 9108;

    public static void testPassthroughSampleForHEAD() throws IOException {
        HttpResponse response = HttpClientRequest.doHead(ServerInstance.getServiceURLHttp(servicePort, "sampleHead"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), null, "Message content mismatched");
    }

    public static void testPassthroughSampleForGET() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort,
                                                                                         "headQuote/default"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "wso2", "Message content mismatched");
    }

    public static void testPassthroughSampleForPOST() throws IOException {
        Map<String, String> headers = new HashMap<>();
        HttpResponse response = HttpClientRequest.doPost(
                ServerInstance.getServiceURLHttp(servicePort, "headQuote/default"), "test", headers);
        if (response == null) {
            //Retrying to avoid intermittent test failure
            response = HttpClientRequest.doPost(ServerInstance.getServiceURLHttp(9090, "headQuote/default")
                    , "test", headers);
            ;
        }
        Assert.assertNotNull(response);
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "ballerina", "Message content mismatched");
    }

    public static void testPassthroughSampleWithDefaultResource() throws IOException {
        HttpResponse response = HttpClientRequest.doHead(ServerInstance.getServiceURLHttp(servicePort,
                                                                                          "headQuote/default"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getHeaders().get("Method"), "any", "Header mismatched");
        Assert.assertEquals(response.getData(), null, "Message content mismatched");
    }

    public static void testOutboundPUT() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort,
                                                                                         "headQuote/getStock/PUT"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getHeaders().get("Method"), "any", "Header mismatched");
        Assert.assertEquals(response.getData(), "default", "Message content mismatched");
    }

    public static void testForwardActionWithGET() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort,
                                                                                         "headQuote/forward11"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "wso2", "Message content mismatched");
    }

    public static void testForwardActionWithPOST() throws IOException {
        HttpResponse response = HttpClientRequest.doPost(
                ServerInstance.getServiceURLHttp(servicePort, "headQuote/forward22"), "test", new HashMap<>());
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "ballerina", "Message content mismatched");
    }

    public static void testDataBindingJsonPayload() throws IOException {
        String payload = "{\"name\":\"WSO2\", \"team\":\"ballerina\"}";
        Map<String, String> headers = new HashMap<>();
        headers.put(HttpHeaderNames.CONTENT_TYPE.toString(), TestConstant.CONTENT_TYPE_JSON);
        HttpResponse response = HttpClientRequest.doPost(
                ServerInstance.getServiceURLHttp(servicePort, "getQuote/employee"), payload, headers);
        Assert.assertNotNull(response);
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), payload);
    }

    public static void testDataBindingWithIncompatiblePayload() throws IOException {
        String payload = "name:WSO2,team:ballerina";
        Map<String, String> headers = new HashMap<>();
        headers.put(HttpHeaderNames.CONTENT_TYPE.toString(), TestConstant.CONTENT_TYPE_TEXT_PLAIN);
        HttpResponse response = HttpClientRequest.doPost(
                ServerInstance.getServiceURLHttp(servicePort, "getQuote/employee"), payload, headers);
        Assert.assertNotNull(response);
        Assert.assertEquals(response.getResponseCode(), 400, "Response code mismatched");
        Assert.assertTrue(response.getData()
                                  .contains("data binding failed: Error in reading payload : unrecognized " +
                                                    "token 'name:WSO2,team:ballerina'"));
    }
}
