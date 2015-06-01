package com.aristobot.managers;

import java.util.ArrayList;
import java.util.List;

import com.aristobot.data.AdminTask;
import com.aristobot.data.GameData;
import com.aristobot.data.GameUpdate;
import com.aristobot.data.IconUnlockInfo;
import com.aristobot.data.Player;
import com.aristobot.data.PushNotification;
import com.aristobot.data.AdminTask.Task;
import com.aristobot.exceptions.GameException;
import com.aristobot.repository.AuthenticationRepositiory;
import com.aristobot.repository.GameRepository;
import com.aristobot.repository.UserRepository;
import com.aristobot.utils.Constants.QueueJDNI;
import com.aristobot.utils.Utility;
import com.aristobot.utils.Constants.GameStatus;
import com.aristobot.utils.Constants.PlayerStatus;

public class GameManager 
{
	private JDBCManager dbManager;
	private GameRepository gameRepo;
	private UserRepository userRepo;
	private AuthenticationRepositiory authRepo;
	private RewardsManager rewardsManager;
	private JMSQueueManager queueManager;
	
	private static final Double WIN_BOOST = 1.25;
	
	private static final String YOUR_TURN_MESSAGE = " Your turn.";
	
	public GameManager(JDBCManager manager, JMSQueueManager queueManager)
	{
		dbManager = manager;
		this.queueManager = queueManager;
		
		gameRepo = new GameRepository(dbManager);
		userRepo = new UserRepository(dbManager);	
		authRepo = new AuthenticationRepositiory(dbManager);
	}
	
	 /**
     * @param players list of player objects
     * @return number of players not yet eliminated
     */
    public static int numActivePlayers(List<Player> players)
    {
    	int count = 0;
    	
    	for (int i=0; i < players.size(); i++){
    		if (players.get(i).active){
    			count++;
    		}
    	}
    	
    	return count;
    }
    /**
     * @param data game object containing all players linked to a given game
     * @return number of players not in game not yet eliminated
     */
    public static int numActivePlayers(GameData data)
    {
    	int count = (data.player.active) ? 1 : 0;
    	
    	for (int i=0; i < data.opposingPlayers.size(); i++){
    		if (data.opposingPlayers.get(i).active){
    			count++;
    		}
    	}
    	
    	return count;
    }
    
    public static List<String> getAllActiveUsernames(GameData gameData){
    	List<String> usernames = new ArrayList<String>();
    	
    	if (gameData.player.active){
    		usernames.add(gameData.player.username);
    	}
		
		for (Player opposingPlayer : gameData.opposingPlayers)
		{
			if (opposingPlayer.active){
				usernames.add(opposingPlayer.username);
			}
		}
		
		return usernames;
    }

    
	public void processGameCompletion(GameUpdate update, String username, int applicationId){
		processGameCompletion( update, username, applicationId, true);
	}
	
	public void processGameCompletion(GameUpdate update, String username, int applicationId, Boolean updateRankings)
	{			
		rewardsManager = new RewardsManager(dbManager);
		
		Boolean rankingEnabled = authRepo.getApplicationData(applicationId).rankingEnabled;
		
		List<Player> players = gameRepo.getAllPlayers(update.gameKey, applicationId);
		
		if (update.winners != null && update.winners.size() > 0){
			updatePlayersByWinners(players, update.winners);
		}
		else{
			throw new GameException("Must supply winners");
			//updatePlayersByScore(players, update.winners);
		}
		
		for (int i=0; i < players.size(); i++)
		{
			Player player = players.get(i);
			
			processPlayer(player, applicationId);
						
			if (rankingEnabled)
			{
				for (int j=i+1; j < players.size(); j++){
					Player player2 = players.get(j);
					updateRatings(player, player2, applicationId);
				}
			}
			
			if (!player.username.equalsIgnoreCase(username)){
				queueManager.queueItem(QueueJDNI.PUSH_NOTIFICATION, new PushNotification(player.username, update.customMessage, update.gameKey, applicationId));
			}
		}

		gameRepo.updateGame(update, username, GameStatus.FINISHED);
		userRepo.updateUserRecords(players, applicationId);
		
		if (rankingEnabled && updateRankings){
			//Queue a ranking update
			queueManager.queueItem(QueueJDNI.ADMIN, new AdminTask(Task.UPDATE_RANKINGS, new Integer(applicationId)));
		}
	}
	
