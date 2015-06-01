package com.aristobot.data;

import java.util.List;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementWrapper;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "com.aristobot.data.GameUpdate")
public class GameUpdate {
	
	//Update Game
    public String gameKey;
    public String customMessage;
    public boolean gameEnded;
    public int score;
    
    public String turnKey;
    
    @XmlElementWrapper(name="invitees")
    @XmlElement(name="String")
    public List<String> invitees;
    
    @XmlElementWrapper(name="winners")
    @XmlElement(name="String")
    public List<String> winners;
    
    public Object gameMove;
    public Object newGameState;    
    
    
}

