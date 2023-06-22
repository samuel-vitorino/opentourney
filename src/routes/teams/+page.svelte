<script lang="ts">
  import {
    Alert,
    Avatar,
    Badge,
    Button,
    Input,
    Label,
    Modal,
    P,
    Popover,
    Search,
    TableBody,
    TableBodyCell,
    TableBodyRow,
    TableHead,
    TableHeadCell,
    TableSearch,
  } from "flowbite-svelte";
  import { onMount } from "svelte";
  import { userData } from "@src/stores/user";
  import { PUBLIC_API_URL } from "$env/static/public";
  import { toast } from "@zerodevx/svelte-toast";
  import { Trash2Icon } from "svelte-feather-icons";

  function isNumber(value?: string | number): boolean {
    return value != null && value !== "" && !isNaN(Number(value.toString()));
  }

  interface User {
    id: number;
    name: string;
    email: string;
    avatar: string;
    status: number;
  }
  interface Team {
    id: number;
    name: string;
    owner: User;
    avatar: string;
    ownername: string;
    members: User[];
  }

  // list of teams
  let teams: Team[] = [];

  let formModal = false;
  let isEditing = false;
  let teamToEdit = null;
  let editingTeamId = 0;

  $: if ($userData.loggedIn) {
    let url =
      `${PUBLIC_API_URL}/` +
      ($userData.role === 1 ? "teams" : "teams?owner=" + $userData.id);
    fetch(`${url}`)
      .then((res) => {
        if (res.ok) {
          return res.json();
        }
        return null;
      })
      .then((data) => {
        teams = data !== null ? data.teams : data;
      });

    fetch(`${PUBLIC_API_URL}/users?role=${$userData.role}`)
      .then((res) => {
        if (res.ok) {
          return res.json();
        }
        return null;
      })
      .then((data) => {
        users = data !== null ? data.users : data;
      });
  }

  let searchTerm = "";
  let buttonPositionStyle = "";

  $: filteredTeams = teams.filter((team) => {
    return team.name.toLowerCase().includes(searchTerm.toLowerCase());
  });

  onMount(() => {
    // Calculate the scroll height of the page to determine if the button should be fixed at the bottom or not
    const windowHeight = window.innerHeight;
    const pageHeight = document.body.scrollHeight;

    if (pageHeight > windowHeight) {
      buttonPositionStyle = "fixed bottom-8 right-8";
    } else {
      buttonPositionStyle = "absolute bottom-8 right-8";
    }
  });

  let users: User[] = [];

  $: filteredUsers = !users
    ? []
    : users.filter(
        (user) =>
          (teamLength == 0 || !isMember(user)) &&
          user.name.toLowerCase().includes(searchForUsersInput.toLowerCase())
      );

  let files_to_upload: FileList;
  let previewImage: string | null = null;

  // Utilizados no Create Team
  let name = "";

  let owner: User | null = null;
  let avatar: string | null = null;
  let showingAlert = false;
  let isSuccess = false;
  let searchForUsersInput = "";
  let members: User[] = [];

  function handleSetAsTeamOwner(teamMember: User) {
    if ($userData.role == 0 && teamMember.id !== $userData.id) {
      return;
    }
    return () => {
      owner = teamMember;
    };
  }

  const isMember = (user: User | App.UserData) => {
    return members.some((u) => u.id === user.id);
  };

  const handleAddTeamMember = (user: User) => {
    if (isMember(user)) {
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
    members = [...members, user];
  };

  const handleRemoveTeamMember = (user: User) => {
    if ($userData.role == 0 && user.id === $userData.id) {
      return;
    }

    if (owner && user.id === owner.id) {
      owner = null;
    }

    members = members.filter((u) => u !== user);
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

  $: teamLength = members.length;
  $: teamIsFull = teamLength === 5;

  const handleCreateButtonClick = () => {
    formModal = true;
    isEditing = false;
    name = "";

    if ($userData.role === 1) {
      owner = null;
      members = [];
    } else {
      if (isMember($userData)) {
        return;
      }
      owner = { ...$userData } as User;
      members = [...members, $userData] as User[];
    }
  };

  const handleEditingButtonClick = (team: Team) => {
    formModal = true;
    isEditing = true;
    editingTeamId = team.id;

    owner = team.owner;
    name = team.name;
    avatar = team.avatar;
    members = [...team.members];
  };

  async function handleCancel(event: Event) {
    event.preventDefault();
    owner = null;
    name = "";
    avatar = null;
    members = [];
    formModal = false;
    editingTeamId = 0;
  }

  // const handleUpdateTeam() {
  //   return async (event) => {
  //     event.preventDefault();

  //   };
  // }

  async function handleSubmit(event: Event) {
    event.preventDefault();
    let id = editingTeamId;
    if (isEditing) {
      try {
        console.log("Editing team");
        console.log(JSON.stringify({ team: { owner, name, avatar, members } }));

        const response = await fetch(`${PUBLIC_API_URL}/teams/${id}`, {
          method: "PUT",
          credentials: "include",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            team: { id, owner, name, avatar, members },
          }),
        });

        console.log("FEZ O PEDIDO");

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
    } else {
      try {
        const response = await fetch(`${PUBLIC_API_URL}/teams`, {
          method: "POST",
          credentials: "include",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ team: { owner, name, avatar, members } }),
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
  }
</script>

<div class="flex flex-col w-full shadow-md">
  <div class="box-content p-4">
    <TableSearch
      placeholder="Search by maker name"
      hoverable={true}
      bind:inputValue={searchTerm}
    >
      <TableHead>
        <TableHeadCell>ID</TableHeadCell>
        <TableHeadCell>Name</TableHeadCell>
        <TableHeadCell>Owner</TableHeadCell>
        <!-- <TableHeadCell on:click={() => sortTable("make")}>Make</TableHeadCell> -->
        <TableHeadCell>
          <span class="sr-only"> Edit </span>
        </TableHeadCell>
      </TableHead>
      <TableBody>
        {#if filteredTeams.length > 0}
          {#each filteredTeams as team}
            <TableBodyRow>
              <TableBodyCell>{team.id}</TableBodyCell>
              <TableBodyCell>{team.name}</TableBodyCell>
              <TableBodyCell>{team.owner.name}</TableBodyCell>
              <!-- <TableBodyCell>{item.make}</TableBodyCell> -->
              <TableBodyCell>
                <Button
                  color="light"
                  on:click={() => handleEditingButtonClick(team)}>Edit</Button
                >
              </TableBodyCell>
            </TableBodyRow>
          {/each}
        {/if}
      </TableBody>
    </TableSearch>

    <div class="create-button {buttonPositionStyle}">
      <button
        class="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded"
        on:click={handleCreateButtonClick}
      >
        CREATE
      </button>
    </div>
    <Modal bind:open={formModal} size="lg" autoclose={false} class="w-full">
      <form class="flex flex-col grow justify-between" on:submit={handleSubmit}>
        <div class="mb-6">
          <Label for="teamName" class="block mb-2">Team Name</Label>
          <Input
            id="teamName"
            type="text"
            size="lg"
            placeholder="Team's Name"
            required
            bind:value={name}
          />
        </div>
        <div>
          <div class="flex flex-row justify-center items-center mt-16 mb-10">
            {#if teamLength != 0}
              {#each members as teamMember}
                <div class="relative mb-2 mx-2 text-center dark:text-white">
                  <button
                    type="button"
                    on:click={handleSetAsTeamOwner(teamMember)}
                  >
                    <Avatar
                      id="avatar-menu"
                      class="w-[100px] h-[100px] cursor-pointer"
                      src={teamMember.avatar ?? avatar}
                    />
                  </button>
                  {#if owner && owner.id === teamMember.id}
                    <P
                      size="xl"
                      color="text-white"
                      align="center"
                      class="flex w-[35px] h-[35px] box-content p-1 absolute -top-2 -right-2 justify-center items-center"
                      id="owner"
                    >
                      <svg
                        version="1.1"
                        id="_x32_"
                        xmlns="http://www.w3.org/2000/svg"
                        xmlns:xlink="http://www.w3.org/1999/xlink"
                        viewBox="0 0 512 512"
                        xml:space="preserve"
                        fill="#e3a008"
                        stroke="#e3a008"
                        ><g id="SVGRepo_bgCarrier" stroke-width="0" /><g
                          id="SVGRepo_tracerCarrier"
                          stroke-linecap="round"
                          stroke-linejoin="round"
                        /><g id="SVGRepo_iconCarrier">
                          <style type="text/css">
                            .st0 {
                              fill: #e3a008;
                            }
                          </style>
                          <g>
                            <path
                              class="st0"
                              d="M512,152.469c0-21.469-17.422-38.875-38.891-38.875c-21.484,0-38.906,17.406-38.906,38.875 c0,10.5,4.172,20.016,10.938,27c-26.453,54.781-77.016,73.906-116.203,56.594c-34.906-15.438-47.781-59.563-52.141-93.75 c14.234-7.484,23.938-22.391,23.938-39.594C300.734,78.016,280.719,58,256,58c-24.703,0-44.734,20.016-44.734,44.719 c0,17.203,9.703,32.109,23.938,39.594c-4.359,34.188-17.234,78.313-52.141,93.75c-39.188,17.313-89.75-1.813-116.203-56.594 c6.766-6.984,10.938-16.5,10.938-27c0-21.469-17.422-38.875-38.891-38.875C17.422,113.594,0,131,0,152.469 c0,19.781,14.781,36.078,33.875,38.547l44.828,164.078h354.594l44.828-164.078C497.234,188.547,512,172.25,512,152.469z"
                            />
                            <path
                              class="st0"
                              d="M455.016,425.063c0,15.984-12.953,28.938-28.953,28.938H85.938C69.953,454,57,441.047,57,425.063v-2.406 c0-16,12.953-28.953,28.938-28.953h340.125c16,0,28.953,12.953,28.953,28.953V425.063z"
                            />
                          </g>
                        </g></svg
                      >
                      <!-- <StarIcon class="w-[35px] h-[35px] text-yellow-400 m-0" /> -->
                    </P>
                    <Popover
                      class="w-40 text-sm font-light "
                      title="Team Owner"
                      triggeredBy="#owner"
                      placement="top"
                    >
                      {teamMember.email}
                    </Popover>
                  {:else if teamMember.status === 0}
                    <P
                      size="xl"
                      color="text-white"
                      align="center"
                      class="flex w-[35px] h-[35px] box-content p-1 absolute justify-center items-center text-yellow-400 -top-4 mx-auto left-0 right-0"
                      id="pending"
                    >
                      <Badge class="m-auto my-2" rounded color="yellow">
                        Pending</Badge
                      >
                    </P>
                    <Popover
                      class="w-60 text-sm font-light "
                      title="Request Pending"
                      triggeredBy="#pending"
                      placement="top"
                    >
                      {"A request has been sent to " + teamMember.email}
                    </Popover>
                  {/if}

                  {#if owner && owner.id === teamMember.id}
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
                    class={$userData.role === 0 &&
                    owner &&
                    owner.id === teamMember.id
                      ? "scale-0"
                      : ""}
                    on:click={() => handleRemoveTeamMember(teamMember)}
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

          <div class="flex gap-2">
            <Search
              size="md"
              bind:value={searchForUsersInput}
              on:keydown={(event) =>
                event.key === "Enter" && event.preventDefault()}
            />
          </div>
          {#if showingAlert}
            {#if isSuccess}
              <Alert
                color="green"
                class="alert {showingAlert ? 'show' : 'hidden'}"
              >
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

          {#if filteredUsers}
            <div
              class="relative p-4 my-4 max-h-80 overflow-auto shadow-md sm:rounded-lg"
            >
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
                          <div
                            class="h-2.5 w-2.5 rounded-full bg-green-500 mr-2"
                          />
                          Online
                        </div>
                      </td>
                      <td class="px-6 py-4">
                        <Button
                          type="button"
                          color="light"
                          on:click={() => handleAddTeamMember(user)}
                          bind:disabled={teamIsFull}>Add Player</Button
                        >
                      </td>
                    </tr>
                  {/each}
                </tbody>
              </table>
            </div>
          {/if}
        </div>
        <div class="flex">
          <Button class="mt-4 mx-auto" type="button" on:click={handleCancel}
            >Cancel</Button
          >
          {#if isEditing}
            <Button class="mt-4 mx-auto" type="submit">Update</Button>
          {:else}
            <Button class="mt-4 mx-auto" type="submit">Create</Button>
          {/if}
        </div>
      </form>
    </Modal>
  </div>
</div>
