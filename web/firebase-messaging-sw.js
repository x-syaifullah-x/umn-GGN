importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyCniC3TzeI8CjFPyJX_BI8fVYx3CDH_dr8",
    authDomain: "globelgirl-2c269.firebaseapp.com",
    databaseURL: "https://globelgirl-2c269-default-rtdb.firebaseio.com",
    projectId: "globelgirl-2c269",
    storageBucket: "globelgirl-2c269.appspot.com",
    messagingSenderId: "813756573374",
    appId: "1:813756573374:web:814522eaf85f06cc12a0ef",
    measurementId: "G-BH442MS22N"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
    console.log("onBackgroundMessage", message);
});