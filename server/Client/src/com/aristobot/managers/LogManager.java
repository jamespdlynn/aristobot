package com.aristobot.managers;

import java.util.logging.Level;
import java.util.logging.Logger;

import javax.ws.rs.WebApplicationException;

/**
 * Simple class used for logging errors.
 * 
 * @author James
 *
 */
public class LogManager 
{
	private static Logger logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
	
	public static WebApplicationException handleException(RuntimeException e)
	{
    	if (e instanceof WebApplicationException){
    		return (WebApplicationException)e;
    	}
    	else{
    		logException(e);
    		return new WebApplicationException(500);
    	}
		
	}
	
	public static void logException(Exception e)
	{
    	logger.log(Level.SEVERE, e.getMessage(), e);
	}
	
	public static void logException(String title, Exception e)
	{
		String eol = System.getProperty("line.separator"); 
    	logger.log(Level.SEVERE, title + eol + eol + e.getMessage(), e);
	}
	
	public static void log(String s)
	{
    	logger.log(Level.INFO, s);
	}

}
