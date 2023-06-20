<script lang="ts">
    import { PUBLIC_API_URL } from "$env/static/public";
    import {
        Tabs,
        TabItem,
        P,
        Button,
        Modal,
        Fileupload,
        Input,
        Label,
        Avatar,
    } from "flowbite-svelte";
    import { ArrowRightIcon } from "svelte-feather-icons";
    import { userData } from "@src/stores/user";

    let connectionsModal = false;
    let fileuploadprops = {
        id: "user_avatar",
    };

    let files_to_upload: FileList;
    let previewImage: string | null = null;

    const handleAvatarChange = (e: Event) => {
        const files = (<HTMLInputElement>e.target).files

        if (files === null || files.length <= 0) {
            return
        }
            
        const reader = new FileReader();
        reader.readAsDataURL(files[0]);
        reader.onload = function () {
            previewImage = <string>reader.result;
        }
    }

    interface User {
        name: string,
        email: string,
        avatar: string
    }

    let user: User;

    
    
    $: if ($userData.loggedIn) {
        fetch(`${PUBLIC_API_URL}/users/${$userData.id}`)
            .then((res) => {
                if (res.ok) {
                    return res.json();
                }
                return null;
            })
            .then((data) => {
                user = data !== null ? data.user : data;
            });
    }
    
</script>

