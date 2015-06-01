package com.aristobot.repository;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.aristobot.data.GameData;
import com.aristobot.data.GameUpdate;
import com.aristobot.data.IconUnlockInfo;
import com.aristobot.data.Player;
import com.aristobot.exceptions.DatabaseException;
import com.aristobot.managers.JDBCManager;
import com.aristobot.utils.Constants;
import com.aristobot.utils.Utility;
import com.aristobot.utils.Constants.GameStatus;
import com.aristobot.utils.Constants.PlayerStatus;

public class GameRepository {

	private JDBCManager dbManager;

	public GameRepository(JDBCManager manager) {
		dbManager = manager;
	}

	public Boolean gameExists(String gameKey, String username, int applicationId)
			throws DatabaseException {
		Boolean hasNext;

		String gameSelect = "SELECT games.gameKey FROM games INNER JOIN players ON games.gameKey = players.gameKey "
				+ "WHERE games.gameKey = ? AND games.applicationId = ? AND players.username = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(gameSelect);

		try {
			pstmt.setString(1, gameKey);
			pstmt.setInt(2, applicationId);
			pstmt.setString(3, username);

			ResultSet rs = pstmt.executeQuery();

			hasNext = rs.next();
		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}

		return hasNext;
	}

	public GameData getGame(String gameKey) throws DatabaseException {

		String gameSelect = "SELECT gameKey, applicationId, turnIndex, creator, createdDate, status, lastActionMessage, lastUpdatedDate, NOW() as currentDate "
				+ "FROM games WHERE gameKey = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(gameSelect);

		try {
			pstmt.setString(1, gameKey);

			ResultSet rs = pstmt.executeQuery();

			if (rs.next()) {
				GameData gameData = new GameData();

				gameData.gameKey = rs.getString("gameKey");
				gameData.applicationId = rs.getInt("applicationId");
				gameData.gameStatus = rs.getString("status");
				gameData.lastActionMessage = rs.getString("lastActionMessage");
				gameData.creator = rs.getString("creator");
				gameData.turnIndex = rs.getInt("turnIndex");

				long currentDate = rs.getTimestamp("currentDate").getTime();
				gameData.createdDate = Utility.generateRoboDate(rs
						.getTimestamp("createdDate").getTime(), currentDate);
				gameData.lastUpdatedDate = Utility
						.generateRoboDate(rs.getTimestamp("lastUpdatedDate")
								.getTime(), currentDate);

				return gameData;
			}

			return null;

		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}

	}

	public GameData getGame(String gameKey, String username,
			Boolean includeCustomGameState) throws DatabaseException {
		GameData gameData;

		String gameSelect = "SELECT  games.gameKey, games.applicationId, games.turnIndex, games.creator, games.createdDate, games.status, games.lastActionMessage, games.lastUpdatedDate, NOW() as currentDate "
				+ (includeCustomGameState ? ",games.customGameState" : "")
				+ " FROM games LEFT OUTER JOIN players ON games.gameKey = players.gameKey "
				+ "WHERE games.gameKey = ? AND players.username = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(gameSelect);

		try {
			pstmt.setString(1, gameKey);
			pstmt.setString(2, username);

			ResultSet rs = pstmt.executeQuery();

			gameData = rs.next() ? generateGameData(rs, username,
					includeCustomGameState) : null;
		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}

		return gameData;
	}

	public GameData getGame(String gameKey, String username,
			Boolean includeCustomGameState, int turnIndex)
			throws DatabaseException {
		GameData gameData;

		String gameSelect = "SELECT games.gameKey, games.applicationId, games.turnIndex, games.creator, games.createdDate, games.status, games.lastActionMessage, games.lastUpdatedDate, NOW() as currentDate "
				+ (includeCustomGameState ? ",games.customGameState" : "")
				+ " FROM games LEFT OUTER JOIN players ON games.gameKey = players.gameKey "
				+ "WHERE games.gameKey = ? AND players.username = ? AND turnIndex > ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(gameSelect);

		try {
			pstmt.setString(1, gameKey);
			pstmt.setString(2, username);
			pstmt.setInt(3, turnIndex);

			ResultSet rs = pstmt.executeQuery();

			gameData = rs.next() ? generateGameData(rs, username,
					includeCustomGameState) : null;
		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}

		return gameData;
	}

