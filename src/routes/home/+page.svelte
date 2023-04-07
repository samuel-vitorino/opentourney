<script>
    import { userData } from "@src/stores/user";
    import { P } from 'flowbite-svelte'
    import "@styles/home.scss";
</script>

{#if !$userData.steamID && $userData.loggedIn}
    <div id="connectWithSteam" class="flex flex-col items-center justify-center">
        <P color="text-white">Connect with steam to start playing!</P>
    </div>
{/if}