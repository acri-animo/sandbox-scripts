<script lang="ts">
	let spawnLocations = [
		{ id: 1, name: 'Downtown', coords: [200, 300, 20] },
		{ id: 2, name: 'Beachside', coords: [400, 500, 10] },
		{ id: 3, name: 'Hillside', coords: [100, 200, 40] }
	];

	/** @type {{ id: number, name: string, coords: number[] } | null} */
	let selectedSpawn: { id: number; name: string; coords: number[] } | null = null;

	function selectSpawn(location: { id: number; name: string; coords: number[] }) {
		selectedSpawn = location;
		console.log('Selected spawn:', location);
	}
</script>

<div
	class="flex h-screen w-screen flex-col items-center justify-center bg-gray-900 text-yellow-300"
	style="font-family: 'VT323', monospace;"
>
	<div class="w-full max-w-md rounded-lg border-4 border-yellow-500 bg-gray-800 p-4">
		<h1 class="mb-6 text-center text-2xl font-bold uppercase tracking-widest">Spawn Locations</h1>
		<div class="flex flex-col space-y-4">
			{#each spawnLocations as location}
				<div
					class={`cursor-pointer rounded-lg border-2 px-4 py-2 text-center transition ${
						selectedSpawn?.id === location.id
							? 'border-yellow-500 bg-yellow-700'
							: 'border-yellow-300 bg-gray-700 hover:bg-gray-600'
					}`}
					role="button"
					tabindex="0"
					on:click={() => selectSpawn(location)}
					on:keydown={(e) => e.key === 'Enter' && selectSpawn(location)}
				>
					<h2 class="text-xl font-semibold uppercase">{location.name}</h2>
				</div>
			{/each}
		</div>
	</div>
</div>

<style>
	@import url('https://fonts.googleapis.com/css2?family=VT323&display=swap');
</style>
