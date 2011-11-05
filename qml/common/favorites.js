// Adapted from:http://www.developer.nokia.com/Community/Wiki/How-to_create_a_persistent_settings_database_in_Qt_Quick_%28QML%29

// First, let's create a short helper function to get the database connection
function getDatabase() {
     return openDatabaseSync("Meegopas", "1.0", "StorageDatabase", 100000);
}

// At the start of the application, we can initialize the tables we need if they haven't been created yet
function initialize() {
    var db = getDatabase();

    db.transaction(
        function(tx) {
            // Create the settings table if it doesn't already exist
            // If the table exists, this is skipped
            tx.executeSql('CREATE TABLE IF NOT EXISTS favorites(coord TEXT UNIQUE, name TEXT);');
          });
}

// This function is used to write a setting into the database
function addFavorite(name, coord) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
                       var rs = tx.executeSql('SELECT coord,name FROM favorites WHERE coord = ?', coord);
                       if (rs.rows.length > 0) {
                           res = "Not exist"
                       }
                       else {
                           rs = tx.executeSql('INSERT INTO favorites VALUES (?,?);', [coord,name]);
                           if (rs.rowsAffected > 0) {
                               res = "OK";
                           } else {
                               res = "Error";
                           }
                       }
                   });
  // The function returns “OK” if it was successful, or “Error” if it wasn't
  return res;
}

// This function is used to write a setting into the database
function deleteFavorite(coord, updatemodel) {
   // setting: string representing the setting name (eg: “username”)
   // value: string representing the value of the setting (eg: “myUsername”)
   var db = getDatabase();
   var res = "";
   db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM favorites WHERE coord = ?;', coord);
              console.log(rs.rowsAffected)
              if (rs.rowsAffected > 0) {
                res = "OK";
                  updatemodel.clear()
                  getFavorites(updatemodel)
              } else {
                res = "Error";
              }
        }
  );
  // The function returns “OK” if it was successful, or “Error” if it wasn't
  return res;
}

// This function is used to retrieve a setting from the database
function getFavorites(model) {
   var db = getDatabase();
   var res="";
   db.transaction(function(tx) {
     var rs = tx.executeSql('SELECT coord,name FROM favorites');
     if (rs.rows.length > 0) {
         for(var i = 0; i < rs.rows.length; i++) {
             var output = {}
             output.modelData = rs.rows.item(i).name;
             output.coord = rs.rows.item(i).coord;
             output.type = "favorite"
             model.append(output)
         }
     } else {
         res = "Unknown";
     }
  })
  // The function returns “Unknown” if the setting was not found in the database
  // For more advanced projects, this should probably be handled through error codes
  return res
}
