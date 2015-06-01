package com.aristobot.data;


import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlTransient;

/**
 * Value object representing a player of a given game instance
 * @author James
 *
 */
@XmlRootElement(name = "com.aristobot.data.Player")
public class Player extends User
{
	
	@XmlTransient
	public int playerId;
	
	@XmlTransient
    public String gameKey;

	@XmlTransient
	public Boolean active;

    public int playerNumber;
    
    public String playerStatus;
    public Boolean isTurn;

    public int score;
    
    public Boolean drawRequested;
    
    @XmlTransient
    public int rank;
    
       

}