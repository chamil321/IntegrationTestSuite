/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
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

import static utils.TestConstant.DEFLATE;
import static utils.TestConstant.ENCODING_GZIP;

/**
 * Integration test for Compression.
 *
 * @since 0.966.0
 */
public class CompressionTestCase {

    private static int servicePort = 9093;

    public static void testAutoCompress() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort, "autoCompress"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getHeaders().get(HttpHeaderNames.CONTENT_TYPE.toString())
                , TestConstant.CONTENT_TYPE_TEXT_PLAIN, "Content-Type mismatched");
        Assert.assertNull(response.getHeaders().get(HttpHeaderNames.CONTENT_ENCODING.toString()),
                          "The content-encoding header should be null");
    }

    public static void testAutoCompressWithAcceptEncoding() throws IOException {
        Map<String, String> headers = new HashMap<>();
        headers.put(HttpHeaderNames.ACCEPT_ENCODING.toString(), ENCODING_GZIP);
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort, "autoCompress"),
                                                        headers);
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getHeaders().get(HttpHeaderNames.CONTENT_TYPE.toString())
                , TestConstant.CONTENT_TYPE_TEXT_PLAIN, "Content-Type mismatched");
        Assert.assertEquals(response.getHeaders().get(HttpHeaderNames.CONTENT_ENCODING.toString()),
                            ENCODING_GZIP, "The content-encoding header should be gzip");
    }

    public static void testAcceptEncodingWithQValueZero() throws IOException {
        Map<String, String> headers = new HashMap<>();
        headers.put(HttpHeaderNames.ACCEPT_ENCODING.toString(), "gzip;q=0");
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort, "autoCompress"),
                                                        headers);
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getHeaders().get(HttpHeaderNames.CONTENT_TYPE.toString())
                , TestConstant.CONTENT_TYPE_TEXT_PLAIN, "Content-Type mismatched");
        Assert.assertNull(response.getHeaders().get(HttpHeaderNames.CONTENT_ENCODING.toString()),
                          "qvalue of 0 means not acceptable");
    }

    public static void testAlwaysCompress() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort,
                                                                                         "alwaysCompress"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getHeaders().get(HttpHeaderNames.CONTENT_TYPE.toString())
                , TestConstant.CONTENT_TYPE_TEXT_PLAIN, "Content-Type mismatched");
        Assert.assertEquals(response.getHeaders().get(HttpHeaderNames.CONTENT_ENCODING.toString()),
                            ENCODING_GZIP, "The content-encoding header should be gzip");
    }

    public static void testAlwaysCompressWithAcceptEncoding() throws IOException {
        Map<String, String> headers = new HashMap<>();
        headers.put(HttpHeaderNames.ACCEPT_ENCODING.toString(), "deflate;q=1.0, gzip;q=0.8");
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort, "alwaysCompress"),
                                                        headers);
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getHeaders().get(HttpHeaderNames.CONTENT_TYPE.toString())
                , TestConstant.CONTENT_TYPE_TEXT_PLAIN, "Content-Type mismatched");
        Assert.assertEquals(response.getHeaders().get(HttpHeaderNames.CONTENT_ENCODING.toString()),
                            DEFLATE, "The content-encoding header should be deflate");
    }

    public static void testNeverCompress() throws IOException {
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort, "neverCompress"));
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getHeaders().get(HttpHeaderNames.CONTENT_TYPE.toString())
                , TestConstant.CONTENT_TYPE_TEXT_PLAIN, "Content-Type mismatched");
        Assert.assertNull(response.getHeaders().get(HttpHeaderNames.CONTENT_ENCODING.toString()),
                          "The content-encoding header should be null");
    }

    public static void testNeverCompressWithAcceptEncoding() throws IOException {
        Map<String, String> headers = new HashMap<>();
        headers.put(HttpHeaderNames.ACCEPT_ENCODING.toString(), "deflate;q=1.0, gzip;q=0.8");
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort, "neverCompress"),
                                                        headers);
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getHeaders().get(HttpHeaderNames.CONTENT_TYPE.toString())
                , TestConstant.CONTENT_TYPE_TEXT_PLAIN, "Content-Type mismatched");
        Assert.assertNull(response.getHeaders().get(HttpHeaderNames.CONTENT_ENCODING.toString()),
                          "The content-encoding header should be null");
    }

    public static void testNeverCompressWithUserOverridenValue() throws IOException {
        Map<String, String> headers = new HashMap<>();
        headers.put(HttpHeaderNames.ACCEPT_ENCODING.toString(), "deflate;q=1.0, gzip;q=0.8");
        HttpResponse response = HttpClientRequest.doGet(ServerInstance.getServiceURLHttp(servicePort,
                                                                                         "userOverridenValue"),
                                                        headers);
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getHeaders().get(HttpHeaderNames.CONTENT_TYPE.toString())
                , TestConstant.CONTENT_TYPE_TEXT_PLAIN, "Content-Type mismatched");
        Assert.assertEquals(response.getHeaders().get(HttpHeaderNames.CONTENT_ENCODING.toString()),
                            DEFLATE, "The content-encoding header should be deflate");
    }
}
