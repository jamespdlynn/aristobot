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
public class IconException extends WebApplicationException {
	
	public static final String ICON_ALREADY_EXISTS = "600::Icon key already exists.";
	public static final String INVALID_ICON_KEY = "601::Invalid Icon Key.";
	public static final String INVALID_ICON_NAME = "602::Invalid Icon Name.";
	public static final String INVALID_ICON_LEVEL = "603::Invalid Icon Level.";
	public static final String INVALID_DEVICE_TYPE = "604::Invalid Icon Device Type.";
	public static final String ICON_NOT_ON_SERVER = "605::Could not find icon on server.";
    public static final String ICON_BELONGS_TO_USER = "606::Cannot delete an icon that a user already has assigned.";
    public static final String ICON_TOO_LARGE = "607::Icon file too large to be uploaded.";
    
    private static final long serialVersionUID = 600;

    public IconException(String message) {
        super(Response.status(400).entity(message).type("text/plain").build());
    }
}
