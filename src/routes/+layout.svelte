<script lang="ts">
  import "../app.postcss";
  import "@styles/navbar.scss";
  import {
    Navbar,
    NavBrand,
    Avatar,
    Dropdown,
    DropdownItem,
    DropdownHeader,
    DropdownDivider,
  } from "flowbite-svelte";
  import { DarkMode } from "flowbite-svelte";
  import { SvelteToast } from "@zerodevx/svelte-toast";
  import { userData } from "@src/stores/user";
  import { LogInIcon } from "svelte-feather-icons";
  import { goto } from "$app/navigation";
  import { PUBLIC_API_URL } from "$env/static/public";
  import { toast } from "@zerodevx/svelte-toast";
  import { page } from "$app/stores";
  import {
    Sidebar,
    SidebarGroup,
    SidebarItem,
    SidebarWrapper,
  } from "flowbite-svelte";
  let spanClass = "flex-1 ml-3 whitespace-nowrap";
  $: activeUrl = $page.url.pathname;

  function handleClick() {
    goto("/login");
  }

  function handleKeyDown(event: KeyboardEvent) {
    if (event.key === "Enter" || event.key === " ") {
      handleClick();
    }
  }

  function signOut() {
    fetch(`${PUBLIC_API_URL}/auth/logout`, {
      method: "GET",
      credentials: "include",
    })
      .then((response) => {
        if (response.ok) {
          toast.push("A team can't have more than 5 members!", {
            theme: {
              "--toastColor": "mintcream",
              "--toastBackground": "rgb(72,187,120)",
              "--toastBarBackground": "#2F855A",
            },
          });
          userData.set({
            loggedIn: false,
          });
          goto("/");
          return;
        }
        throw new Error();
      })
      .catch(() => {
        toast.push("There was an error signing out!", {
          theme: {
            "--toastColor": "mintcream",
            "--toastBackground": "#DC3545",
            "--toastBarBackground": "#B42D3A",
          },
        });
      });
  }

  let requests: Request[] = [];

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

  $: if ($userData.loggedIn) {
    let url =
      `${PUBLIC_API_URL}/` +
      ($userData.role === 1 ? "requests" : "requests?user=" + $userData.id);
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

  $: pendingRequests = !requests
    ? 0
    : requests.filter((request) => request.status === 0).length;
</script>

<Navbar
  let:hidden
  let:toggle
  class="route-background-transparent dark:bg-gray-900"
  color="gray"
>
  <NavBrand href={$userData.loggedIn ? "/home" : "/"}>
    <img src="/favicon.png" class="mr-3 h-10 sm:h-10" alt="OpenTourney Logo" />
  </NavBrand>
  {#if $userData.loggedIn}
    <div class="flex items-center md:order-2">
      <Avatar
        id="avatar-menu"
        class="cursor-pointer"
        src={$userData.avatar ?? ""}
      />
    </div>
    <Dropdown placement="bottom" triggeredBy="#avatar-menu">
      <DropdownHeader>
        <span class="block text-sm"> {$userData.name} </span>
        <span class="block truncate text-sm font-medium">
          {$userData.email}
        </span>
      </DropdownHeader>
      <DropdownItem href={`/users/${$userData.id}`}>Profile</DropdownItem>
      <DropdownItem href="/settings">Settings</DropdownItem>
      <DropdownItem>
        <div class="flex justify-between items-center">
          <span>Theme</span>
          <DarkMode />
        </div>
      </DropdownItem>
      <DropdownDivider />
      <DropdownItem on:click={signOut}>Sign out</DropdownItem>
    </Dropdown>
  {:else}
    <div class="logInIcon" on:click={handleClick} on:keydown={handleKeyDown}>
      <LogInIcon />
    </div>
  {/if}
</Navbar>

<div class="flex flex-col grow">
  <div class="flex grow">
    {#if $userData.loggedIn}
      <Sidebar>
        <SidebarWrapper class="h-full dark:bg-gray-900">
          <SidebarGroup>
            <SidebarItem
              label="Home"
              active={activeUrl == "/home"}
              href="/home"
            >
              <svelte:fragment slot="icon">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                  class="w-6 h-6"
                  ><path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M10.5 6a7.5 7.5 0 107.5 7.5h-7.5V6z"
                  /><path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M13.5 10.5H21A7.5 7.5 0 0013.5 3v7.5z"
                  /></svg
                >
              </svelte:fragment>
            </SidebarItem>
            <SidebarItem
              label="Tournaments"
              active={activeUrl == "/tournaments"}
              href="/tournaments"
              {spanClass}
            >
              <svelte:fragment slot="icon">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                  class="w-6 h-6"
                  ><path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M3.75 6A2.25 2.25 0 016 3.75h2.25A2.25 2.25 0 0110.5 6v2.25a2.25 2.25 0 01-2.25 2.25H6a2.25 2.25 0 01-2.25-2.25V6zM3.75 15.75A2.25 2.25 0 016 13.5h2.25a2.25 2.25 0 012.25 2.25V18a2.25 2.25 0 01-2.25 2.25H6A2.25 2.25 0 013.75 18v-2.25zM13.5 6a2.25 2.25 0 012.25-2.25H18A2.25 2.25 0 0120.25 6v2.25A2.25 2.25 0 0118 10.5h-2.25a2.25 2.25 0 01-2.25-2.25V6zM13.5 15.75a2.25 2.25 0 012.25-2.25H18a2.25 2.25 0 012.25 2.25V18A2.25 2.25 0 0118 20.25h-2.25A2.25 2.25 0 0113.5 18v-2.25z"
                  /></svg
                >
              </svelte:fragment>
            </SidebarItem>
            <SidebarItem
              label="Teams"
              active={activeUrl == "/teams"}
              href="/teams"
            >
              <svelte:fragment slot="icon">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                  class="w-6 h-6"
                  ><path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z"
                  /></svg
                >
              </svelte:fragment>
            </SidebarItem>
            <SidebarItem
              label="Inbox"
              active={activeUrl == "/inbox"}
              href="/inbox"
            >
              <svelte:fragment slot="icon">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                  class="w-6 h-6"
                  ><path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M9 3.75H6.912a2.25 2.25 0 00-2.15 1.588L2.35 13.177a2.25 2.25 0 00-.1.661V18a2.25 2.25 0 002.25 2.25h15A2.25 2.25 0 0021.75 18v-4.162c0-.224-.034-.447-.1-.661L19.24 5.338a2.25 2.25 0 00-2.15-1.588H15M2.25 13.5h3.86a2.25 2.25 0 012.012 1.244l.256.512a2.25 2.25 0 002.013 1.244h3.218a2.25 2.25 0 002.013-1.244l.256-.512a2.25 2.25 0 012.013-1.244h3.859M12 3v8.25m0 0l-3-3m3 3l3-3"
                  /></svg
                >
              </svelte:fragment>
              <svelte:fragment slot="subtext">
                <span
                  class="inline-flex justify-center items-center p-3 ml-3 w-3 h-3 text-sm font-medium text-blue-600 bg-blue-200 rounded-full dark:bg-blue-900 dark:text-blue-200"
                >
                  {pendingRequests}
                </span>
              </svelte:fragment>
            </SidebarItem>
          </SidebarGroup>
          <SidebarGroup border>
            <SidebarItem
              label="Documentation"
              active={activeUrl == "/documentation"}
              href="/documentation"
            >
              <svelte:fragment slot="icon">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                  class="w-6 h-6"
                  ><path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z"
                  /></svg
                >
              </svelte:fragment>
            </SidebarItem>
            <SidebarItem
              label="Help"
              active={activeUrl == "/help"}
              href="/help"
            >
              <svelte:fragment slot="icon">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                  class="w-6 h-6"
                  ><path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M16.712 4.33a9.027 9.027 0 011.652 1.306c.51.51.944 1.064 1.306 1.652M16.712 4.33l-3.448 4.138m3.448-4.138a9.014 9.014 0 00-9.424 0M19.67 7.288l-4.138 3.448m4.138-3.448a9.014 9.014 0 010 9.424m-4.138-5.976a3.736 3.736 0 00-.88-1.388 3.737 3.737 0 00-1.388-.88m2.268 2.268a3.765 3.765 0 010 2.528m-2.268-4.796a3.765 3.765 0 00-2.528 0m4.796 4.796c-.181.506-.475.982-.88 1.388a3.736 3.736 0 01-1.388.88m2.268-2.268l4.138 3.448m0 0a9.027 9.027 0 01-1.306 1.652c-.51.51-1.064.944-1.652 1.306m0 0l-3.448-4.138m3.448 4.138a9.014 9.014 0 01-9.424 0m5.976-4.138a3.765 3.765 0 01-2.528 0m0 0a3.736 3.736 0 01-1.388-.88 3.737 3.737 0 01-.88-1.388m2.268 2.268L7.288 19.67m0 0a9.024 9.024 0 01-1.652-1.306 9.027 9.027 0 01-1.306-1.652m0 0l4.138-3.448M4.33 16.712a9.014 9.014 0 010-9.424m4.138 5.976a3.765 3.765 0 010-2.528m0 0c.181-.506.475-.982.88-1.388a3.736 3.736 0 011.388-.88m-2.268 2.268L4.33 7.288m6.406 1.18L7.288 4.33m0 0a9.024 9.024 0 00-1.652 1.306A9.025 9.025 0 004.33 7.288"
                  /></svg
                >
              </svelte:fragment>
            </SidebarItem>
          </SidebarGroup>
        </SidebarWrapper>
      </Sidebar>
    {/if}
    <slot />
  </div>
</div>

<SvelteToast />
