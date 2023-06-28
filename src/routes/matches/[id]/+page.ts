import { PUBLIC_API_URL } from "$env/static/public";
import type { PageLoad } from './$types';

export const load: PageLoad = async({ fetch, params }) => {
    interface Game {
        status: number;
        team_one_score: number;
        team_two_score: number;
        order: number;
        map: string;
    }

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
            if (data.match.games) {
                data.match.games.sort((a: Game, b: Game) => a.order - b.order);
            }
            
            return data !== null ? data.match : data;
        })
    return {
        match: match
    };
}