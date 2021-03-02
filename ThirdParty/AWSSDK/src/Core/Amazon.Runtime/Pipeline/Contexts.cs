﻿/*
 * Copyright 2010-2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 * 
 *  http://aws.amazon.com/apache2.0
 * 
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */
#define AWS_APM_API
#define AWSSDK_UNITY
using Amazon.Runtime.Internal;
using Amazon.Runtime.Internal.Auth;
using Amazon.Runtime.Internal.Transform;
using Amazon.Runtime.Internal.Util;
using System;

namespace Amazon.Runtime
{
    public interface IRequestContext
    {
        AmazonWebServiceRequest OriginalRequest { get; }
        string RequestName { get; }
        IMarshaller<IRequest, AmazonWebServiceRequest> Marshaller { get; }
        ResponseUnmarshaller Unmarshaller { get; }
        RequestMetrics Metrics { get; }
        AbstractAWSSigner Signer { get; }
        IClientConfig ClientConfig { get; }
        ImmutableCredentials ImmutableCredentials { get; set; }

        IRequest Request { get; set; }
        bool IsSigned { get; set; }
        bool IsAsync { get; }
        int Retries { get; set; }

#if AWS_ASYNC_API
        System.Threading.CancellationToken CancellationToken { get; }
#endif
    }

    public interface IResponseContext
    {
        AmazonWebServiceResponse Response { get; set; }
        IWebResponseData HttpResponse { get; set; }
    }

    public interface IAsyncRequestContext : IRequestContext
    {
        AsyncCallback Callback { get; }
        object State { get; }

#if UNITY || AWSSDK_UNITY

        AsyncOptions AsyncOptions { get; }
        Action<AmazonWebServiceRequest, AmazonWebServiceResponse, Exception, AsyncOptions> Action { get; }
#endif
    }    

    public interface IAsyncResponseContext : IResponseContext
    {
#if AWS_APM_API
        Amazon.Runtime.Internal.RuntimeAsyncResult AsyncResult { get; set; }
#endif
    }

    public interface IExecutionContext
    {
        IResponseContext ResponseContext { get; }
        IRequestContext RequestContext { get; }

    }

    public interface IAsyncExecutionContext
    {
        IAsyncResponseContext ResponseContext { get; }
        IAsyncRequestContext RequestContext { get; }

        object RuntimeState { get; set; }
    }
}

namespace Amazon.Runtime.Internal
{
    public class RequestContext : IRequestContext
    {
        AbstractAWSSigner clientSigner;

        public RequestContext(bool enableMetrics, AbstractAWSSigner clientSigner)
        {
            if (clientSigner == null)
                throw new ArgumentNullException("clientSigner");

            this.clientSigner = clientSigner;
            this.Metrics = new RequestMetrics();
            this.Metrics.IsEnabled = enableMetrics;
        }

        public IRequest Request { get; set; }
        public RequestMetrics Metrics { get; private set; }
        public IClientConfig ClientConfig { get; set; }
        public int Retries { get; set; }
        public bool IsSigned { get; set; }
        public bool IsAsync { get; set; }
        public AmazonWebServiceRequest OriginalRequest { get; set; }
        public IMarshaller<IRequest, AmazonWebServiceRequest> Marshaller { get; set; }
        public ResponseUnmarshaller Unmarshaller { get; set; }
        public ImmutableCredentials ImmutableCredentials { get; set; }

        public AbstractAWSSigner Signer
        {
            get
            {
                var requestSigner = OriginalRequest == null ? null : OriginalRequest.GetSigner();
                if (requestSigner == null)
                    return clientSigner;
                else
                    return requestSigner;
            }
        }

#if AWS_ASYNC_API
        public System.Threading.CancellationToken CancellationToken { get; set; }
#endif

        public string RequestName
        {
            get { return this.OriginalRequest.GetType().Name; }
        }
    }

    public class AsyncRequestContext : RequestContext, IAsyncRequestContext
    {
        public AsyncRequestContext(bool enableMetrics, AbstractAWSSigner clientSigner):
            base(enableMetrics, clientSigner)
        {
        }

        public AsyncCallback Callback { get; set; }
        public object State { get; set; }
#if UNITY || AWSSDK_UNITY

        public AsyncOptions AsyncOptions { get; set; }
        public Action<AmazonWebServiceRequest, AmazonWebServiceResponse, Exception, AsyncOptions> Action { get; set; }
#endif
    }

    public class ResponseContext : IResponseContext
    {
        public AmazonWebServiceResponse Response { get; set; }        
        public IWebResponseData HttpResponse { get; set; }
    }

    public class AsyncResponseContext : ResponseContext, IAsyncResponseContext
    {
#if AWS_APM_API
        public Amazon.Runtime.Internal.RuntimeAsyncResult AsyncResult { get; set; }
#endif
    }

    public class ExecutionContext : IExecutionContext
    {
        public IRequestContext RequestContext { get; private set; }
        public IResponseContext ResponseContext { get; private set; }        

        public ExecutionContext(bool enableMetrics, AbstractAWSSigner clientSigner)
        {
            this.RequestContext = new RequestContext(enableMetrics, clientSigner);
            this.ResponseContext = new ResponseContext();
        }

        public ExecutionContext(IRequestContext requestContext, IResponseContext responseContext)
        {
            this.RequestContext = requestContext;
            this.ResponseContext = responseContext;
        }

        public static IExecutionContext CreateFromAsyncContext(IAsyncExecutionContext asyncContext)
        {
            return new ExecutionContext(asyncContext.RequestContext,
                asyncContext.ResponseContext);
        }
    }

    public class AsyncExecutionContext : IAsyncExecutionContext
    {
        public IAsyncResponseContext ResponseContext { get; private set; }
        public IAsyncRequestContext RequestContext { get; private set; }

        public object RuntimeState { get; set; }

        public AsyncExecutionContext(bool enableMetrics, AbstractAWSSigner clientSigner)
        {
            this.RequestContext = new AsyncRequestContext(enableMetrics, clientSigner);
            this.ResponseContext = new AsyncResponseContext();
        }

        public AsyncExecutionContext(IAsyncRequestContext requestContext, IAsyncResponseContext responseContext)
        {
            this.RequestContext = requestContext;
            this.ResponseContext = responseContext;
        }
    }
}