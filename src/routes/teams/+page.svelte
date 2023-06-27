<script lang="ts">
  import {
    Alert,
    Avatar,
    Badge,
    Button,
    Fileupload,
    Heading,
    Input,
    Label,
    Modal,
    P,
    Popover,
    Search,
    Table,
    TableBody,
    TableBodyCell,
    TableBodyRow,
  } from "flowbite-svelte";
  import { onMount } from "svelte";
  import { userData } from "@src/stores/user";
  import { PUBLIC_API_URL } from "$env/static/public";
  import { toast } from "@zerodevx/svelte-toast";
  import { Trash2Icon } from "svelte-feather-icons";
  import { goto } from "$app/navigation";

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
  let editingTeamId = 0;

  // let url =
  //     `${PUBLIC_API_URL}/` +
  //     ($userData.role === 1 ? "teams" : "teams?owner=" + $userData.id);

  // let url =
  //     `${PUBLIC_API_URL}/` +
  //     ($userData.role === 1 ? "teams" : "teams?user=" + $userData.id);

  const getTeams = async () => {
    let url =
      `${PUBLIC_API_URL}/` +
      ($userData.role === 1 ? "teams" : "teams?user=" + $userData.id);
    fetch(`${url}`)
      .then((res) => {
        if (res.ok) {
          return res.json();
        }
        return null;
      })
      .then((data) => {
        teams = data !== null ? data.teams : data;
        console.log(teams);
      });
  };

  $: if ($userData.loggedIn) {
    getTeams();

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

  let fileuploadprops = {
    id: "team_avatar",
  };

  let files_to_upload: FileList;
  let image_to_upload: string;
  let previewImage: string | null = null;

  const handleAvatarChange = (e: Event) => {
    const files = (<HTMLInputElement>e.target).files;

    if (files === null || files.length <= 0) {
      return;
    }

    files_to_upload = files;

    const reader = new FileReader();
    reader.readAsDataURL(files[0]);
    reader.onload = function () {
      previewImage = <string>reader.result;
      image_to_upload = <string>reader.result;
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

  const handleEditingButtonClick = (e: Event, team: Team) => {
    e.stopPropagation();

    if ($userData.role === 0 && team.owner.id !== $userData.id) {
      return;
    }

    formModal = true;
    isEditing = true;
    editingTeamId = team.id;

    owner = team.owner;
    name = team.name;
    avatar = team.avatar;
    members = [...team.members];
  };

  const handleDeleteButton = async (e: Event, team: Team) => {
    e.stopPropagation();

    if ($userData.role === 0 && team.owner.id !== $userData.id) {
      return;
    }

    const res = await fetch(`${PUBLIC_API_URL}/teams/${team.id}`, {
      method: "DELETE",
    }).then((res) => {
      if (res.ok) {
        getTeams();
        // return res.json();
        // goto("/teams", { replaceState: true });
      }
      return null;
    });
  };

  async function handleCancel(event: Event) {
    event.preventDefault();
    previewImage = null;
    owner = null;
    name = "";
    avatar = null;
    members = [];
    formModal = false;
    editingTeamId = 0;
  }

  async function handleSubmit(event: Event) {
    event.preventDefault();
    let id = editingTeamId;
    if (isEditing) {
      try {
        fetch(`${PUBLIC_API_URL}/teams/${id}`, {
          method: "PUT",
          credentials: "include",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            team: {
              id,
              owner,
              name,
              avatar: image_to_upload ?? avatar,
              members,
            },
          }),
        }).then((res) => {
          if (res.ok) {
            toast.push("Team edited successfully!", {
              theme: {
                "--toastColor": "mintcream",
                "--toastBackground": "rgb(72,187,120)",
                "--toastBarBackground": "#2F855A",
              },
            });

            showingAlert = true;
            formModal = false;
            getTeams();
          }
        });
      } catch (error) {
        console.log(error);
      }
    } else {
      try {
        console.log("POST", { owner, name, avatar: image_to_upload, members });

        fetch(`${PUBLIC_API_URL}/teams`, {
          method: "POST",
          credentials: "include",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            team: { owner, name, avatar: image_to_upload ?? avatar, members },
          }),
        }).then((res) => {
          if (res.ok) {
            toast.push("Team created successfully!", {
              theme: {
                "--toastColor": "mintcream",
                "--toastBackground": "rgb(72,187,120)",
                "--toastBarBackground": "#2F855A",
              },
            });

            showingAlert = true;
            formModal = false;
            getTeams();
          }
        });
      } catch (error) {
        console.log(error);
      }
    }
  }
