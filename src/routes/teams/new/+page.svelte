<script lang="ts">
  import { PUBLIC_API_URL } from "$env/static/public";
  import {
    P,
    Button,
    Fileupload,
    Input,
    Label,
    Avatar,
    Alert,
  } from "flowbite-svelte";
  import { ArrowRightIcon } from "svelte-feather-icons";
  import { userData } from "@src/stores/user";

  let fileuploadprops = {
    id: "user_avatar",
  };

  let files_to_upload: FileList;
  let previewImage: string | null = null;

  let owner = 0;
  let name = "";
  let avatar: string | null = null;
  let showingAlert = false;
  let isSuccess = false;

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

  async function handleSubmit(event) {
    event.preventDefault();

    owner = $userData.id as number;

    const data = { owner, name, avatar };

    console.log(data);

    try {
      const response = await fetch(`${PUBLIC_API_URL}/teams`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(data),
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

      // const result = await response.json();
      // console.log(result);
    } catch (error) {
      showingAlert = true;
      isSuccess = false;
      setTimeout(() => {
        showingAlert = false;
      }, 4000);
    }
  }
</script>

<div class="flex flex-col w-full shadow-md">
  <div class="box-content p-4">
    <P size="4xl" weight="bold">Create new Team</P>

    <div>
      <form class="flex flex-col" on:submit={handleSubmit}>
        <div class="flex justify-between">
          <div class="grow mr-4">
            <div class="mb-6">
              <Label for="first_name" class="mb-2">Name</Label>
              <Input
                type="text"
                id="name"
                placeholder="Team Name"
                required
                bind:value={name}
              />
            </div>
            <div class="flex flex-col items-center">
              <Avatar
                id="avatar-menu"
                class="w-[150px] h-[150px] rounded-sm mb-2"
                src={previewImage !== null ? previewImage : avatar ?? ""}
              />
              <Fileupload
                bind:files={files_to_upload}
                accept="image/jpeg, image/png"
                on:change={handleAvatarChange}
                {...fileuploadprops}
              />
            </div>
          </div>
          <Button class="self-end" type="submit">Create</Button>
        </div>
      </form>
      {#if showingAlert}
        {#if isSuccess}
          <Alert color="green" class="alert {showingAlert ? 'show' : 'hidden'}">
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
    </div>
  </div>
</div>
