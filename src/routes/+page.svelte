<script>
    import { Spinner } from "flowbite-svelte";
</script>

<svelte:head>
    <style>
        .route-background {
            background: url("/images/background.png") !important;
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
    <div class="flex flex-col items-center self-center mt-20 mb-auto">
        <img src="favicon.png" alt="OpenTourney Logo" class="w-[250px]" />
        <h1
            class="text-4xl font-extrabold tracking-tight text-gray-900 md:text-5xl lg:text-6xl dark:text-white"
        >
            Welcome to OpenTourney
        </h1>
        <Spinner class="mt-10" />
    </div>
</div>
