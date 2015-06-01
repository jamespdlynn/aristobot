package com.aristobot.exceptions;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Response;

/**
 * Checked service exception thrown for any authentication related errors.
 * Checked service exceptions contain messages that are comprised of a three digit number the client can toggle off of
 * as well as a brief description of why the exception was thrown.
 * @author James
 *
 */
public class AuthenticationException extends WebApplicationException {
    public static final String INVALID_API_KEY = "200::API Key is Invalid or has been revoked";
    public static final String INVALID_ACCESS_TOKEN = "201::Access Token is invalid or has expired please try a full login";
    public static final String INVALID_WRITE_ACCESS = "202::This API Key does not have the correct write permssions to make this server call";
    public static final String LOGIN_FAILED = "203::Username or Password is incorrect";
    public static final String AUTO_LOGIN_FAILED = "204::Refresh Token is invalid";
    public static final String DEPRACATED_VERSION_NUMBER = "205::Invalid Service Version";
    public static final String INVALID_DEVICE_ID = "206::Device Id is not supplied or is invalid";
    public static final String INVALID_DEVICE_TYPE = "207::Device Type is not supplied or is invalid (must be one of the following = 'android', 'ios', 'other')";
    public static final String INVALID_PUSH_NOTIFCATION_TOKEN = "208::Push Notification Token is not supplied or is invalid";
    public static final String DATA_LOCKED = "209::Data locked";

    private static final long serialVersionUID = 200;

    public AuthenticationException(String message) {
        super(Response.status(401).entity(message).type("text/plain").build());
    }
}
