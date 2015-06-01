package com.aristobot.filters;

import java.util.zip.InflaterInputStream;

import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.ResponseBuilder;
import javax.ws.rs.ext.Provider;

import com.google.common.net.HttpHeaders;
import com.sun.jersey.spi.container.ContainerRequest;
import com.sun.jersey.spi.container.ContainerRequestFilter;
import com.sun.jersey.spi.container.ContainerResponse;
import com.sun.jersey.spi.container.ContainerResponseFilter;

/**
 * The Interceptor class intercepts all incoming service calls and performs actions before the service is invoked.
 * 
 * @author James
 *
 */
@Provider
public class RequestFilter implements ContainerRequestFilter, ContainerResponseFilter
{
	/**
	 * Intercept service request and determine permissions
	 * 
	 * @Param incoming http request
	 */
		
	@Override
	public ContainerRequest filter(ContainerRequest request) 
	{
		
		String encoding = request.getHeaderValue(HttpHeaders.CONTENT_ENCODING);
		
		if (encoding != null && encoding.trim().equals("deflate")){
			request.getRequestHeaders().remove(HttpHeaders.CONTENT_ENCODING);
			request.setEntityInputStream(new InflaterInputStream(request.getEntityInputStream()));
		}
		
		/*String versionNumber = request.getHeaderValue("VN");
		if (versionNumber != null)
		{
			try 
	    	{
	    		String [] requiredVersion = Constants.REQUIRED_VERSION_NUMBER.split("\\.");
	        	String [] givenVersion = versionNumber.split("\\.");
	        	
	        	for (int i=0; i < requiredVersion.length; i++)
	        	{
	        		int required = Integer.parseInt(requiredVersion[i]);
	        		int given = Integer.parseInt(givenVersion[i]);
	        		
	        		if (required > given){
	        			throw new AuthenticationException(AuthenticationException.DEPRACATED_VERSION_NUMBER);
	        		}
	        		else if(given > required){
	        			break;
	        		}
	        	}
	    	}
	    	catch (Exception e){
	    		throw new AuthenticationException(AuthenticationException.DEPRACATED_VERSION_NUMBER);
	    	}
		}*/
			
    	
		return request;
	} 
	
	@Override
	public ContainerResponse filter(ContainerRequest request, ContainerResponse response) 
	{		
		ResponseBuilder resp = Response.fromResponse(response.getResponse());
		resp.header("Cache-Control", "no-cache");
		resp.header("Cache-Control", "max-age=0");
		resp.header("Expires", "0");		
		
		response.setResponse(resp.build());
		
		return response;
	} 
	
}
