package com.aristobot.services;

import java.util.ArrayList;
import java.util.List;

import javax.ws.rs.Consumes;
import javax.ws.rs.DefaultValue;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.Response;

import com.aristobot.data.Opponent;
import com.aristobot.data.User;
import com.aristobot.data.wrappers.OpponentsWrapper;
import com.aristobot.exceptions.OpponentException;
import com.aristobot.managers.AuthenticationManager;
import com.aristobot.managers.JDBCManager;
import com.aristobot.managers.LogManager;
import com.aristobot.repository.MessageRepository;
import com.aristobot.repository.UserRepository;
import com.aristobot.utils.Utility;

@Path("/opponents")
public class OpponentService {

	private JDBCManager dbManager;
	private AuthenticationManager authManager;

	public OpponentService(
			@DefaultValue("true") @QueryParam("includeMessages") Boolean includeAllData) {
		try {
			dbManager = new JDBCManager();
			authManager = new AuthenticationManager(dbManager);
		} catch (RuntimeException e) {
			dbManager.rollback();
			throw LogManager.handleException(e);
		} finally {
			dbManager.close();
		}
	}

	@GET
	@Produces("application/xml")
	public OpponentsWrapper getOpponents(@Context HttpHeaders headers) {
		OpponentsWrapper wrapper;

		try {
			dbManager.connect();

			authManager.setHeaders(headers.getRequestHeaders());
			authManager.requireFullAuthentication();

			UserRepository repo = new UserRepository(dbManager);

			wrapper = new OpponentsWrapper();
			wrapper.opponents = repo.getAllOpponents(authManager.getUsername(),
					authManager.getApplicationId());

		} catch (RuntimeException e) {
			throw LogManager.handleException(e);
		} finally {
			dbManager.close();
		}

		return wrapper;
	}

	@GET
	@Path("/{username}")
	@Produces("application/xml")
	public Opponent getOpponent(
			@Context HttpHeaders headers,
			@PathParam("username") String opponentUsername,
			@DefaultValue("true") @QueryParam("includeOpponentRecord") Boolean includeOpponentRecord,
			@DefaultValue("true") @QueryParam("includeConversation") Boolean includeConversation) {
		Opponent opponent;

		try {
			dbManager.connect();

			authManager.setHeaders(headers.getRequestHeaders());
			authManager.requireFullAuthentication();

			UserRepository repo = new UserRepository(dbManager);

			String username = authManager.getUsername();
			int applicationId = authManager.getApplicationId();
			
			if (!repo.userExists(username)){
				throw new OpponentException(
						OpponentException.UNABLE_TO_FIND_OPPONENT_USERNAME);
			}
			
			//add opponent if none exist but don't validate it
			repo.addOpponent(username, opponentUsername, false);			
			
			opponent = repo.getOpponent(username, opponentUsername,
					applicationId, includeOpponentRecord);


			if (includeConversation) {
				MessageRepository messageRepo = new MessageRepository(dbManager);

				List<String> usernames = new ArrayList<String>(2);
				usernames.add(authManager.getUsername());
				usernames.add(opponentUsername);

				String conversationKey = Utility.generateSeededToken(usernames);

				opponent.conversation = messageRepo.getConversation(username,
						conversationKey, applicationId);
			}

		} catch (RuntimeException e) {
			throw LogManager.handleException(e);
		} finally {
			dbManager.close();
		}

		return opponent;
	}
	
	@POST
	@Path("/add")
	@Consumes("text/xml")
	@Produces("application/xml")
	public User addOpponent(@Context HttpHeaders headers, String usernameOrEmail) {
		User user;

		try {
			dbManager.connect();

			authManager.setHeaders(headers.getRequestHeaders());
			authManager.requireFullAuthentication();
			authManager.requirePartialWriteAccess();

			UserRepository repo = new UserRepository(dbManager);

			if (Utility.isValidUserName(usernameOrEmail)) {
				user = repo.getUser(usernameOrEmail);
				if (user == null) {
					throw new OpponentException(
							OpponentException.UNABLE_TO_FIND_OPPONENT_USERNAME);
				}
			} else if (Utility.isValidEmailAddress(usernameOrEmail)) {
				user = repo.getUserByEmail(usernameOrEmail);
				if (user == null) {
					throw new OpponentException(
							OpponentException.UNABLE_TO_FIND_OPPONENT_EMAIL);
				}
			} else {
				throw new OpponentException(OpponentException.INVALID_OPPONENT);
			}

			String username = authManager.getUsername();
			String opponentUsername = user.username;

			if (Utility.equals(username, opponentUsername)) {
				throw new OpponentException(OpponentException.INVALID_OPPONENT);
			}

			int oppositionId = repo.addOpponent(username, opponentUsername, true);
			int applicationId = authManager.getApplicationId();
			
			if (repo.getApplicationUser(opponentUsername, applicationId) != null){
				repo.addApplicationOppostion(applicationId, oppositionId);
			}

			dbManager.commit();

		} catch (RuntimeException e) {
			dbManager.rollback();
			throw LogManager.handleException(e);
		} finally {
			dbManager.close();
		}

		return user;

	}
	
	@POST
	@Path("/remove")
	@Consumes("text/xml")
	@Produces("application/xml")
	public Response removeOpponent(@Context HttpHeaders headers,
			String opponentUsername) {

		try {
			dbManager.connect();

			authManager.setHeaders(headers.getRequestHeaders());
			authManager.requireFullAuthentication();

			UserRepository repo = new UserRepository(dbManager);

			repo.removeOpponent(authManager.getUsername(), opponentUsername);

			dbManager.commit();

			return Response.status(200).build();

		} catch (RuntimeException e) {
			dbManager.rollback();
			throw LogManager.handleException(e);
		} finally {
			dbManager.close();
		}

	}
	
	@GET
	@Path("/random")
	@Produces("application/xml")
	public User findRandomOpponent(@Context HttpHeaders headers) {

		try {
			dbManager.connect();

			authManager.setHeaders(headers.getRequestHeaders());
			authManager.requireFullAuthentication();

			UserRepository repo = new UserRepository(dbManager);

			String username = authManager.getUsername();
			int applicationId = authManager.getApplicationId();

			User randomUser = repo.matchRandomUser(username, applicationId);

			if (randomUser == null) {
				throw new OpponentException(
						OpponentException.UNABLE_TO_FIND_RANDOM_OPPONENT);
			}
			
			dbManager.commit();
			
			return randomUser;

		} catch (RuntimeException e) {
			dbManager.rollback();
			throw LogManager.handleException(e);
		} finally {
			dbManager.close();
		}

	
	}

	
	
	//Deprecated functions
	@GET
	@Path("/findRandom")
	@Produces("application/xml")
	public User deprecatedRandomOpponent(@Context HttpHeaders headers) {
		return findRandomOpponent(headers);
	}
	
	

}
