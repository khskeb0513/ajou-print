-- CreateTable
CREATE TABLE "PrintQueue" (
    "queueId" TEXT NOT NULL PRIMARY KEY,
    "jobName" TEXT NOT NULL,
    "nickname" TEXT NOT NULL,
    "length" INTEGER NOT NULL,
    "jobStatus" TEXT NOT NULL DEFAULT 'INITIAL_JOB_PASSING',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
