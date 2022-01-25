package application;

import java.io.IOException;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.control.Alert;
import javafx.scene.control.Alert.AlertType;
import javafx.stage.Stage;

public class Main extends Application {

	public static void main(String[] args) {
		try {
			Database.connect();
			launch(args);
			Database.closeConnection();
		} catch (Exception e) {
			showError(e);
		}
	}

	@Override
	public void start(Stage primaryStage) throws IOException {
		primaryStage.setTitle("Room Availability");
		primaryStage.setScene(new Scene(FXMLLoader.load(getClass().getResource("Scene.fxml"))));
		primaryStage.show();
	}

	private static void showError(Throwable exception) {
		Platform.runLater(() -> {
			Throwable e = exception;
			while (e.getCause() != null)
				e = e.getCause();
			Alert alert = new Alert(AlertType.ERROR);
			alert.setTitle("Error Dialog");
			alert.setHeaderText("An error has occurred!");
			alert.setContentText(e.getMessage());
			alert.showAndWait();
		});
	}

}
