<script>
    import { Spinner } from "flowbite-svelte";
    import { userData } from "@src/stores/user";
    import { P } from 'flowbite-svelte'
    import "@styles/dashboard.scss";
</script>

{#if !$userData.steamID}
    <div id="connectWithSteam" class="flex flex-col items-center justify-center">
        <P color="text-white">Connect with steam to start playing!</P>
    </div>
{/if}
<div class="flex flex-col items-center self-center mt-20 mb-auto">
    <img src="favicon.png" alt="OpenTourney Logo" class="w-[250px]" />
    <h1
        class="text-4xl font-extrabold tracking-tight text-gray-900 md:text-5xl lg:text-6xl dark:text-white"
    >
        Welcome to OpenTourney
    </h1>
    <Spinner class="mt-10" />
</div>
