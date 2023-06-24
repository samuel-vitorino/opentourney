<script lang="ts">
    import { goto } from "$app/navigation";
    import { PUBLIC_API_URL } from "$env/static/public";
    import { userData } from "@src/stores/user";
    import { toast } from "@zerodevx/svelte-toast";
    import {
        Heading,
        Table,
        TableBody,
        TableBodyCell,
        TableBodyRow,
        Search,
        Button,
        Badge,
        P,
    } from "flowbite-svelte";
    import { CheckIcon, XIcon } from "svelte-feather-icons";
    import "@styles/scrollbar.scss";

    let value = "";

    let requests: Request[] = [];

    let previewImage: string | null = null;

    enum RequestStatus {
        Pending = 0,
        Accepted = 1,
        Declined = 2,
    }

    interface Request {
        id: number;
        user_id: number;
        team_id: number;
        status: RequestStatus;
        username: string;
        teamname: string;
        createdat: string;
    }

    // TODO Toast for successfull request
    const handleAcceptRequest = (request: Request) => {
        fetch(`${PUBLIC_API_URL}/requests/${request.id}`, {
            method: "PUT",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                request: { ...request, status: RequestStatus.Accepted },
            }),
        }).then((res) => {
            if (res.ok) {
                toast.push("You declined an invite!", {
                    theme: {
                        "--toastColor": "mintcream",
                        "--toastBackground": "rgb(72,187,120)",
                        "--toastBarBackground": "#2F855A",
                    },
                });

                requests = requests.map((item) => {
                    if (item.id === request.id) {
                        item.status = RequestStatus.Accepted;
                    }
                    return item;
                });
                // request = { ...request, status: RequestStatus.Accepted };
            }
            return null;
        });
    };

    // TODO Toast for successfull request
    const handleDeclineRequest = (request: Request) => {
        fetch(`${PUBLIC_API_URL}/requests/${request.id}`, {
            method: "PUT",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                request: { ...request, status: RequestStatus.Declined },
            }),
        }).then((res) => {
            if (res.ok) {
                toast.push("You declined an invite!", {
                    theme: {
                        "--toastColor": "mintcream",
                        "--toastBackground": "rgb(72,187,120)",
                        "--toastBarBackground": "#2F855A",
                    },
                });

                requests = requests.map((item) => {
                    if (item.id === request.id) {
                        item.status = RequestStatus.Declined;
                    }
                    return item;
                });
                // requests = { ...request, status: RequestStatus.Declined };
            }
            return null;
        });
    };

    $: filteredrequests = requests.filter(
        (item) =>
            item.teamname.toLowerCase().indexOf(value.toLowerCase()) > -1 ||
            item.username.toLowerCase().indexOf(value.toLowerCase()) > -1
    );

    //get all request for the user (if not admin)
    $: if ($userData.loggedIn) {
        let url =
            `${PUBLIC_API_URL}/` +
            ($userData.role === 1
                ? "requests"
                : "requests?user=" + $userData.id);
        fetch(`${url}`)
            .then((res) => {
                if (res.ok) {
                    return res.json();
                }
                return null;
            })
            .then((data) => {
                requests = data !== null ? data.requests : data;
            });
    }
</script>

<div class="flex flex-col w-full shadow-md">
    <div class="box-content p-4">
        <Heading
            class="mb-3"
            customSize="text-2xl font-extrabold mb-4 md:text-3xl lg:text-4xl"
            >Inbox
        </Heading>
        <div>
            <div class="flex mb-2 w-1/3">
                <Search size="md" class="w-3/12" bind:value />
            </div>

            <div
                class="shadow-md sm:rounded-lg overflow-y-auto h-[calc(100vh-200px)] custom-scrollbar"
            >
                <Table hoverable={true}>
                    <TableBody tableBodyClass="divide-y">
                        {#each filteredrequests as item}
                            <TableBodyRow>
                                <TableBodyCell class="w-0 justify-center">
                                    <div
                                        class="flex flex-row text-center m-auto"
                                    >
                                        {#if item.status === 0}
                                            <Badge
                                                class="m-auto my-2"
                                                rounded
                                                color="yellow">Pending</Badge
                                            >
                                        {:else if item.status === 1}
                                            <Badge
                                                class="m-auto my-2"
                                                rounded
                                                color="green">Accepted</Badge
                                            >
                                        {:else if item.status === 2}
                                            <Badge
                                                class="m-auto my-2"
                                                rounded
                                                color="red">Declined</Badge
                                            >
                                        {/if}
                                    </div>
                                </TableBodyCell>

                                <TableBodyCell class="text-left">
                                    <div class="flex flex-row gap-1">
                                        {#if $userData}
                                            {#if $userData.role === 1}
                                                <button
                                                    on:click={() =>
                                                        goto("/teams")}
                                                    class="font-bold hover:font-extrabold"
                                                    >{item.teamname}</button
                                                >
                                                <P size="sm">
                                                    {"has invited"}
                                                </P>
                                                <P size="sm" weight="semibold">
                                                    {item.username}
                                                </P>
                                                <P size="sm">
                                                    {"to join them!"}
                                                </P>
                                            {:else}
                                                <P size="sm">
                                                    {"You have been invited to join"}
                                                </P>
                                                <button
                                                    on:click={() =>
                                                        goto("/teams")}
                                                    class="font-bold hover:font-extrabold"
                                                    >{item.teamname}!</button
                                                >
                                            {/if}
                                        {/if}
                                    </div>
                                </TableBodyCell>
                                <TableBodyCell>
                                    <P
                                        size="sm"
                                        class="flex flex-row justify-end"
                                    >
                                        {new Date(
                                            item.createdat
                                        ).toLocaleDateString("en-US", {
                                            weekday: "long",
                                            day: "numeric",
                                            month: "long",
                                            year: "numeric",
                                            minute: "2-digit",
                                            hour: "2-digit",
                                        })}
                                    </P>
                                </TableBodyCell>

                                <TableBodyCell
                                    class="flex flex-row m-auto content-end gap-2 justify-end"
                                >
                                    {#if item.status === 0}
                                        <Button
                                            size="sm"
                                            outline
                                            color="primary"
                                            bind:disabled={item.status}
                                            on:click={() =>
                                                handleAcceptRequest(item)}
                                            class="font-medium text-green-600 dark:text-green-500 bg-green-200 rounded-full"
                                        >
                                            <CheckIcon class="w-5 h-5" />
                                        </Button>
                                        <Button
                                            size="sm"
                                            outline
                                            color="primary"
                                            bind:disabled={item.status}
                                            on:click={() =>
                                                handleDeclineRequest(item)}
                                            class="font-medium text-red-600 dark:text-red-500 bg-red-200 rounded-full"
                                        >
                                            <XIcon class="w-5 h-5" />
                                        </Button>
                                    {/if}
                                </TableBodyCell>
                            </TableBodyRow>
                        {/each}
                    </TableBody>
                </Table>
            </div>
        </div>
    </div>
</div>
