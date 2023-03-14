/*
  Warnings:

  - Added the required column `contentType` to the `PrintQueue` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_PrintQueue" (
    "queueId" TEXT NOT NULL PRIMARY KEY,
    "jobName" TEXT NOT NULL,
    "nickname" TEXT NOT NULL,
    "length" INTEGER NOT NULL,
    "jobStatus" TEXT NOT NULL DEFAULT 'INITIAL_JOB_PASSING',
    "contentType" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_PrintQueue" ("createdAt", "jobName", "jobStatus", "length", "nickname", "queueId", "updatedAt") SELECT "createdAt", "jobName", "jobStatus", "length", "nickname", "queueId", "updatedAt" FROM "PrintQueue";
DROP TABLE "PrintQueue";
ALTER TABLE "new_PrintQueue" RENAME TO "PrintQueue";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
