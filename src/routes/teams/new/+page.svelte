<script lang="ts">
  import { PUBLIC_API_URL } from "$env/static/public";
  import {
    P,
    Button,
    Fileupload,
    Input,
    Label,
    Avatar,
    Alert,
    Search,
    Table,
    TableBody,
    TableBodyCell,
    TableBodyRow,
    TableHead,
    TableHeadCell,
    Popover,
  } from "flowbite-svelte";
  import {
    ArrowRightIcon,
    AwardIcon,
    MapIcon,
    StarIcon,
    Trash2Icon,
    TrashIcon,
    XIcon,
  } from "svelte-feather-icons";
  import { userData } from "@src/stores/user";
  import { onMount } from "svelte";
  import { each } from "svelte/internal";
  import { toast } from "@zerodevx/svelte-toast";

  let fileuploadprops = {
    id: "user_avatar",
  };

  let users = null;
  let filteredUsers = null;

  let files_to_upload: FileList;
  let previewImage: string | null = null;

  let owner = 0;
  let name = "";
  let avatar: string | null = null;
  let showingAlert = false;
  let isSuccess = false;
  let searchForUsersInput = "";
  let currentTeamMembers = [];
  let teamLength = 0;
  let selectedOwner = "";
  let teamIsFull = false;

  function handleSetAsTeamOwner(teamMember) {
    return () => {
      owner = teamMember.id;
      selectedOwner = teamMember.name;
    };
  }

  const handleAddTeamMember = (user) => {
    if (currentTeamMembers.includes(user)) {
      return;
    }
    if (teamLength >= 5) {
      toast.push("A team can't have more than 5 members!", {
        theme: {
          "--toastColor": "mintcream",
          "--toastBackground": "rgba(247,70,69,0.9)",
          "--toastBarBackground": "#852F5A",
        },
      });
      return;
    }
    currentTeamMembers = [...currentTeamMembers, user];
    teamLength += 1;

    if (teamLength == 5) {
      teamIsFull = true;
    }
  };

  const handleRemoveTeamMember = (user) => {
    if (user.id === owner) {
      owner = 0;
      selectedOwner = "";
    }

    currentTeamMembers = currentTeamMembers.filter((u) => u !== user);
    teamLength -= 1;
    if (teamLength < 5) {
      teamIsFull = false;
    }
  };

  const handleAvatarChange = (e: Event) => {
    const files = (<HTMLInputElement>e.target).files;

    if (files === null || files.length <= 0) {
      return;
    }

    const reader = new FileReader();
    reader.readAsDataURL(files[0]);
    reader.onload = function () {
      previewImage = <string>reader.result;
    };
  };

  const searchLocal = () => {
    if (users == null) {
      return [];
    }
    return (filteredUsers = users.filter((user) => {
      let userName = user.name.toLowerCase();
      let userEmail = user.email.toLowerCase();
      return (
        userName.includes(searchForUsersInput.toLowerCase()) ||
        userEmail.includes(searchForUsersInput.toLowerCase())
      );
    }));
  };

  const search = () => {
    fetch(`${PUBLIC_API_URL}/users?name=${searchForUsersInput}`, {
      credentials: "include",
    })
      .then((res) => {
        if (res.ok) {
          return res.json();
        }
        return null;
      })
      .then((data) => {
        users = data !== null ? data.users : data;
      });
  };

  const getAll = () => {
    fetch(`${PUBLIC_API_URL}/users`, {
      credentials: "include",
    })
      .then((res) => {
        if (res.ok) {
          return res.json();
        }
        return null;
      })
      .then((data) => {
        users = data !== null ? data.users : data;
        filteredUsers = users;
      });
  };

  async function handleSubmit(event) {
    event.preventDefault();
    console.log(event);

    try {
      const response = await fetch(`${PUBLIC_API_URL}/teams`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ team: { owner, name, avatar } }),
      });

      if (response.ok) {
        isSuccess = true;
      } else {
        isSuccess = false;
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      showingAlert = true;

      setTimeout(() => {
        showingAlert = false;
      }, 4000);
    } catch (error) {
      showingAlert = true;
      isSuccess = false;
      setTimeout(() => {
        showingAlert = false;
      }, 4000);
    }
  }

  getAll();