</script>

<div class="flex flex-col w-full shadow-md">
  <div class="box-content p-4">
    <Heading
      class="mb-3"
      customSize="text-2xl font-extrabold mb-4 md:text-3xl lg:text-4xl"
      >Teams
    </Heading>

    <div class="flex justify-between mb-2">
      <div class="w-4/12">
        <Search size="md" bind:value={searchTerm} />
      </div>
      <Button size="md" on:click={() => handleCreateButtonClick()}
        >Create <svg
          aria-hidden="true"
          class="ml-2 -mr-1 w-5 h-5"
          fill="currentColor"
          viewBox="0 0 20 20"
          xmlns="http://www.w3.org/2000/svg"
          ><path
            fill-rule="evenodd"
            d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z"
            clip-rule="evenodd"
          /></svg
        ></Button
      >
    </div>

    <div
      class="shadow-md sm:rounded-lg overflow-y-auto h-[calc(100vh-200px)] custom-scrollbar"
    >
      <Table hoverable={true}>
        <TableBody>
          {#if filteredTeams.length > 0}
            {#each filteredTeams as team}
              <TableBodyRow on:click={() => goto(`/teams/${team.id}`)}>
                <TableBodyCell>
                  <div class="flex flex-row gap-2 text-center">
                    <P size="xl">{team.name}</P>
                    <P size="xs" weight="semibold">{team.owner.name}</P>
                  </div>
                </TableBodyCell>

                <TableBodyCell>
                  <div class="flex flex-row gap-1">
                    {#each team.members as member}
                      <Avatar
                        id="avatar-menu"
                        class="cursor-pointer"
                        src={member.avatar !== null
                          ? `${PUBLIC_API_URL.replace("/api", "/images")}/${
                              member.avatar
                            }`
                          : undefined}
                      />
                    {/each}
                  </div>
                </TableBodyCell>

                <TableBodyCell
                  class="flex flex-row m-auto content-end gap-2 justify-end"
                >
                  <Button
                    color="light"
                    class={$userData.role != 1 && team.owner.id !== $userData.id
                      ? "hidden"
                      : ""}
                    on:click={(e) => handleEditingButtonClick(e, team)}
                    >Edit</Button
                  >
                  <Button
                    color="light"
                    class={$userData.role != 1 && team.owner.id !== $userData.id
                      ? "hidden"
                      : ""}
                    on:click={(e) => handleDeleteButton(e, team)}>DELETE</Button
                  >
                </TableBodyCell>
              </TableBodyRow>
            {/each}
          {/if}
        </TableBody>
      </Table>
    </div>

    <Modal
      permanent
      bind:open={formModal}
      size="lg"
      autoclose={false}
      class="w-full"
    >
      <form
        class="flex flex-col grow justify-between"
        id="newTeamForm"
        on:submit={handleSubmit}
      >
        <div class="flex flex-col items-center mb-6">
          <!-- <Avatar
            class="w-[250px] h-[250px] cursor-pointer"
            src={avatar !== null
              ? `${PUBLIC_API_URL.replace("/api", "/images")}/${avatar}`
              : undefined}
          /> -->
          <img
            id="avatar-menu"
            class="w-full h-[250px] rounded-sm mb-2"
            src={previewImage !== null
              ? previewImage
              : avatar
              ? `${PUBLIC_API_URL.replace("/api", "/images")}/${avatar}`
              : "/images/placeholder.png"}
            alt="Tournament Avatar"
          />
          <Fileupload
            class="mt-6"
            bind:files={files_to_upload}
            accept="image/jpeg, image/png"
            on:change={handleAvatarChange}
            {...fileuploadprops}
          />
        </div>
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
          <div class="flex flex-row justify-center items-center my-10">
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
                      src={teamMember.avatar !== null
                        ? `${PUBLIC_API_URL.replace("/api", "/images")}/${
                            teamMember.avatar
                          }`
                        : undefined}
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
                          src={user.avatar !== null
                            ? `${PUBLIC_API_URL.replace("/api", "/images")}/${
                                user.avatar
                              }`
                            : undefined}
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
      </form>
      <svelte:fragment slot="footer">
        <div class="flex flex-row gap-5 grow">
          <Button class="w-full" type="button" on:click={handleCancel}
            >Cancel</Button
          >
          <Button class="w-full" type="submit" form="newTeamForm"
            >{isEditing ? "Update" : "Create new Team"}</Button
          >
        </div>
      </svelte:fragment>
    </Modal>
  </div>
</div>
