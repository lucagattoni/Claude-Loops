// Open every external link in a new tab and mark it so CSS can show an icon.
// Uses Material's `document$` observable so it re-runs on instant navigation,
// not just the first page load.
document$.subscribe(function () {
  var host = location.hostname;
  document
    .querySelectorAll('.md-content a[href^="http"]')
    .forEach(function (a) {
      if (a.hostname && a.hostname !== host) {
        a.target = "_blank";
        a.rel = "noopener noreferrer";
        a.classList.add("external-link");
      }
    });
});
