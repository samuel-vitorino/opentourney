<script lang="ts">
    import { PUBLIC_API_URL } from "$env/static/public";
    import { userData } from "@src/stores/user";
    import {
        Heading,
        Table,
        TableBody,
        TableBodyCell,
        TableBodyRow,
        TableHead,
        TableHeadCell,
        Search,
        Button,
    } from "flowbite-svelte";

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
    }

    // TODO Toast for successfull request
    const handleAcceptRequest = (request: Request) => {
        fetch(`${PUBLIC_API_URL}/requests/${request.id}`, {
            method: "PUT",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                status: RequestStatus.Accepted,
            }),
        }).then((res) => {
            if (res.ok) {
                request.status = RequestStatus.Accepted;
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
                status: RequestStatus.Declined,
            }),
        }).then((res) => {
            if (res.ok) {
                request.status = RequestStatus.Declined;
            }
            return null;
        });
    };

    //TODO FILTER REQUESTS
    $: filteredrequests = requests.filter(
        (item) => item.status === RequestStatus.Pending
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
                console.log(data);
                requests = data !== null ? data.requests : data;
            });
    }
</script>

<div class="flex flex-col w-full shadow-md">
    <div class="box-content p-4">
        <Heading
            class="mb-3"
            customSize="text-2xl font-extrabold  md:text-3xl lg:text-4xl"
            >Inbox</Heading
        >
        <div>
            <div class="flex mb-2 w-1/3">
                <Search size="md" class="w-3/12" bind:value />
            </div>

            <Table shadow hoverable={true}>
                <TableHead>
                    <TableHeadCell>Status</TableHeadCell>
                    <TableHeadCell>User</TableHeadCell>
                    <TableHeadCell>Team</TableHeadCell>
                    <TableHeadCell>Action</TableHeadCell>
                </TableHead>
                <TableBody tableBodyClass="divide-y">
                    {#each filteredrequests as item}
                        <TableBodyRow>
                            <TableBodyCell>{item.status}</TableBodyCell>
                            <TableBodyCell>{item.user_id}</TableBodyCell>
                            <TableBodyCell>{item.team_id}</TableBodyCell>
                            <TableBodyCell>
                                <Button
                                    on:click={() => handleAcceptRequest(item)}
                                    class="font-medium text-green-600 hover:underline dark:text-green-500"
                                >
                                    Accept
                                </Button>
                                <Button
                                    on:click={() => handleDeclineRequest(item)}
                                    class="font-medium text-red-600 hover:underline dark:text-red-500"
                                >
                                    Decline
                                </Button>
                            </TableBodyCell>
                        </TableBodyRow>
                    {/each}
                </TableBody>
            </Table>
        </div>
    </div>
</div>
