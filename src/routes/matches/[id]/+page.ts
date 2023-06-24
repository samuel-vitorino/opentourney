import { PUBLIC_API_URL } from "$env/static/public";
import type { PageLoad } from './$types';

export const load: PageLoad = async({ fetch, params }) => {
    const match = await fetch(`${PUBLIC_API_URL}/matches/${params.id}`, {
        credentials: 'include'
    })
        .then((res) => {
            if (res.ok) {
                return res.json();
            }
            return null
        })
        .then((data) => {
            return data !== null ? data.match : data;
        })
    return {
        match: match
    };
}