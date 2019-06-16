package testcases;

import org.testng.Assert;
import utils.HttpClientRequest;
import utils.HttpResponse;
import utils.ServerInstance;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * Testing accept-encoding header.
 */
public class AcceptEncodingHeaderTestCase {

    private static final String CONTENT_TYPE = "Content-Type";
    private static final String ACCEPT_VALUE = "AcceptValue";
    private static Map<String, String> headers = new HashMap<>();
    private static final int servicePort = 9091;

    public static void testAcceptEncodingEnabled() throws IOException {
        String expectedResponse = "{\"acceptEncoding\":\"deflate, gzip\"}";
        String message = "accept encoding test";
        headers.put(ACCEPT_VALUE, "enable");
        headers.put(CONTENT_TYPE, "text/plain");
        HttpResponse response = HttpClientRequest.doPost(ServerInstance.getServiceURLHttp(servicePort, "passthrough"),
                                                         message, headers);
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");

        Assert.assertEquals(response.getData(), expectedResponse,
                            "Response does not contains accept-encoding value.");
    }

    public static void testAcceptEncodingDisabled() throws IOException {
        String expectedResponse = "{\"acceptEncoding\":\"Accept-Encoding hdeaer not present.\"}";
        String message = "accept encoding test";
        headers.put(ACCEPT_VALUE, "disable");
        headers.put(CONTENT_TYPE, "text/plain");
        HttpResponse response = HttpClientRequest.doPost(ServerInstance.getServiceURLHttp(servicePort, "passthrough"),
                                                         message, headers);
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");

        Assert.assertEquals(response.getData(), expectedResponse,
                            "Response does not contains accept-encoding value.");
    }

    public static void testAcceptEncodingAuto() throws IOException {
        String expectedResponse = "{\"acceptEncoding\":\"Accept-Encoding hdeaer not present.\"}";
        String message = "accept encoding test";
        headers.put(ACCEPT_VALUE, "auto");
        headers.put(CONTENT_TYPE, "text/plain");
        HttpResponse response = HttpClientRequest.doPost(ServerInstance.getServiceURLHttp(servicePort, "passthrough"),
                                                         message, headers);
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");

        Assert.assertEquals(response.getData(), expectedResponse,
                            "Response does not contains accept-encoding value.");
    }
}
