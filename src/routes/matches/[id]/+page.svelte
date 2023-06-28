<script lang="ts">
  import {
    Tabs,
    TabItem,
    P,
    Table,
    TableBody,
    TableBodyCell,
    TableBodyRow,
    TableHead,
    TableHeadCell,
    Button,
  } from "flowbite-svelte";
  import type { PageData } from "./$types";
  import { PUBLIC_API_URL, PUBLIC_WSURL } from "$env/static/public";
  import { onMount } from "svelte";
  import { Socket, io } from "socket.io-client";
  import { userData } from "@src/stores/user";

  interface User {
    id: number;
    avatar: string;
    email: string;
    status: number;
    name: string;
  }

  interface Team {
    id: number;
    name: string;
    avatar: string;
    members: Array<User>;
    owner: User;
  }

  interface Game {
    status: number;
    team_one_score: number;
    team_two_score: number;
    order: number;
    map: string;
  }

  interface Match {
    id: number;
    team_one_name: string;
    team_two_name: string;
    type: number;
    games: Game[];
    createdAt: string;
    status: number;
    score: [number, number];
    connect_ip: string;
    teams: Array<Team>;
  }

  interface VetoStatus {
    status: number;
    matchType: number;
    maps: string[];
    team1Bans: string[];
    team2Bans: string[];
    team1Picks: string[];
    team2Picks: string[];
    finalized: boolean;
    finalMap: string | null;
  }

  let currentVetoStatus: VetoStatus;
  let socket: Socket;

  onMount(() => {
    if (match.status == 0) {
      socket = io(PUBLIC_WSURL, { rejectUnauthorized: false });

      socket.on("connect", () => {
        console.log("Socket.IO connected");
        socket.emit("joinMatchRoom", match.id);
      });

      socket.on("vetoStatus", (status: VetoStatus) => {
        currentVetoStatus = status;

        if (currentVetoStatus.status == 4) {
          updateMatch();
        }
      });
    }
  });

  export let data: PageData;
  let match = data.match as Match;
  let imOwner: boolean;
  let myTeam: number;

  let breakNow = false;

  $: {
    for (let i = 0; i < match.teams.length; i++) {
      for (let j = 0; j < match.teams[i].members.length; j++) {
        if (match.teams[i].owner.id == $userData.id) {
          imOwner = true;
          myTeam = i;
          breakNow = true;
          break;
        }
      }

      if (breakNow) {
        break;
      }
    }
  }

  let myTurn: boolean;

  $: {
    if (
      typeof imOwner != undefined &&
      typeof myTeam != undefined &&
      match &&
      match.status == 0 &&
      currentVetoStatus
    ) {
      if (
        imOwner &&
        myTeam == 0 &&
        (currentVetoStatus.status == 0 || currentVetoStatus.status == 1)
      ) {
        myTurn = true;
      } else if (
        imOwner &&
        myTeam == 1 &&
        (currentVetoStatus.status == 2 || currentVetoStatus.status == 3)
      ) {
        myTurn = true;
      } else {
        myTurn = false;
      }
    }
  }

  const sendPickBan = (action: string, map: string) => {
    socket.emit("vetoPickBan", match.id, action, map);
  };

  const vetoStatusToString = (s: number, owner: boolean) => {
    if (s == 0) {
      if (owner && myTeam == 0) {
        return "Your turn to ban a map";
      } else {
        return `Captain of team ${match.team_one_name} is banning`;
      }
    } else if (s == 1) {
      if (owner && myTeam == 0) {
        return "Your turn to pick a map";
      } else {
        return `Captain of team ${match.team_one_name} is picking`;
      }
    } else if (s == 2) {
      if (owner && myTeam == 1) {
        return "Your turn to ban a map";
      } else {
        return `Captain of team ${match.team_two_name} is banning`;
      }
    } else if (s == 3) {
      if (owner && myTeam == 1) {
        return "Your turn to pick a map";
      } else {
        return `Captain of team ${match.team_two_name} is picking`;
      }
    }
  };

  const updateMatch = () => {
    fetch(`${PUBLIC_API_URL}/matches/${match.id}`, {
      credentials: "include",
    })
      .then((res) => {
        if (res.ok) {
          return res.json();
        }
        return null;
      })
      .then((data) => {
        let matchGames: Game[] = [];

        data.match.games.forEach((g: Game) => {
            matchGames[g.order] = g;
        });

        data.match.games = matchGames!;

        match = data.match;

        updateMatchScore();
      });
  };

  const updateMatchScore = () => {
    match.score = [0, 0];
    if (match.games) {
      match.games.forEach((g) => {
        if (g.team_one_score == 16) {
          match.score[0] += 1;
        }
        if (g.team_two_score == 16) {
          match.score[1] += 1;
        }
      });
    }
  };

  match.teams.forEach((t) => {
    t.members.forEach((m) => {
      if (m.id == $userData.id) {
        imOwner = true;
      }
    });
  });

  updateMatchScore();
