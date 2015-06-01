package com.aristobot.services;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;

import com.aristobot.data.wrappers.IconsWrapper;
import com.aristobot.managers.AuthenticationManager;
import com.aristobot.managers.LogManager;
import com.aristobot.managers.JDBCManager;
import com.aristobot.repository.IconRepository;

/**
 * Service class used to retrieve Icons
 * 
 * @author James
 *
 */



@Path("/icons")
public class IconService 
{
	private JDBCManager dbManager;
	private AuthenticationManager authManager;

	public IconService()
	{
		try{
			dbManager = new JDBCManager();
			authManager = new AuthenticationManager(dbManager);
		}
		catch (RuntimeException e){
			throw LogManager.handleException(e);
		}
	}
	
	
    @GET
    @Produces("application/xml")
    public IconsWrapper getIcons(@Context HttpHeaders headers)
    {
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
        	IconRepository repo = new IconRepository(dbManager);
        	
        	IconsWrapper wrapper = new IconsWrapper();
	    	wrapper.icons = repo.getUserIcons(authManager.getUsername());
	    	
	        return wrapper;
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
	    
	  
    }
    
    
    
    
    /**
     * Get the default icons available for all Users.
     * This service call is mostly likely to be used during registration so a User can choose
     * an initial icon.
     * @return
     */
    @GET
	@Path("/default")
    @Produces("application/xml")
    public IconsWrapper getDefaultIcons(@Context HttpHeaders headers, @QueryParam("deviceType") String deviceType )
    {    
    	try{    	
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireValidApiKey();
    		
    		IconRepository repo = new IconRepository(dbManager);
        	
    		IconsWrapper wrapper = new IconsWrapper();
			wrapper.icons = repo.getDefaultIcons(authManager.getApplicationId(), deviceType);
			
			 return wrapper;
		}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
    }
  
}
