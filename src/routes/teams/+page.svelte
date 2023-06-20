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

  let searchTerm = "";
  let items = [
    { id: 1, maker: "Toyota", type: "ABC", make: 2017 },
    { id: 2, maker: "Ford", type: "CDE", make: 2018 },
    { id: 3, maker: "Volvo", type: "FGH", make: 2019 },
    { id: 4, maker: "Saab", type: "IJK", make: 2020 },
  ];
  let buttonPositionStyle = "";

  const sortKey = writable("id"); // default sort key
  const sortDirection = writable(1); // default sort direction (ascending)
  const sortItems = writable(items.slice()); // make a copy of the items array

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

  $: filteredItems = items.filter(
    (item) => item.maker.toLowerCase().indexOf(searchTerm.toLowerCase()) !== -1
  );

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

  interface Team {
    name: string;
    owner: string;
    avatar: string;
  }

  let team: Team;

  // $: if ($userData.loggedIn) {
  // console.log(`user: ${$userData.id}`);
  //   fetch(`${PUBLIC_API_URL}/teams/${$userData.id}`)
  //     .then((res) => {
  //         if (res.ok) {
  //             return res.json();
  //         }
  //         return null;
  //     })
  //     .then((data) => {
  //       console.log(data);
  //         team = data !== null ? data.user : data;
  //     });
  // }

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
        <TableHeadCell on:click={() => sortTable("maker")}>Maker</TableHeadCell>
        <TableHeadCell on:click={() => sortTable("type")}>Type</TableHeadCell>
        <TableHeadCell on:click={() => sortTable("make")}>Make</TableHeadCell>
        <TableHeadCell>
          <span class="sr-only"> Edit </span>
        </TableHeadCell>
      </TableHead>
      <TableBody class="divide-y">
        {#each filteredItems as item}
          <TableBodyRow>
            <TableBodyCell>{item.id}</TableBodyCell>
            <TableBodyCell>{item.maker}</TableBodyCell>
            <TableBodyCell>{item.type}</TableBodyCell>
            <TableBodyCell>{item.make}</TableBodyCell>
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
