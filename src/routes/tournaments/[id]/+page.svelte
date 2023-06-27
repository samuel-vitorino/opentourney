<script lang="ts">
  import {
    P,
    Tabs,
    TabItem,
    Input,
    Button,
    Modal,
    Select,
    Label,
    Avatar,
  } from "flowbite-svelte";
  import { SendIcon } from "svelte-feather-icons";
  import type { Database } from "brackets-manager";
  import { toast } from "@zerodevx/svelte-toast";
  import "brackets-viewer";
  import "@styles/tournament.scss";
  import "@styles/brackets-viewer.min.css";
  import type { PageData } from "./$types";
  import { PUBLIC_API_URL, PUBLIC_WSURL } from "$env/static/public";
  import { userData } from "@src/stores/user";
  import { afterUpdate, onMount } from "svelte";
  import { goto } from "$app/navigation";
  import { io } from "socket.io-client";
  import "@styles/scrollbar.scss";

  export let data: PageData;

  interface User {
    id: number;
    avatar: string;
    email: string;
    status: number;
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
  }

  interface Match {
    id: number;
    team_one_name: string;
    team_two_name: string;
    games: Game[];
    createdAt: string;
    status: number;
    score: [number, number];
  }

  interface MessageData {
    senderName: string;
    messageType: number;
    message: string;
  }

  let defaultModal = false;
  let joinModal = false;
  let teams: Array<Object> = [];
  let teamToJoin = {} as Team;

  let alreadyJoined = false;
  let joinedTeamName: string;
  let joinedTeamId: number;

  let tournamentTeams: Array<Team> = [];
  let tournamentMatches: Array<Match> = [];

  let messageList: MessageData[] = [];
  let messageInput = "";

  const socket = io(PUBLIC_WSURL, {
    rejectUnauthorized: false,
    transports: ["websocket"],
  });

  onMount(() => {
    console.log(socket);
    socket.on("connect", () => {
      console.log("Socket.IO connected");
      socket.emit("joinTournamentRoom", tournament.id);
    });

    socket.on("chatMessage", (data: MessageData) => {
      messageList = [...messageList, data];
    });

    socket.on("initialMessages", (data: MessageData[]) => {
      messageList = messageList.concat(data);
    });
  });

  afterUpdate(() => {
    scrollToBottom();
  });

  let firstTime = true;
  let prevScrollHeight = 0;
  function scrollToBottom() {
    let objDiv = document.getElementById("chatscroll");
    console.log(objDiv);
    if (!objDiv) return;

    console.log(prevScrollHeight);
    console.log("scroll:", objDiv.scrollTop + objDiv.clientHeight);

    if (firstTime) {
      objDiv.scrollTop = prevScrollHeight = objDiv.scrollHeight;
      firstTime = false;
    } else if (objDiv.scrollTop + objDiv.clientHeight === prevScrollHeight) {
      objDiv.scrollTop = prevScrollHeight = objDiv.scrollHeight;
    } else {
      prevScrollHeight = objDiv.scrollHeight;
    }
  }

  function sendMessage() {
    const message = messageInput.trim();
    if (message) {
      messageList = [
        ...messageList,
        {
          senderName: "",
          messageType: 0,
          message: message,
        },
      ];
      socket.emit("chatMessage", tournament.id, {
        senderName: $userData.name,
        message: message,
        messageType: 0,
      });
      messageInput = "";
      console.log(`sent`, message);
    }
  }

  function formatDate(date: Date) {
    const daysOfWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
    const months = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC",
    ];

    const dayOfWeek = daysOfWeek[date.getUTCDay()];
    const dayOfMonth = date.getUTCDate();
    const month = months[date.getUTCMonth()];
    const hours = ("0" + date.getUTCHours()).slice(-2);
    const minutes = ("0" + date.getUTCMinutes()).slice(-2);

    return `${dayOfWeek} ${dayOfMonth} ${month}, ${hours}:${minutes}`;
  }

  const getTournamentTeams = async (id: number) => {
    await fetch(`${PUBLIC_API_URL}/tournaments/${id}/teams`, {
      method: "GET",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
    })
      .then((response) => {
        if (response.ok) {
          return response.json();
        }
        throw new Error();
      })
      .then((data) => {
        tournamentTeams = data["tournament"];

        tournamentTeams.forEach((t) => {
          t.members.forEach((m) => {
            if (m.id == $userData.id) {
              alreadyJoined = true;
              joinedTeamName = t.name;
              joinedTeamId = t.id;
            }
          });
        });
      })
      .catch((data) => {
        alert(data);
      });
  };

  const getTournamentMatches = async (id: number) => {
    await fetch(`${PUBLIC_API_URL}/tournaments/${id}/matches`, {
      method: "GET",
      credentials: "include",
    })
      .then((response) => {
        if (response.ok) {
          return response.json();
        }
        throw new Error();
      })
      .then((data) => {
        tournamentMatches = data["tournament"];

        tournamentMatches.forEach((m) => {
          m.score = [0, 0];
          m.games.forEach((g) => {
            if (g.team_one_score == 16) {
              m.score[0] += 1;
            }
            if (g.team_two_score == 16) {
              m.score[1] += 1;
            }
          });
        });
      })
      .catch((data) => {
        alert(data);
      });
  };

  const getPlayerTeams = async () => {
    if (teams.length == 0) {
      await fetch(`${PUBLIC_API_URL}/teams?owner=${$userData.id}`, {
        method: "GET",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
      })
        .then((response) => {
          if (response.ok) {
            return response.json();
          }
          throw new Error();
        })
        .then((data) => {
          data = data["teams"];
          data.forEach((t: Team) => {
            teams.push({ name: t.name, value: t.id });
          });
        })
        .catch((data) => {
          alert(data);
        });
    }
    joinModal = true;
  };

  const joinTournament = async (id: number, team: number) => {
    fetch(`${PUBLIC_API_URL}/tournaments/${id}/teams`, {
      method: "POST",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        team: team,
      }),
    })
      .then((response) => {
        if (response.ok) {
          return response;
        }
        throw new Error();
      })
      .then(() => {
        toast.push(`Joined tournament successfully!`, {
          theme: {
            "--toastColor": "mintcream",
            "--toastBackground": "rgb(72,187,120)",
            "--toastBarBackground": "#2F855A",
          },
        });
        updateTournament();
        getTournamentTeams(id);
        joinModal = false;
      })
      .catch((data) => {
        alert(data);
      });
  };

  const leaveTournament = async (id: number, team: number) => {
    fetch(`${PUBLIC_API_URL}/tournaments/${id}/teams/${team}`, {
      method: "DELETE",
      credentials: "include",
    })
      .then((response) => {
        if (response.ok) {
          return response;
        }
        throw new Error();
      })
      .then(() => {
        toast.push(`Left tournament successfully!`, {
          theme: {
            "--toastColor": "mintcream",
            "--toastBackground": "rgb(72,187,120)",
            "--toastBarBackground": "#2F855A",
          },
        });
        getTournamentTeams(id);
        updateTournament();
        alreadyJoined = false;
      })
      .catch((data) => {
        alert(data);
      });
  };

  const updateStatus = async (id: number, status: number) => {
    fetch(`${PUBLIC_API_URL}/tournaments/${id}`, {
      method: "PATCH",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        status: status,
      }),
    })
      .then((response) => {
        if (response.ok) {
          return response;
        }
        throw new Error();
      })
      .then(() => {
        toast.push(
          `Tournament ${status == 1 ? "started" : "ended"} successfully!`,
          {
            theme: {
              "--toastColor": "mintcream",
              "--toastBackground": "rgb(72,187,120)",
              "--toastBarBackground": "#2F855A",
            },
          }
        );
        updateTournament();
        getTournamentTeams(id);
      })
      .catch((data) => {
        alert(data);
      });
  };

  function addOrdinalSuffix(number: number) {
    if (typeof number !== "number" || isNaN(number)) {
      return number;
    }

    // Check for special cases (11th, 12th, 13th)
    if (number % 100 >= 11 && number % 100 <= 13) {
      return number + "th";
    }

    // Handle general cases
    switch (number % 10) {
      case 1:
        return number + "st";
      case 2:
        return number + "nd";
      case 3:
        return number + "rd";
      default:
        return number + "th";
    }
  }

  let draw = async () => {
    let data = tournament.tournamentData;

    window.bracketsViewer.render(
      {
        stages: data.stage,
        matches: data.match,
        matchGames: data.match_game,
        participants: data.participant,
      },
      { selector: document.querySelectorAll(".brackets-viewer")[0] }
    );
  };

  let stagesToString = (stage: number) => {
    switch (stage) {
      case 0:
        return "Round-Robin";
      case 1:
        return "Single-Elimination";
      case 2:
        return "Double-Elimination";
      case 3:
        return "Round-Robin + Single-Elimination";
      case 4:
        return "Round-Robin + Double-Elimination";
    }
  };

  let currentStageToString = (stages: number, currentStage: number) => {
    if (stages <= 2) {
      switch (stages) {
        case 0:
          return "Round-Robin";
        case 1:
          return "Single-Elimination";
        case 2:
          return "Double-Elimination";
      }
    } else {
      if (currentStage == 0) {
        return "Round-Robin";
      } else {
        switch (stages) {
          case 3:
            return "Single-Elimination";
          case 4:
            return "Double-Elimination";
        }
      }
    }
  };

  interface Tournament {
    id: number;
    name: string;
    max_teams: number;
    admin: number;
    avatar: string;
    organizer: string;
    information: string;
    prizes: string[];
    stages: number;
    current_stage: number;
    createdAt: string;
    tournamentData: Database;
    status: number;
  }

  let tournament = data.tournament as Tournament;

  onMount(() => {
    getTournamentTeams(tournament.id);
    scrollToBottom();
  });

  const updateTournament = () => {
    fetch(`${PUBLIC_API_URL}/tournaments/${tournament.id}`, {
      credentials: "include",
    })
      .then((res) => {
        if (res.ok) {
          return res.json();
        }
        return null;
      })
      .then((data) => {
        tournament = data.tournament;
      });
  };