	public List<GameData> getAllGames(String username, int applicationId,
			String opponentUsername, long minLastUpdatedTime,
			Boolean expiredGames, Boolean includeCustomGameState) {
		List<GameData> gameList;

		String gamesSelect = "SELECT games.gameKey, games.applicationId, games.turnIndex, games.creator, games.createdDate, games.status, games.lastActionMessage, games.lastUpdatedDate, NOW() as currentDate "
				+ (includeCustomGameState ? ",games.customGameState" : "")
				+ "FROM games "
				+ "INNER JOIN players ON games.gameKey = players.gameKey "
				+ "WHERE games.applicationId = ? AND LOWER(players.username) = LOWER(?) ";

		if (expiredGames) {
			gamesSelect += "AND (games.status = ? OR TIMESTAMPDIFF(DAY, games.lastUpdatedDate, NOW()) > ?) ";
		} else {
			gamesSelect += "AND (games.status != ? OR TIMESTAMPDIFF(DAY, games.lastUpdatedDate, NOW()) < ?) ";
		}

		if (opponentUsername != null && opponentUsername.length() > 0) {
			gamesSelect += "AND EXISTS (SELECT * FROM players WHERE username = ? AND players.gameKey = games.gameKey) ";
		}
		if (minLastUpdatedTime > 0) {
			gamesSelect += "AND games.lastUpdatedDate > ? ";
		}

		gamesSelect += "ORDER BY games.status, players.isTurn DESC, games.lastUpdatedDate DESC LIMIT 15";

		PreparedStatement pstmt = dbManager.getPreparedStatement(gamesSelect);

		try {

			int i = 1;

			pstmt.setInt(i, applicationId);
			i++;
			pstmt.setString(i, username);
			i++;
			pstmt.setString(i, GameStatus.FINISHED.value());
			i++;
			pstmt.setInt(i, Constants.GAME_EXPIRATION_TIME_DAYS);
			i++;
			if (opponentUsername != null && opponentUsername.length() > 0)
				pstmt.setString(i, opponentUsername);
			i++;
			if (minLastUpdatedTime > 0)
				pstmt.setLong(i, minLastUpdatedTime);

			ResultSet rs = pstmt.executeQuery();

			gameList = new ArrayList<GameData>();

			while (rs.next()) {
				gameList.add(generateGameData(rs, username,
						includeCustomGameState));
			}
		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}

		return gameList;

	}

	public int getNumActiveGames(String username, int applicationId) {
		int numActiveGames;

		String gamesSelect = "SELECT COUNT(games.gameKey) FROM games "
				+ "LEFT OUTER JOIN players ON games.gameKey = players.gameKey "
				+ "WHERE games.applicationId = ? AND LOWER(players.username) = LOWER(?) "
				+ "AND NOT games.status = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(gamesSelect);

		try {

			pstmt.setInt(1, applicationId);
			pstmt.setString(2, username);
			pstmt.setString(3, GameStatus.FINISHED.value());

			ResultSet rs = pstmt.executeQuery();
			rs.next();

			numActiveGames = rs.getInt(1);

		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}

		return numActiveGames;

	}

	public int getNumActiveGamesWithOpponent(String username,
			int applicationId, String opponentUsername) {
		int numActiveGames;

		String gamesSelect = "SELECT COUNT(games.gameKey) FROM games "
				+ "INNER JOIN players ON games.gameKey = players.gameKey "
				+ "WHERE games.applicationId = ? AND LOWER(players.username) = LOWER(?) "
				+ "AND NOT games.status = ?"
				+ "AND games.gameKey IN (SELECT games.gameKey FROM games "
				+ "LEFT OUTER JOIN players ON games.gameKey = players.gameKey "
				+ "WHERE LOWER(players.username) = LOWER(?))";

		PreparedStatement pstmt = dbManager.getPreparedStatement(gamesSelect);

		try {

			pstmt.setInt(1, applicationId);
			pstmt.setString(2, username);
			pstmt.setString(3, GameStatus.FINISHED.value());
			pstmt.setString(4, opponentUsername);

			ResultSet rs = pstmt.executeQuery();
			rs.next();

			numActiveGames = rs.getInt(1);

		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}

		return numActiveGames;

	}

