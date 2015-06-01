package com.aristobot.data;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementWrapper;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlTransient;

import com.aristobot.utils.Utility;

/**
 * Value object representing a User of a certain client application.
 * Contains the user's wins/ties/losses for this application.
 * @author James
 *
 */
@XmlRootElement(name = "com.aristobot.data.ApplicationUser")
public class ApplicationUser extends User 
{
	
	@XmlElement(required = true)
    public int wins;
    
    @XmlElement(required = true)
	public int losses;
    
    @XmlElement(required = true)
	public int ties;
    
    @XmlElement(required = true)
    public int rating;
    
    @XmlElement(required = false)
    public Boolean hasApplication;
  
    @XmlElementWrapper(name="messages", required=false)
	@XmlElement(name="com.aristobot.data.SystemMessage")
	public List<SystemMessage> messages;
	
	@XmlElementWrapper(name="icons", required=false)
	@XmlElement(name="com.aristobot.data.UserIcon")
	public List<UserIcon> icons;
	
	@XmlElement(required=false)
	public Boolean hasUnreadMessages;
	
	@XmlElement(required=false)
	public Boolean hasUnreadPriorityMessages;
    
	public static ApplicationUser generate(ResultSet rs, Boolean min) throws SQLException{
    	ApplicationUser user = new ApplicationUser();
        user.username = rs.getString("username");
        user.icon = Utility.getIconRank(rs.getString("iconKey"), rs.getInt("rank"));
        user.wins = rs.getInt("wins");
        user.losses = rs.getInt("losses");
        user.ties = rs.getInt("ties");
        user.rating = rs.getInt("rating");
        user.hasApplication = true;
        
        if (!min){
    	  user.emailAddress = rs.getString("emailAddress");
          user.level = rs.getInt("level");
          user.unlockPercent = rs.getFloat("unlockPercent");
          user.isDebug = rs.getBoolean("isDebug");
          
          Timestamp registrationDate = rs.getTimestamp("registrationDate");
          Timestamp currentDate = rs.getTimestamp("currentDate");
          user.registrationDate = Utility.generateRoboDate(registrationDate.getTime(), currentDate.getTime());
        }
      
        return user;
    }
	
	public static ApplicationUser generate(User user){
		ApplicationUser appUser = new ApplicationUser();
		appUser.username = user.username;
		appUser.icon = user.icon;
		appUser.emailAddress = user.emailAddress;
		appUser.level = user.level;
		appUser.unlockPercent = user.unlockPercent;
		appUser.isDebug = user.isDebug;
        appUser.registrationDate = user.registrationDate;
        appUser.hasApplication = false;
	  
	    return appUser;
	}
    
}
