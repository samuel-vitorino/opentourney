<script lang="ts">
    import { P, Tabs, TabItem, Input, Button } from "flowbite-svelte";
    import { SendIcon } from "svelte-feather-icons";
    import { BracketsManager } from "brackets-manager";
    import { InMemoryDatabase } from "brackets-memory-db";
    import { onMount } from "svelte";
    import "brackets-viewer";
    import "@styles/tournament.scss";
    import "@styles/brackets-viewer.min.css";

    let draw = async () => {
        const storage = new InMemoryDatabase();
        const manager = new BracketsManager(storage);

        await manager.create({
            tournamentId: 3,
            name: "Elimination stage",
            type: "double_elimination",
            seeding: ["Team 1", "Team 2", "Team 3", "Team 4"],
            settings: { grandFinal: "double" },
        });

        await manager.update.match({
            id: 0, // First match of winner bracket (round 1)
            opponent1: { score: 16, result: "win" },
            opponent2: { score: 12 },
        });

        let data = await manager.get.tournamentData(3);

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

    interface Tournament {
        name: string;
        maxTeams: number;
        avatar: string;
    }

    let tournament = {} as Tournament;
</script>

<div class="flex flex-col w-full shadow-md">
    <div class="box-content p-4">
        <div class="flex flex-row h-[250px]" id="tournamentBackground">
            <div
                class="w-full h-full flex flex-col justify-end bg-"
                id="tournamentOverlay"
            >
                <div class="ml-5 mb-5">
                    <P size="xs" weight="extrabold" color="text-gray-300"
                        >FINISHED</P
                    >
                    <P size="3xl" color="text-white" weight="semibold"
                        >IPL Lan Party</P
                    >
                    <div class="flex">
                        <P
                            color="text-gray-200"
                            weight="medium"
                            class="mr-1"
                            size="sm">Organized by</P
                        >
                        <P size="sm" weight="semibold" color="text-orange-300"
                            >IPLeiria</P
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
                                <P size="2xl" class="mb-4" weight="semibold"
                                    >Details</P
                                >
                                <div class="flex ml-3 mb-4 justify-around">
                                    <div class="flex items-center">
                                        <svg
                                            class="w-[50px]"
                                            viewBox="0 -201.55 689.123 689.123"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="#000000"
                                            ><g
                                                id="SVGRepo_bgCarrier"
                                                stroke-width="0"
                                            /><g
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
                                                <P color="text-gray-500">Game</P
                                                >
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
                                            ><g
                                                id="SVGRepo_bgCarrier"
                                                stroke-width="0"
                                            /><g
                                                id="SVGRepo_tracerCarrier"
                                                stroke-linecap="round"
                                                stroke-linejoin="round"
                                            /><g id="SVGRepo_iconCarrier">
                                                <g>
                                                    <path
                                                        fill="none"
                                                        d="M0 0h24v24H0z"
                                                    />
                                                    <path
                                                        d="M12 11a5 5 0 0 1 5 5v6H7v-6a5 5 0 0 1 5-5zm-6.712 3.006a6.983 6.983 0 0 0-.28 1.65L5 16v6H2v-4.5a3.5 3.5 0 0 1 3.119-3.48l.17-.014zm13.424 0A3.501 3.501 0 0 1 22 17.5V22h-3v-6c0-.693-.1-1.362-.288-1.994zM5.5 8a2.5 2.5 0 1 1 0 5 2.5 2.5 0 0 1 0-5zm13 0a2.5 2.5 0 1 1 0 5 2.5 2.5 0 0 1 0-5zM12 2a4 4 0 1 1 0 8 4 4 0 0 1 0-8z"
                                                    />
                                                </g>
                                            </g></svg
                                        >
                                        <div class="ml-3">
                                            <div>
                                                <P color="text-gray-500"
                                                    >Team Size</P
                                                >
                                                <P weight="bold">5v5</P>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="flex">
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
                                            ><g
                                                id="SVGRepo_bgCarrier"
                                                stroke-width="0"
                                            /><g
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
                                                <P color="text-gray-500"
                                                    >Format</P
                                                >
                                                <P weight="bold"
                                                    >Single-Elimination</P
                                                >
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <P size="2xl" weight="semibold">Information</P>
                                <P>
                                    Lorem ipsum dolor sit amet, consectetur
                                    adipiscing elit, sed do eiusmod tempor
                                    incididunt ut labore et dolore magna aliqua.
                                    Ac tincidunt vitae semper quis lectus nulla.
                                    Lorem dolor sed viverra ipsum nunc aliquet
                                    bibendum enim facilisis. Ac ut consequat
                                    semper viverra nam libero justo. Mauris a
                                    diam maecenas sed enim ut. Aliquet lectus
                                    proin nibh nisl condimentum id. Scelerisque
                                    viverra mauris in aliquam sem fringilla ut.
                                    Pulvinar sapien et ligula ullamcorper
                                    malesuada proin libero nunc. Sed enim ut sem
                                    viverra aliquet eget sit amet tellus. Quis
                                    enim lobortis scelerisque fermentum dui
                                    faucibus in. Sed elementum tempus egestas
                                    sed sed risus pretium quam vulputate. Id
                                    nibh tortor id aliquet lectus proin. Ante in
                                    nibh mauris cursus mattis molestie a iaculis
                                    at. Pellentesque dignissim enim sit amet
                                    venenatis urna cursus eget. Lorem ipsum
                                    dolor sit amet consectetur adipiscing elit
                                    pellentesque habitant. Tempor nec feugiat
                                    nisl pretium fusce. Enim nulla aliquet
                                    porttitor lacus luctus. Adipiscing elit ut
                                    aliquam purus sit amet luctus. Nam aliquam
                                    sem et tortor consequat id porta nibh
                                    venenatis. Id velit ut tortor pretium
                                    viverra. Lectus proin nibh nisl condimentum
                                    id venenatis a condimentum. Mus mauris vitae
                                    ultricies leo integer. Quis ipsum
                                    suspendisse ultrices gravida dictum fusce ut
                                    placerat orci. Est ante in nibh mauris
                                    cursus mattis molestie a. Eu turpis egestas
                                    pretium aenean pharetra magna ac placerat
                                    vestibulum. Tellus in hac habitasse platea
                                    dictumst. Urna condimentum mattis
                                    pellentesque id nibh tortor. Mattis
                                    vulputate enim nulla aliquet porttitor lacus
                                    luctus accumsan. Elementum tempus egestas
                                    sed sed risus. Proin sagittis nisl rhoncus
                                    mattis rhoncus urna neque. Mauris vitae
                                    ultricies leo integer malesuada nunc. Diam
                                    maecenas ultricies mi eget mauris pharetra
                                    et ultrices neque. Eu mi bibendum neque
                                    egestas congue quisque egestas diam in.
                                    Pulvinar pellentesque habitant morbi
                                    tristique senectus. Volutpat ac tincidunt
                                    vitae semper quis lectus nulla at volutpat.
                                    In arcu cursus euismod quis viverra nibh
                                    cras pulvinar mattis. Sit amet commodo nulla
                                    facilisi. Pulvinar mattis nunc sed blandit
                                    libero volutpat. Vitae nunc sed velit
                                    dignissim. A pellentesque sit amet porttitor
                                    eget dolor morbi non arcu.
                                </P>
                            </div>
                            <div class="ml-2">
                                <div
                                    class="bg-gray-100 h-[20px] flex box-content p-2"
                                >
                                    <P weight="extrabold" size="sm"
                                        >TOURNAMENT</P
                                    >
                                    <P
                                        color="text-green-500"
                                        class="ml-1"
                                        weight="extrabold"
                                        size="sm">FINISHED</P
                                    >
                                </div>
                                <P weight="bold" class="mt-4 mb-4" size="2xl"
                                    >Prizes</P
                                >
                                <div
                                    class="border rounded-sm w-[400px] box-content p-3"
                                >
                                    <div class="flex justify-between">
                                        <P>1st</P>
                                        <P>100 Dollars plus a t-shirt</P>
                                    </div>
                                    <hr class="mt-2 mb-2" />
                                    <div class="flex justify-between">
                                        <P>2nd</P>
                                        <P>100 Dollars plus a t-shirt</P>
                                    </div>
                                    <hr class="mt-2 mb-2" />
                                    <div class="flex justify-between">
                                        <P>3rd-4th</P>
                                        <P>100 Dollars plus a t-shirt</P>
                                    </div>
                                </div>
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
                    <div class="flex w-full">
                        <Input type="text" placeholder="Message" />
                        <Button class="ml-2"><SendIcon /></Button>
                    </div>
                </div>
            </TabItem>
            <TabItem on:click={draw}>
                <div slot="title" class="flex items-center gap-2">Bracket</div>
                <div id="#example" class="brackets-viewer" />
            </TabItem>
            <TabItem>
                <div slot="title" class="flex items-center gap-2">
                    <span>Teams</span>
                    <div
                        class="bg-gray-400 w-[20px] rounded-full flex justify-center"
                    >
                        <P
                            weight="bold"
                            class="w-100"
                            color="text-white"
                            size="xs">12</P
                        >
                    </div>
                </div>

                <div class="relative overflow-x-auto shadow-md sm:rounded-lg box-content p-3 bg-white">
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
                                placeholder="Search for users"
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
                            <tr
                                class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
                            >
                                <th
                                    scope="row"
                                    class="flex items-center px-6 py-4 text-gray-900 whitespace-nowrap dark:text-white"
                                >
                                    <img
                                        class="w-10 h-10 rounded-full"
                                        src="/images/placeholder.png"
                                        alt="Jese"
                                    />
                                    <div class="pl-3">
                                        <div class="text-base font-semibold">
                                            Neil Sims
                                        </div>
                                    </div>
                                </th>
                            </tr>
                            <tr
                                class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
                            >
                                <th
                                    scope="row"
                                    class="flex items-center px-6 py-4 text-gray-900 whitespace-nowrap dark:text-white"
                                >
                                    <img
                                        class="w-10 h-10 rounded-full"
                                        src="/images/placeholder.png"
                                        alt="Jese"
                                    />
                                    <div class="pl-3">
                                        <div class="text-base font-semibold">
                                            Neil Sims
                                        </div>
                                    </div>
                                </th>
                            </tr>
                            <tr
                                class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
                            >
                                <th
                                    scope="row"
                                    class="flex items-center px-6 py-4 text-gray-900 whitespace-nowrap dark:text-white"
                                >
                                    <img
                                        class="w-10 h-10 rounded-full"
                                        src="/images/placeholder.png"
                                        alt="Jese"
                                    />
                                    <div class="pl-3">
                                        <div class="text-base font-semibold">
                                            Neil Sims
                                        </div>
                                    </div>
                                </th>
                            </tr>
                            <tr
                                class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
                            >
                                <th
                                    scope="row"
                                    class="flex items-center px-6 py-4 text-gray-900 whitespace-nowrap dark:text-white"
                                >
                                    <img
                                        class="w-10 h-10 rounded-full"
                                        src="/images/placeholder.png"
                                        alt="Jese"
                                    />
                                    <div class="pl-3">
                                        <div class="text-base font-semibold">
                                            Neil Sims
                                        </div>
                                    </div>
                                </th>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </TabItem>
            <TabItem>
                <div slot="title" class="flex items-center gap-2">Matches</div>
                <div class="mb-5 h-[100px] box-content p-3 border bg-gray-200 rounded-md flex justify-center items-center">
                    <div class="flex items-center">
                        <P class="mr-2" size="sm">Team Pedro</P>
                        <img
                            class="w-10 h-10 rounded-full mr-[100px]"
                            src="/images/placeholder.png"
                            alt="Jese"
                        />
                    </div>
                    <div class="flex flex-col"> 
                        <P class="text-center mb-1" size="xs" weight="semibold">FINISHED</P>
                        <P class="text-center mb-2" size="xs">SAT 13 MAY, 18:15</P>
                        <div class="flex justify-center">
                            <P size="2xl" class="mr-1" color="text-green-500" weight="semibold">2</P>
                            <P size="2xl" class="mr-1" weight="semibold">-</P>
                            <P size="2xl" weight="semibold">0</P>
                        </div>
                    </div>
                    <div class="flex items-center">
                        <img
                            class="w-10 h-10 rounded-full ml-[100px]"
                            src="/images/placeholder.png"
                            alt="Jese"
                        />
                        <P class="ml-2" size="sm">Team Tomas</P>
                    </div>
                </div>
                <div class="mb-5 h-[100px] box-content p-3 border bg-gray-200 rounded-md flex justify-center items-center">
                    <div class="flex items-center">
                        <P class="mr-2" size="sm">Team Pedro</P>
                        <img
                            class="w-10 h-10 rounded-full mr-[100px]"
                            src="/images/placeholder.png"
                            alt="Jese"
                        />
                    </div>
                    <div class="flex flex-col"> 
                        <P class="text-center mb-1" size="xs" weight="semibold">FINISHED</P>
                        <P class="text-center mb-2" size="xs">SAT 13 MAY, 18:15</P>
                        <div class="flex justify-center">
                            <P size="2xl" class="mr-1" color="text-green-500" weight="semibold">2</P>
                            <P size="2xl" class="mr-1" weight="semibold">-</P>
                            <P size="2xl" weight="semibold">0</P>
                        </div>
                    </div>
                    <div class="flex items-center">
                        <img
                            class="w-10 h-10 rounded-full ml-[100px]"
                            src="/images/placeholder.png"
                            alt="Jese"
                        />
                        <P class="ml-2" size="sm">Team Tomas</P>
                    </div>
                </div>
                <div class="h-[100px] box-content p-3 border bg-gray-200 rounded-md flex justify-center items-center">
                    <div class="flex items-center">
                        <P class="mr-2" size="sm">Team Pedro</P>
                        <img
                            class="w-10 h-10 rounded-full mr-[100px]"
                            src="/images/placeholder.png"
                            alt="Jese"
                        />
                    </div>
                    <div class="flex flex-col"> 
                        <P class="text-center mb-1" size="xs" weight="semibold">FINISHED</P>
                        <P class="text-center mb-2" size="xs">SAT 13 MAY, 18:15</P>
                        <div class="flex justify-center">
                            <P size="2xl" class="mr-1" color="text-green-500" weight="semibold">2</P>
                            <P size="2xl" class="mr-1" weight="semibold">-</P>
                            <P size="2xl" weight="semibold">0</P>
                        </div>
                    </div>
                    <div class="flex items-center">
                        <img
                            class="w-10 h-10 rounded-full ml-[100px]"
                            src="/images/placeholder.png"
                            alt="Jese"
                        />
                        <P class="ml-2" size="sm">Team Tomas</P>
                    </div>
                </div>
            </TabItem>
        </Tabs>
    </div>
</div>
