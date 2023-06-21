// See https://kit.svelte.dev/docs/types#app
// for information about these interfaces
declare global {
	namespace App {
		// interface Error {}
		// interface Locals {}
		// interface PageData {}
		// interface Platform {}
		interface UserData {
			loggedIn: boolean,
			name?: string,
			email?: string,
			avatar?: string,
			role?: number,
			steamid?: string,
			id?: number
		}       
	}
	
	declare interface Window {
		bracketsViewer: any;
	}
}

export {UserData};
