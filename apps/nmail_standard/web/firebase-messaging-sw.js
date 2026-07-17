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

firebase.initializeApp({
  apiKey: "AIzaSyBYqjME1fTEo-D0UDaubnB3HtGWh2Q8BLM",
  authDomain: "nostr-mail.firebaseapp.com",
  projectId: "nostr-mail",
  storageBucket: "nostr-mail.firebasestorage.app",
  messagingSenderId: "309138530398",
  appId: "1:309138530398:web:3b174d508664a3ce8694cf",
  measurementId: "G-4SLVZC5G7S",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  if (message.notification) return;

  const data = message.data || {};
  const title = data.title || "Nmail";
  const body = data.body || "New email";

  self.registration.showNotification(title, {
    body,
    icon: "/icons/Icon-192.png",
    badge: "/icons/Icon-192.png",
    data,
  });
});
