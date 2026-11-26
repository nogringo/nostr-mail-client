function routeFromMessageData(data) {
  const nevent = data && data.nevent;
  return nevent ? `/inbox/email/${nevent}` : "/inbox";
}

self.addEventListener("notificationclick", (event) => {
  event.notification.close();

  const notificationData = event.notification.data || {};
  const messageData =
    (notificationData.FCM_MSG && notificationData.FCM_MSG.data) ||
    notificationData.data ||
    notificationData;
  const route = routeFromMessageData(messageData);
  const targetUrl = new URL(route, self.location.origin).href;

  event.waitUntil(
    clients
      .matchAll({ type: "window", includeUncontrolled: true })
      .then((windowClients) => {
        for (const client of windowClients) {
          if (client.url.startsWith(self.location.origin)) {
            if ("navigate" in client) {
              return client.navigate(targetUrl).then((navigatedClient) => {
                return navigatedClient ? navigatedClient.focus() : client.focus();
              });
            }
            return client.focus();
          }
        }
        return clients.openWindow(targetUrl);
      }),
  );
});

importScripts("https://www.gstatic.com/firebasejs/12.15.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/12.15.0/firebase-messaging-compat.js");

firebase.initializeApp(
  Object.fromEntries(new URLSearchParams(self.location.search)),
);

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  if (message.notification) return;

  const data = message.data || {};
  const title = data.title || "Nmail";
  const body = data.body || "New email";

  self.registration.showNotification(title, {
    body,
    icon: "/icons/Icon-192.png",
    badge: "/icons/badge-96.png",
    data,
  });
});
