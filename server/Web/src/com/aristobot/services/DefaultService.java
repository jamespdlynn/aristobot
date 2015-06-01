package com.aristobot.services;

import java.io.File;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Response;

import com.aristobot.data.ServiceInfo;
import com.aristobot.managers.LogManager;
import com.aristobot.managers.JDBCManager;

@Path("/")
public class DefaultService 
{

    @GET
    @Produces("application/xml") 
    public ServiceInfo test() 
    {
        return new ServiceInfo();
    }
    
    @GET
    @Path("/icon")
    @Produces("image/png")
    public Response getIcon() 
    {
        File icon = new File("icons/100000.png");

        if (!icon.exists()) {
            throw new WebApplicationException(404);
        }

        return Response.ok(icon, "image/png").build();

    }
    
    @GET
    @Path("/exception")
    public Response getException() 
    {
        throw new WebApplicationException(500);
    }
    
    @GET
    @Path("/connection")
    @Produces("application/xml")
    public Response testConnection() 
    {        
    	JDBCManager dbManager = new JDBCManager();	
    	
        try{
        	dbManager.connect();	
    	}
		catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
		finally{
			dbManager.close();
		}
		
		return Response.status(200).build();
    }
    
 
}
