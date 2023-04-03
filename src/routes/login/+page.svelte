<script lang="ts">
    import { PUBLIC_API_URL } from "$env/static/public";
    import { userData } from '@src/stores/user.js';
    import { goto } from '$app/navigation';
    import { toast } from '@zerodevx/svelte-toast'

    let email = "";
    let pwd = "";

    const handleSubmit = async () => {
        fetch(`${PUBLIC_API_URL}/auth/login`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            credentials: 'include',
            body: JSON.stringify({ email, pwd }),
        }).then(response => {
            if (response.ok) {
                return response.json();
            }
            throw new Error();
        }).then (data => {
            toast.push('Successfully logged in!', {
                theme: {
                    '--toastColor': 'mintcream',
                    '--toastBackground': 'rgb(72,187,120)',
                    '--toastBarBackground': '#2F855A'
                }
            })
            userData.set({
                id: data.id,
                username: data.name,
                email: data.email,
                avatar: data.avatar,
                steamID: data.steamID,
                loggedIn: true
            })
            goto("/");
        }).catch(data => {
            alert(data);
        });
    };
</script>

<div>
    <form on:submit|preventDefault={handleSubmit}>
        <label>
            Email:
            <input type="text" bind:value={email} />
        </label>

        <label>
            Password:
            <input type="password" bind:value={pwd} />
        </label>

        <button type="submit">Log In</button>
    </form>
</div>
