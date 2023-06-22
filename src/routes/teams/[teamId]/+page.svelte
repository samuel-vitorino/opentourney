<script lang="ts">
  import {
    Input,
    Label,
    Button,
    Heading,
    P,
    Avatar,
    Popover,
    Badge,
  } from "flowbite-svelte";
  import { page } from "$app/stores";
  import { onMount } from "svelte";
  import { PUBLIC_API_URL } from "$env/static/public";
  import { goto } from "$app/navigation";

  const teamId = Number($page.params.teamId);

  interface User {
    id: number;
    name: string;
    email: string;
    avatar: string;
    status: number;
  }
  interface Team {
    name: string;
    owner: User;

    avatar: string;
    ownername: string;
    members: User[];
  }

  // list of teams
  let team: Team;

  onMount(async () => {
    const res = await fetch(`${PUBLIC_API_URL}/teams/${teamId}`)
      .then((res) => {
        if (res.ok) {
          return res.json();
        }
        return null;
      })
      .then((data) => {
        team = data !== null ? data.team : data;
        console.log(team.members);
      });
  });
</script>

<div class="flex flex-col w-full shadow-md">
  <div class="flex flex-col box-content p-4 grow">
    <Heading tag="h1" class="text-center">{team?.name}</Heading>
    <div class="flex flex-row justify-center pt-10">
      <Avatar
        id="avatar-menu"
        class="cursor-pointer"
        size="xl"
        src={team?.avatar ?? ""}
      />
    </div>
    <div class="flex flex-col grow justify-between">
      <div>
        <div class="flex flex-row justify-center items-center mt-16 mb-10">
          {#if team}
            {#each team.members as member}
              <div class="relative mb-2 mx-2 text-center dark:text-white">
                <Avatar
                  id="avatar-menu"
                  class="w-[100px] h-[100px] cursor-pointer"
                  src={member.avatar ?? ""}
                />
              </div>

              {#if team?.owner.id === member.id}
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
                  {member.email}
                </Popover>
              {:else if member.status === 0}
                <P
                  size="xl"
                  color="text-white"
                  align="center"
                  class="flex w-[35px] h-[35px] box-content p-1 absolute justify-center items-center text-yellow-400 -top-4 mx-auto left-0 right-0"
                  id="pending"
                >
                  <Badge class="m-auto my-2" rounded color="yellow"
                    >Pending</Badge
                  >
                </P>
              {/if}

              {#if team?.owner.id === member.id}
                <div class="text-base font-semibold mb-2 text-yellow-400">
                  {member.name}
                </div>
                <div class="text-base font-semibold mb-2 text-yellow-400">
                  {member.email}
                </div>
              {:else}
                <div class="text-base font-semibold mb-2">
                  {member.name}
                </div>
                <div class="text-base font-semibold mb-2">
                  {member.email}
                </div>
              {/if}
            {/each}
          {/if}
        </div>
      </div>
    </div>
  </div>
</div>
