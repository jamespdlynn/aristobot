package com.aristobot.beans;

import java.util.ArrayList;
import java.util.List;

import javax.ejb.Schedule;
import javax.ejb.Stateless;
import javax.ejb.Timer;

import com.aristobot.data.AuthenticationData;
import com.aristobot.data.GameData;
import com.aristobot.data.GameUpdate;
import com.aristobot.data.Player;
import com.aristobot.data.PushNotification;
import com.aristobot.managers.GameManager;
import com.aristobot.managers.JDBCManager;
import com.aristobot.managers.JMSQueueManager;
import com.aristobot.managers.LogManager;
import com.aristobot.repository.AuthenticationRepositiory;
import com.aristobot.repository.GameRepository;
import com.aristobot.repository.UserRepository;
import com.aristobot.utils.Constants;
import com.aristobot.utils.Constants.PlayerStatus;
import com.aristobot.utils.Constants.QueueJDNI;

@Stateless
public class AdminBean {

	private static JMSQueueManager queueManager;
	private JDBCManager dbManager;
	
    public AdminBean() {
    	if (queueManager == null){
    		queueManager = new JMSQueueManager();
    	}
    	
    	dbManager = new JDBCManager();
    }
	
    @Schedule(second="0", minute="0", hour="8") 
    private void nightlyCleanup(final Timer t) 
	{ 
    	LogManager.log("Performing nightly cleanup");
    	clean();
    }
    
    @Schedule(second="0", minute="30", hour="15") 
	private void dailyTasks(final Timer t)
    {
    	LogManager.log("Performing daily tasks"); 
    	
	    sendQueuedItems();
    }
	
	public void clean(){
		 try{
    		 dbManager.connect();
    		 
    		 deleteExpiredTokens();
      		 processExpiredGames();
      		 resetRankings();
      		 notifyPendingExpiredGames();
      		 //sendRatingsMessages();
    	 }
  		 catch (Exception e){
  			 LogManager.logException("Error doing nightly cleanup", e);
  		 }
    	 finally{
    		 dbManager.close();
    	 }
	}
	
	public void sendQueuedItems()
	{
		try{
			queueManager.sendQueuedItems();
		}
		catch (RuntimeException e){
			 LogManager.handleException(e);
		}
	}
	
	public void updateRankings(int applicationId){    	
    	try{
    		dbManager.connect();
    		UserRepository userRepo = new UserRepository(dbManager);
    		userRepo.updateUserRankings(applicationId);
    	}
    	catch(RuntimeException e){
    		LogManager.logException("Error updating user rankings",e);
    	}
    	finally{
    		dbManager.close();
    	}
    	
    }

    
	private void processExpiredGames()
    {
		
		
    	try{
    		    		
    		GameRepository gameRepo = new GameRepository(dbManager);
    		
    		List<Player> players = gameRepo.getExpiredPlayers();
    		
    		for (int i=0; i < players.size(); i++)
    		{
    			try
    			{
    				Player player = players.get(i);
    			
    	    		GameManager gm = new GameManager(dbManager, queueManager);
    	    		
    	    		GameData gameData = gameRepo.getGame(player.gameKey, player.username, true);
    				
    				GameUpdate update = new GameUpdate();
    	        	update.gameKey = gameData.gameKey;
    	        	update.newGameState = gameData.currentGameState;
    	        	update.customMessage = player.username + " forfeited due to inactivity.";
    				
    				if (GameManager.numActivePlayers(gameData) <= 2)
    	    		{
    	    			List<String> winners = new ArrayList<String>();
    	    			for (int j = 0; j < gameData.opposingPlayers.size(); j++)
    	    			{
    	    				Player opposingPlayer = gameData.opposingPlayers.get(j);
    	    				if (opposingPlayer.active){
    	    					winners.add(opposingPlayer.username);
    	    				}
    	    			}
    	    			
    	            	update.winners = winners;
    	            	gm.processGameCompletion(update, player.username, gameData.applicationId, false);
    	    		}
    	    		else
    	    		{
    	    			gameRepo.updatePlayer(gameData.player.playerId, PlayerStatus.LOST, 0);
    	    			
    	    			if (gameData.player.isTurn){
    	    				gm.updatePlayerTurns(update, gameData.applicationId);
    	    			}
    	    		}
    				
    				dbManager.commit();    				
    	    	}
    	    	catch (RuntimeException e){
    	 	    	dbManager.rollback();
    	 	    	LogManager.logException(e);
    	     	}
    		}
    		 
    		gameRepo.deleteExpiredPendingGames();
    		
    		dbManager.commit();
		}
    	 catch (RuntimeException e){
 	    	dbManager.rollback();
 			LogManager.logException(e);
     	}
    }
	
