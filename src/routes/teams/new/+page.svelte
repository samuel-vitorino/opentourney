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
  } from "flowbite-svelte";
  import { ArrowRightIcon } from "svelte-feather-icons";
  import { userData } from "@src/stores/user";
  import { onMount } from "svelte";
  import { each } from "svelte/internal";
  import { toast } from "@zerodevx/svelte-toast";

  let fileuploadprops = {
    id: "user_avatar",
  };

  let users = null;

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
    currentTeamMembers.push(user);
    teamLength += 1;
    console.log(teamLength);
  };

  const handleRemoveTeamMember = (user) => {
    owner = 0;
    selectedOwner = "";
    currentTeamMembers = currentTeamMembers.filter((u) => u !== user);
    teamLength -= 1;
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

  const submitted = () => {
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
        console.log(data);
        // teams = data !== null ? data.teams : data;
        users = data !== null ? data.users : data;
      });
  };

  async function handleSubmit(event) {
    event.preventDefault();

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

      // const result = await response.json();
      // console.log(result);
    } catch (error) {
      showingAlert = true;
      isSuccess = false;
      setTimeout(() => {
        showingAlert = false;
      }, 4000);
    }
  }
</script>

<div class="flex flex-col w-full shadow-md">
  <div class="box-content p-4">
    <P size="4xl" weight="bold">Create new Team</P>

    <div>
      <form class="flex flex-col" on:submit={handleSubmit}>
        <div class="flex justify-between">
          <div class="grow mr-4">
            <div class="flex flex-col items-center">
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
            </div>
            <div class="mb-6">
              <Label for="first_name" class="mb-2">Name</Label>
              <Input
                type="text"
                id="name"
                placeholder="Team Name"
                required
                bind:value={name}
              />
            </div>
            <div class="mb-3">
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
            </div>
          </div>
          <Button class="self-end" type="submit">Create</Button>
        </div>
      </form>

      <form class="flex gap-2" id="example-form" on:submit={submitted}>
        <Search size="md" bind:value={searchForUsersInput} />
        <Button class="!p-2.5" type="submit">
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
      </form>
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

      {#if users != null}
        <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
          <div
            class="flex items-center justify-between pb-4 bg-white dark:bg-gray-900"
          >
            <div>
              <div
                id="dropdownAction"
                class="z-10 hidden bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700 dark:divide-gray-600"
              >
                <ul
                  class="py-1 text-sm text-gray-700 dark:text-gray-200"
                  aria-labelledby="dropdownActionButton"
                >
                  <li>
                    <a
                      href="#"
                      class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
                      >Reward</a
                    >
                  </li>
                  <li>
                    <a
                      href="#"
                      class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
                      >Promote</a
                    >
                  </li>
                  <li>
                    <a
                      href="#"
                      class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
                      >Activate account</a
                    >
                  </li>
                </ul>
                <div class="py-1">
                  <a
                    href="#"
                    class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600 dark:text-gray-200 dark:hover:text-white"
                    >Delete User</a
                  >
                </div>
              </div>
            </div>
          </div>
          <div
            class="relative overflow-x-auto max-h-80 shadow-md sm:rounded-lg"
          >
            <table
              class="w-full text-sm text-left text-gray-500 dark:text-gray-400"
            >
              <thead
                class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400"
              >
                <tr>
                  <th scope="col" class="p-4">
                    <div class="flex items-center" />
                  </th>
                  <th scope="col" class="px-6 py-3"> Name </th>
                  <th scope="col" class="px-6 py-3"> Status </th>
                  <th scope="col" class="px-6 py-3"> Action </th>
                </tr>
              </thead>
              <tbody>
                {#each users as user}
                  <tr
                    class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
                  >
                    <td class="w-4 p-4">
                      <div class="flex items-center" />
                    </td>
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
                        <div
                          class="h-2.5 w-2.5 rounded-full bg-green-500 mr-2"
                        />
                        Online
                      </div>
                    </td>
                    <td class="px-6 py-4">
                      <Button color="light" on:click={handleAddTeamMember(user)}
                        >Add Player</Button
                      >
                    </td>
                  </tr>
                {/each}
              </tbody>
            </table>
          </div>
        </div>
      {/if}
      {#if teamLength != 0}
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
      {/if}
    </div>
  </div>
</div>