	public int getNumPendingGames(String username, int applicationId) {
		int numActiveGames;

		String gamesSelect = "SELECT COUNT(games.gameKey) FROM games "
				+ "INNER JOIN players ON games.gameKey = players.gameKey "
				+ "WHERE games.applicationId = ? AND LOWER(players.username) = LOWER(?) "
				+ "AND (players.status = ? OR players.isTurn = 1)";

		PreparedStatement pstmt = dbManager.getPreparedStatement(gamesSelect);

		try {

			pstmt.setInt(1, applicationId);
			pstmt.setString(2, username);
			pstmt.setString(3, PlayerStatus.INVITED.value());

			ResultSet rs = pstmt.executeQuery();
			rs.next();

			numActiveGames = rs.getInt(1);

		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}

		return numActiveGames;

	}

	public Player getPlayer(String gameKey, String username) {
		Player player;

		String playerSelect = "SELECT players.playerId, players.username, players.score, players.isTurn, players.drawRequested"
				+ "players.status, players.playerNumber, users.iconKey FROM players "
				+ "LEFT OUTER JOIN users ON players.username = users.username WHERE players.gameKey = ? AND players.username = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(playerSelect);

		try {
			pstmt.setString(1, gameKey);
			pstmt.setString(2, username);
			ResultSet rs = pstmt.executeQuery();

			if (rs.next()) {
				player = new Player();

				player.playerId = rs.getInt("playerId");
				player.username = rs.getString("username");
				player.icon = Utility.getIcon(rs.getString("iconKey"));
				player.isTurn = rs.getBoolean("isTurn");
				player.score = rs.getInt("score");
				player.playerStatus = rs.getString("status");
				player.playerNumber = rs.getInt("playerNumber");
				player.drawRequested = rs.getBoolean("drawRequested");
				player.active = PlayerStatus.PLAYING
						.equals(player.playerStatus);
			} else {
				player = null;
			}
		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}

		return player;
	}

	public List<Player> getAllPlayers(String gameKey, int applicationId)
			throws DatabaseException {
		List<Player> players;

		String playerSelect = "SELECT playerId, players.username, score, isTurn, drawRequested, "
				+ "status, playerNumber, iconKey, rank FROM players "
				+ "INNER JOIN users ON players.username = users.username "
				+ "INNER JOIN applications_users ON applications_users.username = users.username "
				+ "WHERE players.gameKey = ? AND applications_users.applicationId = ? "
				+ "ORDER BY playerNumber";

		PreparedStatement pstmt = dbManager.getPreparedStatement(playerSelect);

		try {

			pstmt.setString(1, gameKey);
			pstmt.setInt(2, applicationId);
			ResultSet rs = pstmt.executeQuery();

			players = new ArrayList<Player>();
			while (rs.next()) {
				Player player = new Player();

				player.playerId = rs.getInt("playerId");
				player.username = rs.getString("username");
				player.icon = Utility.getIconRank(rs.getString("iconKey"),
						rs.getInt("rank"));
				player.isTurn = rs.getBoolean("isTurn");
				player.score = rs.getInt("score");
				player.playerNumber = rs.getInt("playerNumber");
				player.drawRequested = rs.getBoolean("drawRequested");
				player.playerStatus = rs.getString("status");
				player.active = PlayerStatus.PLAYING
						.equals(player.playerStatus);

				players.add(player);
			}
		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}

		return players;
	}