</script>

<div class="flex flex-col w-full shadow-md">
  <div class="box-content p-4">
    <Tabs style="underline">
      <TabItem open>
        <div slot="title" class="flex items-center gap-2">Overview</div>
        <div class="flex justify-center h-[120px]">
          <div class="flex items-center mr-5">
            <P weight="semibold" class="mr-3">{match.team_one_name}</P>
            <img
              class="w-10 h-10 rounded-full"
              src={match.teams[0].avatar
                ? `${PUBLIC_API_URL.replace("/api", "/backend-images")}/${
                    match.teams[0].avatar
                  }`
                : "/images/placeholder.png"}
              alt="Jese"
            />
          </div>
          <div class="flex items-center">
            <P
              color={match.score[0] > match.score[1]
                ? "text-green-500"
                : "text-gray-600"}
              class="mr-5"
              size="3xl"
              weight="bold">{match.score[0]}</P
            >
            <div class="flex flex-col items-center mr-5">
              <P size="sm">5v5</P>
              <P weight="semibold"
                >{match.status == 0
                  ? "Veto phase"
                  : match.status == 1
                  ? "Ongoing"
                  : "Finished"}</P
              >
              <P size="xs">{match.type == 0 ? "Best of 1" : "Best of 3"}</P>
            </div>
            <P
              weight="bold"
              color={match.score[0] < match.score[1]
                ? "text-green-500"
                : "text-gray-600"}
              size="3xl">{match.score[1]}</P
            >
          </div>
          <div class="flex items-center ml-5">
            <img
              class="w-10 h-10 rounded-full"
              src={match.teams[1].avatar
                ? `${PUBLIC_API_URL.replace("/api", "/backend-images")}/${
                    match.teams[1].avatar
                  }`
                : "/images/placeholder.png"}
              alt="Jese"
            />
            <P weight="semibold" class="ml-3">{match.team_two_name}</P>
          </div>
        </div>
        <hr class="mt-5 mb-5" />
        <div class="flex justify-between">
          <div class="flex flex-col w-[350px] h-[380px] justify-between">
            {#each match.teams[0].members as m}
              <div class="flex items-center box-content p-3 rounded-md border">
                <P weight="semibold" class="mr-3">{m.name}</P>
                <img
                  class="w-10 h-10 rounded-full"
                  src={m.avatar
                    ? `${PUBLIC_API_URL.replace("/api", "/backend-images")}/${
                        m.avatar
                      }`
                    : "/images/placeholder.png"}
                  alt="Profile avatar"
                />
              </div>
            {/each}
          </div>
          <div>
            {#if match.status == -1}
              <div>
                <P weight="semibold">Waiting for match to start</P>
              </div>
            {:else if match.status == 0 && currentVetoStatus}
              <div
                class="flex flex-col justify-between items-center h-[430px] mb-5"
              >
                {#if currentVetoStatus && currentVetoStatus.status != 4}
                  <P class="mb-3"
                    >{vetoStatusToString(currentVetoStatus.status, imOwner)}</P
                  >
                {/if}
                {#each currentVetoStatus.maps as m, i}
                  <div
                    class="flex w-[350px] h-[20px] bg-gray-200 box-content justify-between justify-center rounded-md p-4"
                  >
                    <div class="flex items-center">
                      <img
                        src={`/images/${m}.jpg`}
                        class="mr-5 w-[60px] h-[40px] rounded-md"
                        alt="Server location flag"
                      />
                      <P weight="semibold" size="sm">{m}</P>
                    </div>
                    {#if currentVetoStatus.team1Bans.includes(m)}
                      <P>Banned by {match.team_one_name}</P>
                    {:else if currentVetoStatus.team2Bans.includes(m)}
                      <P>Banned by {match.team_two_name}</P>
                    {:else if currentVetoStatus.team1Picks.includes(m)}
                      <P>Picked by {match.team_one_name}</P>
                    {:else if currentVetoStatus.team2Picks.includes(m)}
                      <P>Picked by {match.team_two_name}</P>
                    {:else if currentVetoStatus.finalMap && currentVetoStatus.finalMap == m}
                      <P>Left out</P>
                    {:else if myTurn}
                      {#if currentVetoStatus.status == 0 || currentVetoStatus.status == 2}
                        <Button
                          color="red"
                          on:click={() => sendPickBan("ban", m)}>Ban</Button
                        >
                      {:else if currentVetoStatus.status == 1 || currentVetoStatus.status == 3}
                        <Button
                          color="green"
                          on:click={() => sendPickBan("pick", m)}>Pick</Button
                        >
                      {/if}
                    {/if}
                  </div>
                {/each}
              </div>
            {:else if match.status == 1}
              <P weight="semibold" size="sm" class="mb-2">Ip address</P>
              <div
                class="flex flex-col w-[350px] h-[20px] bg-gray-200 box-content justify-center rounded-md p-4"
              >
                <P
                  >{match.connect_ip
                    ? match.connect_ip
                    : "Waiting for match ip..."}</P
                >
              </div>
              <P weight="semibold" size="sm" class="mt-5 mb-2"
                >Map{match.games.length > 1 ? "s" : ""}</P
              >
              {#each match.games as g}
                <div
                  class="flex flex-col w-[350px] h-[20px] bg-gray-200 box-content justify-center rounded-md p-4 mb-2"
                >
                  <div class="flex items-center">
                    <img
                      src={`/images/${g.map}.jpg`}
                      class="mr-5 w-[60px] h-[40px] rounded-md"
                      alt="Server location flag"
                    />
                    <P weight="semibold" size="sm">{g.map}</P>
                  </div>
                </div>
              {/each}
            {:else if match.status == 2}
              <P weight="semibold" size="sm" class="mt-5 mb-2">Maps</P>
              {#each match.games as g}
                <div
                  class="flex flex-col w-[350px] h-[20px] bg-gray-200 box-content justify-center rounded-md p-4 mb-2"
                >
                  <div class="flex items-center">
                    <img
                      src={`/images/${g.map}.jpg`}
                      class="mr-5 w-[60px] h-[40px] rounded-md"
                      alt="Server location flag"
                    />
                    <P weight="semibold" size="sm">{g.map}</P>
                  </div>
                </div>
              {/each}
              <div class="w-full flex justify-center mt-[50px]">
                <P weight="semibold" size="sm" color="text-orange-500"
                  >WATCH DEMO</P
                >
              </div>
            {/if}
          </div>
          <div class="flex flex-col w-[350px] h-[380px] justify-between">
            {#each match.teams[1].members as m}
              <div
                class="flex items-center justify-end box-content p-3 rounded-md border"
              >
                <img
                  class="w-10 h-10 rounded-full"
                  src={m.avatar
                    ? `${PUBLIC_API_URL.replace("/api", "/backend-images")}/${
                        m.avatar
                      }`
                    : "/images/placeholder.png"}
                  alt="Jese"
                />
                <P weight="semibold" class="ml-3">{m.name}</P>
              </div>
            {/each}
          </div>
        </div>
      </TabItem>
      <TabItem>
        <div slot="title" class="flex items-center gap-2">Scoreboard</div>
        <div class="flex justify-center h-[120px]">
          <div class="flex items-center mr-5">
            <P weight="semibold" class="mr-3">{match.team_one_name}</P>
            <img
              class="w-10 h-10 rounded-full"
              src={`${PUBLIC_API_URL.replace("/api", "/backend-images")}/${
                match.teams[0].avatar
              }`}
              alt="Jese"
            />
          </div>
          <div class="flex items-center">
            <P
              color={match.score[0] > match.score[1]
                ? "text-green-500"
                : "text-gray-600"}
              class="mr-5"
              size="3xl"
              weight="bold">{match.score[0]}</P
            >
            <div class="flex flex-col items-center mr-5">
              <P size="sm">5v5</P>
              <P weight="semibold"
                >{match.status == 0 ? "Ongoing" : "Finished"}</P
              >
              <P size="xs">{match.type == 0 ? "Best of 1" : "Best of 3"}</P>
            </div>
            <P
              weight="bold"
              color={match.score[0] < match.score[1]
                ? "text-green-500"
                : "text-gray-600"}
              size="3xl">{match.score[1]}</P
            >
          </div>
          <div class="flex items-center ml-5">
            <img
              class="w-10 h-10 rounded-full"
              src={`${PUBLIC_API_URL.replace("/api", "/backend-images")}/${
                match.teams[1].avatar
              }`}
              alt="Jese"
            />
            <P weight="semibold" class="ml-3">{match.team_two_name}</P>
          </div>
        </div>
        <hr class="mt-5 mb-5" />
        <div class="flex mb-3 justify-between w-full">
          <div class="flex">
            <img
              class="w-5 h-5 rounded-full"
              src="/images/placeholder.png"
              alt="Jese"
            />
            <P size="sm" class="ml-3" weight="semibold">Team Pedro</P>
          </div>
          <div class="flex">
            <P size="sm" class="ml-3" color="text-gray-500" weight="semibold"
              >LOSS</P
            >
            <P size="sm" class="ml-3" weight="semibold">First Half Score: 8</P>
            <P size="sm" class="ml-3" weight="semibold">Second Half Score: 8</P>
            <P size="sm" class="ml-3" weight="semibold">Final Score: 16</P>
          </div>
        </div>
        <Table>
          <TableHead>
            <TableHeadCell>Player</TableHeadCell>
            <TableHeadCell>Kills</TableHeadCell>
            <TableHeadCell>Assists</TableHeadCell>
            <TableHeadCell>Deaths</TableHeadCell>
            <TableHeadCell>K/R Ratio</TableHeadCell>
            <TableHeadCell>K/D Ratio</TableHeadCell>
            <TableHeadCell>Headshots</TableHeadCell>
            <TableHeadCell>Headshots %</TableHeadCell>
            <TableHeadCell>MVPs</TableHeadCell>
            <TableHeadCell>Triple Kills</TableHeadCell>
            <TableHeadCell>Quadro Kills</TableHeadCell>
            <TableHeadCell>Penta Kills</TableHeadCell>
          </TableHead>
          <TableBody tableBodyClass="divide-y">
            <TableBodyRow class="h-[10px]">
              <TableBodyCell>
                <div class="flex items-center">
                  <P size="sm" class="mr-3">Pedro</P>
                  <img
                    class="w-5 h-5 rounded-full"
                    src="/images/placeholder.png"
                    alt="Jese"
                  />
                </div>
              </TableBodyCell>
              <TableBodyCell>30</TableBodyCell>
              <TableBodyCell>20</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>1.5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>50%</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>3</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
            </TableBodyRow>
            <TableBodyRow>
              <TableBodyCell>
                <div class="flex items-center">
                  <P size="sm" class="mr-3">Pedro</P>
                  <img
                    class="w-5 h-5 rounded-full"
                    src="/images/placeholder.png"
                    alt="Jese"
                  />
                </div>
              </TableBodyCell>
              <TableBodyCell>30</TableBodyCell>
              <TableBodyCell>20</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>1.5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>50%</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>3</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
            </TableBodyRow>
            <TableBodyRow>
              <TableBodyCell>
                <div class="flex items-center">
                  <P size="sm" class="mr-3">Pedro</P>
                  <img
                    class="w-5 h-5 rounded-full"
                    src="/images/placeholder.png"
                    alt="Jese"
                  />
                </div>
              </TableBodyCell>
              <TableBodyCell>30</TableBodyCell>
              <TableBodyCell>20</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>1.5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>50%</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>3</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
            </TableBodyRow>
            <TableBodyRow>
              <TableBodyCell>
                <div class="flex items-center">
                  <P size="sm" class="mr-3">Pedro</P>
                  <img
                    class="w-5 h-5 rounded-full"
                    src="/images/placeholder.png"
                    alt="Jese"
                  />
                </div>
              </TableBodyCell>
              <TableBodyCell>30</TableBodyCell>
              <TableBodyCell>20</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>1.5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>50%</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>3</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
            </TableBodyRow>
            <TableBodyRow>
              <TableBodyCell>
                <div class="flex items-center">
                  <P size="sm" class="mr-3">Pedro</P>
                  <img
                    class="w-5 h-5 rounded-full"
                    src="/images/placeholder.png"
                    alt="Jese"
                  />
                </div>
              </TableBodyCell>
              <TableBodyCell>30</TableBodyCell>
              <TableBodyCell>20</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>1.5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>50%</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>3</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
            </TableBodyRow>
          </TableBody>
        </Table>
        <div class="flex mb-3 mt-5 justify-between w-full">
          <div class="flex">
            <img
              class="w-5 h-5 rounded-full"
              src="/images/placeholder.png"
              alt="Jese"
            />
            <P size="sm" class="ml-3" weight="semibold">Team Pedro</P>
          </div>
          <div class="flex">
            <P size="sm" class="ml-3" color="text-gray-500" weight="semibold"
              >LOSS</P
            >
            <P size="sm" class="ml-3" weight="semibold">First Half Score: 8</P>
            <P size="sm" class="ml-3" weight="semibold">Second Half Score: 8</P>
            <P size="sm" class="ml-3" weight="semibold">Final Score: 16</P>
          </div>
        </div>
        <Table>
          <TableHead>
            <TableHeadCell>Player</TableHeadCell>
            <TableHeadCell>Kills</TableHeadCell>
            <TableHeadCell>Assists</TableHeadCell>
            <TableHeadCell>Deaths</TableHeadCell>
            <TableHeadCell>K/R Ratio</TableHeadCell>
            <TableHeadCell>K/D Ratio</TableHeadCell>
            <TableHeadCell>Headshots</TableHeadCell>
            <TableHeadCell>Headshots %</TableHeadCell>
            <TableHeadCell>MVPs</TableHeadCell>
            <TableHeadCell>Triple Kills</TableHeadCell>
            <TableHeadCell>Quadro Kills</TableHeadCell>
            <TableHeadCell>Penta Kills</TableHeadCell>
          </TableHead>
          <TableBody tableBodyClass="divide-y">
            <TableBodyRow class="h-[10px]">
              <TableBodyCell>
                <div class="flex items-center">
                  <P size="sm" class="mr-3">Pedro</P>
                  <img
                    class="w-5 h-5 rounded-full"
                    src="/images/placeholder.png"
                    alt="Jese"
                  />
                </div>
              </TableBodyCell>
              <TableBodyCell>30</TableBodyCell>
              <TableBodyCell>20</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>1.5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>50%</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>3</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
            </TableBodyRow>
            <TableBodyRow>
              <TableBodyCell>
                <div class="flex items-center">
                  <P size="sm" class="mr-3">Pedro</P>
                  <img
                    class="w-5 h-5 rounded-full"
                    src="/images/placeholder.png"
                    alt="Jese"
                  />
                </div>
              </TableBodyCell>
              <TableBodyCell>30</TableBodyCell>
              <TableBodyCell>20</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>1.5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>50%</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>3</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
            </TableBodyRow>
            <TableBodyRow>
              <TableBodyCell>
                <div class="flex items-center">
                  <P size="sm" class="mr-3">Pedro</P>
                  <img
                    class="w-5 h-5 rounded-full"
                    src="/images/placeholder.png"
                    alt="Jese"
                  />
                </div>
              </TableBodyCell>
              <TableBodyCell>30</TableBodyCell>
              <TableBodyCell>20</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>1.5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>50%</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>3</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
            </TableBodyRow>
            <TableBodyRow>
              <TableBodyCell>
                <div class="flex items-center">
                  <P size="sm" class="mr-3">Pedro</P>
                  <img
                    class="w-5 h-5 rounded-full"
                    src="/images/placeholder.png"
                    alt="Jese"
                  />
                </div>
              </TableBodyCell>
              <TableBodyCell>30</TableBodyCell>
              <TableBodyCell>20</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>1.5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>50%</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>3</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
            </TableBodyRow>
            <TableBodyRow>
              <TableBodyCell>
                <div class="flex items-center">
                  <P size="sm" class="mr-3">Pedro</P>
                  <img
                    class="w-5 h-5 rounded-full"
                    src="/images/placeholder.png"
                    alt="Jese"
                  />
                </div>
              </TableBodyCell>
              <TableBodyCell>30</TableBodyCell>
              <TableBodyCell>20</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>1.5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
              <TableBodyCell>15</TableBodyCell>
              <TableBodyCell>50%</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>3</TableBodyCell>
              <TableBodyCell>5</TableBodyCell>
              <TableBodyCell>2</TableBodyCell>
            </TableBodyRow>
          </TableBody>
        </Table>
      </TabItem>
    </Tabs>
  </div>
</div>
