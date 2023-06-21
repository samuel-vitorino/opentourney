<script lang="ts">
  import { Heading, Table, TableBody, TableBodyCell, TableBodyRow, TableHead, TableHeadCell, Search, Button, Modal, Avatar, Fileupload, Input, Label, NumberInput } from 'flowbite-svelte';

  let value = '';
  let items = [
    { id: 1, maker: 'Toyota', type: 'ABC', make: 2017 },
    { id: 2, maker: 'Ford', type: 'CDE', make: 2018 },
    { id: 3, maker: 'Volvo', type: 'FGH', make: 2019 },
    { id: 4, maker: 'Saab', type: 'IJK', make: 2020 }
  ];

  let formModal = false;

  let fileuploadprops = {
      id: "tournament_avatar",
  };

  let files_to_upload: FileList;
  let previewImage: string | null = null;

  const handleAvatarChange = (e: Event) => {
      const files = (<HTMLInputElement>e.target).files

      if (files === null || files.length <= 0) {
          return
      }
          
      const reader = new FileReader();
      reader.readAsDataURL(files[0]);
      reader.onload = function () {
          previewImage = <string>reader.result;
      }
  }
  
  interface Tournament {
      name: string,
      maxTeams: number,
      avatar: string
  }

  let tournament = {} as Tournament;

  $: filteredItems = items.filter(
    (item) => item.maker.toLowerCase().indexOf(value.toLowerCase()) !== -1
  ); 
</script>

<div class="flex flex-col w-full shadow-md">
  <div class="box-content p-4">
    <Heading class="mb-3" customSize="text-2xl font-extrabold  md:text-3xl lg:text-4xl">Tournaments</Heading>
    <div>
      <div class="flex mb-2">
        <Search size="md" class="w-3/12" bind:value  />
        <Button size="md" on:click={() => formModal = true}>Create <svg aria-hidden="true" class="ml-2 -mr-1 w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clip-rule="evenodd"></path></svg></Button>
      </div>
      
      <Table shadow hoverable={true}>
        <TableHead>
          <TableHeadCell>ID</TableHeadCell>
          <TableHeadCell>Maker</TableHeadCell>
          <TableHeadCell>Type</TableHeadCell>
          <TableHeadCell>Make</TableHeadCell>
          <TableHeadCell>Action</TableHeadCell>
        </TableHead>
        <TableBody tableBodyClass="divide-y">
          {#each filteredItems as item}
            <TableBodyRow>
              <TableBodyCell>{item.id}</TableBodyCell>
              <TableBodyCell>{item.maker}</TableBodyCell>
              <TableBodyCell>{item.type}</TableBodyCell>
              <TableBodyCell>{item.make}</TableBodyCell>
              <TableBodyCell>
                <a href="/tables" class="font-medium text-orange-400 hover:underline dark:text-primary-500">
                  Edit
                </a>
                <a href="/tables" class="font-medium text-red-600 hover:underline dark:text-red-500">
                  Remove
                </a>
              </TableBodyCell>
            </TableBodyRow>
          {/each}
        </TableBody>
      </Table>
    </div>
    <Modal bind:open={formModal} size="xs" autoclose={false} class="w-full">
      <form>
          <div>
              <div class="flex flex-col items-center">
                  <img
                      id="avatar-menu"
                      class="w-[150px] h-[150px] rounded-sm mb-2"
                      src={previewImage !== null ? previewImage : tournament.avatar ?? "/images/placeholder.png"}
                      alt="Tournament Avatar"
                  />
                  <Fileupload class="mt-6" bind:files={files_to_upload} accept="image/jpeg, image/png" on:change={handleAvatarChange} {...fileuploadprops}/>
              </div>
              <div class="mb-6 mt-6">
                  <Label for="name" class="mb-2"
                      >Name</Label
                  >
                  <Input
                      type="text"
                      id="name"
                      placeholder={tournament.name}
                      required
                      value={tournament.name}
                  />

              </div>
              <div class="mb-6">
                  <Label for="maxTeams" class="mb-2"
                      >Maximum number of teams</Label
                  >
                  <NumberInput
                      id="maxTeams"
                      value={tournament.maxTeams}
                  />
              </div>
          </div>
          <Button class="w-full" type="submit">Create new tournament</Button>
      </form>
    </Modal>
  </div>
</div>