	public String addGame(String gameKey, String creator, GameUpdate game,
			int applicationId) {

		String gameInsert = "INSERT INTO games (gameKey, applicationId, creator, status, lastActionUser, lastActionMessage, customGameState, lastUpdatedDate) "
				+ "VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";

		// Insert Game
		PreparedStatement pstmt = dbManager.getPreparedStatement(gameInsert);

		try {

			pstmt.setString(1, gameKey);
			pstmt.setInt(2, applicationId);
			pstmt.setString(3, creator);
			pstmt.setString(4, GameStatus.INITIALIZING.value());
			pstmt.setString(5, creator);
			pstmt.setString(6, game.customMessage);
			dbManager.write(pstmt, 7, game.newGameState);

			pstmt.executeUpdate();
		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}

		String gameUserInsert = "INSERT INTO players (gameKey, username, playerNumber, isTurn, status) "
				+ "VALUES (?, ?, ?, ?, ?)";

		PreparedStatement pstmt2 = dbManager
				.getPreparedStatement(gameUserInsert);

		try {
			pstmt2.setString(1, gameKey);
			pstmt2.setString(2, creator);
			pstmt2.setInt(3, 1);
			pstmt2.setBoolean(4, true);
			pstmt2.setString(5, PlayerStatus.PLAYING.value());

			pstmt2.executeUpdate();
		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt2);
		}

		// Insert Invitees
		for (int i = 0; i < game.invitees.size(); i++) {
			PreparedStatement pstmt3 = dbManager
					.getPreparedStatement(gameUserInsert);

			try {
				pstmt3.setString(1, gameKey);
				pstmt3.setString(2, game.invitees.get(i));
				pstmt3.setInt(3, 0);
				pstmt3.setBoolean(4, false);
				pstmt3.setString(5, PlayerStatus.INVITED.value());

				pstmt3.executeUpdate();
			} catch (SQLException e) {
				throw new DatabaseException(
						DatabaseException.DATABASE_QUERY_ERROR, e);
			} finally {
				dbManager.closeStatement(pstmt3);
			}

		}