	private void notifyPendingExpiredGames()
	{
		
		try{
    		    		
    		GameRepository gameRepo = new GameRepository(dbManager);
    		
    		List<Player> players = gameRepo.getExpiredPlayers(Constants.GAME_EXPIRATION_TIME_DAYS-1);
    		
    		for (Player player : players)
    		{
    			try
    			{    			
    	    		GameData gameData = gameRepo.getGame(player.gameKey, player.username, true);
    				
    	    		String message = "Your game with "+gameData.opposingPlayers.get(0).username+" is about to expire. If you do not move soon you will be automatically forfeited!";
    	    		
    	    		PushNotification pn = new PushNotification(player.username, message, gameData.gameKey, gameData.applicationId);

    	    		queueManager.queueItem(QueueJDNI.PUSH_NOTIFICATION, pn);
    	    	
    	    	}
    	    	catch (RuntimeException e){
    	 	    	LogManager.handleException(e);
    	     	}
    		}
		}
    	catch (RuntimeException e){
    		 LogManager.handleException(e);
     	}
		
	}

    
    private void resetRankings()
    { 
    	
    	try{
    		
    		AuthenticationRepositiory authRepo = new AuthenticationRepositiory(dbManager);		
        	UserRepository userRepo = new UserRepository(dbManager);
    		
    		for (AuthenticationData data:authRepo.getAllApplicationData())
    		{
    			if (data.rankingEnabled){
    				userRepo.resetUserRankings(data.applicationId);
    			}
    		}
    		
    		dbManager.commit();
    	}
    	 catch (RuntimeException e){
	    	dbManager.rollback();
			LogManager.handleException(e);
    	}
	}
    
    private void deleteExpiredTokens()
    {
    	
    	try{
    			
    		AuthenticationRepositiory authRepo = new AuthenticationRepositiory(dbManager);
    		
    		authRepo.deleteExpiredAccessTokens();
    		authRepo.deleteExpiredRefreshTokens();		
    		
    	    dbManager.commit();
    	}
	    catch (RuntimeException e){
	    	dbManager.rollback();
	    	LogManager.handleException(e);
 		}
    }

	/*private void sendRatingsMessages()
	{
		
		try{
			dbManager.connect();
			
			MessageRepository messageRepo = new MessageRepository(dbManager);
			UserRepository userRepo = new UserRepository(dbManager);
			AuthenticationRepositiory authRepo = new AuthenticationRepositiory(dbManager);
			
			SystemMessage message = messageRepo.getSystemMessages(MessageType.RATING).get(0);
		
			for (AuthenticationData data : authRepo.getAllApplicationData()){
				try{
					List<ApplicationUser> users = userRepo.getAllAppicationsUsers(data.applicationId, Constants.RATING_MESSAGE_DAYS);
					
					for (User user : users){
						messageRepo.addMessageToUser(message.messageKey, user.username, data.applicationId);
					}
				}
				catch (RuntimeException e){
					dbManager.rollback();
					LogManager.handleException(e);
				}
			
				dbManager.commit();
			}
			
		}
		catch (RuntimeException e){
			LogManager.handleException(e);
		}
		
	}*/

	
	
	
	
	
}