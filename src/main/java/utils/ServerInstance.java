package utils;/*
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

/**
 * This class is a simple representation of an HTTP response.
 */
public class ServerInstance {

    public static String getServiceURLHttp(int port, String servicePath) {
        return "http://" + getServiceUrl(port, servicePath);
    }

    private static String getServiceUrl(int port, String servicePath) {
        return "localhost:" + port + "/" + servicePath;
    }

    public static String getServerHome() {
        return "/home/chamil/Documents/projects/ballerina/distribution/zip/jballerina-tools/build/distributions" +
                "/jballerina-tools-0.992.0-m2-SNAPSHOT/";
    }
}


