const net = require('net');

const server = net.createServer((socket) => {
  console.log('Client connecté.');

  socket.on('data', (data) => {
    console.log('Message reçu du client:', data.toString());
    socket.write('Message bien reçu !');
  });

  socket.on('end', () => {
    console.log('Client déconnecté.');
  });

  socket.on('error', (err) => {
    console.error('Erreur de connexion:', err.message);
  });
});

const PORT = 3000;
server.listen(PORT, () => {
  console.log(`Serveur en écoute sur le port ${PORT}`);
});
