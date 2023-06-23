<script lang="ts">
  import {
    P,
    Heading,
    Table,
    TableBody,
    TableBodyCell,
    TableBodyRow,
    TableHead,
    TableHeadCell,
    Search,
    Button,
    Modal,
    Textarea,
    Fileupload,
    Input,
    Label,
    NumberInput,
    Select,
  } from "flowbite-svelte";
  import { writable } from "svelte/store";
  import { PUBLIC_API_URL } from "$env/static/public";
  import { toast } from "@zerodevx/svelte-toast";
  import { userData } from "@src/stores/user";
  import { goto } from "$app/navigation";

  let value = "";
  let items: Tournament[] = [];

  let stageTypes = [
    {value: 0, name: "Round-Robin"},
    {value: 1, name: "Single-Elimination"},
    {value: 2, name: "Double-Elimination"},
    {value: 3, name: "Round-Robin + Single-Elimination"},
    {value: 4, name: "Round-Robin + Double-Elimination"},
  ]

  let formModal = false;
  let editModal = false;

  let fileuploadprops = {
    id: "tournament_avatar",
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

  let fieldIndex = 0;
  let fieldValues: (string | undefined)[] = [];
  const fieldValuesStore = writable(fieldValues);

  function addTextField() {
    registerFieldValue(fieldIndex);
    fieldIndex++;
  }

  function registerFieldValue(index: number) {
    fieldValues[index] = "";

    fieldValuesStore.set(fieldValues);

    fieldValuesStore.subscribe((values: (string | undefined)[]) => {
      fieldValues = values;
    });
  }

  interface Tournament {
    id: number;
    name: string;
    max_teams: number;
    avatar: string;
    organizer: string;
    information: string;
    createdAt: string;
    status: number;
    stages: number;
    prizes: string[];
  }

  let tournament = {} as Tournament;
  let tournamentEdit = {} as Tournament;

  const handleSubmit = async () => {
    fetch(`${PUBLIC_API_URL}/tournaments`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        tournament: {
          name: tournament.name,
          admin: $userData.id,
          max_teams: tournament.max_teams,
          organizer: tournament.organizer,
          information: tournament.information,
          prizes: fieldValues,
          status: 0,
          stages: tournament.stages,
          currentStage: 0,
          avatar: image_to_upload,
        },
      }),
    })
      .then((response) => {
        if (response.ok) {
          return response;
        }
        throw new Error();
      })
      .then(() => {
        toast.push("Tournament created successfully!", {
          theme: {
            "--toastColor": "mintcream",
            "--toastBackground": "rgb(72,187,120)",
            "--toastBarBackground": "#2F855A",
          },
        });
        formModal = false;
        updateTournaments();
      })
      .catch((data) => {
        alert(data);
      });
  };
  
  const handleSubmitEdit = async (id: number) => {
    fetch(`${PUBLIC_API_URL}/tournaments/${id}`, {
      method: "PUT",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        tournament: {
          id: tournamentEdit.id,
          name: tournamentEdit.name,
          admin: $userData.id,
          max_teams: tournamentEdit.max_teams,
          organizer: tournamentEdit.organizer,
          information: tournamentEdit.information,
          prizes: fieldValues,
          status: 0,
          stages: tournamentEdit.stages,
          avatar: image_to_upload,
        },
      }),
    })
      .then((response) => {
        if (response.ok) {
          return response;
        }
        throw new Error();
      })
      .then(() => {
        toast.push("Tournament edited successfully!", {
          theme: {
            "--toastColor": "mintcream",
            "--toastBackground": "rgb(72,187,120)",
            "--toastBarBackground": "#2F855A",
          },
        });
        editModal = false;
        updateTournaments();
      })
      .catch((data) => {
        alert(data);
      });
  };

  let deleteTournament = (id: number) => {
    fetch(`${PUBLIC_API_URL}/tournaments/${id}`, {
      method: "DELETE",
      credentials: "include",
    }).then((res) => {
      if (res.ok) {
        updateTournaments();
        toast.push("Tournament deleted successfully!", {
          theme: {
            "--toastColor": "mintcream",
            "--toastBackground": "rgb(72,187,120)",
            "--toastBarBackground": "#2F855A",
          },
        });
      } else {
        toast.push("There was an error deleting the tournament", {
          theme: {
            "--toastColor": "red",
            "--toastBackground": "rgb(72,187,120)",
            "--toastBarBackground": "#2F855A",
          },
        });
      }
    });
  };

  const updateTournaments = () => {
    fetch(`${PUBLIC_API_URL}/users/${$userData.id}/tournaments`)
      .then((res) => {
        if (res.ok) {
          return res.json();
        }
        return null;
      })
      .then((data) => {
        items = data["tournaments"];
      });
  };

  $: {
    if (formModal) {
      tournament = {} as Tournament;
      fieldIndex = 0;
      fieldValues = [];
      previewImage = null;
    }
  }

  $: filteredItems = items.filter(
    (item) => item.name.toLowerCase().indexOf(value.toLowerCase()) !== -1
  );

  $: if ($userData.loggedIn) {
    updateTournaments();
  }
