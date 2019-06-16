import testcases.AcceptEncodingHeaderTestCase;
import testcases.CompressionTestCase;
import testcases.EchoServiceSampleTestCase;
import testcases.EcommerceSampleTestCase;
import testcases.ExpectContinueTestCase;
import testcases.HTTPVerbsPassthruTestCases;
import testcases.HelloWorldSampleTestCase;
import testcases.HttpHeaderTestCases;
import testcases.HttpOptionsTestCase;
import testcases.IdleTimeoutResponseTestCase;
import testcases.RedirectTestCase;
import testcases.RetrySampleTestCase;
import testcases.ServiceChainingSampleTestCase;

import java.io.IOException;

/**
 * Testing accept-encoding header.
 */
public class AAARunTestSuite {

    public static void main(String[] args) throws Exception {
        System.out.println("Running - AcceptEncodingHeaderTestCase");
        AcceptEncodingHeaderTestCase.testAcceptEncodingEnabled();
        AcceptEncodingHeaderTestCase.testAcceptEncodingAuto();
        AcceptEncodingHeaderTestCase.testAcceptEncodingDisabled();

//        System.out.println("Running - ExpectContinueTestCase");
//        ExpectContinueTestCase.test100Continue();
//        ExpectContinueTestCase.test100ContinueNegative();
//        ExpectContinueTestCase.testMultipartWith100ContinueHeader();
//        ExpectContinueTestCase.test100ContinuePassthrough();
//
        System.out.println("Running - ServiceChainingSampleTestCase");
        ServiceChainingSampleTestCase.testEchoServiceByBasePath();

        System.out.println("Running - CompressionTestCase");
        CompressionTestCase.testAutoCompress();
        CompressionTestCase.testAutoCompressWithAcceptEncoding();
        CompressionTestCase.testAcceptEncodingWithQValueZero();
        CompressionTestCase.testAlwaysCompress();
        CompressionTestCase.testAlwaysCompressWithAcceptEncoding();
        CompressionTestCase.testNeverCompress();
        CompressionTestCase.testNeverCompressWithAcceptEncoding();
        CompressionTestCase.testNeverCompressWithUserOverridenValue();

        System.out.println("Running - EchoServiceSampleTestCase");
        EchoServiceSampleTestCase.testEchoServiceByBasePath();
        EchoServiceSampleTestCase.testEchoServiceWithDynamicPortByBasePath();
        EchoServiceSampleTestCase.testEchoServiceWithDynamicPortShared();
        EchoServiceSampleTestCase.testEchoServiceWithDynamicPortHttpsByBasePath();
        EchoServiceSampleTestCase.testEchoServiceWithDynamicPortHttpsShared();
        EchoServiceSampleTestCase.testHttpImportAsAlias();

        System.out.println("Running - EcommerceSampleTestCase");
        EcommerceSampleTestCase.testGetProducts();
        EcommerceSampleTestCase.testGetOrders();
        EcommerceSampleTestCase.testGetCustomers();
        EcommerceSampleTestCase.testPostOrder();
        EcommerceSampleTestCase.testPostProduct();
        EcommerceSampleTestCase.testPostCustomers();

        System.out.println("Running - HelloWorldSampleTestCase");
        HelloWorldSampleTestCase.testHelloWorldServiceByBasePath();

        //CipherStrengthSSLTestCase test2.bal
        System.out.println("Running - HttpOptionsTestCase");
        HttpOptionsTestCase.testOptionsContentLengthHeader();
        HttpOptionsTestCase.testOptionsResourceWithPayload();

        //test2.bal
        System.out.println("Running - RedirectTestCase");
        RedirectTestCase.testRedirect();
        RedirectTestCase.testMaxRedirect();
        RedirectTestCase.testCrossDomain();
        RedirectTestCase.testNoRedirect();
//        RedirectTestCase.testRedirectOff(); //__init is not called, so getting null
        RedirectTestCase.testQPWithAbsolutePath();
        RedirectTestCase.testQPWithRelativePath();
        RedirectTestCase.testOriginalRequestWithQP();
        RedirectTestCase.test303Status();
        RedirectTestCase.testRedirectWithHTTPs();

        System.out.println("Running - RetrySampleTestCase");
        RetrySampleTestCase.testSimpleRetry();
//        RetrySampleTestCase.testMultiPart();
//        RetrySampleTestCase.testNestedMultiPart();
        RetrySampleTestCase.testRetryBasedOnHttpStatusCodes();
        RetrySampleTestCase.testRetryBasedOnHttpStatusCodesContinuousFailure();

        System.out.println("Running - HttpHeaderTestCases");
        HttpHeaderTestCases.testOutboundRequestHeaders();
        HttpHeaderTestCases.testInboundResponseHeaders();
        HttpHeaderTestCases.testOutboundNonEntityBodyGetRequestHeaders();
        HttpHeaderTestCases.testOutboundEntityBodyGetRequestHeaders();
        HttpHeaderTestCases.testOutboundEntityGetRequestHeaders();
        HttpHeaderTestCases.testOutboundForwardNoEntityBodyRequestHeaders();
        HttpHeaderTestCases.testOutboundForwardEntityBodyRequestHeaders();
        HttpHeaderTestCases.testHeadersWithExecuteAction();
        HttpHeaderTestCases.testHeadersWithExecuteActionWithoutBody();
        HttpHeaderTestCases.testPassthruWithBody();

        System.out.println("Running - HTTPVerbsPassthruTestCases");
        HTTPVerbsPassthruTestCases.testPassthroughSampleForHEAD();
        HTTPVerbsPassthruTestCases.testPassthroughSampleForGET();
        HTTPVerbsPassthruTestCases.testPassthroughSampleForPOST();
        HTTPVerbsPassthruTestCases.testPassthroughSampleWithDefaultResource();
        HTTPVerbsPassthruTestCases.testOutboundPUT();
        HTTPVerbsPassthruTestCases.testForwardActionWithGET();
        HTTPVerbsPassthruTestCases.testForwardActionWithPOST();
        HTTPVerbsPassthruTestCases.testDataBindingJsonPayload();
        HTTPVerbsPassthruTestCases.testDataBindingWithIncompatiblePayload();

        System.out.println("Running - IdleTimeoutResponseTestCase");
        IdleTimeoutResponseTestCase.test408Response();
        IdleTimeoutResponseTestCase.test500Response();


        System.out.println("All tests completed successfully");
    }
}