		return gameKey;
	}

	public void updateGame(String gameKey, String username, String customMessage) {
		String gameUpdate = "UPDATE games SET lastActionUser = ?, lastActionMessage = ?, lastUpdatedDate = NOW(), turnIndex=turnIndex+1 WHERE gameKey = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(gameUpdate);

		try {
			pstmt.setString(1, username);
			pstmt.setString(2, customMessage);
			pstmt.setString(3, gameKey);

			pstmt.executeUpdate();
		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);

		}
	}

	public void updateGame(GameUpdate game, String lastActionUser,
			GameStatus status) {
		addMove(game.gameKey, game.gameMove, game.customMessage);

		String gameUpdate = "UPDATE games SET lastActionUser = ?, lastActionMessage = ?, customGameState = ?, status = ?, lastUpdatedDate = NOW(), turnIndex=turnIndex+1 WHERE gameKey = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(gameUpdate);

		try {
			pstmt.setString(1, lastActionUser);
			pstmt.setString(2, game.customMessage);
			dbManager.write(pstmt, 3, game.newGameState);
			pstmt.setString(4, status.value());
			pstmt.setString(5, game.gameKey);

			pstmt.executeUpdate();
		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);

		}
	}

	public void updateGameStatus(String gameKey, GameStatus status) {
		String gameUpdate = "UPDATE games SET status = ?, lastUpdatedDate = NOW() WHERE gameKey = ?";

		// Insert Game
		PreparedStatement pstmt = dbManager.getPreparedStatement(gameUpdate);

		try {
			pstmt.setString(1, status.value());
			pstmt.setString(2, gameKey);

			pstmt.executeUpdate();

		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}
	}

	private void addMove(String gameKey, Object move, String actionMessage) {
		String moveAdd = "INSERT INTO moves(gameKey, actionMessage, move) VALUES(?,?,?)";

		PreparedStatement pstmt = dbManager.getPreparedStatement(moveAdd);

		try {
			pstmt.setString(1, gameKey);
			pstmt.setString(2, actionMessage);
			dbManager.write(pstmt, 3, move);

			pstmt.executeUpdate();
		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}
	}

	public int getNumberOfPlayers(String gameKey) {
		int numPlayers;

		String playersSelect = "SELECT COUNT(playerId) FROM players WHERE gameKey = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(playersSelect);

		try {

			pstmt.setString(1, gameKey);

			ResultSet rs = pstmt.executeQuery();
			rs.next();

			numPlayers = rs.getInt(1);

		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}

		return numPlayers;
	}

	public Boolean hasDrawRequested(int playerId) {
		Boolean hasDrawRequested;

		String playersSelect = "SELECT drawRequested FROM players WHERE playerId = ?";

		// Insert Game
		PreparedStatement pstmt = dbManager.getPreparedStatement(playersSelect);

		try {

			pstmt.setInt(1, playerId);

			ResultSet rs = pstmt.executeQuery();
			rs.next();

			hasDrawRequested = rs.getBoolean("drawRequested");

		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}

		return hasDrawRequested;
	}

	public void updatePlayer(int playerId, PlayerStatus status, int playerNumber) {
		String playerUpdate = "UPDATE players SET status = ?, playerNumber = ? WHERE playerId = ?";

		// Insert Game
		PreparedStatement pstmt = dbManager.getPreparedStatement(playerUpdate);

		try {

			pstmt.setString(1, status.value());
			pstmt.setInt(2, playerNumber);
			pstmt.setInt(3, playerId);

			pstmt.executeUpdate();

		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}
	}

	public void updatePlayer(int playerId, PlayerStatus status,
			IconUnlockInfo unlockInfo) {
		String playerUpdate = "UPDATE players SET status = ?, unlockedIconKey = ?, oldUnlockPercent = ?,  newUnlockPercent = ?, isTurn = 0 WHERE playerId = ?";

		// Insert Game
		PreparedStatement pstmt = dbManager.getPreparedStatement(playerUpdate);

		try {
			pstmt.setString(1, status.value());

			if (unlockInfo.unlockedIcon != null) {
				pstmt.setString(2, unlockInfo.unlockedIcon.iconKey);
			} else {
				pstmt.setString(2, null);
			}

			pstmt.setDouble(3, unlockInfo.oldUnlockPercent);
			pstmt.setDouble(4, unlockInfo.newUnlockPercent);

			pstmt.setInt(5, playerId);

			pstmt.executeUpdate();

		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}
	}

	public void updatePlayer(int playerId, Boolean drawRequested) {
		String gameUpdate = "UPDATE players SET drawRequested = ? WHERE playerId = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(gameUpdate);

		try {
			pstmt.setBoolean(1, drawRequested);
			pstmt.setInt(2, playerId);

			pstmt.executeUpdate();

		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}
	}

	public void updatePlayerTurn(int playerId, Boolean isTurn) {
		String gameUpdate = "UPDATE players SET isTurn = ? WHERE playerId = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(gameUpdate);

		try {
			pstmt.setBoolean(1, isTurn);
			pstmt.setInt(2, playerId);

			pstmt.executeUpdate();

		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}
	}

	public void deleteExpiredPendingGames() {
		String gameUpdate = "DELETE FROM games WHERE status = ? AND TIMESTAMPDIFF(DAY, createdDate, NOW()) > ?";
		PreparedStatement pstmt = dbManager.getPreparedStatement(gameUpdate);

		try {
			pstmt.setString(1, GameStatus.INITIALIZING.value());
			pstmt.setInt(2, Constants.GAME_EXPIRATION_TIME_DAYS);

			pstmt.executeUpdate();
		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}
	}

	public void deleteGame(String gameKey) {
		String gameUpdate = "DELETE FROM games WHERE gameKey = ?";
		PreparedStatement pstmt = dbManager.getPreparedStatement(gameUpdate);

		try {
			pstmt.setString(1, gameKey);
			pstmt.executeUpdate();
		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}
	}

	public void deletePlayer(int playerId) {
		String gameUpdate = "DELETE FROM players WHERE playerId = ?";
		PreparedStatement pstmt = dbManager.getPreparedStatement(gameUpdate);

		try {
			pstmt.setInt(1, playerId);
			pstmt.executeUpdate();
		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}
	}

	public List<Player> getExpiredPlayers() {
		return getExpiredPlayers(Constants.GAME_EXPIRATION_TIME_DAYS);
	}

	public List<Player> getExpiredPlayers(int expirationTimeDays) {
		List<Player> players;

		String playerSelect = "SELECT players.playerId, players.gameKey, players.username FROM players INNER JOIN games ON games.gameKey = players.gameKey "
				+ "WHERE isTurn = 1 AND players.status = ? AND TIMESTAMPDIFF(DAY, games.lastUpdatedDate, NOW()) >= ?";
		PreparedStatement pstmt = dbManager.getPreparedStatement(playerSelect);

		try {
			pstmt.setString(1, PlayerStatus.PLAYING.value());
			pstmt.setInt(2, expirationTimeDays);

			ResultSet rs = pstmt.executeQuery();

			players = new ArrayList<Player>();

			while (rs.next()) {
				Player player = new Player();
				player.playerId = rs.getInt("playerId");
				player.username = rs.getString("username");
				player.gameKey = rs.getString("gameKey");
				players.add(player);
			}

		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}

		return players;
	}

	private GameData generateGameData(ResultSet rs, String username,
			Boolean readCustomGameObject) throws SQLException {
		GameData gameData = new GameData();

		long currentDate = rs.getTimestamp("currentDate").getTime();

		gameData.gameKey = rs.getString("gameKey");
		gameData.applicationId = rs.getInt("applicationId");
		gameData.gameStatus = rs.getString("status");
		gameData.lastActionMessage = rs.getString("lastActionMessage");
		gameData.creator = rs.getString("creator");
		gameData.createdDate = Utility.generateRoboDate(
				rs.getTimestamp("createdDate").getTime(), currentDate);
		gameData.lastUpdatedDate = Utility.generateRoboDate(
				rs.getTimestamp("lastUpdatedDate").getTime(), currentDate);
		gameData.turnIndex = rs.getInt("turnIndex");

		if (readCustomGameObject) {
			gameData.currentGameState = dbManager.read(rs, "customGameState");
			gameData.previousGameMoves = getGameMoves(gameData.gameKey, 5);
		}

		gameData.opposingPlayers = new ArrayList<Player>();

		List<Player> players = getAllPlayers(gameData.gameKey,
				gameData.applicationId);

		for (int i = 0; i < players.size(); i++) {
			Player player = players.get(i);

			if (player.username.equalsIgnoreCase(username)) {
				gameData.player = player;
			} else {
				gameData.opposingPlayers.add(player);
			}
		}

		if (GameStatus.FINISHED.equals(gameData.gameStatus)) {
			gameData.iconUnlockInfo = getIconUnlockInfo(gameData.player.playerId);
		}

		return gameData;
	}

	public List<Object> getGameMoves(String gameKey) {
		return getGameMoves(gameKey, -1);
	}

	public List<Object> getGameMoves(String gameKey, final int numMoves) {
		List<Object> moves;

		String moveSelect = "SELECT move FROM moves INNER JOIN games ON games.gameKey = moves.gameKey "
				+ "WHERE games.gameKey = ?" + "ORDER BY moveId DESC";

		if (numMoves > 0) {
			moveSelect += " LIMIT ?";
		}

		PreparedStatement pstmt = dbManager.getPreparedStatement(moveSelect);

		try {
			pstmt.setString(1, gameKey);

			if (numMoves > 0) {
				pstmt.setInt(2, numMoves);
			}

			ResultSet rs = pstmt.executeQuery();

			moves = new ArrayList<Object>();

			while (rs.next()) {
				moves.add(dbManager.read(rs, "move"));
			}

			Collections.reverse(moves);

		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}

		return moves;
	}

	private IconUnlockInfo getIconUnlockInfo(int playerId) {
		IconUnlockInfo unlockInfo;

		String playerSelect = "SELECT unlockedIconKey, oldUnlockPercent, newUnlockPercent FROM players WHERE playerId = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(playerSelect);

		try {
			pstmt.setInt(1, playerId);

			ResultSet rs = pstmt.executeQuery();

			if (rs.next()) {
				unlockInfo = new IconUnlockInfo();

				String iconKey = rs.getString("unlockedIconKey");

				if (iconKey != null && iconKey.length() > 0) {
					unlockInfo.hasUnlockedIcon = true;
					unlockInfo.unlockedIcon = Utility.getIcon(iconKey);
				} else {
					unlockInfo.hasUnlockedIcon = false;
				}

				unlockInfo.oldUnlockPercent = rs.getFloat("oldUnlockPercent");
				unlockInfo.newUnlockPercent = rs.getFloat("newUnlockPercent");

			} else {
				unlockInfo = null;
			}

		} catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR,
					e);
		} finally {
			dbManager.closeStatement(pstmt);
		}

		return unlockInfo;
	}

}