	private void updatePlayersByWinners(List<Player> players, List<String> winners)
	{
		for (int i = 0; i < winners.size(); i++)
		{
			Boolean foundMatchingPlayer = false;
			for (Player player : players)
			{
				if (player.active && winners.get(i).equalsIgnoreCase(player.username)){
					foundMatchingPlayer = true;
					break;
				}
			}
			
			if (!foundMatchingPlayer){
				throw new GameException(GameException.INVALID_WINNER + " ("+winners.get(i)+")");
			}
		}
		
		for (int i = 0; i < players.size(); i++)
		{
			Player player = players.get(i);
			
			if (!player.active){
				player.playerStatus = PlayerStatus.LOST.value();
				player.rank = 2;
				continue;
			}
			
			for (int j = 0; j < winners.size(); j++)
			{
				if (Utility.equals(winners.get(j), player.username)){
					player.playerStatus = (winners.size() == 1) ? PlayerStatus.WON.value() : PlayerStatus.TIED.value();
					player.rank = 1;
					break;
				}
			}
			
			if (PlayerStatus.PLAYING.equals(player.playerStatus)){
				player.rank = 2;
				player.playerStatus = PlayerStatus.LOST.value();
			}
		}
	}
	
	
	
	//private void updatePlayersByScore(List<Player> players, List<String> winners)
	//{
		//Implement later
	//}
	
	private void updateRatings(Player p1, Player p2, int applicationId)
	{	
		double p1Rating = userRepo.getUserRating(p1.username, applicationId);
		double p2Rating = userRepo.getUserRating(p2.username, applicationId);
		
		double p1ExpectedResult = 1/(1+Math.pow(10, (p2Rating-p1Rating)/400));
		double p1ActualResult = (p1.rank < p2.rank) ? 1 : ((p1.rank > p2.rank) ? 0 : 0.5);
				
		double p1K = p1Rating > 2000 ? 16 : (p1Rating > 1650 ? 24 : 32);
		double p1NewRating = Math.max(p1Rating+(p1K*(p1ActualResult-p1ExpectedResult)), 100);
		
		userRepo.updateUserRating(p1.username, applicationId, (int)Math.round(p1NewRating));
		
		double p2ExpectedResult = 1-p1ExpectedResult;
		double p2ActualResult = 1-p1ActualResult;
				
		double p2K = p2Rating > 2000 ? 16 : (p2Rating > 1700 ? 24 : 32);
		double p2NewRating = Math.max(p2Rating+(p2K*(p2ActualResult-p2ExpectedResult)), 100);
		
		userRepo.updateUserRating(p2.username, applicationId, (int)Math.round(p2NewRating));
		
		
	}
	
	
	private void processPlayer(Player player, int applicationId)
	{	
		IconUnlockInfo unlockInfo = rewardsManager.processPlayerRewards(player, applicationId);
		gameRepo.updatePlayer(player.playerId, PlayerStatus.generate(player.playerStatus), unlockInfo);
		
		if (player.isTurn){
			gameRepo.updatePlayerTurn(player.playerId, false);
		}
	}
	
	 public Player updatePlayerTurns(GameUpdate gameUpdate, int applicationId)
		{
			List<Player> players = gameRepo.getAllPlayers(gameUpdate.gameKey, applicationId);
			
			int i = 0;
			while (i < players.size())
		    {
		       	Player player = players.get(i);
		       	     	
		       	if (player.isTurn){
		       		gameRepo.updatePlayerTurn(player.playerId, false);
		       		break;
		        }  	
		       	i++;
		    }
			
			int j = i+1;
			
			while (j != i)
			{
				if (j >= players.size()){
					j = 0;
				}
				
				if (players.get(j).active){					
					gameRepo.updatePlayerTurn(players.get(j).playerId, true);
					queueManager.queueItem(QueueJDNI.PUSH_NOTIFICATION, new PushNotification(players.get(j).username, gameUpdate.customMessage+YOUR_TURN_MESSAGE, gameUpdate.gameKey, applicationId));
					return players.get(j);
				}
				
				j++;
			}
			
			return null;
			
				
	    }
	
	
	
	

}