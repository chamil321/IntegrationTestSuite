package testcases;

import io.netty.buffer.Unpooled;
import io.netty.handler.codec.http.DefaultHttpRequest;
import io.netty.handler.codec.http.DefaultLastHttpContent;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpHeaderNames;
import io.netty.handler.codec.http.HttpHeaderValues;
import io.netty.handler.codec.http.HttpMethod;
import io.netty.handler.codec.http.HttpResponseStatus;
import io.netty.handler.codec.http.HttpVersion;
import org.testng.Assert;
import utils.HttpClient;
import utils.HttpClientRequest;
import utils.HttpResponse;
import utils.ServerInstance;
import utils.TestUtils;

import java.io.IOException;
import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Test case for verifying the server-side 100-continue behaviour.
 */
public class ExpectContinueTestCase {

    private static final int servicePort = 9090;

    public static void test100Continue() {
        HttpClient httpClient = new HttpClient("localhost", servicePort);

        DefaultHttpRequest httpRequest = new DefaultHttpRequest(HttpVersion.HTTP_1_1, HttpMethod.POST, "/continue");
        DefaultLastHttpContent reqPayload = new DefaultLastHttpContent(
                Unpooled.wrappedBuffer(TestUtils.LARGE_ENTITY.getBytes()));

        httpRequest.headers().set(HttpHeaderNames.CONTENT_LENGTH, TestUtils.LARGE_ENTITY.getBytes().length);
        httpRequest.headers().set(HttpHeaderNames.CONTENT_TYPE, HttpHeaderValues.TEXT_PLAIN);
        httpRequest.headers().set("X-Status", "Positive");

        List<FullHttpResponse> responses = httpClient.sendExpectContinueRequest(httpRequest, reqPayload);

        Assert.assertFalse(httpClient.waitForChannelClose());

        // 100-continue response
        Assert.assertEquals(responses.get(0).status(), HttpResponseStatus.CONTINUE);
        Assert.assertEquals(Integer.parseInt(responses.get(0).headers().get(HttpHeaderNames.CONTENT_LENGTH)), 0);

        // Actual response
        String responsePayload = TestUtils.getEntityBodyFrom(responses.get(1));
        Assert.assertEquals(responses.get(1).status(), HttpResponseStatus.OK);
        Assert.assertEquals(responsePayload, TestUtils.LARGE_ENTITY);
        Assert.assertEquals(responsePayload.getBytes().length, TestUtils.LARGE_ENTITY.getBytes().length);
        Assert.assertEquals(Integer.parseInt(responses.get(1).headers().get(HttpHeaderNames.CONTENT_LENGTH)),
                TestUtils.LARGE_ENTITY.getBytes().length);
    }

    public static void test100ContinueNegative() {
        HttpClient httpClient = new HttpClient("localhost", servicePort);

        DefaultHttpRequest httpRequest = new DefaultHttpRequest(HttpVersion.HTTP_1_1, HttpMethod.POST, "/continue");
        DefaultLastHttpContent reqPayload = new DefaultLastHttpContent(
                Unpooled.wrappedBuffer(TestUtils.LARGE_ENTITY.getBytes()));

        httpRequest.headers().set(HttpHeaderNames.CONTENT_LENGTH, TestUtils.LARGE_ENTITY.getBytes().length);
        httpRequest.headers().set(HttpHeaderNames.CONTENT_TYPE, HttpHeaderValues.TEXT_PLAIN);

        List<FullHttpResponse> responses = httpClient.sendExpectContinueRequest(httpRequest, reqPayload);

        Assert.assertFalse(httpClient.waitForChannelClose());

        // 417 Expectation Failed response
        Assert.assertEquals(responses.get(0).status(), HttpResponseStatus.EXPECTATION_FAILED, "Response code mismatch");
        int length = Integer.parseInt(responses.get(0).headers().get(HttpHeaderNames.CONTENT_LENGTH));
        Assert.assertEquals(length, 26, "Content length mismatched");
        String payload = responses.get(0).content().readCharSequence(length, Charset.defaultCharset()).toString();
        Assert.assertEquals(payload, "Do not send me any payload", "Entity body mismatched");
        // Actual response
        Assert.assertEquals(responses.size(), 1,
                            "Multiple responses received when only a 417 response was expected");
    }

    public static void testMultipartWith100ContinueHeader() throws IOException {
        Map<String, String> headers = new HashMap<>();
        headers.put(HttpHeaderNames.EXPECT.toString(), HttpHeaderValues.CONTINUE.toString());

        Map<String, String> formData = new HashMap<>();
        formData.put("person", "engineer");
        formData.put("team", "ballerina");

        HttpResponse response = HttpClientRequest.doMultipartFormData(
                ServerInstance.getServiceURLHttp(servicePort, "continue/getFormParam"), headers, formData);
        Assert.assertNotNull(response);
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
        Assert.assertEquals(response.getData(), "Result = Key:person Value: engineer Key:team Value: ballerina");
    }

    public static void test100ContinuePassthrough() {
        HttpClient httpClient = new HttpClient("localhost", servicePort);

        DefaultHttpRequest reqHeaders = new DefaultHttpRequest(HttpVersion.HTTP_1_1, HttpMethod.POST,
                                                               "/continue/testPassthrough");
        DefaultLastHttpContent reqPayload = new DefaultLastHttpContent(
                Unpooled.wrappedBuffer(TestUtils.LARGE_ENTITY.getBytes()));

        reqHeaders.headers().set(HttpHeaderNames.CONTENT_LENGTH, TestUtils.LARGE_ENTITY.getBytes().length);
        reqHeaders.headers().set(HttpHeaderNames.CONTENT_TYPE, HttpHeaderValues.TEXT_PLAIN);

        List<FullHttpResponse> responses = httpClient.sendExpectContinueRequest(reqHeaders, reqPayload);

        Assert.assertFalse(httpClient.waitForChannelClose());

        // 100-continue response
        Assert.assertEquals(responses.get(0).status(), HttpResponseStatus.CONTINUE);
        Assert.assertEquals(Integer.parseInt(responses.get(0).headers().get(HttpHeaderNames.CONTENT_LENGTH)), 0);

        // Actual response
        String responsePayload = TestUtils.getEntityBodyFrom(responses.get(1));
        Assert.assertEquals(responses.get(1).status(), HttpResponseStatus.OK);
        Assert.assertEquals(responsePayload, TestUtils.LARGE_ENTITY);
        Assert.assertEquals(responsePayload.getBytes().length, TestUtils.LARGE_ENTITY.getBytes().length);
        Assert.assertEquals(Integer.parseInt(responses.get(1).headers().get(HttpHeaderNames.CONTENT_LENGTH)),
                            TestUtils.LARGE_ENTITY.getBytes().length);
    }
}
