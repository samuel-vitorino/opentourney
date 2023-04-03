import { writable } from 'svelte/store';
import { browser } from "$app/environment";

const initialUserData: App.UserData = {
    loggedIn: false
}

export const userData = writable(initialUserData);

if (browser) {
    const storedData = localStorage.getItem('userData');
    if (storedData) {
        userData.set(JSON.parse(storedData));
    }
}

if (browser) {
    userData.subscribe((value) => {
        localStorage.setItem('userData', JSON.stringify(value));
    });
}