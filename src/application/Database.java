package application;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

class Database {

	static Connection con;

	static Statement s;

	static void connect() throws SQLException {
		con = DriverManager.getConnection("jdbc:oracle:thin:sheradom/sheradom@//localhost:1521/orcl");
		s = con.createStatement();
	}

	static ArrayList<String> getHotels() throws SQLException {
		ResultSet set = s.executeQuery("SELECT HNAME FROM HOTELS");
		ArrayList<String> hotels = new ArrayList<>();
		while (set.next())
			hotels.add(set.getString(1));
		return hotels;
	}

	static ArrayList<Integer> getRooms(String hotel) throws SQLException {
		ResultSet set = s.executeQuery(
				"SELECT CODE FROM ROOMS WHERE HOTEL=(SELECT REF(H) FROM HOTELS H WHERE HNAME='" + hotel + "')");
		ArrayList<Integer> rooms = new ArrayList<>();
		while (set.next())
			rooms.add(set.getInt(1));
		return rooms;
	}

	static List<String> getAvailability(String hotel, int room, LocalDate start, LocalDate end) throws SQLException {
		ResultSet set = s.executeQuery("SELECT ROOMAVAILABILITY('" + hotel + "'," + room + ",DATE'" + start + "',DATE'"
				+ end + "') FROM DUAL");
		set.next();
		return Arrays.asList(set.getString(1).split("\n"));
	}

	static void closeConnection() throws SQLException {
		con.close();
	}

}
