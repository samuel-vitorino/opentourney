import { PUBLIC_API_URL } from "$env/static/public";
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async({ fetch, params }) => {
    const user = await fetch(`${PUBLIC_API_URL}/users/${params.id}`)
        .then((res) => {
            if (res.ok) {
                return res.json();
            }
            return null
        })
        .then((data) => {
            return data !== null ? data.user : data;
        })

    return {
        user: user
    };
}
