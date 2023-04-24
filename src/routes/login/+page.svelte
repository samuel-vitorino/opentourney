<script lang="ts">
    import { PUBLIC_API_URL } from "$env/static/public";
    import { userData } from "@src/stores/user.js";
    import { goto } from "$app/navigation";
    import { toast } from "@zerodevx/svelte-toast";
    import { Input, Label, Button } from "flowbite-svelte";
    import { P } from "flowbite-svelte";
    import "@styles/login.scss";

    let email = "";
    let pwd = "";

    const handleSubmit = async () => {
        fetch(`${PUBLIC_API_URL}/auth/login`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            credentials: "include",
            body: JSON.stringify({ email, pwd }),
        })
            .then((response) => {
                if (response.ok) {
                    return response.json();
                }
                throw new Error();
            })
            .then((data) => {
                toast.push("Successfully logged in!", {
                    theme: {
                        "--toastColor": "mintcream",
                        "--toastBackground": "rgb(72,187,120)",
                        "--toastBarBackground": "#2F855A",
                    },
                });
                data["loggedIn"] = true;
                userData.set(data);
                goto("/home");
            })
            .catch((data) => {
                alert(data);
            });
    };
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
    </style>
</svelte:head>

<div
    class="container flex flex-col justify-center mx-auto flex-grow items-center"
>
    <form
        on:submit|preventDefault={handleSubmit}
        id="loginForm"
        class="bg-white dark:bg-gray-800 h-200 md:h-auto"
    >
        <P size="3xl" weight="medium">Sign in</P>
        <P size="base" class="mb-4">Start playing tournaments now</P>
        <div class="flex flex-col align-center">
            <div class="mb-6">
                <Label for="email" class="mb-2">Email address</Label>
                <Input
                    type="email"
                    id="email"
                    placeholder="john.doe@company.com"
                    bind:value={email}
                    required
                />
            </div>
            <div class="mb-6">
                <Label for="password" class="mb-2">Password</Label>
                <Input
                    type="password"
                    id="password"
                    placeholder="•••••••••"
                    bind:value={pwd}
                    required
                />
            </div>

            <Button type="submit" id="loginButton">Sign in</Button>
            <div class="flex mt-5 self-center">
                <P size="base" class="mr-2">New to OpenTourney?</P>
                <!-- svelte-ignore a11y-click-events-have-key-events -->
                <div class="cursor-pointer" on:click={() => goto("/register")}>
                    <P size="base" color="text-blue-700 dark:text-blue-500">Join now</P>
                </div>
            </div>
        </div>
    </form>
</div>
