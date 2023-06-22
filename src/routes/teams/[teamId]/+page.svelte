<script lang="ts">

  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { writable } from 'svelte/store';

  const { subscribe, set } = writable({});
  const teamId = $page.params.teamId;

  onMount(async () => {
    const res = await fetch(`/api/teams/${teamId}`);
    const data = await res.json();
    set(data);
  });

</script>

<div class="flex flex-col w-full shadow-md">
  <div class="box-content p-4">
    <p>{teamId}</p>
  </div>
</div>
