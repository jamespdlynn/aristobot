package com.aristobot.exceptions;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Response;


/**
 * Checked service exception thrown for any user related errors.
 * Checked service exceptions contain messages that are comprised of a three digit number the client can toggle off of
 * as well as a brief description of why the exception was thrown.
 * @author James
 *
 */
public class UserException extends WebApplicationException {
	
	public static final String REGISTRATION_ERROR = "300::Unknown registration error please try again";
	public static final String UPDATE_ERROR = "301::Unknown update error please try again";
    public static final String INVALID_USER_NAME = "302::Username not specified or is invalid";
    public static final String INVALID_PASSWORD = "303::Password not specified or is invalid";
    public static final String INVALID_EMAIL_ADDRESS = "304::Email Address not specified or in invalid format";
    public static final String INVALID_ICON_ID = "305::UserIcon Id is invalid";
    public static final String DUPLICATE_USER_NAME = "306::Username already exists";
    public static final String DUPLICATE_EMAIL_ADDRESS = "307::Email Addresss already exists";
    public static final String INVALID_MESSAGE = "308::Message does not exist";
    public static final String INVALID_MESSAGE_SUBJECT = "309::Invalid Message Subject";
    public static final String INVALID_MESSAGE_BODY = "310::Invalid Message Body";
    public static final String INVALID_USER = "310::Invalid User";
    public static final String NO_KEYWORD_SUPPLIED = "311::No keyword supplied";
    
    
    private static final long serialVersionUID = 300;

    public UserException(String message) {
        super(Response.status(400).entity(message).type("text/plain").build());
    }
}
