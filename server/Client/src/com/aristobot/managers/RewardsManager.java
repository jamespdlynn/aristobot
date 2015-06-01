package com.aristobot.managers;

import com.aristobot.data.IconUnlockInfo;
import com.aristobot.data.Player;
import com.aristobot.data.User;
import com.aristobot.repository.IconRepository;
import com.aristobot.repository.UserRepository;
import com.aristobot.utils.Constants.PlayerStatus;

public class RewardsManager 
{
	public static final int WIN_EXPERIENCE = 30;
	public static final int TIE_EXPERIENCE = 15;
	public static final int LOSS_EXPERIENCE = 10;
	
	public static final int DEFAULT_LEVEL_EXPERIENCE = 30;
	
	private JDBCManager dbManager;
	private UserRepository userRepo;
	private IconRepository iconRepo;
		
	public RewardsManager(JDBCManager manager)
	{
		dbManager = manager;
		
		userRepo = new UserRepository(dbManager);
		iconRepo = new IconRepository(dbManager);
	}
	
	
	public IconUnlockInfo processPlayerRewards(Player player, int applicationId)
	{	
		int newExperience = 0;
		PlayerStatus status = PlayerStatus.generate(player.playerStatus);
		
		switch (status)
		{
		  	case WON:
		  		newExperience = WIN_EXPERIENCE;
		  		break;
			 
		  	case LOST:
		  		newExperience = LOSS_EXPERIENCE;
		  		break;
				  
		  	case TIED:
		  		newExperience = TIE_EXPERIENCE;
		  		break;
		  		
		  	case INVITED:
		  	case PLAYING:
		  		break;
		}
	
		return rewardUserExperience(player.username, applicationId, newExperience);
	}
	
	public IconUnlockInfo rewardUserExperience(String username, int applicationId ,int experienceGained)
	{
		userRepo = new UserRepository(dbManager);
		User user = userRepo.getUserExtended(username);
						
		int experienceNeeded = ((user.level+1) * 15);
		int currentExperience = (int)Math.round(user.unlockPercent * experienceNeeded);
		int newExperience = currentExperience + experienceGained;
		
		IconUnlockInfo info = new IconUnlockInfo();
		int level = user.level;
		float newUnlockPercent = (float)newExperience/(float)experienceNeeded;
		
		if (newExperience >= experienceNeeded)
		{
			level++;
			
			info.hasUnlockedIcon = true;
			info.oldUnlockPercent = user.unlockPercent;
			info.newUnlockPercent = 1;
			info.unlockedIcon = iconRepo.unlockRandomIcon(username, getIconLevel(level), applicationId);
			
			newExperience -= experienceNeeded;
			experienceNeeded+= 15;
			
			newUnlockPercent = (float)newExperience/(float)experienceNeeded;
		}
		else{
			info.hasUnlockedIcon = false;
			info.oldUnlockPercent = user.unlockPercent;
			info.newUnlockPercent = newUnlockPercent;			
		}
		
		userRepo.updateUserExperience(username, level, newUnlockPercent);
		
		return info;
	}
	
	private int getIconLevel(int userLevel)
	{
		if (userLevel >= 15){
			return 3;
		}
		if (userLevel >= 7){
			return 2;
		}
		else{
			return 1;
		}
	}
			
}
