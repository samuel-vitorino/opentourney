<script lang="ts">
  import {
    Table,
    TableBody,
    TableBodyCell,
    TableBodyRow,
    TableHead,
    TableHeadCell,
    TableSearch,
  } from "flowbite-svelte";
  import { writable } from "svelte/store";
  import { onMount } from "svelte";
  import { userData } from "@src/stores/user";
  import { PUBLIC_API_URL } from "$env/static/public";
  import { goto } from "$app/navigation";

  function isNumber(value?: string | number): boolean {
    return value != null && value !== "" && !isNaN(Number(value.toString()));
  }

  interface Team {
    name: string;
    owner: string;
    avatar: string;
    ownername: string;
  }

  // list of teams
  let teams: Team[] = [];

  // let url = `${PUBLIC_API_URL}`, if userdata.role = 1, then url = `${PUBLIC_API_URL}/teams` else if userdata.role = 2, then url = `${PUBLIC_API_URL}/teams?owner=${$userData.id}`
  console.log(`$userData.role = ${$userData.role}`);

  $: if ($userData.loggedIn) {
    console.log($userData.id);
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
        console.log(data);
        teams = data !== null ? data.teams : data;
      });
  }

  // // Now fetch the API to get the user that created the team using the owner ID from the team and update the teams array with the user's name, the URL is /users/:id
  // teams.forEach((team) => {
  //   fetch(`${PUBLIC_API_URL}/users/${team.owner}`)
  //     .then((res) => {
  //       if (res.ok) {
  //         return res.json();
  //       }
  //       return null;
  //     })
  //     .then((data) => {
  //       team.owner = data !== null ? data.user.name : data.user.name;
  //     });
  // });
  // console.log(teams);

  let searchTerm = "";
  let buttonPositionStyle = "";

  const sortKey = writable("id"); // default sort key
  const sortDirection = writable(1); // default sort direction (ascending)
  const sortItems = writable(teams.slice()); // make a copy of the items array

  // Define a function to sort the items
  const sortTable = (key) => {
    // If the same key is clicked, reverse the sort direction
    if ($sortKey === key) {
      sortDirection.update((val) => -val);
    } else {
      sortKey.set(key);
      sortDirection.set(1);
    }
  };

  $: filteredTeams = teams.filter((team) => {
    return team.name.toLowerCase().includes(searchTerm.toLowerCase());
  });

  $: {
    const key = $sortKey;
    const direction = $sortDirection;
    const sorted = [...$sortItems].sort((a, b) => {
      const aVal = a[key];
      const bVal = b[key];
      if (aVal < bVal) {
        return -direction;
      } else if (aVal > bVal) {
        return direction;
      }
      return 0;
    });
    sortItems.set(sorted);
  }

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
</script>

<div class="flex flex-col w-full shadow-md">
  <div class="box-content p-4">
    <TableSearch
      placeholder="Search by maker name"
      hoverable={true}
      bind:inputValue={searchTerm}
    >
      <TableHead>
        <TableHeadCell on:click={() => sortTable("id")}>ID</TableHeadCell>
        <TableHeadCell on:click={() => sortTable("name")}>Name</TableHeadCell>
        <TableHeadCell on:click={() => sortTable("owner")}>Owner</TableHeadCell>
        <!-- <TableHeadCell on:click={() => sortTable("make")}>Make</TableHeadCell> -->
        <TableHeadCell>
          <span class="sr-only"> Edit </span>
        </TableHeadCell>
      </TableHead>
      <TableBody class="divide-y">
        {#if filteredTeams.length > 0 && isNumber(filteredTeams[0].owner)}
          {#each filteredTeams as team}
            <TableBodyRow>
              <TableBodyCell>{team.id}</TableBodyCell>
              <TableBodyCell>{team.name}</TableBodyCell>
              <TableBodyCell>{team.ownername}</TableBodyCell>
              <!-- <TableBodyCell>{item.make}</TableBodyCell> -->
              <TableBodyCell>
                <a
                  href="/tables"
                  class="font-medium text-primary-600 hover:underline dark:text-primary-500"
                >
                  Edit
                </a>
              </TableBodyCell>
            </TableBodyRow>
          {/each}
        {/if}
      </TableBody>
    </TableSearch>

    <div class="create-button {buttonPositionStyle}">
      <button
        class="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded"
        on:click={() => goto("/teams/new")}
      >
        CREATE
      </button>
    </div>
  </div>
</div>

<style>
  .create-button {
    /* Add any additional styles for the button here */
  }
</style>
