import { Foo } from './smoke-dependency.js';
import "./nested-smoke-dependency.js";

async function main(event) {
    try {
        let p = fetch("https://jsonplaceholder.typicode.com/users");
        let response = await p;
        console.log("RESPONSE", response);
        for (let [key, value] of response.headers.entries()) {
            console.log([key, value]);
        }
        console.log("RESPONSE", response);
        // This throws an error.
        let text = await response.json();
        console.log("Successfully retrieved response body\n", JSON.stringify(text));
        // resolve(new Response(text));
        // setTimeout(() => console.log(1), 1);
        // setTimeout(() => console.log(10), 10);
    } catch (e) {
        console.log(`Error: ${e}. Stack: ${e.stack}`);
    }
}

addEventListener('fetch', main);
