<!-- Documentation.svelte -->
<script>
    import { P } from "flowbite-svelte";

    // Add necessary variables and data for documentation content

    // Example content
    let sections = [
        {
            title: "Getting Started",
            content:
                "This section provides instructions on how to get started with the tournament management website.",
        },
        {
            title: "User Guide",
            content:
                "The user guide covers the different features and functionality of the website.",
        },
        {
            title: "FAQs",
            content:
                "Frequently Asked Questions about the tournament and website.",
        },
    ];
</script>

<!-- Render documentation sections -->
<div class="w-max flex flex-col">
    <P size="5xl">Documentation</P>

    {#each sections as section}
        <div class="flex flex-col">
            <h2>{section.title}</h2>
            <p>{section.content}</p>
        </div>
    {/each}
</div>
