<script>
    import { userData } from "@src/stores/user";
    import {
        P,
        Card,
        Table,
        TableBody,
        TableBodyCell,
        TableBodyRow,
        TableHead,
        TableHeadCell,
    } from "flowbite-svelte";
    import { ArrowRightCircleIcon } from "svelte-feather-icons";
    import { goto } from '$app/navigation';
    import "@styles/home.scss";
</script>

<div class="flex flex-col w-full shadow-md">
    {#if !$userData.steamid && $userData.loggedIn}
        <div
            id="connectWithSteam"
            class="flex flex-col items-center justify-center"
        >
            <P color="text-white">Connect with Steam to start playing!</P>
        </div>
    {/if}
    <div class="flex flex-col box-content p-4 grow">
        <div class="flex flex-col grow">
            <div class="flex flex-row grow box-content p-2 justify-center">
                <!-- svelte-ignore a11y-click-events-have-key-events -->
                <div class="relative flex grow cursor-pointer mr-2" on:click={() => goto("/tournaments")}>
                    <div class="w-full rounded-lg box-content p-5" id="tournamentsCard">
                        <h5
                            class="mb-2 text-2xl font-extrabold tracking-tight text-white"
                        >
                            Tournaments
                        </h5>
                    </div>
                    <div class="flex h-full w-full items-center justify-center absolute top-0 left-0 text-white rounded-lg" id="tournamentsArrowContainer">
                        <div id="tournamentsArrow" class="hidden">
                            <ArrowRightCircleIcon size="150"/>
                        </div>
                    </div>
                </div>
                <!-- svelte-ignore a11y-click-events-have-key-events -->
                <div class="relative flex grow cursor-pointer mr-2" on:click={() => goto("/teams")}>
                    <div class="w-full rounded-lg box-content p-5" id="teamsCard">
                        <h5
                            class="mb-2 text-2xl font-extrabold tracking-tight text-white"
                        >
                            Teams
                        </h5>
                    </div>
                    <div class="flex h-full w-full items-center justify-center absolute top-0 left-0 text-white rounded-lg" id="teamsArrowContainer">
                        <div id="teamsArrow" class="hidden">
                            <ArrowRightCircleIcon size="150"/>
                        </div>
                    </div>
                </div>
                <!-- svelte-ignore a11y-click-events-have-key-events -->
                <div class="relative flex grow cursor-pointer" on:click={() => goto(`/users/${$userData.id}`)}>
                    <div class="w-full rounded-lg box-content p-5" id="profileCard">
                        <h5
                            class="mb-2 text-2xl font-extrabold tracking-tight text-white"
                        >
                            Profile
                        </h5>
                    </div>
                    <div class="flex h-full w-full items-center justify-center absolute top-0 left-0 text-white rounded-lg" id="profileArrowContainer">
                        <div id="profileArrow" class="hidden">
                            <ArrowRightCircleIcon size="150"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <Table>
            <caption
                class="p-5 text-lg font-semibold text-left text-gray-900 bg-white dark:text-white dark:bg-gray-800"
            >
                Ongoing tournaments
            </caption>
            <TableHead>
                <TableHeadCell>Name</TableHeadCell>
                <TableHeadCell>Team</TableHeadCell>
                <TableHeadCell>Game</TableHeadCell>
                <TableHeadCell>Start Date</TableHeadCell>
                <TableHeadCell>
                    <span class="sr-only"> Edit </span>
                </TableHeadCell>
            </TableHead>
            <TableBody tableBodyClass="divide-y">
                <TableBodyRow>
                    <TableBodyCell>Leiria Esports"</TableBodyCell>
                    <TableBodyCell>Maceira</TableBodyCell>
                    <TableBodyCell>CS:GO</TableBodyCell>
                    <TableBodyCell>17/05/2020</TableBodyCell>
                    <TableBodyCell>
                        <a
                            href="/tables"
                            class="font-medium text-blue-600 hover:underline dark:text-blue-500"
                        >
                            Edit
                        </a>
                    </TableBodyCell>
                </TableBodyRow>
                <TableBodyRow>
                    <TableBodyCell>Lisboa Esports"</TableBodyCell>
                    <TableBodyCell>Maceira</TableBodyCell>
                    <TableBodyCell>CS:GO</TableBodyCell>
                    <TableBodyCell>10/05/2020</TableBodyCell>
                    <TableBodyCell>
                        <a
                            href="/tables"
                            class="font-medium text-blue-600 hover:underline dark:text-blue-500"
                        >
                            Edit
                        </a>
                    </TableBodyCell>
                </TableBodyRow>
                <TableBodyRow>
                    <TableBodyCell>Porto Esports"</TableBodyCell>
                    <TableBodyCell>Maceira</TableBodyCell>
                    <TableBodyCell>CS:GO</TableBodyCell>
                    <TableBodyCell>25/05/2020</TableBodyCell>
                    <TableBodyCell>
                        <a
                            href="/tables"
                            class="font-medium text-blue-600 hover:underline dark:text-blue-500"
                        >
                            Edit
                        </a>
                    </TableBodyCell>
                </TableBodyRow>
            </TableBody>
        </Table>
    </div>
</div>