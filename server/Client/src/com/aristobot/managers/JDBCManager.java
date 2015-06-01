package com.aristobot.managers;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import com.aristobot.exceptions.DatabaseException;
import com.aristobot.utils.Constants;

/**
 * Manager class for setting up a JDBC connection and supplying
 * PreparedStatements that can read/write to the database.
 * 
 * @author James
 * 
 */
public class JDBCManager {
	private static DataSource ds;
	// There is only one JDBC connection per service call
	private Connection conn;

	public static void initializeDatasource() {
		try {
			ds = (DataSource) new InitialContext()
					.lookup(Constants.DATABASE_JDNI);
		} catch (NamingException e) {
			LogManager.logException(e);
		}

	}

	/*
	 * Sets up the JDBC connection. Called when service request first reaches
	 * server.
	 */
	public void connect() throws RuntimeException {
		try {
			conn = ds.getConnection();
			// All database writes have to manually committed to take effect
			conn.setAutoCommit(false);

		} catch (Exception e) {
			DatabaseException dbException = new DatabaseException(
					DatabaseException.DATABASE_CONNECTION_ERROR, e);
			throw dbException;
		}
	}

	/**
	 * Quick function used to execute SQL Query. NOTE: SHOULD ONLY BE USED WHEN
	 * NO CLIENT GENERATED PARAMETERS ARE PASSED INTO QUERY, AS VULNERABLE TO
	 * SQLINJECTION ATTACKS
	 */
	public Statement getStatement() {
		try {
			return conn.createStatement();
		} catch (Exception e) {
			DatabaseException dbException = new DatabaseException(
					DatabaseException.DATABASE_STATEMENT_ERROR, e);
			throw dbException;
		}
	}

	/**
	 * 
	 * @param query
	 *            valid sql query
	 * @return a PreparedStatement object able to write/read to the database
	 * @throws SQLException
	 */
	public PreparedStatement getPreparedStatement(String query) {
		try {
			return conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);
		} catch (Exception e) {
			DatabaseException dbException = new DatabaseException(
					DatabaseException.DATABASE_STATEMENT_ERROR, e);
			throw dbException;
		}

	}

	public void closeStatement(Statement stmt) {
		try {
			stmt.close();
		} catch (Exception e) {
			DatabaseException dbException = new DatabaseException(
					DatabaseException.DATABASE_STATEMENT_ERROR, e);
			throw dbException;
		}
	}

	/**
	 * Serializes and attaches a Java Object to a PreparedStatement Object so it
	 * can be written to the database
	 * 
	 * @param ps
	 *            the PreparedStatement object which to attach the serialized
	 *            object to
	 * @param paramaterIndex
	 *            the index where the serialized object to be attached
	 * @param obj
	 *            the java object to be serialized
	 * @throws SQLException
	 */
	public void write(PreparedStatement ps, int paramaterIndex, Object obj)
			throws SQLException {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();

		try {
			ObjectOutputStream oout = new ObjectOutputStream(baos);

			oout.writeObject(obj);
			oout.close();
			ps.setBytes(paramaterIndex, baos.toByteArray());
		} catch (Exception e) {
			DatabaseException dbException = new DatabaseException(
					DatabaseException.DATABASE_IO_ERROR, e);
			throw dbException;
		}
	}

	public void setArray(PreparedStatement ps, int paramaterIndex, Object[] objs)
			throws SQLException {
		ps.setArray(paramaterIndex, conn.createArrayOf("keys", objs));
	}

	/**
	 * Reads a serialized java object from a given result set and returns it
	 * deserialized
	 * 
	 * @param rs
	 *            the result set containing the serialized object
	 * @param column
	 *            the column name in the result set of the serialized object
	 * @return deserialized java object
	 * @throws SQLException
	 */
	public Object read(ResultSet rs, String column) throws SQLException {
		byte[] buf = rs.getBytes(column);

		try {
			if (buf != null) {
				ObjectInputStream objectIn = new ObjectInputStream(
						new ByteArrayInputStream(buf));
				Object obj = objectIn.readObject();
				return obj;
			}
			return null;

		} catch (Exception e) {
			DatabaseException dbException = new DatabaseException(
					DatabaseException.DATABASE_IO_ERROR, e);
			throw dbException;
		}
	}

	/**
	 * Commits all changes to the database. Should only be called once all
	 * changes are made and the service call has been completed succesffully.
	 */
	public void commit() {
		try {
			conn.commit();
		} catch (Exception e) {
			DatabaseException dbException = new DatabaseException(
					DatabaseException.DATABASE_COMMIT_ERROR, e);
			throw dbException;
		}
	}

	/**
	 * Rollbacks changes to the database during this transactions. This should
	 * be called whenever an exception is caught during a service call.
	 */
	public void rollback() {
		try {
			conn.rollback();
		} catch (Exception e) {
			DatabaseException dbException = new DatabaseException(
					DatabaseException.DATABASE_ROLLBACK_ERROR, e);
			throw dbException;
		}
	}

	/**
	 * Closes the database connection.
	 */
	public void close() {
		if (conn == null)
			return;

		try {
			conn.close();
			conn = null;
		} catch (Exception e) {
			DatabaseException dbException = new DatabaseException(
					DatabaseException.DATABASE_CLOSE_ERROR, e);
			throw LogManager.handleException(dbException);
		}
	}

}
