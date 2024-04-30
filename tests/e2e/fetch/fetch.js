async function main(event) {
    let resolve, reject;
    
    try {
        let responsePromise = new Promise(async (res, rej) => {
            resolve = res;
            reject = rej;
        });
        event.respondWith(responsePromise);
        
        let p = fetch("https://jsonplaceholder.typicode.com/users");
        let response = await p;
        // Not logging the response results in an error
        console.log("RESPONSE", response.status);

        let text = await response.json();
        console.log("Successfully received response json body");

        resolve(new Response(JSON.stringify(text), { headers: response.headers }));
    } catch (e) {
        console.log(`Error: ${e}. Stack: ${e.stack}`);
    }
}

addEventListener('fetch', main);
