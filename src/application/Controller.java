package application;

import java.sql.SQLException;
import java.time.LocalDate;

import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.ComboBox;
import javafx.scene.control.DateCell;
import javafx.scene.control.DatePicker;
import javafx.scene.control.ListView;

public class Controller {

	@FXML
	private ComboBox<String> hotelsComboBox;

	@FXML
	private ComboBox<Integer> roomsComboBox;

	@FXML
	private DatePicker startDatePicker;

	@FXML
	private DatePicker endDatePicker;

	@FXML
	private Button button;

	@FXML
	private ListView<String> resultsView;

	@FXML
	private void initialize() throws SQLException {
		hotelsComboBox.setItems(FXCollections.observableArrayList((Database.getHotels())));
	}

	@FXML
	private void hotelSelection() throws SQLException {
		if (hotelsComboBox.getValue() != null) {
			roomsComboBox.setItems(FXCollections.observableArrayList((Database.getRooms(hotelsComboBox.getValue()))));
			roomsComboBox.setDisable(false);
		}
	}

	@FXML
	private void roomSelection() throws SQLException {
		if (roomsComboBox.getValue() != null)
			startDatePicker.setDisable(false);
	}

	@FXML
	private void checkInSelection() throws SQLException {
		if (startDatePicker.getValue() != null) {
			endDatePicker.setDayCellFactory(picker -> new DateCell() {
				@Override
				public void updateItem(LocalDate date, boolean empty) {
					super.updateItem(date, empty);
					setDisable(date.compareTo(startDatePicker.getValue()) < 1);
				}
			});
			endDatePicker.setDisable(false);
		}

	}

	@FXML
	private void checkOutSelection() throws SQLException {
		if (endDatePicker.getValue() != null)
			button.setDisable(false);
	}

	@FXML
	private void buttonAction() throws SQLException {
		if (button.getText() == "New Check") {
			button.setDisable(true);
			button.setText("Check Availability");
			hotelsComboBox.setValue(null);
			roomsComboBox.setValue(null);
			endDatePicker.setValue(null);
			startDatePicker.setValue(null);
			resultsView.setItems(null);
			hotelsComboBox.setDisable(false);
		} else {
			hotelsComboBox.setDisable(true);
			roomsComboBox.setDisable(true);
			startDatePicker.setDisable(true);
			endDatePicker.setDisable(true);
			button.setText("New Check");
			resultsView.setItems(FXCollections.observableArrayList(Database.getAvailability(hotelsComboBox.getValue(),
					roomsComboBox.getValue(), startDatePicker.getValue(), endDatePicker.getValue())));
		}
	}

}
