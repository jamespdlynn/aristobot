package com.aristobot.exceptions;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Response;

/**
 * Checked service exception thrown for any opponent related errors.
 * Checked service exceptions contain messages that are comprised of a three digit number the client can toggle off of
 * as well as a brief description of why the exception was thrown.
 * @author James
 *
 */
public class OpponentException extends WebApplicationException {
	
	public static final String INVALID_OPPONENT = "400::Opponent username or email address is not valid";
	public static final String UNABLE_TO_FIND_OPPONENT_USERNAME = "401::Could not find opponent by given username";
	public static final String UNABLE_TO_FIND_OPPONENT_EMAIL = "402::Could not find opponent by given email address";
	public static final String DUPLICATE_OPPONENT = "403::This opponent is the current user";
	public static final String UNABLE_TO_FIND_RANDOM_OPPONENT = "404::Could not find an Opponent at this time";
	public static final String INVALID_CONVERSAIION_KEY = "405::Conversation Key is invalid";

    private static final long serialVersionUID = 400;

    public OpponentException(String message) {
        super(Response.status(400).entity(message).type("text/plain").build());
    }
}
