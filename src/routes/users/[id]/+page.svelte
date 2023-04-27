<script lang="ts">
  import type { PageData } from "./$types";
  import {
    P,
    Popover,
    Avatar,
    Card,
    Table,
    TableBody,
    TableBodyCell,
    TableBodyRow,
    TableHead,
    TableHeadCell,
  } from "flowbite-svelte";
  import "@styles/home.scss";

  export let data: PageData;

  const getDate = (s: string) => {
    const d = new Date(s);
    const monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return `${d.getDay()} ${monthNames[d.getMonth()]} ${d.getFullYear()}`;
  };
</script>

<div class="flex flex-col w-full shadow-md">
  <div class="box-content p-4">
    <div>
      <div class="flex flex-row">
        <div class="relative">
          <Avatar
            id="avatar-menu"
            class="w-[150px] h-[150px] rounded-sm"
            src={data.user.avatar ?? ""}
          />
          <P
            size="xl"
            color="text-white"
            align="center"
            class="bg-sky-500 rounded-full w-[30px] h-[30px] box-content p-1 absolute -top-3 -right-3"
            id="role"
            >{data.user.role === 0 ? "S" : "D"}</P
          >
          <Popover
            class="w-64 text-sm font-light "
            title="User Role"
            triggeredBy="#role"
            placement="right"
          >
            {data.user.role == 0 ? "This user is a standard user with default permissions" : "This user is a platform developer"}
          </Popover>
        </div>
        <div class="self-end">
          <P size="4xl" class="ml-3">{data.user.name ?? ""}</P>
          <P size="xl" class="ml-3"
            >Member since {getDate(data.user.createdAt)}</P
          >
        </div>
      </div>
      <div />
    </div>
    <hr class="mt-5 mb-5" />
    <div>
      <div class="flex">
        <caption
          class="pb-5 pl-5 text-lg font-semibold text-left text-gray-900 bg-white dark:text-white dark:bg-gray-800 grow"
          >Individual Statistics</caption
        >
      </div>
      <div class="flex flex-row justify-around">
        <Card class="grow mr-3">
          <h5
            class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white"
          >
            Maps played
          </h5>
          <p class="font-normal text-gray-700 dark:text-gray-400 leading-tight">
            25
          </p>
        </Card>
        <Card class="grow mr-3">
          <h5
            class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white"
          >
            K/D
          </h5>
          <p class="font-normal text-gray-700 dark:text-gray-400 leading-tight">
            1.5
          </p>
        </Card>
        <Card class="grow mr-3">
          <h5
            class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white"
          >
            K/R
          </h5>
          <p class="font-normal text-gray-700 dark:text-gray-400 leading-tight">
            1.5
          </p>
        </Card>
        <Card class="grow mr-3">
          <h5
            class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white"
          >
            Headshot %
          </h5>
          <p class="font-normal text-gray-700 dark:text-gray-400 leading-tight">
            53%
          </p>
        </Card>
        <Card class="grow">
          <h5
            class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white"
          >
            Favourite Weapon
          </h5>
          <p class="font-normal text-gray-700 dark:text-gray-400 leading-tight">
            AK-47
          </p>
        </Card>
      </div>
    </div>
    <div>
      <div class="flex">
        <caption
          class="p-5 text-lg font-semibold text-left text-gray-900 bg-white dark:text-white dark:bg-gray-800 grow"
          >Tournament Statistics</caption
        >
      </div>
      <div class="flex flex-row justify-around">
        <Card class="grow mr-3">
          <h5
            class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white"
          >
            Tournaments played
          </h5>
          <p class="font-normal text-gray-700 dark:text-gray-400 leading-tight">
            10
          </p>
        </Card>
        <Card class="grow mr-3">
          <h5
            class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white"
          >
            First Places
          </h5>
          <p class="font-normal text-gray-700 dark:text-gray-400 leading-tight">
            2
          </p>
        </Card>
        <Card class="grow mr-3">
          <h5
            class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white"
          >
            Second Places
          </h5>
          <p class="font-normal text-gray-700 dark:text-gray-400 leading-tight">
            5
          </p>
        </Card>
        <Card class="grow">
          <h5
            class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white"
          >
            Third places
          </h5>
          <p class="font-normal text-gray-700 dark:text-gray-400 leading-tight">
            3
          </p>
        </Card>
      </div>
    </div>
    <Table>
      <caption
        class="p-5 text-lg font-semibold text-left text-gray-900 bg-white dark:text-white dark:bg-gray-800"
      >
        Ongoing tournaments
      </caption>
      <TableHead>
        <TableHeadCell>Name</TableHeadCell>
        <TableHeadCell>Team</TableHeadCell>
        <TableHeadCell>Game</TableHeadCell>
        <TableHeadCell>Start Date</TableHeadCell>
        <TableHeadCell>
          <span class="sr-only"> Edit </span>
        </TableHeadCell>
      </TableHead>
      <TableBody tableBodyClass="divide-y">
        <TableBodyRow>
          <TableBodyCell>Leiria Esports"</TableBodyCell>
          <TableBodyCell>Maceira</TableBodyCell>
          <TableBodyCell>CS:GO</TableBodyCell>
          <TableBodyCell>10/05/2020</TableBodyCell>
          <TableBodyCell>
            <a
              href="/tables"
              class="font-medium text-blue-600 hover:underline dark:text-blue-500"
            >
              Edit
            </a>
          </TableBodyCell>
        </TableBodyRow>
        <TableBodyRow>
          <TableBodyCell>Lisboa Esports"</TableBodyCell>
          <TableBodyCell>Maceira</TableBodyCell>
          <TableBodyCell>CS:GO</TableBodyCell>
          <TableBodyCell>10/05/2020</TableBodyCell>
          <TableBodyCell>
            <a
              href="/tables"
              class="font-medium text-blue-600 hover:underline dark:text-blue-500"
            >
              Edit
            </a>
          </TableBodyCell>
        </TableBodyRow>
      </TableBody>
    </Table>
  </div>
</div>