</script>

<div class="flex flex-col box-content p-4 w-full shadow-md">
  <P size="4xl" weight="bold" class="text-center">Team Name</P>
  <form class="flex flex-col grow justify-between" on:submit={handleSubmit}>
    <div>
      <div class="flex flex-row justify-center items-center mt-16 mb-10">
        <!-- <div class="flex flex-col items-center">
                <Avatar
                  id="avatar-menu"
                  class="w-[150px] h-[150px] rounded-sm mb-2"
                  src={previewImage !== null ? previewImage : avatar ?? ""}
                />
                <Fileupload
                  bind:files={files_to_upload}
                  accept="image/jpeg, image/png"
                  on:change={handleAvatarChange}
                  {...fileuploadprops}
                />
              </div> -->
        {#if teamLength != 0}
          {#each currentTeamMembers as teamMember}
            <div class="relative mb-2 mx-2 text-center dark:text-white">
              <button type="button" on:click={handleSetAsTeamOwner(teamMember)}>
                <Avatar
                  id="avatar-menu"
                  class="w-[100px] h-[100px] cursor-pointer"
                  src={teamMember.avatar ?? avatar}
                />
              </button>
              {#if owner === teamMember.id}
                <P
                  size="xl"
                  color="text-white"
                  align="center"
                  class="flex w-[35px] h-[35px] box-content p-1 absolute -top-2 -right-2 justify-center items-center"
                  id="owner"
                >
                  <StarIcon class="w-[35px] h-[35px] text-yellow-400 m-0" />
                </P>
                <Popover
                  class="w-40 text-sm font-light "
                  title="Team Owner"
                  triggeredBy="#owner"
                  placement="top"
                >
                  {teamMember.email}
                </Popover>
              {/if}

              {#if owner === teamMember.id}
                <div class="text-base font-semibold mb-2 text-yellow-400">
                  {teamMember.name}
                </div>
              {:else}
                <div class="text-base font-semibold mb-2">
                  {teamMember.name}
                </div>
              {/if}
              <button
                type="button"
                on:click={handleRemoveTeamMember(teamMember)}
              >
                <Trash2Icon
                  size="20"
                  class="m-auto text-gray-500 hover:text-red-600"
                />
              </button>
            </div>
          {/each}
        {:else}
          <div class="h-[10.75rem] flex justify-center">
            <P size="xl" weight="bold" class="text-center m-auto">
              No team members yet
            </P>
          </div>
        {/if}
      </div>
      <!-- <div class="mb-6">
          <Label for="first_name" class="mb-2">Name</Label>
          <Input
            type="text"
            id="name"
            placeholder="Team Name"
            required
            bind:value={name}
          />
        </div> -->
      <!-- <div class="mb-3">
          <Label for="first_name" class="mb-2">Owner</Label>
          {#if $userData.role == 0}
            <Input
              type="text"
              id="name"
              placeholder="Team Name"
              disabled
              required
              bind:value={$userData.name}
            />
          {:else}
            <Input
              type="text"
              id="name"
              disabled
              placeholder="Owner"
              required
              bind:value={selectedOwner}
            />
          {/if}
        </div> -->

      <div class="flex gap-2">
        <Search
          size="md"
          bind:value={searchForUsersInput}
          on:input={searchLocal}
          on:keydown={(event) =>
            event.key === "Enter" && event.preventDefault()}
        />
        <Button class="!p-2.5" type="button" on:click={searchLocal}>
          <svg
            class="w-5 h-5"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
            xmlns="http://www.w3.org/2000/svg"
            ><path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
            /></svg
          >
        </Button>
      </div>
      {#if showingAlert}
        {#if isSuccess}
          <Alert color="green" class="alert {showingAlert ? 'show' : 'hidden'}">
            <span slot="icon"
              ><svg
                aria-hidden="true"
                class="w-5 h-5"
                fill="currentColor"
                viewBox="0 0 20 20"
                xmlns="http://www.w3.org/2000/svg"
                ><path
                  fill-rule="evenodd"
                  d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"
                  clip-rule="evenodd"
                /></svg
              >
            </span>
            <span class="font-medium">Success!</span> A new Team has been created.
          </Alert>
        {:else}
          <div class="alert {showingAlert ? 'show' : 'hidden'}">
            <Alert color="red">
              <span slot="icon"
                ><svg
                  aria-hidden="true"
                  class="w-5 h-5"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                  xmlns="http://www.w3.org/2000/svg"
                  ><path
                    fill-rule="evenodd"
                    d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"
                    clip-rule="evenodd"
                  /></svg
                >
              </span>
              <span class="font-medium">Error!</span> Something wrong ain't right.
            </Alert>
          </div>
        {/if}
      {/if}

      {#if filteredUsers != null}
        <div class="relative p-4 my-4 max-h-96 overflow-auto shadow-md sm:rounded-lg">
          <table
            class="w-full text-sm text-left text-gray-500 dark:text-gray-400"
          >
            <thead
              class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400"
            >
              <tr>
                <th scope="col" class="px-6 py-3"> Name </th>
                <th scope="col" class="px-6 py-3"> Status </th>
                <th scope="col" class="px-6 py-3"> Action </th>
              </tr>
            </thead>
            <tbody class="overflow-auto">
              {#each filteredUsers as user}
                <tr
                  class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
                  >
                  <th
                    scope="row"
                    class="flex items-center px-6 py-4 text-gray-900 whitespace-nowrap dark:text-white"
                  >
                    <Avatar
                      id="avatar-menu"
                      class="cursor-pointer"
                      src={user.avatar ?? ""}
                    />
                    <div class="pl-3">
                      <div class="text-base font-semibold">{user.name}</div>
                      <div class="font-normal text-gray-500">
                        {user.email}
                      </div>
                    </div>
                  </th>

                  <td class="px-6 py-4">
                    <div class="flex items-center">
                      <div class="h-2.5 w-2.5 rounded-full bg-green-500 mr-2" />
                      Online
                    </div>
                  </td>
                  <td class="px-6 py-4">
                    <Button
                      type="button"
                      color="light"
                      on:click={handleAddTeamMember(user)}
                      bind:disabled={teamIsFull}>Add Player</Button
                    >
                  </td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      {/if}
      <!-- {#if teamLength != 0}
        <Table hoverable={true}>
          <TableHead>
            <TableHeadCell>Avatar</TableHeadCell>
            <TableHeadCell>Name</TableHeadCell>
            <TableHeadCell>Action</TableHeadCell>
            <TableHeadCell>
              <span class="sr-only"> Edit </span>
            </TableHeadCell>
          </TableHead>
          <TableBody class="divide-y">
            {#each currentTeamMembers as teamMember}
              <TableBodyRow>
                <TableBodyCell
                  ><Avatar
                    id="avatar-menu"
                    class="cursor-pointer"
                    src={teamMember.avatar ?? ""}
                  /></TableBodyCell
                >
                <TableBodyCell>{teamMember.name}</TableBodyCell>
                <TableBodyCell>
                  <Button
                    color="light"
                    on:click={handleRemoveTeamMember(teamMember)}
                    >Remove Player</Button
                  >
                </TableBodyCell>
                <TableBodyCell>
                  {#if owner === teamMember.id}
                    <Button color="blue" disabled>Set as Team Owner</Button>
                  {:else}
                    <Button
                      color="blue"
                      on:click={handleSetAsTeamOwner(teamMember)}
                    >
                      Set as Team Owner
                    </Button>
                  {/if}
                </TableBodyCell>
              </TableBodyRow>
            {/each}
          </TableBody>
        </Table>
      {/if} -->
    </div>
    <Button class="mt-4 mx-auto" type="submit">Create</Button>
  </form>
</div>
