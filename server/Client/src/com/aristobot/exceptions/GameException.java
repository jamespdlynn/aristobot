package com.aristobot.exceptions;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Response;

/**
 * Checked service exception thrown for any Game related errors.
 * Checked service exceptions contain messages that are comprised of a three digit number the client can toggle off of
 * as well as a brief description of why the exception was thrown.
 * @author James
 *
 */
public class GameException extends WebApplicationException {
	
	public static final String UNABLE_TO_FIND_GAME = "500::Game does not exist.";
	public static final String INVALID_INVITEE_NUMBER = "501::Invalid number of invitees (must be between 1-3).";
	public static final String INVALID_INVITEE_OPPONENT = "502::Invitee is not a valid opponent.";
	public static final String TOO_MANY_GAMES = "503::Reached maximum number of active games";
	public static final String TOO_MANY_GAMES_PER_OPPONENT = "504::Reached number of active games per opponent.";
	public static final String GAME_RUNNING = "505::Cannot perfrom this action on an active game.";
	public static final String GAME_INITIALIZING = "506::Cannot perform this action while game is initializing.";
	public static final String GAME_ENDED = "507::Cannot perform this action on a game that has already ended.";
	public static final String NOT_PLAYING = "509::User is not a valid player in the current game.";
	public static final String NOT_TURN = "509::Not user's turn.";
	public static final String INVALID_WINNER = "510::A specified winner is not a valid player of this game.";
	public static final String CANNOT_END_GAME_AT_THIS_TIME = "511::Cannot end game at this time.";
	public static final String DRAW_ALREADY_REQUESTED = "512::Draw has already been offered.";
	public static final String NOT_CREATOR = "513::Cannot cancel this game because user is not the creator.";
	public static final String TOO_MANY_PLAYERS = "514::Cannot request draw in games with more than two active players.";
	public static final String NO_DRAW_REQUESTED = "515::No draw has been requested.";
	public static final String INVALID_GAME_DATA = "516::Invalid Game Data";
	public static final String GAME_LOCKED = "517::Game is locked.";
	public static final String OPPONENT_TOO_MANY_GAMES = "518::Opponent cannot have any more active games.";

    private static final long serialVersionUID = 500;

    public GameException(String message) {
        super(Response.status(400).entity(message).type("text/plain").build());
    }
}
