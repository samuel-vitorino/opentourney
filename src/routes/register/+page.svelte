<script>
  import { PUBLIC_API_URL } from "$env/static/public";
  import { P, Label, Input, Button } from "flowbite-svelte";
  import "@styles/register.scss";
  import { toast } from "@zerodevx/svelte-toast";
  import { goto } from "$app/navigation";
  
  let name = '';
  let email = '';
  let pwd = '';
  let role = 0;

  const handleSubmit = async () => {
      fetch(`${PUBLIC_API_URL}/users`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ user: { name, email, pwd, role }})
      })
          .then((response) => {
              if (response.ok) {
                  return response;
              }
              throw new Error();
          })
          .then(() => {
              toast.push("User registered successfully!", {
                  theme: {
                      "--toastColor": "mintcream",
                      "--toastBackground": "rgb(72,187,120)",
                      "--toastBarBackground": "#2F855A",
                  },
              });
              goto("/login");
          })
          .catch((data) => {
              alert(data);
          });
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
  </style>
</svelte:head>

<div
  class="container flex flex-col justify-center mx-auto flex-grow items-center"
>
  <form
    on:submit|preventDefault={handleSubmit}
    id="registerForm"
    class="bg-white dark:bg-gray-800 h-200 md:h-auto"
  >
    <P size="3xl" weight="medium">Register</P>
    <P size="base" class="mb-4">Create an account to start playing</P>
    <div class="flex flex-col align-center">
      <div class="mb-6">
        <Label for="email" class="mb-2">Username</Label>
        <Input
          type="text"
          id="username"
          placeholder="john"
          bind:value={name}
          required
        />
      </div>
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

      <Button type="submit" id="registerButton">Register</Button>
      <div class="flex mt-5 self-center">
        <P size="base" class="mr-2">Already have an account?</P>
        <!-- svelte-ignore a11y-click-events-have-key-events -->
        <div class="cursor-pointer" on:click={() => goto("/login")}>
          <P
            size="base"
            color="text-blue-700 dark:text-blue-500">Sign in
          </P>
        </div>
      </div>
    </div>
  </form>
</div>
