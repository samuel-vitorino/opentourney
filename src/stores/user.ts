import { writable } from 'svelte/store';

import { PUBLIC_API_URL } from "$env/static/public";

const initialUserData: App.UserData = {
    loggedIn: false
}

export const userData = writable(initialUserData);

fetch(`${PUBLIC_API_URL}/users/me`, {
    credentials: "include"
})
    .then((res) => {
        if (res.ok) {
            return res.json();
        }
        throw Error();
    })
    .then((data) => {
        data['loggedIn'] = true;
        userData.set(data);
    })
    .catch(() => {});