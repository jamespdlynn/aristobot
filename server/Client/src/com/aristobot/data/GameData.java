package com.aristobot.data;


import java.util.List;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementWrapper;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlTransient;

import com.aristobot.data.wrappers.Conversation;

@XmlRootElement(name = "com.aristobot.data.GameData")
public class GameData {

	
    @XmlElement(required = true)
    public String gameKey;
    public String gameStatus;
    public Player player;
    
    @XmlTransient
    public int applicationId;
    
    @XmlElementWrapper(name="opposingPlayers")
	@XmlElement(name="com.aristobot.data.Player")
    public List<Player> opposingPlayers;
    
    public String lastActionMessage;
    
    public RoboDate createdDate;
    
    public RoboDate lastUpdatedDate;
    
    public Object currentGameState;
    
    @XmlElementWrapper(name="previousGameMoves")
    @XmlElement(name="String")
    public List<Object> previousGameMoves;
        
    public Conversation conversation;
    
    public int turnIndex;
    
    public IconUnlockInfo iconUnlockInfo;
        
    @XmlTransient
    public String creator;
    
}
