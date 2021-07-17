var addBookmarks = function () {
    window.setTimeout(() => {
        var elements = document.getElementsByClassName("hljs-ln-n");

        Array.from(elements).forEach((el) => {
            var link = document.createElement("a");

            // Do stuff here
            var ln = el.getAttribute("data-line-number");
            var id = `L${ln}`;
            el.setAttribute('id', id);
            el.setAttribute('href', `#${id}`);
            el.addEventListener('click', (event) => {
                console.log("you clicked line " + ln);
                document.location.hash = id;
            });
        });
    });
};

if (document.readyState === 'interactive' || document.readyState === 'complete') {
    addBookmarks();
}
else {
    window.addEventListener('DOMContentLoaded', function () {
        addBookmarks();
    });
}
