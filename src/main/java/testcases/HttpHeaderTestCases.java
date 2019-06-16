/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package testcases;

import org.testng.Assert;
import utils.HttpClientRequest;
import utils.HttpResponse;
import utils.ServerInstance;

import java.io.IOException;
import java.util.HashMap;

/**
 * Testing the Http headers availability in pass-through scenarios.
 */
public class HttpHeaderTestCases {

    private static final int servicePort = 9106;

    public static void testOutboundRequestHeaders() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort, "product/value"));
        Assert.assertNotNull(response);
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "{\"header1\":\"aaa\", \"header2\":\"bbb\"}");
    }

    public static void testInboundResponseHeaders() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort, "product/id"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "{\"header1\":\"kkk\", \"header2\":\"jjj\"}");
    }

    public static void testOutboundNonEntityBodyGetRequestHeaders() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(
                ServerInstance.getServiceURLHttp(servicePort, "product/nonEntityBodyGet"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "No Content size related header present");
    }

    public static void testOutboundEntityBodyGetRequestHeaders() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(
                ServerInstance.getServiceURLHttp(servicePort, "product/entityBodyGet"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "Content-length header available");
    }

    public static void testOutboundEntityGetRequestHeaders() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(
                ServerInstance.getServiceURLHttp(servicePort, "product/entityGet"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "No Content size related header present");
    }

    public static void testOutboundForwardNoEntityBodyRequestHeaders() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(
                ServerInstance.getServiceURLHttp(servicePort, "product/entityForward"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "No Content size related header present");
    }

    public static void testOutboundForwardEntityBodyRequestHeaders() throws IOException {
        HttpResponse response = HttpClientRequest.doPost(
                ServerInstance.getServiceURLHttp(servicePort, "product/entityForward"), "hello",
                new HashMap<>());
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "Content-length header available");
    }

    public static void testHeadersWithExecuteAction() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(
                ServerInstance.getServiceURLHttp(servicePort, "product/entityExecute"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "Content-length header available");
    }

    public static void testHeadersWithExecuteActionWithoutBody() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(
                ServerInstance.getServiceURLHttp(servicePort, "product/noEntityExecute"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "No Content size related header present");
    }

    public static void testPassthruWithBody() throws IOException {
        HttpResponse response = HttpClientRequest.doPost(
                ServerInstance.getServiceURLHttp(servicePort, "product/passthruGet"), "HelloWorld", new HashMap<>());
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "Content-length header available");
    }
}
