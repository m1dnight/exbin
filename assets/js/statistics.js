var purple = 'rgb(255,0,255)';
var purpleTransparent = 'rgba(255, 0, 255, 0.2)';
var gray = 'rgb(10, 10, 10)';
var grayTransparent = 'rgba(10, 10, 10, 0.2)';


////////////////////////////////////////////////////////////////////////////////
// Private/Public chart.

if (document.getElementById('publicPrivateRatio')) {
    var totalPrivate = JSON.parse(document.getElementById("total-private").dataset.values);
    var totalPublic = JSON.parse(document.getElementById("total-public").dataset.values);


    var ctx = document.getElementById('publicPrivateRatio').getContext('2d');

    var myChart = new Chart(ctx, {
        type: 'doughnut',
        options: {
            responsive: true,
            maintainAspectRatio: false
        },
        data:
        {
            datasets: [{
                data: [totalPrivate, totalPublic],
                backgroundColor: [
                    purpleTransparent,
                    grayTransparent
                ],
                borderColor: [
                    purpleTransparent,
                    grayTransparent
                ],
            }],

            labels: ['Private', 'Public']
        }
    });
}

////////////////////////////////////////////////////////////////////////////////
// Per month chart.

if (document.getElementById('monthlySnippets')) {
    // Get the data from the DOM.
    var labels = JSON.parse(document.getElementById("monthly-private").dataset.labels);
    var valuesPrivate = JSON.parse(document.getElementById("monthly-private").dataset.values);
    var valuesPublic = JSON.parse(document.getElementById("monthly-public").dataset.values);

    var ctx = document.getElementById('monthlySnippets').getContext('2d');
    var myChart = new Chart(ctx, {
        type: 'bar',
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: {
                    stacked: true,
                    grid: {
                        display: false
                    }
                },
                y: {
                    stacked: true,
                    grid: {
                        display: false
                    },
                    beginAtZero: true,
                    ticks: {
                        maxTicksLimit: 4,
                        precision: 0
                    }
                }
            }
        },
        data: {
            labels: labels,
            datasets: [{
                label: '# Private',
                data: valuesPrivate,
                // Smooth line.
                cubicInterpolationMode: 'monotone',
                tension: 0.5,
                // Color of the line itself.
                borderColor: purpleTransparent,
                // Color of the dots and the area underneath.
                backgroundColor: purpleTransparent,
                // Fill the area underneath.
                fill: true
            },
            {
                label: '# Public',
                data: valuesPublic,
                // Smooth line.
                cubicInterpolationMode: 'monotone',
                tension: 0.5,
                // Color of the line itself.
                borderColor: grayTransparent,
                // Color of the dots and the area underneath.
                backgroundColor: grayTransparent,
                // Fill the area underneath.
                fill: true
            }]
        }
    });
}