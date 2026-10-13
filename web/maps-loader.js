// Load Maps before Flutter, while allowing the UI to run when Maps is unconfigured.
(function () {
  function startFlutter() {
    if (document.getElementById('flutter-app-loader')) return;
    const script = document.createElement('script');
    script.id = 'flutter-app-loader';
    script.src = 'flutter_bootstrap.js';
    script.async = true;
    document.body.appendChild(script);
  }
  if (!window.higoMapsApiKey) { startFlutter(); return; }
  const maps = document.createElement('script');
  maps.src = 'https://maps.googleapis.com/maps/api/js?key=' + encodeURIComponent(window.higoMapsApiKey);
  maps.onload = startFlutter;
  maps.onerror = startFlutter;
  const timeout = setTimeout(startFlutter, 15000);
  maps.addEventListener('load', () => clearTimeout(timeout));
  document.head.appendChild(maps);
})();
