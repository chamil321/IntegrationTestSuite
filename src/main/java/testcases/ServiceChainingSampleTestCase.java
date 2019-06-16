package testcases;/*
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
 * Testing the Service Chaining sample located in
 * ballerina_home/samples/serviceChaining/ATMLocatorService.bal.
 */
public class ServiceChainingSampleTestCase {
    private static final String requestMessage = "{\"ATMLocator\": {\"ZipCode\": \"95999\"}}";
    private static final String responseMessage = "{\"ABC Bank\":{\"Address\":\"111 River Oaks Pkwy" +
            ", San Jose, CA 95999\"}}";

    public static void testEchoServiceByBasePath() throws IOException {
        Map<String, String> headers = new HashMap<>();
        headers.put(HttpHeaderNames.CONTENT_TYPE.toString(), TestConstant.CONTENT_TYPE_JSON);
        HttpResponse response = HttpClientRequest.doPost(ServerInstance.getServiceURLHttp(9092, "ABCBank/locator"),
                                                         requestMessage, headers);
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getHeaders().get(HttpHeaderNames.CONTENT_TYPE.toString())
                , TestConstant.CONTENT_TYPE_JSON, "Content-Type mismatched");
        Assert.assertEquals(response.getData(), responseMessage, "Message content mismatched");
    }
}
