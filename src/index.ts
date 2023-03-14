import { printer } from './servers/create-ipp-server.js';
import { schedule } from 'node-cron';
import {
  findManyPrintQueue,
  updatePrintQueue,
} from './print-queue/print-queue.repository.js';
import { JobStatus } from './print-queue/job-status.enum.js';
import { ContentType } from './servers/content-type.enum.js';
import { handlePdfService } from './convert-to-raster/handle-pdf.service.js';
import { handlePsService } from './convert-to-raster/handle-ps.service.js';
import { sendRemote } from './send-remote/send-remote.js';
import { PrintQueue } from '@prisma/client';
import { tmpPath } from './config/path.service.js';
import { rimrafSync } from 'rimraf';

const singlePrintProcess = async (printQueue: PrintQueue) => {
  switch (printQueue.jobStatus) {
    case JobStatus.INITIAL_JOB_PARSING || JobStatus.CONVERT_PRINT_FILE: {
      if (printQueue.contentType === ContentType.PDF) {
        await handlePdfService(printQueue);
      } else if (printQueue.contentType === ContentType.POSTSCRIPT) {
        await handlePsService(printQueue);
      }
      break;
    }
    case JobStatus.SEND_REMOTE: {
      await sendRemote(printQueue);
      break;
    }
  }
};

const bootstrap = async () => {
  const remainPrintQueues = await findManyPrintQueue({
    where: {
      jobStatus: {
        in: [
          JobStatus.INITIAL_JOB_PARSING,
          JobStatus.CONVERT_PRINT_FILE,
          JobStatus.SEND_REMOTE,
        ],
      },
    },
  });
  for (const printQueue of remainPrintQueues) {
    await singlePrintProcess(printQueue);
  }
  await schedule('*/2 * * * *', async () => {
    const printQueues = await findManyPrintQueue({
      where: {
        updatedAt: {
          lte: new Date(Date.now() - 1000 * 60 * 5),
        },
        jobStatus: {
          in: [
            JobStatus.INITIAL_JOB_PARSING,
            JobStatus.CONVERT_PRINT_FILE,
            JobStatus.SEND_REMOTE,
          ],
        },
      },
    });
    for (const printQueue of printQueues) {
      if (Date.now() - printQueue.updatedAt.valueOf() > 1000 * 60 * 15) {
        if ((process.env.DEBUG || '').toUpperCase() === 'TRUE') {
          rimrafSync(tmpPath([printQueue.queueId]));
        }
        await updatePrintQueue(printQueue.queueId, {
          jobStatus: JobStatus.DROP_BY_TIMEOUT,
        });
        continue;
      }
      await singlePrintProcess(printQueue);
    }
  });
  await console.log('bootstrap finished');
};

printer.on('server-opened', (err) => {
  if (!err) {
    void bootstrap();
  } else {
    console.error(err);
  }
});