</script>

<div class="flex flex-col w-full shadow-md">
  <div class="box-content p-4">
    <Heading
      class="mb-3"
      customSize="text-2xl font-extrabold mb-4 md:text-3xl lg:text-4xl"
      >Tournaments</Heading
    >
    <div>
      <div class="flex justify-between mb-2">
        <div class="w-4/12">
          <Search size="md" bind:value />
        </div>
        <Button size="md" on:click={() => (formModal = true)}
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

      <Table shadow hoverable={true}>
        <TableHead>
          <TableHeadCell>Name</TableHeadCell>
          <TableHeadCell>Organizer</TableHeadCell>
          <TableHeadCell>Max Teams</TableHeadCell>
          <TableHeadCell>Status</TableHeadCell>
          <TableHeadCell>Action</TableHeadCell>
        </TableHead>
        <TableBody tableBodyClass="divide-y">
          {#each filteredItems as item}
            <TableBodyRow
              class="cursor-pointer"
              on:click={() => goto(`/tournaments/${item.id}`)}
            >
              <TableBodyCell>{item.name}</TableBodyCell>
              <TableBodyCell>{item.organizer}</TableBodyCell>
              <TableBodyCell>{item.max_teams}</TableBodyCell>
              <TableBodyCell
                ><P
                  >{item.status === 0
                    ? "Scheduled"
                    : item.status === 1
                    ? "Ongoing"
                    : "Finished"}</P
                ></TableBodyCell
              >
              <!-- svelte-ignore a11y-click-events-have-key-events -->
              <TableBodyCell>
                <!-- svelte-ignore a11y-missing-attribute -->
                <a
                  on:click={(e) => {
                    e.stopPropagation();
                    tournamentEdit = item;
                    fieldValues = tournamentEdit.prizes;
                    fieldIndex = fieldValues.length;
                    editModal = true;
                  }}
                  class="text-orange-400"
                >
                  Edit
                </a>
                <!-- svelte-ignore a11y-click-events-have-key-events -->
                <!-- svelte-ignore a11y-missing-attribute -->
                <a
                  on:click={(e) => {
                    e.stopPropagation();
                    deleteTournament(item.id);
                  }}
                  class="font-medium text-red-600 hover:underline dark:text-red-500"
                >
                  Remove
                </a>
              </TableBodyCell>
            </TableBodyRow>
          {/each}
        </TableBody>
      </Table>
    </div>
    <Modal bind:open={formModal} size="xs" autoclose={false} class="w-full">
      <form on:submit|preventDefault={handleSubmit} id="newTournamentForm">
        <div>
          <div class="flex flex-col items-center">
            <img
              id="avatar-menu"
              class="w-full h-[150px] rounded-sm mb-2"
              src={previewImage !== null
                ? previewImage
                : tournament.avatar ?? "/images/placeholder.png"}
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
          <div class="mb-6 mt-6">
            <Label for="name" class="mb-2">Name</Label>
            <Input
              type="text"
              id="name"
              placeholder="Tournament name"
              required
              bind:value={tournament.name}
            />
          </div>
          <div class="mb-6 mt-6">
            <Label for="name" class="mb-2">Organizer</Label>
            <Input
              type="text"
              id="name"
              placeholder="Tournament organizer"
              required
              bind:value={tournament.organizer}
            />
          </div>
          <div class="mb-6 mt-6">
            <Label>Select the tournament stages
              <Select class="mt-2" required items={stageTypes} bind:value={tournament.stages} />
            </Label>
          </div>
          <div class="mb-6 mt-6">
            <Label for="name" class="mb-2">Prizes</Label>
            {#each Array(fieldIndex) as _, i}
              <div class="form-group flex items-center">
                <label for="text-field-{i}" class="mr-3 ml-3">{i + 1}</label>
                <Input
                  type="text"
                  id="text-field-{i}"
                  class="form-control"
                  bind:value={fieldValues[i]}
                  name="textFields[]"
                />
              </div>
            {/each}
            <div class="w-full flex justify-center">
              <button
                type="button"
                on:click={addTextField}
                class="btn btn-primary mt-2">Add prize</button
              >
            </div>
          </div>
          <div class="mb-6 mt-6">
            <Label for="textarea-id" class="mb-2">Extra information</Label>
            <Textarea
              id="textarea-id"
              placeholder="Extra tournament information"
              rows="4"
              name="info"
              bind:value={tournament.information}
            />
          </div>
          <div class="mb-6">
            <Label for="maxTeams" class="mb-2">Maximum number of teams</Label>
            <NumberInput id="maxTeams" bind:value={tournament.max_teams} />
          </div>
        </div>
      </form>
      <svelte:fragment slot="footer">
        <Button class="w-full" type="submit" form="newTournamentForm"
          >Create new tournament</Button
        >
      </svelte:fragment>
    </Modal>
    <Modal bind:open={editModal} size="xs" autoclose={false} class="w-full">
      <form on:submit|preventDefault={() => handleSubmitEdit(tournamentEdit.id)} id="editTournamentForm">
        <div>
          <div class="flex flex-col items-center">
            <img
              id="avatar-menu"
              class="w-full h-[150px] rounded-sm mb-2"
              src={previewImage !== null
                ? previewImage
                : tournament.avatar ? `${PUBLIC_API_URL.replace("/api", "/images")}/${
                    tournamentEdit.avatar
                  }` : "/images/placeholder.png"}
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
          <div class="mb-6 mt-6">
            <Label for="name" class="mb-2">Name</Label>
            <Input
              type="text"
              id="name"
              placeholder="Tournament name"
              required
              bind:value={tournamentEdit.name}
            />
          </div>
          <div class="mb-6 mt-6">
            <Label for="name" class="mb-2">Organizer</Label>
            <Input
              type="text"
              id="name"
              placeholder="Tournament organizer"
              required
              bind:value={tournamentEdit.organizer}
            />
          </div>
          <div class="mb-6 mt-6">
            <Label for="name" class="mb-2">Prizes</Label>
            {#each Array(fieldIndex) as _, i}
              <div class="form-group flex items-center">
                <label for="text-field-{i}" class="mr-3 ml-3">{i + 1}</label>
                <Input
                  type="text"
                  id="text-field-{i}"
                  class="form-control"
                  bind:value={fieldValues[i]}
                  name="textFields[]"
                />
              </div>
            {/each}
            <div class="w-full flex justify-center">
              <button
                type="button"
                on:click={addTextField}
                class="btn btn-primary mt-2">Add prize</button
              >
            </div>
          </div>
          <div class="mb-6 mt-6">
            <Label for="textarea-id" class="mb-2">Extra information</Label>
            <Textarea
              id="textarea-id"
              placeholder="Extra tournament information"
              rows="4"
              name="info"
              bind:value={tournamentEdit.information}
            />
          </div>
          <div class="mb-6">
            <Label for="maxTeams" class="mb-2">Maximum number of teams</Label>
            <NumberInput id="maxTeams" bind:value={tournamentEdit.max_teams} />
          </div>
        </div>
      </form>
      <svelte:fragment slot="footer">
        <Button
          color="green"
          class="w-full"
          type="submit"
          form="editTournamentForm">Edit tournament</Button
        >
      </svelte:fragment>
    </Modal>
  </div>
</div>
