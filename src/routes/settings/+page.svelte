<script lang="ts">
    import { PUBLIC_API_URL } from "$env/static/public";
    
    async function handleLoginWithSteam() {
        window.location.href = `${PUBLIC_API_URL}/auth/steam/connect`;
    }
</script>

<button on:click="{handleLoginWithSteam}">Log In with Steam</button>
