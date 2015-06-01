package com.aristobot.services;

import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.Response;

import com.aristobot.data.LogData;
import com.aristobot.exceptions.DatabaseException;
import com.aristobot.managers.AuthenticationManager;
import com.aristobot.managers.LogManager;
import com.aristobot.managers.JDBCManager;

/**
 * Service used to authenticate and grant a user an accesstoken they can use
 * to make subsequent service calls
 * @author James
 *
 */
@Path("/log")
public class LogService
{

	private JDBCManager dbManager;
	private AuthenticationManager authManager;
	
	public LogService()
	{
		try{
			dbManager = new JDBCManager();
			authManager = new AuthenticationManager(dbManager);
		}
		catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	}
	
	 /**
     * Performs cleanup on database deleting or otherwise handling expired games, players or tokens
     * @return Response Object with 201 Success Message on successful addition of User
     */
    @POST
    @Consumes("application/xml")
	@Produces("application/xml")
	public Response log(@Context HttpHeaders headers, LogData data)
	{
    	try
    	{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullWriteAccess();
    		
    		int applicationId = authManager.getApplicationId();
    		String username = authManager.getUsername();
    		
    		String logInsert = "INSERT INTO clientlogs (deviceId, applicationId, username, version, view, errorMessage, additionalInfo)" +
    							"VALUES (?,?,?,?,?,?,?)";
    		
    		PreparedStatement pstmt = dbManager.getPreparedStatement(logInsert);
    		
    		try{
    			pstmt.setString(1, data.deviceId);
        		pstmt.setInt(2, applicationId);
        		pstmt.setString(3, username);
        		pstmt.setString(4, data.version);
        		pstmt.setString(5, data.view);
        		pstmt.setString(6, data.errorMessage);
        		pstmt.setString(7, data.additionalInfo);
        		
        		pstmt.execute();
    		}
    		catch (SQLException e){
    			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
    		}
    		finally{
    			dbManager.closeStatement(pstmt);
    		}
    		
    	}
	    catch (RuntimeException e){
	    	dbManager.rollback();
    		RuntimeException re = LogManager.handleException(e);
    		throw re;
 		}
	    finally{
	    	dbManager.close();
	    }
	    
	    return Response.status(200).build();

	}
 
	
	

}
