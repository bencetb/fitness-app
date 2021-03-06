var admin = require("firebase-admin");

var serviceAccount = require("./service_key.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://fitness-app-c830e-default-rtdb.europe-west1.firebasedatabase.app"
});

const firestore = admin.firestore();
const path = require("path");
const fs = require("fs");
const directoryPath = path.join(__dirname, "files");

fs.readdir(directoryPath, function(files) {

  files.forEach(function(file) {
    var lastDotIndex = file.lastIndexOf(".");

    var menu = require("./files/" + file);

    menu.forEach(function(obj) {
      firestore
        .collection(file.substring(0, lastDotIndex))
        .doc(obj.foodId)
        .set(obj)
        .then(function(docRef) {
          console.log("Document written");
        })
    });
  });
});