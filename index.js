import { initializeApp } from "firebase/app";
import { getFirestore, collection, addDoc } from "firebase/firestore";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyCxQqg0TScpE0GEgkDG3IPEuqw5u6k9QAE",
  authDomain: "falconnet-6c1ed.firebaseapp.com",
  projectId: "falconnet-6c1ed",
  storageBucket: "falconnet-6c1ed.appspot.com",
  messagingSenderId: "303885748047",
  appId: "1:303885748047:web:e87e1e15c7f5f7da5a273a",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
console.log("Firebase initialized.");

// Initialize Firestore
const db = getFirestore(app);
console.log("Firestore initialized.");

// Function to add example data
async function addExampleData() {
  try {
    const docRef = await addDoc(collection(db, "users"), {
      name: "John Doe",
      email: "johndoe@example.com",
    });
    console.log("Document written with ID: ", docRef.id);
  } catch (error) {
    console.error("Error adding document: ", error);
  }
}

// Add the example data
addExampleData();
