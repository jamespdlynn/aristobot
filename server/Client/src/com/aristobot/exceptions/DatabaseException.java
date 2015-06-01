package com.aristobot.exceptions;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Response;

import com.aristobot.managers.LogManager;

/**
 * Checked service exception thrown for any database related errors.
 * Checked service exceptions contain messages that are comprised of a three digit number the client can toggle off of
 * as well as a brief description of why the exception was thrown.
 * @author James
 *
 */
public class DatabaseException extends WebApplicationException 
{
    public static final String DATABASE_CONNECTION_ERROR = "100::Error Opening Database Connection Open ";
    public static final String DATABASE_QUERY_ERROR = "101::Error Querying Data";
    public static final String DATABASE_PARSE_ERROR = "102::Error Parsing Data";
    public static final String DATABASE_CLOSE_ERROR = "103::Error Closing Database Connection";
    public static final String DATABASE_COMMIT_ERROR = "104::Data Commit Error";
    public static final String DATABASE_ROLLBACK_ERROR = "105::Error Rollingback Database";
    public static final String DATABASE_IO_ERROR = "106: Database IO Error ";
    public static final String DATABASE_STATEMENT_ERROR = "107::Database Statement Error";
    

    private static final long serialVersionUID = 100;

    public DatabaseException(String message, Exception e) {
       super(Response.status(500).entity(message).type("text/plain").build());
       LogManager.logException(message, e);
    }
    
    public DatabaseException(String message, String query, Exception e) {
        super(Response.status(500).entity(message).type("text/plain").build());
        LogManager.logException(message, e);
        LogManager.log(query);
     }
}