<div class="flex flex-col w-full shadow-md">
    <div class="box-content p-4">
        {#if user}
            <P size="4xl" weight="bold">Settings</P>
            <Tabs style="underline">
                <TabItem open>
                    <div slot="title" class="flex items-center gap-2">
                        <svg
                            aria-hidden="true"
                            class="w-5 h-5"
                            fill="currentColor"
                            viewBox="0 0 20 20"
                            xmlns="http://www.w3.org/2000/svg"
                            ><path
                                fill-rule="evenodd"
                                d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-6-3a2 2 0 11-4 0 2 2 0 014 0zm-2 4a5 5 0 00-4.546 2.916A5.986 5.986 0 0010 16a5.986 5.986 0 004.546-2.084A5 5 0 0010 11z"
                                clip-rule="evenodd"
                            /></svg
                        >
                        Account
                    </div>
                    <div>
                        <form class="flex flex-col">
                            <div class="flex justify-between">
                                <div class="grow mr-4">
                                    <div class="mb-6">
                                        <Label for="first_name" class="mb-2"
                                            >Username</Label
                                        >
                                        <Input
                                            type="text"
                                            id="name"
                                            placeholder={user.name}
                                            required
                                            value={user.name}
                                        />

                                    </div>
                                    <div>
                                        <Label for="email" class="mb-2"
                                            >Email address</Label
                                        >
                                        <Input
                                            type="email"
                                            id="email"
                                            readonly
                                            value={user.email}
                                        />
                                    </div>
                                </div>
                                <div class="flex flex-col items-center">
                                    <Avatar
                                        id="avatar-menu"
                                        class="w-[150px] h-[150px] rounded-sm mb-2"
                                        src={previewImage !== null ? previewImage : user.avatar ?? ""}
                                    />
                                    <Fileupload bind:files={files_to_upload} accept="image/jpeg, image/png" on:change={handleAvatarChange} {...fileuploadprops}/>
                                </div>
                            </div>
                            <div class="mb-6">
                                <Label for="password" class="mb-2"
                                    >Password</Label
                                >
                                <Input
                                    type="password"
                                    id="password"
                                    placeholder="•••••••••"
                                    required
                                />
                            </div>
                            <div class="mb-6">
                                <Label for="confirm_password" class="mb-2"
                                    >Confirm password</Label
                                >
                                <Input
                                    type="password"
                                    id="confirm_password"
                                    placeholder="•••••••••"
                                    required
                                />
                            </div>
                            <Button class="self-end" type="submit">Apply</Button>
                        </form>
                    </div>
                </TabItem>
                <TabItem>
                    <div slot="title" class="flex items-center gap-2">
                        <svg
                            aria-hidden="true"
                            class="w-5 h-5"
                            fill="currentColor"
                            viewBox="0 0 20 20"
                            xmlns="http://www.w3.org/2000/svg"
                            ><path
                                d="M5 4a1 1 0 00-2 0v7.268a2 2 0 000 3.464V16a1 1 0 102 0v-1.268a2 2 0 000-3.464V4zM11 4a1 1 0 10-2 0v1.268a2 2 0 000 3.464V16a1 1 0 102 0V8.732a2 2 0 000-3.464V4zM16 3a1 1 0 011 1v7.268a2 2 0 010 3.464V16a1 1 0 11-2 0v-1.268a2 2 0 010-3.464V4a1 1 0 011-1z"
                            /></svg
                        >
                        General
                    </div>
                    <div class="flex justify-between">
                        <P class="flex items-center"
                            >Connect with an external account</P
                        >
                        <Button
                            color="green"
                            on:click={() => (connectionsModal = true)}
                            ><ArrowRightIcon /></Button
                        >
                    </div>
                </TabItem>
            </Tabs>
        {/if}
    </div>
</div>
<Modal
    title="Connect account"
    bind:open={connectionsModal}
    size="xs"
    padding="xs"
>
    <p class="text-sm font-normal text-gray-500 dark:text-gray-400">
        Connect with an external account to start playing.
    </p>
    <ul class="my-4 space-y-3">
        <li>
            <a
                href={`${PUBLIC_API_URL}/auth/steam/connect`}
                class="flex items-center p-3 text-base font-bold text-gray-900 bg-gray-50 rounded-lg hover:bg-gray-100 group hover:shadow dark:bg-gray-600 dark:hover:bg-gray-500 dark:text-white"
            >
                <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="16"
                    height="16"
                    fill="currentColor"
                    class="bi bi-steam"
                    viewBox="0 0 16 16"
                >
                    <path
                        d="M.329 10.333A8.01 8.01 0 0 0 7.99 16C12.414 16 16 12.418 16 8s-3.586-8-8.009-8A8.006 8.006 0 0 0 0 7.468l.003.006 4.304 1.769A2.198 2.198 0 0 1 5.62 8.88l1.96-2.844-.001-.04a3.046 3.046 0 0 1 3.042-3.043 3.046 3.046 0 0 1 3.042 3.043 3.047 3.047 0 0 1-3.111 3.044l-2.804 2a2.223 2.223 0 0 1-3.075 2.11 2.217 2.217 0 0 1-1.312-1.568L.33 10.333Z"
                    />
                    <path
                        d="M4.868 12.683a1.715 1.715 0 0 0 1.318-3.165 1.705 1.705 0 0 0-1.263-.02l1.023.424a1.261 1.261 0 1 1-.97 2.33l-.99-.41a1.7 1.7 0 0 0 .882.84Zm3.726-6.687a2.03 2.03 0 0 0 2.027 2.029 2.03 2.03 0 0 0 2.027-2.029 2.03 2.03 0 0 0-2.027-2.027 2.03 2.03 0 0 0-2.027 2.027Zm2.03-1.527a1.524 1.524 0 1 1-.002 3.048 1.524 1.524 0 0 1 .002-3.048Z"
                    />
                </svg>
                <span class="flex-1 ml-3 whitespace-nowrap">Steam</span>
            </a>
        </li>
    </ul>
    <div>
        <a
            href="/"
            class="inline-flex items-center text-xs font-normal text-gray-500 hover:underline dark:text-gray-400"
        >
            <span class="mr-2"
                ><svg
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke-width="1.5"
                    stroke="currentColor"
                    class="w-6 h-6"
                    ><path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9 5.25h.008v.008H12v-.008z"
                    /></svg
                ></span
            > Why do I need to connect an external account?</a
        >
    </div>
</Modal>
