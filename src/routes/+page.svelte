<script>
    import { P, Spinner, Button } from "flowbite-svelte";
    import { userData } from "@src/stores/user";
    import { goto } from "$app/navigation";
    import { GithubIcon } from "svelte-feather-icons";

    console.log($userData.loggedIn)
    if ($userData.loggedIn) {
        goto("/home")
    }
</script>

<svelte:head>
    <style>
        .route-background {
            background: url("/images/background.jpg") !important;
            background-size: cover !important;
        }

        .route-background-transparent {
            background-color: transparent !important;
        }

        #logInIcon {
            color: black;
        }
    </style>
</svelte:head>

<div class="grow">
    <div class="flex flex-col items-center self-center mt-20 content-box pl-80 pr-80">
        <P size="6xl" align="center" weight="extrabold" class="leading-tight">Rapidly create tournaments, manage servers, track statistics and have fun.</P>
        <P size="xl" align="center" class="mt-3 content-box pr-20 pl-20">A free, open-source tool to easily create LAN or WLAN tournaments with automatic match scheduling and server configuration.</P>
        <div class="mt-10">
            <Button size="lg" href="/login">Get started</Button>
            <Button color="dark" size="lg" href="https://github.com/samuel-vitorino/opentourney">Github<GithubIcon class="ml-2"/></Button>
        </div>
    </div>
</div>