</script>

<div class="flex flex-col w-full shadow-md">
  <div class="box-content p-4">
    <div
      class="flex flex-row h-[250px]"
      id="tournamentBackground"
      style="background-image: url('{`${PUBLIC_API_URL.replace(
        '/api',
        '/backend-images'
      )}/${tournament.avatar}`}')"
    >
      <div
        class="w-full h-full flex flex-col justify-end bg-"
        id="tournamentOverlay"
      >
        <div class="ml-5 mb-5">
          <P size="xs" weight="extrabold" color="text-gray-300"
            >{tournament.status === 0
              ? "SCHEDULED"
              : tournament.status === 1
              ? "ONGOING"
              : "FINISHED"}</P
          >
          <P size="3xl" color="text-white" weight="semibold"
            >{tournament.name}</P
          >
          <div class="flex">
            <P color="text-gray-200" weight="medium" class="mr-1" size="sm"
              >Organized by</P
            >
            <P size="sm" weight="semibold" color="text-orange-300"
              >{tournament.organizer}</P
            >
          </div>
        </div>
      </div>
    </div>
    <Tabs style="underline">
      <TabItem open>
        <div slot="title" class="flex items-center gap-2">Overview</div>
        <div>
          <div>
            <div class="flex justify-between">
              <div class="grow">
                <P size="2xl" class="mb-4" weight="semibold">Details</P>
                <div class="flex ml-3 mb-4 justify-around">
                  <div class="flex items-center">
                    <svg
                      class="w-[50px]"
                      viewBox="0 -201.55 689.123 689.123"
                      xmlns="http://www.w3.org/2000/svg"
                      fill="#000000"
                      ><g id="SVGRepo_bgCarrier" stroke-width="0" /><g
                        id="SVGRepo_tracerCarrier"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      /><g id="SVGRepo_iconCarrier">
                        <g fill="#231F20">
                          <path
                            d="M343.816.699c4.56-1.58 9.541-.261 13.72 1.8 2.92 1.88 5.84 3.78 9.11 5.01.25.47.77 1.4 1.02 1.86-.13.31-.38.95-.51 1.26 2.33 5.3 3.82 11.58 1.56 17.149-1.54 1.88-4.22 2.171-6.39 2.899-.01 2.69.42 5.351.65 8.021 4.64.75 8.568-2.48 13.158-2.16.62-2.57 1.11-5.182 1.932-7.701.95 1.67.989 3.591 1 5.471 1.2.34 2.42.65 3.648.949.012.461.021 1.381.021 1.841 20.12.12 40.229-.091 60.35.11-.05.688-.148 2.069-.188 2.76.52 0 1.58.01 2.108.01-.02-3.659 0-7.33-.01-10.989.51-.021 1.51-.051 2.01-.061.012 2.88.021 5.76.051 8.641.439.54 1.319 1.619 1.761 2.159.33-.391.989-1.159 1.318-1.55 1.53 1.431.66 3.391.592 5.149 5.63-.061 11.318.319 16.93-.141.42-.31 1.26-.92 1.68-1.229.771.299 1.55.6 2.32.91 2.53-.062 5.07-.07 7.61-.08-.052 1.31-.092 2.619-.142 3.93-3.27-.051-6.55-.12-9.77.439-2.08-1.789-4.87-1.221-7.38-1.289-3.86.18-7.842-.5-11.58.729-2.222.62-4.66.471-6.62-.79-.472 1.17.25 3.79-1.722 3.689-7.76.101-15.51-.069-23.26.051-1.06.56-2.13 1.09-3.188 1.609-1.12 3.34-4.33 5.569-7.062 7.609-.34 5.13 1.69 9.92 2.48 14.899-1.53.439-3.07.891-4.58 1.391-2.17 5.12-.84 12.109-5.86 15.681-3.85 2.239-6.398 7.109-11.59 6.34 2.64 2.2-.72 1.51-.37-.25-9.39-.83-17.3-6.34-25.46-10.539-.38 2.299-.979 4.56-1.6 6.81 3.1.59 5.66 2.87 6.21 6.05.99 6.931-.99 13.812-.96 20.761.22 4.08-1.53 7.819-3.71 11.149-1.91 2.16-4.92-.061-7.21-.38-.521 1.01-1.03 2.021-1.53 3.04.65 2.719.93 5.549 1.84 8.209 5.11 5.65 9.76 11.771 13.33 18.521a244.586 244.586 0 0 1 9.811 23.459c.279 1.551 1.739 2.108 3.021 2.67.17 1.6.34 3.198.5 4.819.5.73 1.01 1.459 1.53 2.199.31 9.861-.9 19.68-2.432 29.41-.948 4.391 1.62 8.68.58 13.1.12 2.263-1.438 3.972-2.17 5.972-.14 4.67-.37 9.399.142 14.061.358 3.42 3.25 5.619 5.21 8.17 2.14 2.271 3.93 5.32 7.17 6.129 3.05.91 5.96 2.23 8.648 3.961.82 2.029.67 4.181.28 6.289-5.86 1.08-11.84.541-17.76.632-4.562.239-8.63-2.211-13.062-2.722-4.29-.108-9.52 2.021-12.818-1.819 1.398-5.328 1.51-11.05 4.068-16.021.82-5.629-.738-11.34-.41-17.02-.488-.41-1.47-1.23-1.96-1.642.352-3.709-1.479-7.01-2.09-10.559-.398-5.183-.87-10.361-1.47-15.521-.47-2.51.83-4.809 2.6-6.479.16-2.9.552-5.771.83-8.65-.43-1.871-1.92-3.26-2.88-4.86-3.21 1.352-7.54.711-9.45-2.431-4.529-6.739-9.05-13.479-13.63-20.18-1.8-.119-3.7.07-5.38-.65-1.938-1.989-2.95-4.639-4.188-7.059-1.771 1.99-1.642 5.039-3.74 6.85-4.44 4.261-5.62 10.521-7.94 15.98-1.778 3.539-.778 7.809-2.76 11.26-1.06 1.859-3.72 2.229-4.42 4.351-.92 2.288-2 4.659-4.15 6.051-2.33 1.528-2.949 4.43-3.988 6.828-.95 2.211.46 4.53.13 6.801-1.48 7.211-6.07 13.24-8 20.301-.88 3.18-2.141 6.76-5.841 7.439-4.21 7.52-6.529 16.721-4.149 25.188 1.46 2.66 1.38 5.65.93 8.58-6.689.521-13.55 1.42-20.119-.449-1.54-3.051-1.32-6.641-1-9.938 2.029-8.672 4.72-17.191 6.369-25.951-2.06-1.83-1.579-4.629-1.54-7.08-.069-4.57 3.04-8.23 5.2-11.98.811-3.85.431-7.987 2.42-11.52 2.341-4.42 4.32-9.199 7.931-12.77.689-3.15 3.011-5.529 3.949-8.562 1-2.68-.75-5.4-.398-8.139.859-8.312 2.37-16.541 3.68-24.791-2.479-2.07-1.68-5.359-2.47-8.15.39-1.1.88-2.149 1.47-3.17-.62-.57-1.229-1.15-1.85-1.719.6-2.933.43-8.183 4.93-7.23.28-9.71-3.09-19.11-1.96-28.831.6.699 1.189 1.41 1.79 2.12l-.32-3.29c1.88-1 3.88-1.77 5.98-2.16-3.42-.449-6.75-1.319-10.102-2.1-.81-2.131-.358-4.4-.06-6.58 1.3-7.36 1.78-14.82 2.05-22.28 3.79-1.318 7.97-.199 11.67-1.96-1.148-9.33-1.438-19.069 1.88-28.02 2.67-7.621 7.771-14.971 15.73-17.65 3.76-.899 8.49-1.91 11.148 1.74.73-.67 1.46-1.36 2.19-2.03-6.069-12.054 1.181-29.664 14.953-32.144m48.569 52.28c-1.6.98-3.17 2.101-1.488 3.881-.82.489-1.642.96-2.472 1.409-1.3 1-4.22 1.569-3.88 3.591a48.68 48.68 0 0 1 3.761 7.369c3.189-2.619 5.729-6.141 7.449-9.869.36-.37 1.091-1.11 1.45-1.471-.16-1.71-.54-3.381-1.21-4.96-1.2.021-2.41.04-3.61.05z"
                          />
                          <path
                            d="M421.726 142.499c4.579-5.779 11.979-8.98 19.318-8.86 22.33.021 44.67-.01 67 .01 10.892.23 21.511 8.741 22.771 19.802-30.91-.103-61.812.09-92.71-.103-.03 20.681-.07 41.371 0 62.062 23.72-.039 47.438-.08 71.16.02-.091-7.41.028-14.82-.07-22.229-11.729.067-23.46.09-35.19 0-9.409-.361-16.409-8.49-18.528-17.15 25.22-.09 50.43-.1 75.648.01-.108 12.67.062 25.351-.09 38.021-.3 10.67-9.479 20.061-20 21.131-24.33 0-48.67-.01-73-.01-7.27-.052-13.7-4.642-17.8-10.371-2.8-4.051-3.431-9.08-3.83-13.851-.04-17 .02-34.01-.021-51.01.092-6.162 1.182-12.671 5.342-17.472zM569.255 134.338c2.512-.68 5.13-.729 7.722-.699 20.64.062 41.29-.069 61.93.05 11.7.5 21.979 10.602 22.43 22.34.021 18.971.021 37.95 0 56.932-.21 11.629-10.51 22.469-22.318 22.27-22.7-.1-45.4.07-68.102-.08-11.32-1.26-20.01-12.069-20.09-23.26-.16-17.301.02-34.621-.09-51.92-.09-5.1.83-10.34 3.53-14.74 3.169-5.531 8.849-9.402 14.988-10.893m3.561 18.462c.04 21.34-.09 42.689.06 64.029 22.17.061 44.352-.01 66.521.028.068-21.358.01-42.719.028-64.09-22.199-.008-44.409-.047-66.609.033zM.035 157.88c.471-11.57 10.16-22.441 21.95-22.891 22.029-.021 44.069-.021 66.1.01 11.9-.119 21.812 10.631 22.71 22.161-1.59.131-3.18.229-4.77.25-26.23-.029-52.46.01-78.681-.021-.011 18.64-.109 37.279.05 55.92 27.841-.041 55.671-.061 83.511.011-.79 11.948-10.851 22.551-22.979 23.02-19.96.281-39.92.01-59.881.131-4.97.17-10.09-.451-14.569-2.721-7.72-3.949-13.181-12-13.449-20.74-.022-18.38-.052-36.751.008-55.13zM131.995 148.82c3.67-8.011 12.07-13.96 21.011-13.851 22 .021 44.01 0 66.021.01 11.489.07 21.609 10.129 22.42 21.481-29.021.41-58.061.059-87.09.17-.131 5.84-.07 11.68-.08 17.529 21.58.069 43.17.02 64.75.02 6.399.25 13.12 2.301 17.479 7.25 4.899 4.381 6.97 11.051 7.13 17.471.109 6.41.109 12.851-.931 19.199-2.38 10.281-12.21 17.941-22.699 18.271-20.979.199-41.971.02-62.95.1-4.949.101-10.069-.61-14.46-3.02-6.96-3.631-11.96-10.933-12.649-18.771 29.54.142 59.09.09 88.63.021.07-6.222.03-12.441.03-18.66-21.86-.15-43.73-.021-65.601-.062-12.569.101-23.689-11.45-23.351-23.979.44-7.72-1.339-16.009 2.34-23.179zM668.166 137.05c2.78-.07 5.59-.18 8.36.24-1.29.33-2.602.5-3.92.52-.17 3.011-.19 6.021-.15 9.029-.29 0-.859 0-1.14.01.02-3.09.05-6.18.01-9.26-.78.062-2.33.201-3.1.26l-.06-.799zM678.085 136.938c.591.031 1.79.091 2.392.121.85 2.709 1.85 5.369 3.09 7.939 1.16-2.59 1.92-5.351 3.2-7.869.56-.08 1.68-.25 2.238-.33-.31 3.68.96 7.75-1.028 11.1-.36-3.26-.21-6.541-.421-9.811-1.521 3.051-2.239 6.48-4.229 9.301-1.521-2.899-2.17-6.201-3.99-8.938-.119 2.92-.06 5.85-.1 8.778l-1.07-.121c-.001-3.388-.051-6.779-.082-10.17z"
                          />
                        </g>
                      </g></svg
                    >
                    <div class="ml-3">
                      <div>
                        <P color="text-gray-500">Game</P>
                        <P weight="bold">CS:GO</P>
                      </div>
                    </div>
                  </div>
                  <div class="flex items-center">
                    <svg
                      class="w-[50px] h-[30px]"
                      viewBox="0 0 24 24"
                      xmlns="http://www.w3.org/2000/svg"
                      fill="#000000"
                      ><g id="SVGRepo_bgCarrier" stroke-width="0" /><g
                        id="SVGRepo_tracerCarrier"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      /><g id="SVGRepo_iconCarrier">
                        <g>
                          <path fill="none" d="M0 0h24v24H0z" />
                          <path
                            d="M12 11a5 5 0 0 1 5 5v6H7v-6a5 5 0 0 1 5-5zm-6.712 3.006a6.983 6.983 0 0 0-.28 1.65L5 16v6H2v-4.5a3.5 3.5 0 0 1 3.119-3.48l.17-.014zm13.424 0A3.501 3.501 0 0 1 22 17.5V22h-3v-6c0-.693-.1-1.362-.288-1.994zM5.5 8a2.5 2.5 0 1 1 0 5 2.5 2.5 0 0 1 0-5zm13 0a2.5 2.5 0 1 1 0 5 2.5 2.5 0 0 1 0-5zM12 2a4 4 0 1 1 0 8 4 4 0 0 1 0-8z"
                          />
                        </g>
                      </g></svg
                    >
                    <div class="ml-3">
                      <div>
                        <P color="text-gray-500">Team Size</P>
                        <P weight="bold">5v5</P>
                      </div>
                    </div>
                  </div>
                  <div class="flex items-center">
                    <svg
                      class="w-[50px] h-[50px]"
                      viewBox="0 0 76 76"
                      xmlns="http://www.w3.org/2000/svg"
                      xmlns:xlink="http://www.w3.org/1999/xlink"
                      version="1.1"
                      baseProfile="full"
                      enable-background="new 0 0 76.00 76.00"
                      xml:space="preserve"
                      fill="#000000"
                      ><g id="SVGRepo_bgCarrier" stroke-width="0" /><g
                        id="SVGRepo_tracerCarrier"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      /><g id="SVGRepo_iconCarrier">
                        <path
                          fill="#000000"
                          fill-opacity="1"
                          stroke-width="0.2"
                          stroke-linejoin="round"
                          d="M 23.75,60.1667L 23.75,53.8333L 31.6667,53.8333L 31.6666,47.5L 23.75,47.5L 23.75,41.1667L 38,41.1667L 38,47.5L 44.3333,47.5L 44.3333,28.5L 38,28.5L 38,34.8333L 23.75,34.8333L 23.75,28.5L 31.6667,28.5L 31.6666,22.1666L 23.75,22.1667L 23.75,15.8333L 38,15.8333L 38,22.1666L 50.6666,22.1667L 50.6666,34.8333L 58.5833,34.8333L 58.5833,41.1667L 50.6666,41.1667L 50.6666,53.8333L 38,53.8333L 38,60.1667L 23.75,60.1667 Z "
                        />
                      </g></svg
                    >
                    <div class="ml-3">
                      <div>
                        <P color="text-gray-500">Format</P>
                        <P weight="bold">{stagesToString(tournament.stages)}</P>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="flex ml-3 mb-4 justify-around mt-4">
                  <div class="flex items-center">
                    <svg
                      class="w-[32px] h-[32px]"
                      fill="#000000"
                      version="1.1"
                      id="Capa_1"
                      xmlns="http://www.w3.org/2000/svg"
                      xmlns:xlink="http://www.w3.org/1999/xlink"
                      viewBox="0 0 478.676 478.676"
                      xml:space="preserve"
                      ><g id="SVGRepo_bgCarrier" stroke-width="0" /><g
                        id="SVGRepo_tracerCarrier"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      /><g id="SVGRepo_iconCarrier">
                        <g>
                          <g>
                            <g>
                              <path
                                d="M361.275,312.934l-68.872-27.462l-16.13-13.587c-4.261-3.601-10.552-3.336-14.5,0.595l-22.422,22.296l-22.487-22.307 c-3.954-3.92-10.236-4.174-14.493-0.584l-16.127,13.587l-68.877,27.467c-22.177,8.831-22.159,87.371-24.063,94.58h292.068 C383.472,400.327,383.462,321.757,361.275,312.934z"
                              />
                              <path
                                d="M160.47,201.105l12.934-0.033c7.99,41.744,36.343,65.492,65.935,65.492s46.785-14.063,58.188-39.991 c-8.707,6.828-21.356,13.074-39.054,14.363c-1.626,2.423-4.39,4.018-7.524,4.018h-8.27c-5.003,0-9.06-4.056-9.06-9.061 c0-5.004,4.057-9.06,9.06-9.06h8.27c2.931,0,5.528,1.397,7.185,3.556c28.45-2.284,41.829-19.538,47.164-29.28l12.913-0.004 c7.906,0,14.314-6.413,14.314-14.317v-32.45c0-5.067-2.643-9.511-6.613-12.056c-4.784-39.943-41.78-71.125-86.571-71.125 s-81.787,31.182-86.57,71.125c-3.974,2.545-6.614,6.988-6.614,12.056v32.449C146.153,194.692,152.563,201.105,160.47,201.105z M239.338,87.384c35.253,0,64.573,23.249,69.979,53.579c-1.688,0.642-3.222,1.589-4.534,2.781 c-8.443-26.654-32.836-42.499-65.443-42.499c-32.608,0-57.016,15.834-65.468,42.478c-1.308-1.182-2.832-2.123-4.51-2.76 C174.765,110.633,204.085,87.384,239.338,87.384z"
                              />
                              <path
                                d="M463.158,322.283l-44.351-17.683l-10.387-8.749c-2.742-2.318-6.793-2.147-9.337,0.382l-14.438,14.356l-14.479-14.362 c-2.546-2.523-6.592-2.688-9.332-0.376l-4.947,4.168l9.091,3.624c19.589,7.789,25.386,43.547,28.364,79.547h85.333 C477.453,378.561,477.446,327.966,463.158,322.283z"
                              />
                              <path
                                d="M324.636,220.159v20.896c0,5.091,4.127,9.22,9.22,9.22l8.327-0.021c5.146,26.879,23.402,42.172,42.457,42.172 c19.057,0,30.126-9.057,37.469-25.75c-5.604,4.396-13.753,8.418-25.146,9.248c-1.047,1.562-2.826,2.588-4.847,2.588h-5.323 c-3.222,0-5.834-2.611-5.834-5.834s2.612-5.834,5.834-5.834h5.323c1.888,0,3.561,0.899,4.627,2.289 c18.317-1.471,26.935-12.582,30.37-18.854l8.312-0.003c5.092,0,9.219-4.129,9.219-9.22v-20.895c0-3.263-1.699-6.124-4.26-7.763 c-3.079-25.721-26.901-45.8-55.745-45.8c-28.842,0-52.665,20.079-55.745,45.8C326.336,214.035,324.636,216.897,324.636,220.159z M384.64,177.046c22.7,0,41.581,14.971,45.062,34.501c-1.087,0.414-2.074,1.024-2.92,1.792 c-5.438-17.164-21.146-27.367-42.143-27.367s-36.714,10.196-42.154,27.353c-0.845-0.761-1.824-1.367-2.904-1.777 C343.059,192.016,361.939,177.046,384.64,177.046z"
                              />
                              <path
                                d="M113.667,303.647l9.099-3.628l-4.947-4.167c-2.742-2.318-6.793-2.148-9.337,0.382L94.044,310.59l-14.48-14.361 c-2.546-2.524-6.592-2.688-9.332-0.376l-10.386,8.749l-44.351,17.687C1.215,327.975,1.225,378.55,0,383.19h85.328 C88.298,347.2,94.081,311.446,113.667,303.647z"
                              />
                              <path
                                d="M43.25,250.274l8.328-0.021c5.146,26.881,23.403,42.174,42.458,42.174c19.055,0,30.126-9.057,37.468-25.752 c-5.606,4.396-13.753,8.418-25.147,9.25c-1.047,1.561-2.826,2.586-4.846,2.586h-5.324c-3.222,0-5.833-2.61-5.833-5.834 c0-3.221,2.611-5.834,5.833-5.834h5.324c1.887,0,3.56,0.9,4.626,2.291c18.32-1.471,26.936-12.582,30.371-18.854l8.314-0.003 c5.091,0,9.218-4.129,9.218-9.219v-20.896c0-3.263-1.7-6.124-4.259-7.763c-3.08-25.721-26.903-45.8-55.745-45.8 c-28.843,0-52.666,20.079-55.745,45.8c-2.56,1.639-4.26,4.5-4.26,7.763v20.895C34.031,246.146,38.158,250.274,43.25,250.274z M94.036,177.046c22.7,0,41.58,14.971,45.061,34.501c-1.088,0.414-2.074,1.024-2.92,1.792 c-5.437-17.164-21.144-27.367-42.141-27.367c-20.998,0-36.714,10.196-42.157,27.353c-0.842-0.761-1.823-1.367-2.903-1.777 C52.455,192.016,71.336,177.046,94.036,177.046z"
                              />
                            </g>
                          </g>
                        </g>
                      </g></svg
                    >
                    <div class="ml-3">
                      <div>
                        <P color="text-gray-500">Max Teams</P>
                        <P weight="bold">{tournament.max_teams}</P>
                      </div>
                    </div>
                  </div>
                  <div class="flex items-center">
                    <svg
                      class="w-[50px] h-[50px]"
                      viewBox="0 0 76 76"
                      xmlns="http://www.w3.org/2000/svg"
                      xmlns:xlink="http://www.w3.org/1999/xlink"
                      version="1.1"
                      baseProfile="full"
                      enable-background="new 0 0 76.00 76.00"
                      xml:space="preserve"
                      fill="#000000"
                      ><g id="SVGRepo_bgCarrier" stroke-width="0" /><g
                        id="SVGRepo_tracerCarrier"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      /><g id="SVGRepo_iconCarrier">
                        <path
                          fill="#000000"
                          fill-opacity="1"
                          stroke-width="0.2"
                          stroke-linejoin="round"
                          d="M 15.8333,53.8333L 22.1666,53.8333L 22.1667,45.9166L 28.5,45.9167L 28.5,53.8333L 34.8333,53.8333L 34.8333,39.5833L 28.5,39.5833L 28.5,33.25L 47.5,33.25L 47.5,39.5833L 41.1667,39.5833L 41.1666,53.8333L 47.5,53.8333L 47.5,45.9166L 53.8333,45.9167L 53.8333,53.8333L 60.1666,53.8333L 60.1667,39.5833L 53.8333,39.5833L 53.8333,26.9167L 41.1667,26.9167L 41.1667,19L 34.8333,19L 34.8333,26.9167L 22.1667,26.9167L 22.1667,39.5833L 15.8333,39.5833L 15.8333,53.8333 Z "
                        />
                      </g></svg
                    >
                    <div class="ml-3">
                      <div>
                        <P color="text-gray-500">Current Stage</P>
                        <P weight="bold"
                          >{currentStageToString(
                            tournament.stages,
                            tournament.current_stage
                          )}</P
                        >
                      </div>
                    </div>
                  </div>
                </div>
                <P size="2xl" weight="semibold">Information</P>
                <P>{tournament.information}</P>
              </div>
              <div class="ml-2">
                <div class="bg-gray-100 h-[20px] flex box-content p-2">
                  <P weight="extrabold" size="sm">TOURNAMENT</P>
                  <P
                    color="text-green-500"
                    class="ml-1"
                    weight="extrabold"
                    size="sm"
                    >{tournament.status === 0
                      ? "SCHEDULED"
                      : tournament.status === 1
                      ? "ONGOING"
                      : "FINISHED"}</P
                  >
                </div>
                <P weight="bold" class="mt-4 mb-4" size="2xl">Prizes</P>
                <div class="border rounded-sm w-[400px] box-content p-3">
                  {#each tournament.prizes as p, i}
                    {#if i <= 2}
                      <div class="flex justify-between">
                        <P>{`${addOrdinalSuffix(i + 1)}`}</P>
                        <P>{p}</P>
                      </div>
                      {#if i != tournament.prizes.length - 1 && i < 2}
                        <hr class="mt-2 mb-2" />
                      {/if}
                    {/if}
                  {/each}
                </div>
                {#if tournament.prizes.length > 3}
                  <div class="w-full flex justify-center">
                    <button
                      type="button"
                      on:click={() => (defaultModal = true)}
                      class="btn btn-primary mt-2">Show all</button
                    >
                  </div>
                {/if}
                {#if tournament.admin == $userData.id}
                  {#if tournament.status == 0}
                    <Button
                      class="mt-5 w-full"
                      color="green"
                      on:click={() => updateStatus(tournament.id, 1)}
                      >Start Tournament</Button
                    >
                  {:else if tournament.status == 1}
                    <Button
                      class="mt-5 w-full"
                      color="red"
                      on:click={() => updateStatus(tournament.id, 2)}
                      >End Tournament</Button
                    >
                  {/if}
                {/if}
                {#if tournament.status == 0 && !alreadyJoined}
                  <Button
                    class="mt-5 w-full"
                    color="yellow"
                    on:click={() => {
                      getPlayerTeams();
                    }}>Join Tournament</Button
                  >
                {:else if alreadyJoined}
                  <div class="flex w-full justify-center mt-5 items-center">
                    <P class="mr-1">You are registered as:</P>
                    <P weight="semibold">{joinedTeamName}</P>
                    {#if tournament.status == 0}
                      <Button
                        class="ml-2"
                        color="red"
                        on:click={() => {
                          leaveTournament(tournament.id, joinedTeamId);
                        }}>Leave</Button
                      >
                    {/if}
                  </div>
                {/if}
              </div>
            </div>
          </div>
        </div>
      </TabItem>
      <TabItem>
        <div slot="title" class="flex items-center gap-2">Chat</div>
        <div
          class="border bg-white rounded-sm h-[350px] flex box-content items-end p-3"
        >
          <div class="flex flex-col justify-end h-full w-full">
            <div id="chatscroll" class="overflow-y-scroll hide-scrollbar">
              <div class="flex flex-col justify-end grow w-full gap-y-1">
                {#each messageList as message}
                  {#if message.senderName == "" || message.senderName == $userData.name}
                    <div
                      class="flex w-full justify-end gap-x-1 max-w-2xl self-end"
                    >
                      <div
                        class="flex flex-row bg-green-200 rounded-xl p-2 gap-x-1"
                      >
                        <p style="font-weight: bold; text-align: right;">Me:</p>
                        <p style="text-align: right;">
                          {message.message}
                        </p>
                      </div>
                      <Avatar class="shrink-0" />
                    </div>
                  {:else}
                    <div class="flex w-full gap-x-1 max-w-2xl">
                      <Avatar class="shrink-0" />

                      <div
                        class="flex flex-row bg-blue-200 rounded-xl p-2 gap-x-1"
                      >
                        <P weight="bold">{message.senderName}:</P>
                        <P>{message.message}</P>
                      </div>
                    </div>
                  {/if}
                {/each}
              </div>
            </div>
            <div class="flex w-full pt-3">
              <Input
                type="text"
                placeholder="Message"
                bind:value={messageInput}
              />
              <Button class="ml-2" on:click={sendMessage}><SendIcon /></Button>
            </div>
          </div>
        </div>
      </TabItem>
      <TabItem on:click={tournament.status > 0 ? draw : () => null}>
        <div slot="title" class="flex items-center gap-2">Bracket</div>
        {#if tournament.status > 0}
          <div id="#example" class="brackets-viewer" />
        {:else}
          <P>Waiting for the tournament to start</P>
        {/if}
      </TabItem>
      <TabItem>
        <div slot="title" class="flex items-center gap-2">
          <span>Teams</span>
          <div class="bg-gray-400 w-[20px] rounded-full flex justify-center">
            <P weight="bold" class="w-100" color="text-white" size="xs"
              >{tournamentTeams.length}</P
            >
          </div>
        </div>
        <div
          class="relative overflow-x-auto shadow-md sm:rounded-lg box-content p-3 bg-white"
        >
          <div
            class="flex items-center justify-between pb-4 bg-white dark:bg-gray-900"
          >
            <label for="table-search" class="sr-only">Search</label>
            <div class="relative">
              <div
                class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none"
              >
                <svg
                  class="w-5 h-5 text-gray-500 dark:text-gray-400"
                  aria-hidden="true"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                  xmlns="http://www.w3.org/2000/svg"
                  ><path
                    fill-rule="evenodd"
                    d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
                    clip-rule="evenodd"
                  /></svg
                >
              </div>
              <input
                type="text"
                id="table-search-users"
                class="block p-2 pl-10 text-sm text-gray-900 border border-gray-300 rounded-lg w-80 bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                placeholder="Search for teams"
              />
            </div>
          </div>
          <table
            class="w-full text-sm text-left text-gray-500 dark:text-gray-400"
          >
            <thead
              class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400"
            >
              <tr>
                <th scope="col" class="px-6 py-3"> Name </th>
              </tr>
            </thead>
            <tbody>
              {#each tournamentTeams as t}
                <tr
                  class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
                >
                  <th
                    scope="row"
                    class="flex items-center px-6 py-4 text-gray-900 whitespace-nowrap dark:text-white"
                  >
                    <img
                      class="w-10 h-10 rounded-full"
                      src={`${PUBLIC_API_URL.replace(
                        "/api",
                        "/backend-images"
                      )}/${t.avatar}` ?? "/images/placeholder.png"}
                      alt="Jese"
                    />
                    <div class="pl-3">
                      <div class="text-base font-semibold">
                        {t.name}
                      </div>
                    </div>
                  </th>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      </TabItem>
      <TabItem on:click={() => getTournamentMatches(tournament.id)}>
        <div slot="title" class="flex items-center gap-2">Matches</div>
        {#if tournamentMatches.length > 0}
          {#each tournamentMatches as m}
            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <div
              class="mb-5 h-[100px] box-content p-3 border bg-gray-100 cursor-pointer hover:bg-gray-200 rounded-md flex justify-center items-center"
              on:click={() => goto(`/matches/${m.id}`)}
            >
              <div class="flex items-center">
                <P class="mr-2" size="sm">{m.team_one_name}</P>
                <img
                  class="w-10 h-10 rounded-full mr-[100px]"
                  src="/images/placeholder.png"
                  alt="Jese"
                />
              </div>
              <div class="flex flex-col">
                <P class="text-center mb-1" size="xs" weight="semibold"
                  >{m.status == 0
                    ? "SCHEDULED"
                    : m.status == 1
                    ? "ONGOING"
                    : "FINISHED"}</P
                >
                <P class="text-center mb-2" size="xs"
                  >{formatDate(new Date(m.createdAt))}</P
                >
                <div class="flex justify-center">
                  <P
                    size="2xl"
                    class="mr-1"
                    color={m.score[0] > m.score[1] ? "text-green-500" : ""}
                    weight="semibold">{m.score[0]}</P
                  >
                  <P size="2xl" class="mr-1" weight="semibold">-</P>
                  <P
                    size="2xl"
                    weight="semibold"
                    color={m.score[0] < m.score[1] ? "text-green-500" : ""}
                    >{m.score[1]}</P
                  >
                </div>
              </div>
              <div class="flex items-center">
                <img
                  class="w-10 h-10 rounded-full ml-[100px]"
                  src="/images/placeholder.png"
                  alt="Jese"
                />
                <P class="ml-2" size="sm">{m.team_two_name}</P>
              </div>
            </div>
          {/each}
        {:else}
          <P>Waiting for the tournament to start</P>
        {/if}
      </TabItem>
    </Tabs>
    <Modal title="Prizes" bind:open={defaultModal} autoclose>
      <div class="w-[250px]">
        {#each tournament.prizes as p, i}
          <div class="flex justify-between">
            <P>{`${addOrdinalSuffix(i + 1)}`}</P>
            <P>{p}</P>
          </div>
          {#if i != tournament.prizes.length - 1}
            <hr class="mt-2 mb-2" />
          {/if}
        {/each}
      </div>
    </Modal>
    <Modal title="Join tournament" bind:open={joinModal}>
      <div class="w-[400px]">
        <form
          on:submit|preventDefault={() =>
            joinTournament(tournament.id, teamToJoin.id)}
          id="joinForm"
        >
          <Label
            >Choose the team
            <Select
              class="mt-2"
              required
              items={teams}
              bind:value={teamToJoin.id}
            />
          </Label>
          <Button class="w-full mt-5" type="submit">Join</Button>
        </form>
      </div>
    </Modal>
  </div>
</div>
