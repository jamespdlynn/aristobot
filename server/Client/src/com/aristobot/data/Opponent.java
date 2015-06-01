package com.aristobot.data;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

import com.aristobot.data.wrappers.Conversation;

/**
 * Value object representing a saved opponent of the user making the service request
 * @author James
 *
 */
@XmlRootElement(name = "com.aristobot.data.Opponent")
public class Opponent extends User
{
    @XmlElement(required=true)
	public Boolean hasApplication;
    
    @XmlElement(required = false)
    public int applicationWins;
    
    @XmlElement(required = false)
	public int applicationLosses;
    
    @XmlElement(required = false)
	public int applicationTies;
	
    @XmlElement(required=true)
	public int winsAgainst;
	 
    @XmlElement(required=true)
    public int lossesAgainst;

    @XmlElement(required=true)
    public int tiesAgainst;
    
    @XmlElement(required=true)
    public RoboDate lastPlayedAgainstDate;
    
    @XmlElement(required=false)
    public int numActiveGames;
    
    @XmlElement(required=false)
    public Conversation conversation;

    @XmlElement(required=false)
    public Boolean validated;
    
}
