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

import com.aristobot.data.ApplicationUser;
import com.aristobot.data.GameData;
import com.aristobot.data.GameUpdate;
import com.aristobot.data.Player;
import com.aristobot.data.PushNotification;
import com.aristobot.data.wrappers.GamesWrapper;
import com.aristobot.data.wrappers.MovesWrapper;
import com.aristobot.exceptions.GameException;
import com.aristobot.exceptions.UserException;
import com.aristobot.managers.AuthenticationManager;
import com.aristobot.managers.LogManager;
import com.aristobot.managers.GameManager;
import com.aristobot.managers.JDBCManager;
import com.aristobot.managers.JMSQueueManager;
import com.aristobot.managers.LocalCacheManager;
import com.aristobot.repository.GameRepository;
import com.aristobot.repository.MessageRepository;
import com.aristobot.repository.UserRepository;
import com.aristobot.utils.Constants;
import com.aristobot.utils.Constants.GameStatus;
import com.aristobot.utils.Constants.PlayerStatus;
import com.aristobot.utils.Constants.QueueJDNI;
import com.aristobot.utils.Utility;

@Path("/games")
public class GameService
{
	private JDBCManager dbManager;
	private AuthenticationManager authManager;
	private LocalCacheManager<Integer> cm;
		
	public GameService()
	{
		dbManager = new JDBCManager();
		authManager = new AuthenticationManager(dbManager);
		cm = new LocalCacheManager<Integer>(Constants.GAME_CACHE_NAME);
	}
	
		
    @GET
	@Produces("application/xml")
    public GamesWrapper getGames(@Context HttpHeaders headers, @QueryParam("opponentUsername") @DefaultValue("")  String opponentUsername,  
    							 @QueryParam("lastUpdatedDateTime") @DefaultValue("0") long lastUpdatedDateTime,
    							 @QueryParam("expiredGames") @DefaultValue("false") Boolean expiredGames)
    {
    	
    	try
    	{
    		dbManager.connect();
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
    		GameRepository gameRepo = new GameRepository(dbManager);
    		GamesWrapper wrapper = new GamesWrapper();
    		wrapper.games = gameRepo.getAllGames(authManager.getUsername(), authManager.getApplicationId(), opponentUsername, lastUpdatedDateTime, expiredGames, false);
    	
    		return wrapper;	
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
	    
	    
    }

  
    
    @GET
    @Path("/{key}")
	@Produces("application/xml")
    public GameData getGame(@Context HttpHeaders headers, @PathParam("key") String gameKey, @QueryParam("turnIndex") @DefaultValue("-1") int turnIndex)
    {	   	
    	try
    	{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
        	GameRepository gameRepo = new GameRepository(dbManager);
        	String username = authManager.getUsername();
        	GameData game = null;
			
        	//If a turn index is supplied we first check the memory cache for a current turn Index
			if (turnIndex >= 0){
				Integer cachedTurnIndex = cm.getFromCache(gameKey);
				//If no cached turn index or the cached turn index is greater than the one supplied then do a query on the repo with the turn index supplied as a filter
				if (cachedTurnIndex == null || cachedTurnIndex > turnIndex){
					game = gameRepo.getGame(gameKey, username, true, turnIndex);
				}
			}
			//If not turn index supplied grab the whole game object and return
        	else
        	{
        		game = gameRepo.getGame(gameKey, username , true);
    	    	
    	    	if (game == null){
    	    		throw new GameException(GameException.UNABLE_TO_FIND_GAME);
    	    	} 	
        	}
        	
        	if (game != null)
        	{
        		MessageRepository messageRepo = new MessageRepository(dbManager);
        		
        		List<String> usernames = new ArrayList<String>(2);
            	usernames.add(authManager.getUsername());
            	for (Player player:game.opposingPlayers){
            		usernames.add(player.username);
            	}
            	game.conversation = messageRepo.getConversation(usernames, authManager.getApplicationId());
            	
            	//Save this turn index to cache to improve performance on subsequent polling calls from this client
            	cm.saveToCache(gameKey, game.turnIndex);
        	}
        	
        	return game;
        	        		    	
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close(); 	
	    }
	    
	    
    }
    
    @GET
    @Path("/moves/{key}")
	@Produces("application/xml")
    public MovesWrapper getGameMoves(@Context HttpHeaders headers, @PathParam("key") String gameKey)
    {	   	    	
    	try
    	{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
        	GameRepository gameRepo = new GameRepository(dbManager);
        	
    	    if (!gameRepo.gameExists(gameKey, authManager.getUsername(), authManager.getApplicationId())){
    	    	throw new GameException(GameException.UNABLE_TO_FIND_GAME);
    	    } 	
    	    
    	   MovesWrapper wrapper = new MovesWrapper();
    	   wrapper.gameKey = gameKey;
    	   wrapper.gameMoves = gameRepo.getGameMoves(gameKey);
    	   
    	   return wrapper;
            	
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
	    
	   
    }
    
    
    
  
    @POST
    @Path("/add")
    @Consumes("application/xml")
    @Produces("text/xml")
	public String createGame(@Context HttpHeaders headers, GameUpdate game)
	{
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		authManager.requirePartialWriteAccess();
    		    		
        	GameRepository gameRepo = new GameRepository(dbManager);
        	UserRepository userRepo = new UserRepository(dbManager);
        	MessageRepository messageRepo = new MessageRepository(dbManager);
        	JMSQueueManager queueManager = new JMSQueueManager();
        	
        	String creator = authManager.getUsername();
        	int applicationId = authManager.getApplicationId();

    		if (game.invitees == null || game.invitees.size() == 0 || game.invitees.size() > 3){
    			throw new GameException(GameException.INVALID_INVITEE_NUMBER);
    		}
    		
    		int gameCount = gameRepo.getNumActiveGames(creator, applicationId);
    		if (gameCount >= Constants.MAX_GAMES){
    			throw new GameException(GameException.TOO_MANY_GAMES);
    		}
    		
    		List<String> playerNames = new ArrayList<String>();
        	playerNames.add(creator);
        	
    		String gameKey = Utility.generateRandomToken();

    		//Validate the array of invitee usernames
    		for (int i =0; i < game.invitees.size(); i++)
    		{
    			String invitee = game.invitees.get(i);
    			
    			//Invitees cannot contain the same username as the creator
    			if (invitee.equalsIgnoreCase(creator)){
    				throw new GameException(GameException.INVALID_INVITEE_OPPONENT+" ("+invitee+")");
    			}
    			
    			//Validate that this invitee is a valid user in the system and is registered with the given application
    			ApplicationUser user = userRepo.getApplicationUser(invitee, applicationId);
    			if (user == null){
    				throw new UserException(UserException.INVALID_USER+" ("+invitee+")");
    			}
    			
    			userRepo.addOpponent(authManager.getUsername(), invitee);
    			
    			int opponentGameCount = gameRepo.getNumActiveGames(invitee, authManager.getApplicationId());
        		if (opponentGameCount >= Constants.MAX_GAMES){
        			throw new GameException(GameException.OPPONENT_TOO_MANY_GAMES);
        		}
        		
        		if (game.invitees.size() == 1){
        			int oppositionGameCount = gameRepo.getNumActiveGamesWithOpponent(creator, applicationId, game.invitees.get(0));
        			
        			if (oppositionGameCount >= Constants.MAX_GAMES_PER_OPPONENT){
        				throw new GameException(GameException.TOO_MANY_GAMES_PER_OPPONENT);
        			}
        		}
    			
    			
    			playerNames.add(invitee);
    			
    			queueManager.queueItem(QueueJDNI.PUSH_NOTIFICATION, new PushNotification(invitee, creator+" invited you to a new game.", gameKey, authManager.getApplicationId()));
    		}
    		
    		if (game.customMessage == null){
    			game.customMessage = creator+" started a new game.";
    		}

    		gameRepo.addGame(gameKey, creator, game, authManager.getApplicationId());
    		messageRepo.addConversation(playerNames);
    		
    		dbManager.commit();
    		
    		queueManager.queueItem(QueueJDNI.PUSH_NOTIFICATION, new PushNotification(authManager.getUsername(), authManager.getApplicationId()));
    		queueManager.sendQueuedItems();
    		
    	    return gameKey;	
    	}
    	catch (RuntimeException e){
	    	dbManager.rollback();
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
		
	
	}
    
    @POST
    @Path("/accept")
    @Consumes("text/xml")
    @Produces("text/xml")
	public String acceptGame(@Context HttpHeaders headers, String gameKey)
	{

    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		authManager.requirePartialWriteAccess();
    		
        	GameRepository gameRepo = new GameRepository(dbManager);
        	UserRepository userRepo = new UserRepository(dbManager);
        	
    		GameData gameData = gameRepo.getGame(gameKey, authManager.getUsername(), false);
    		
    		if (gameData == null){
    			throw new GameException(GameException.UNABLE_TO_FIND_GAME);
    		}
    		if (GameStatus.RUNNING.equals(gameData.gameStatus)){
        		throw new GameException(GameException.GAME_RUNNING);
        	}
        	if (GameStatus.FINISHED.equals(gameData.gameStatus)){
        		throw new GameException(GameException.GAME_ENDED);
        	}
        	
        	int oppositionId = userRepo.addOpponent(authManager.getUsername(), gameData.creator);
    		userRepo.addApplicationOppostion(authManager.getApplicationId(), oppositionId);
    		userRepo.updateOppositionActiveGames(authManager.getApplicationId(), oppositionId, 1);

    		gameRepo.updatePlayer(gameData.player.playerId, PlayerStatus.PLAYING, GameManager.numActivePlayers(gameData)+1);
    		if (gameData.gameStatus.compareTo(GameStatus.INITIALIZING.value()) == 0){
    			gameRepo.updateGameStatus(gameKey, GameStatus.RUNNING);
    		}
    		
    		Boolean isPlayerTurn = true;
    		for (int i = 0; i < gameData.opposingPlayers.size(); i++){
    			if (gameData.opposingPlayers.get(i).isTurn){
    				isPlayerTurn = false;
    			}
    		}
    		
    		if (isPlayerTurn){
    			gameRepo.updatePlayerTurn(gameData.player.playerId, true);
    		}
    		
    		dbManager.commit();
    		
    		return gameKey;
    	}
    	catch (RuntimeException e){
	    	dbManager.rollback();
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
			
	    
	}
    
    @POST
    @Path("/decline")
    @Consumes("text/xml")
	public Response declineGame(@Context HttpHeaders headers, String gameKey)
	{

    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		authManager.requirePartialWriteAccess();
    		
        	GameRepository gameRepo = new GameRepository(dbManager);
    		GameData gameData = gameRepo.getGame(gameKey, authManager.getUsername(), false);
    		
    		if (gameData == null){
    			throw new GameException(GameException.UNABLE_TO_FIND_GAME);
    		}
    		if (GameStatus.RUNNING.equals(gameData.gameStatus)){
        		throw new GameException(GameException.GAME_RUNNING);
        	}
        	
        	if (GameStatus.FINISHED.equals(gameData.gameStatus)){
        		throw new GameException(GameException.GAME_ENDED);
        	}
    		
        	
    		if (gameRepo.getNumberOfPlayers(gameKey) <= 2){
    			gameRepo.deleteGame(gameData.gameKey);
    		}
    		else{
    			gameRepo.deletePlayer(gameData.player.playerId);
    		}
    		
    		dbManager.commit();
    		
    		return Response.status(200).build();
    	}
    	catch (RuntimeException e){
	    	dbManager.rollback();
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
		
	   	
	}
    
    @POST
    @Path("/cancel")
    @Consumes("text/xml")
	public Response cancelGame(@Context HttpHeaders headers, String gameKey)
	{
    	
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		authManager.requirePartialWriteAccess();
    		
        	GameRepository gameRepo = new GameRepository(dbManager);
        	
    		GameData gameData = gameRepo.getGame(gameKey, authManager.getUsername(), false);
    		
    		if (gameData == null){
    			throw new GameException(GameException.UNABLE_TO_FIND_GAME);
    		}
    		
    		if (!Utility.equals(gameData.creator, authManager.getUsername())){
    			throw new GameException(GameException.NOT_CREATOR);
    		}
    		
    		if (GameStatus.RUNNING.equals(gameData.gameStatus)){
        		throw new GameException(GameException.GAME_RUNNING);
        	}
        	
        	if (GameStatus.FINISHED.equals(gameData.gameStatus)){
        		throw new GameException(GameException.GAME_ENDED);
        	}
    		
        	gameRepo.deleteGame(gameData.gameKey);
        	dbManager.commit();
        	
        	return Response.status(200).build();
    	   	
    	}
    	catch (RuntimeException e){
	    	dbManager.rollback();
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
		
	   
	}

    @POST
    @Path("/update")
    @Consumes("application/xml")
    @Produces("text/xml")
	public String updateGame(@Context HttpHeaders headers, GameUpdate gameUpdate)
	{
    	
    	try{
    		
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		authManager.requirePartialWriteAccess();
    		
    		if (gameUpdate == null || gameUpdate.gameKey == null || gameUpdate.turnKey == null){
    			throw new GameException(GameException.INVALID_GAME_DATA);
    		}
    		
    		GameRepository gameRepo = new GameRepository(dbManager);
    		String username = authManager.getUsername();
        	int applicationId = authManager.getApplicationId();
    		
    		cm.acquireLock(gameUpdate.gameKey);
    		
        	        	
			GameData gameData = gameRepo.getGame(gameUpdate.gameKey, username, false);
			validateCanPlay(gameData);
			
			if (gameData == null){
	    		throw new GameException(GameException.UNABLE_TO_FIND_GAME);
	    	}
	    	
	    	if (GameStatus.FINISHED.equals(gameData.gameStatus)){
	    		throw new GameException(GameException.GAME_ENDED);
	    	}
	    	
	   		if (!PlayerStatus.PLAYING.equals(gameData.player.playerStatus)){
	   			throw new GameException(GameException.NOT_PLAYING);
	   		}
						
			if (!equalsTurnKey(gameUpdate.gameKey, gameData.turnIndex, gameUpdate.turnKey)){
				throw new GameException(GameException.NOT_TURN);
			}
			
			JMSQueueManager queueManager = new JMSQueueManager();
			GameManager gm = new GameManager(dbManager, queueManager);
    		
			if (gameUpdate.gameEnded)
			{
				if (gameData.gameStatus.equals(GameStatus.INITIALIZING.value())){
					throw new GameException(GameException.GAME_INITIALIZING);
				}
				gm.processGameCompletion(gameUpdate, username, applicationId);
			}
			else if (gameData.turnIndex > Constants.MAX_GAME_TURNS){
				gameUpdate.gameEnded = true;
				gameUpdate.customMessage = "Game exceeded maximum number of moves.";
				gameUpdate.winners = GameManager.getAllActiveUsernames(gameData);
				
				gm.processGameCompletion(gameUpdate, username, applicationId);
				
			}else{
				gameRepo.updateGame(gameUpdate, username, GameStatus.generate(gameData.gameStatus));
				gm.updatePlayerTurns(gameUpdate, applicationId);
			}
			
    				
			dbManager.commit();
			
			cm.removeFromCache(gameUpdate.gameKey);
			
			queueManager.queueItem(QueueJDNI.PUSH_NOTIFICATION, new PushNotification(username, applicationId));
			queueManager.sendQueuedItems();
			
			return gameUpdate.gameKey;
	    }
    	catch (RuntimeException e){
	    	dbManager.rollback();
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    	cm.releaseCurrentLocks();
	    }

	    
	}
        
    @POST
    @Path("/resign")
    @Consumes("text/xml")
    @Produces("text/xml")
    public String resign(@Context HttpHeaders headers, String gameKey)
    {
    	
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		authManager.requirePartialWriteAccess();
    		
        	GameRepository gameRepo = new GameRepository(dbManager);        	
        	JMSQueueManager queueManager = new JMSQueueManager();
    		GameManager gm = new GameManager(dbManager, queueManager);
    		
        	String username = authManager.getUsername();
        	int applicationId = authManager.getApplicationId();
        	
        	cm.acquireLock(gameKey);

        	GameData gameData = gameRepo.getGame(gameKey, username, true);
        	validateCanPlay(gameData);

        	if (GameStatus.INITIALIZING.equals(gameData.gameStatus)){
        		throw new GameException(GameException.GAME_INITIALIZING);
        	}
        	
        	if (gameData.createdDate.timeAgo < (Constants.GAME_MIN_RUNNING_TIME_MINUTES*60*1000)){
    			throw new GameException(GameException.CANNOT_END_GAME_AT_THIS_TIME);
    		}
        	

        	GameUpdate update = new GameUpdate();
        	update.gameKey = gameData.gameKey;
        	update.newGameState = gameData.currentGameState;
        	update.customMessage = username + " resigned from game.";
        	
        	gameData.player.active = false;
        	        	
    		if (GameManager.numActivePlayers(gameData) <= 1)
    		{
            	update.winners = GameManager.getAllActiveUsernames(gameData);
    			gm.processGameCompletion(update, username, applicationId);    		
    		}
    		else
    		{
    			gameRepo.updatePlayer(gameData.player.playerId, PlayerStatus.LOST, 0);
    			
    			if (gameData.player.isTurn){
    				 gm.updatePlayerTurns(update, applicationId);  				
    			}

    		}
    		
    		dbManager.commit(); 
    		
    		cm.removeFromCache(gameKey);
    		
    		queueManager.queueItem(QueueJDNI.PUSH_NOTIFICATION, new PushNotification(username, applicationId));
    		queueManager.sendQueuedItems();
    		
    		return gameKey;
    	
    	}
    	catch (RuntimeException e){
	    	dbManager.rollback();
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    	cm.releaseCurrentLocks();
	    	
	    }
	    
	    
    	
    }
    
  
    
    @POST
    @Path("/requestDraw")
    @Consumes("text/xml")
    @Produces("text/xml")
    public String requestDraw(@Context HttpHeaders headers, String gameKey)
    {
    	    	
    	try
    	{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		authManager.requirePartialWriteAccess();
    		
        	GameRepository gameRepo = new GameRepository(dbManager);
        	JMSQueueManager queueManager = new JMSQueueManager();
        	
        	cm.acquireLock(gameKey);
        	
    		GameData gameData = gameRepo.getGame(gameKey, authManager.getUsername(), false);
    		
    		if (gameData == null){
    			throw new GameException(GameException.UNABLE_TO_FIND_GAME);
    		}
    		if (GameStatus.INITIALIZING.equals(gameData.gameStatus)){
        		throw new GameException(GameException.GAME_INITIALIZING);
        	}
        	if (GameStatus.FINISHED.equals(gameData.gameStatus)){
        		throw new GameException(GameException.GAME_ENDED);
        	}
        	if (!PlayerStatus.PLAYING.equals(gameData.player.playerStatus)){
        		throw new GameException(GameException.NOT_PLAYING);
        	}
        	
        	
        	String customMessage = authManager.getUsername()+ " is offering a draw.";
        	
        	//gameRepo.updateGame(gameData.gameKey, authManager.getUsername(), customMessage);
        	gameRepo.updatePlayer(gameData.opposingPlayers.get(0).playerId, true);
        	 
    		dbManager.commit();  
    		
    		//cm.removeFromCache(gameKey);
    		
    		queueManager.sendItem(QueueJDNI.PUSH_NOTIFICATION, new PushNotification(gameData.opposingPlayers.get(0).username, customMessage, gameKey, authManager.getApplicationId()));
    		return gameKey;
    	}
    	catch (RuntimeException e){
	    	dbManager.rollback();
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    	cm.releaseCurrentLocks();
	    	
	    }
	    
	   
    }
    
    @POST
    @Path("/acceptDraw")
    @Consumes("text/xml")
    @Produces("text/xml")
    public String acceptDraw(@Context HttpHeaders headers, String gameKey)
    {
    	
    	try
    	{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		authManager.requirePartialWriteAccess();
    		
        	GameRepository gameRepo = new GameRepository(dbManager); 
        	
        	JMSQueueManager queueManager = new JMSQueueManager();
    		GameManager gm = new GameManager(dbManager, queueManager);
    		
    		cm.acquireLock(gameKey);
    		
    		GameData gameData = gameRepo.getGame(gameKey, authManager.getUsername(), true);
    		
    		if (gameData == null){
    			throw new GameException(GameException.UNABLE_TO_FIND_GAME);
    		}
    		if (GameStatus.INITIALIZING.equals(gameData.gameStatus)){
        		throw new GameException(GameException.GAME_INITIALIZING);
        	}
        	if (GameStatus.FINISHED.equals(gameData.gameStatus)){
        		throw new GameException(GameException.GAME_ENDED);
        	}
        	if (!PlayerStatus.PLAYING.equals(gameData.player.playerStatus)){
        		throw new GameException(GameException.NOT_PLAYING);
        	}
        	if (!gameRepo.hasDrawRequested(gameData.player.playerId)){
        		throw new GameException(GameException.NO_DRAW_REQUESTED);
        	}
        	

			GameUpdate update = new GameUpdate();
        	update.gameKey = gameData.gameKey;
        	update.newGameState = gameData.currentGameState;
        	update.customMessage = authManager.getUsername() +" accepted draw.";
        	update.winners = GameManager.getAllActiveUsernames(gameData);
        	
			gm.processGameCompletion(update, authManager.getUsername(), authManager.getApplicationId());
			
			dbManager.commit();   
			
			//cm.removeFromCache(gameKey);
			
			queueManager.queueItem(QueueJDNI.PUSH_NOTIFICATION, new PushNotification(authManager.getUsername(), authManager.getApplicationId()));
			queueManager.sendQueuedItems();
			return gameKey;
    	}
    	catch (RuntimeException e){
	    	dbManager.rollback();
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    	cm.releaseCurrentLocks();
	    }
	    
	   
    }
    
    @POST
    @Path("/declineDraw")
    @Consumes("text/xml")
    @Produces("text/xml")
    public String declineDraw(@Context HttpHeaders headers, String gameKey)
    {
    	
    	try
    	{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		authManager.requirePartialWriteAccess();
    		
    		JMSQueueManager queueManager = new JMSQueueManager();
        	GameRepository gameRepo = new GameRepository(dbManager); 
        	cm.acquireLock(gameKey);
        	
    		GameData gameData = gameRepo.getGame(gameKey, authManager.getUsername(), false);
    		
    		if (gameData == null){
    			throw new GameException(GameException.UNABLE_TO_FIND_GAME);
    		}
    		if (GameStatus.INITIALIZING.equals(gameData.gameStatus)){
        		throw new GameException(GameException.GAME_INITIALIZING);
        	}
        	if (GameStatus.FINISHED.equals(gameData.gameStatus)){
        		throw new GameException(GameException.GAME_ENDED);
        	}
        	if (!PlayerStatus.PLAYING.equals(gameData.player.playerStatus)){
        		throw new GameException(GameException.NOT_PLAYING);
        	}
        	if (!gameRepo.hasDrawRequested(gameData.player.playerId)){
        		throw new GameException(GameException.NO_DRAW_REQUESTED);
        	}
        	
        	String customMessage =  authManager.getUsername()+" declined draw offer.";
        	
    		gameRepo.updatePlayer(gameData.player.playerId, false);
    		//gameRepo.updateGameMessageOnly(gameKey, customMessage);
    		
    		dbManager.commit();
    		
    		queueManager.sendItem(QueueJDNI.PUSH_NOTIFICATION, new PushNotification(gameData.opposingPlayers.get(0).username, customMessage, gameKey, authManager.getApplicationId()));
    		
    		return gameKey;
    	   
    	}
    	catch (RuntimeException e){
	    	dbManager.rollback();
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    	cm.releaseCurrentLocks();
	    }
	    
	    
    }
    
    @POST
    @Path("/nudge")
    @Consumes("text/xml")
    @Produces("text/xml")
    public String nudge(@Context HttpHeaders headers, String gameKey)
    {
    	
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		authManager.requirePartialWriteAccess();
    		
        	GameRepository gameRepo = new GameRepository(dbManager);        	
        	JMSQueueManager queueManager = new JMSQueueManager();
    		
        	GameData gameData = gameRepo.getGame(gameKey, authManager.getUsername(), true);
        	
        	if (gameData == null){
        		throw new GameException(GameException.UNABLE_TO_FIND_GAME);
        	}
        	
        	if (GameStatus.FINISHED.equals(gameData.gameStatus)){
        		throw new GameException(GameException.GAME_ENDED);
        	}
        	
       		if (!PlayerStatus.PLAYING.equals(gameData.player.playerStatus)){
       			throw new GameException(GameException.NOT_PLAYING);
       		}
       		
       		if (gameData.player.isTurn){
       			throw new GameException(GameException.NOT_TURN);
       		}
       		
       		if (gameData.lastUpdatedDate.timeAgo > (Constants.ACCESS_TOKEN_EXPIRATION_TIME_MINUTES * 60 * 1000))
       		{
       			for (Player player : gameData.opposingPlayers)
           		{
           			if (player.isTurn){
           				queueManager.queueItem(QueueJDNI.PUSH_NOTIFICATION, new PushNotification(player.username, "Your turn with "+ authManager.getUsername()+".", gameData.gameKey, authManager.getApplicationId()));
           				break;
           			}
           		}

       			queueManager.sendQueuedItems();
       		}
       		
       		return gameKey;
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
    	
    }
    
    private void validateCanPlay(GameData gameData)
    {
    	if (gameData == null){
    		throw new GameException(GameException.UNABLE_TO_FIND_GAME);
    	}
    	
    	if (GameStatus.FINISHED.equals(gameData.gameStatus)){
    		throw new GameException(GameException.GAME_ENDED);
    	}
    	
   		if (!PlayerStatus.PLAYING.equals(gameData.player.playerStatus)){
   			throw new GameException(GameException.NOT_PLAYING);
   		}
   		if (!gameData.player.isTurn){
   			throw new GameException(GameException.NOT_TURN);
   		}

    }

    
    private Boolean equalsTurnKey(String gameKey, int turnIndex, String turnKey)
    {
    	return turnKey.equals(Long.toHexString(gameKey.charAt(turnIndex%gameKey.length()) + (turnIndex * 599))) || turnKey.equals(Long.toHexString((gameKey.charAt(1) + turnIndex) * 599));
    }
    
   
}
