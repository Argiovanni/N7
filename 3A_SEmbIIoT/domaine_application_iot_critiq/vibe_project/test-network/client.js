const net = require('net');

const client = new net.Socket();
const PORT = 3000;
const HOST = '127.0.0.1';

client.connect(PORT, HOST, () => {
  console.log('Connecté au serveur.');
  client.write('Bonjour serveur !');
});

client.on('data', (data) => {
  console.log('Réponse du serveur:', data.toString());
  client.destroy(); // Ferme la connexion après avoir reçu la réponse
});

client.on('close', () => {
  console.log('Connexion fermée.');
});

client.on('error', (err) => {
  console.error('Erreur de connexion:', err.message);
});
