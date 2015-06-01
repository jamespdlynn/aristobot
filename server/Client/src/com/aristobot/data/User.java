package com.aristobot.data;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlTransient;

import com.aristobot.utils.Utility;

/**
 * Value object representing a registered Sir Robot user.
 * Acts as a super class to many other user related value objects.
 * @author James
 *
 */
@XmlRootElement(name = "com.aristobot.data.User")
public class User {
	
    @XmlElement(required = true)
    public String username;
    
    @XmlElement(required = true)
    public UserIcon icon;
    
    @XmlElement(required=false)
   	public String emailAddress;
        
    @XmlElement(required = false)
    public int level;
    
    @XmlElement(required = false)
    public float unlockPercent;

    @XmlElement(required = false)
    public Boolean isDebug;

    @XmlElement(required=false)
    public RoboDate registrationDate;
    
    public static User generate(ResultSet rs, Boolean min) throws SQLException{
    	User user = new User();
        user.username = rs.getString("username");
        user.icon = Utility.getIcon(rs.getString("iconKey"));
        
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
    
   

}
