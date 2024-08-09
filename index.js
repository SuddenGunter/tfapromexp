import express from 'express';
import Co2Monitor from 'co2-monitor';
import client, { collectDefaultMetrics, register } from 'prom-client';

collectDefaultMetrics();

const app = express();

app.get('/metrics', async (_req, res) => {
  try {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (err) {
    res.status(500).end(err);
  }
});

let co2Monitor = new Co2Monitor();


co2Monitor.on('connected', () => {
  console.log('Co2Monitor connected');
});

co2Monitor.on('disconnected', () => {
  console.log('Co2Monitor disconnected');
});

co2Monitor.on('error', (error) => {
  console.error(error);

  co2Monitor.disconnect(() => {
    process.exit(1);
  });
})

const co2gauge = new client.Gauge({ name: 'tfa_co2', help: 'ppm' });

co2Monitor.on('co2', (co2) => {
  co2gauge.set(co2.value);
})

const tempgauge = new client.Gauge({ name: 'tfa_temp', help: 'C' });

co2Monitor.on('temperature', (temperature) => {
  tempgauge.set(temperature.value);
})


co2Monitor.connect((error) => {
  if (error) {
    console.error(error);
    process.exit(1);
  }

  co2Monitor.startTransfer((error) => {
    if (error) {
      console.error(error);
    }
  });
});


app.listen(9999, '0.0.0.0');