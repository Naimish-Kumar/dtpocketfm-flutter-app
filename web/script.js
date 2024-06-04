
async function jsOpenTab(url, target) {
    let promise = new Promise(function (resolve, reject) {
        var win = window.open(url, target);
        console.log("window", win);
        // var timer = setInterval(function () {
        //     if (win.closed) {
        //         clearInterval(timer);
        //         alert("'Popup Window' closed!");
        //         resolve('Paid');
        //     }
        // }, 500);
        console.log("window", win);
    });
    let result = await promise;
    console.log("result", result);
    return result;
}