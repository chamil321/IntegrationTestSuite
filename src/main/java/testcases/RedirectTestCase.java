/*
 *  Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import org.testng.Assert;
import org.testng.annotations.Test;
import utils.HttpClientRequest;
import utils.HttpResponse;
import utils.ServerInstance;

import java.io.IOException;

/**
 * A test case for http redirect.
 */
public class RedirectTestCase {

    private static final int servicePort = 9103;

    public static void testRedirect() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort, "service1/"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "http://localhost:9102/redirect2", "Incorrect resolvedRequestedURI");
    }

    public static void testMaxRedirect() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort,
                "service1/maxRedirect"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "/redirect1/round5:http://localhost:9103/redirect1/round4",
                "Incorrect resolvedRequestedURI");
    }

    public static void testCrossDomain() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort,
                "service1/crossDomain"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "hello world:http://localhost:9102/redirect2",
                "Incorrect resolvedRequestedURI");
    }

    public static void testNoRedirect() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort,
                "service1/noRedirect"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "hello world:http://localhost:9102/redirect2",
                "Incorrect resolvedRequestedURI");
    }

    public static void testRedirectOff() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort,
                "service1/redirectOff"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "/redirect1/round2:",
                "Incorrect resolvedRequestedURI");
    }

    public static void testQPWithRelativePath() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort,
                "service1/qpWithRelativePath"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "value:ballerina:http://localhost:9103/redirect1/" +
                "processQP?key=value&lang=ballerina", "Incorrect resolvedRequestedURI");
    }

    public static void testQPWithAbsolutePath() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort,
                "service1/qpWithAbsolutePath"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "value:ballerina:http://localhost:9103/redirect1/" +
                "processQP?key=value&lang=ballerina", "Incorrect resolvedRequestedURI");
    }

    public static void testOriginalRequestWithQP() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort,
                "service1/originalRequestWithQP"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "hello world:http://localhost:9102/redirect2",
                "Incorrect resolvedRequestedURI");
    }

    public static void test303Status() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort,
                "service1/test303"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "hello world:http://localhost:9102/redirect2",
                "Incorrect resolvedRequestedURI");
    }

    public static void testRedirectWithHTTPs() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort,
                "service1/httpsRedirect"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "HTTPs Result:https://localhost:9104/redirect3/result",
                "Incorrect resolvedRequestedURI");
    }
}
